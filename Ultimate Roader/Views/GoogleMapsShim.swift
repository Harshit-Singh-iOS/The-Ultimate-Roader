//
//  GoogleMapsShim.swift
//  Ultimate Roader
//
//  Minimal GoogleMaps compatibility layer using MapKit.
//

import MapKit
import UIKit

// MARK: - Map View + Delegate

protocol GMSMapViewDelegate: MKMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool)
}

extension GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool { false }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {}
}

final class GMSMapView: MKMapView, MKMapViewDelegate {
    weak var gmsDelegate: GMSMapViewDelegate?
    private(set) var minZoom: Float = 0
    private(set) var maxZoom: Float = 20

    override weak var delegate: MKMapViewDelegate? {
        get { gmsDelegate }
        set {
            gmsDelegate = newValue as? GMSMapViewDelegate
            super.delegate = self
        }
    }

    var gmsCamera: GMSCameraPosition {
        get {
            GMSCameraPosition(target: centerCoordinate, zoom: 14, bearing: 0, viewingAngle: 0)
        }
        set {
            let region = MKCoordinateRegion(center: newValue.target, span: span(for: newValue.zoom))
            setRegion(region, animated: false)
        }
    }

    func animate(to cameraPosition: GMSCameraPosition) {
        let region = MKCoordinateRegion(center: cameraPosition.target, span: span(for: cameraPosition.zoom))
        setRegion(region, animated: true)
    }

    func animate(to update: GMSCameraUpdate) {
        setVisibleMapRect(update.bounds.mapRect, edgePadding: update.edgeInsets, animated: true)
    }

    func moveCamera(_ update: GMSCameraUpdate) {
        setVisibleMapRect(update.bounds.mapRect, edgePadding: update.edgeInsets, animated: false)
    }

    func setMinZoom(_ minZoom: Float, maxZoom: Float) {
        self.minZoom = minZoom
        self.maxZoom = maxZoom
    }

    // MARK: MKMapViewDelegate forwarding

    func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
        gmsDelegate?.mapView(self, willMove: true)
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? GMSMarkerAnnotation {
            _ = gmsDelegate?.mapView(self, didTap: annotation.marker)
        }
    }

    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        if let renderer = gmsDelegate?.mapView?(mapView, rendererFor: overlay) {
            return renderer
        }
        if let polyline = overlay as? MKPolyline {
            let renderer = MKPolylineRenderer(polyline: polyline)
            renderer.strokeColor = .systemBlue
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }

    private func span(for zoom: Float) -> MKCoordinateSpan {
        let delta = max(0.005, 360.0 / pow(2.0, Double(zoom)))
        return MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
    }
}

extension MKMapType {
    static var none: MKMapType { .standard }
}

// MARK: - Camera + Bounds

struct GMSCameraPosition {
    let target: CLLocationCoordinate2D
    let zoom: Float
    let bearing: CLLocationDirection
    let viewingAngle: Double

    static func camera(withTarget target: CLLocationCoordinate2D, zoom: Float, bearing: CLLocationDirection, viewingAngle: Double) -> GMSCameraPosition {
        GMSCameraPosition(target: target, zoom: zoom, bearing: bearing, viewingAngle: viewingAngle)
    }
}

struct GMSCameraUpdate {
    let bounds: GMSCoordinateBounds
    let edgeInsets: UIEdgeInsets

    static func fit(_ bounds: GMSCoordinateBounds, withPadding padding: Double) -> GMSCameraUpdate {
        let inset = CGFloat(padding)
        return GMSCameraUpdate(bounds: bounds, edgeInsets: UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset))
    }
}

struct GMSCoordinateBounds {
    let mapRect: MKMapRect

    init(path: GMSMutablePath) {
        self.mapRect = path.mapRect
    }

