//
//  GMSModels.swift
//  Ultimate Roader
//
//  Created by Harshit on 2/28/26.
//  Copyright © 2026 RJT. All rights reserved.
//

import Foundation
import MapKit

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

class GMSMutablePath {
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

struct GMSPolyline {
    weak var path: GMSMutablePath?
    var strokeColor: UIColor = Theme.pathColor
    var strokeWidth: CGFloat = Theme.pathWidth
    var zIndex: Int32 = 0

    private var overlay: MKPolyline?

    weak var map: GMSMapView? {
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

final class GMSMarkerAnnotation: MKPointAnnotation {
    let marker: GMSMarker
    init(marker: GMSMarker) {
        self.marker = marker
        super.init()
        self.coordinate = marker.position
        self.title = marker.title
        self.subtitle = marker.snippet
    }
}

class GMSMarker {
    var position: CLLocationCoordinate2D
    var title: String? { annotationType.title }
    var snippet: String?
    var icon: UIImage?
    var iconView: UIView?
    var isDraggable: Bool = false
    var groundAnchor: CGPoint = .zero
    var annotationType: MapAnnotation
    var spotTitle: String?

    private weak var annotation: GMSMarkerAnnotation?

    init(annotationType: MapAnnotation, position: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)) {
        self.annotationType = annotationType
        self.position = position
    }

    weak var map: GMSMapView? {
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
struct GMSGroundOverlay {
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

    weak var map: GMSMapView?
}