    init(coordinate: CLLocationCoordinate2D, coordinate other: CLLocationCoordinate2D) {
        let p1 = MKMapPoint(coordinate)
        let p2 = MKMapPoint(other)
        let minX = min(p1.x, p2.x)
        let minY = min(p1.y, p2.y)
        let maxX = max(p1.x, p2.x)
        let maxY = max(p1.y, p2.y)
        self.mapRect = MKMapRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

// MARK: - Path + Polyline

enum GMSLengthKind {
    case geodesic
}

final class GMSMutablePath {
    private(set) var coordinates: [CLLocationCoordinate2D] = []

    func add(_ coord: CLLocationCoordinate2D) {
        coordinates.append(coord)
    }

    func removeAllCoordinates() {
        coordinates.removeAll()
    }

    func length(of kind: GMSLengthKind) -> CLLocationDistance {
        guard coordinates.count > 1 else { return 0 }
        var total: CLLocationDistance = 0
        for i in 1..<coordinates.count {
            let a = CLLocation(latitude: coordinates[i - 1].latitude, longitude: coordinates[i - 1].longitude)
            let b = CLLocation(latitude: coordinates[i].latitude, longitude: coordinates[i].longitude)
            total += a.distance(from: b)
        }
        return total
    }

    var mapRect: MKMapRect {
        let points = coordinates.map(MKMapPoint.init)
        guard let first = points.first else { return MKMapRect.null }
        var minX = first.x, minY = first.y, maxX = first.x, maxY = first.y
        for p in points.dropFirst() {
            minX = min(minX, p.x)
            minY = min(minY, p.y)
            maxX = max(maxX, p.x)
            maxY = max(maxY, p.y)
        }
        return MKMapRect(x: minX, y: minY, width: maxX - minX, height: maxY - minY)
    }
}

final class GMSPolyline {
    var path: GMSMutablePath?
    var strokeColor: UIColor = .systemBlue
    var strokeWidth: CGFloat = Theme.pathWidth
    var zIndex: Int32 = 0

    private var overlay: MKPolyline?

    var map: GMSMapView? {
        didSet {
            if let old = oldValue, let overlay = overlay {
                old.removeOverlay(overlay)
            }
            guard let map = map, let path = path else { return }
            let polyline = MKPolyline(coordinates: path.coordinates, count: path.coordinates.count)
            overlay = polyline
            map.addOverlay(polyline)
        }
    }
}

// MARK: - Marker

private final class GMSMarkerAnnotation: MKPointAnnotation {
    let marker: GMSMarker
    init(marker: GMSMarker) {
        self.marker = marker
        super.init()
        self.coordinate = marker.position
        self.title = marker.title
        self.subtitle = marker.snippet
    }
}

final class GMSMarker {
    var position: CLLocationCoordinate2D
    var title: String?
    var snippet: String?
    var icon: UIImage?
    var iconView: UIView?
    var isDraggable: Bool = false
    var groundAnchor: CGPoint = .zero

    private var annotation: GMSMarkerAnnotation?

    init() {
        self.position = CLLocationCoordinate2D(latitude: 0, longitude: 0)
    }

    init(position: CLLocationCoordinate2D) {
        self.position = position
    }

    var map: GMSMapView? {
        didSet {
            if let old = oldValue, let annotation = annotation {
                old.removeAnnotation(annotation)
            }
            guard let map = map else { return }
            let annotation = GMSMarkerAnnotation(marker: self)
            annotation.coordinate = position
            annotation.title = title
            annotation.subtitle = snippet
            self.annotation = annotation
            map.addAnnotation(annotation)
        }
    }
}

// MARK: - Ground Overlay (no-op)

final class GMSGroundOverlay {
    var bounds: GMSCoordinateBounds
    var icon: UIImage?
    var bearing: CLLocationDirection = 0

    init() {
        self.bounds = GMSCoordinateBounds(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0))
    }

    init(bounds: GMSCoordinateBounds, icon: UIImage?) {
        self.bounds = bounds
        self.icon = icon
    }

    var map: GMSMapView?
}
