//
//  GoogleMapsShim.swift
//  Ultimate Roader
//
//  Minimal GoogleMaps compatibility layer using MapKit.
//

import MapKit
import UIKit

// MARK: - Map View + Delegate
enum MapAnnotation: String {
    case start, finish, current, spot
    
    init?(rawValue: String) {
        switch rawValue {
        case "Start": self = .start
        case "Finish": self = .finish
        case "Current": self = .current
        case "Spot": self = .spot
        default: return nil
        }
    }
    
    var title: String {
        switch self {
        case .start: return "Start"
        case .finish: return "Finish"
        case .current: return "Current"
        case .spot: return "Spot"
        }
    }
    
    var image: UIImage? {
        switch self {
        case .start: return UIImage(named: "starting_point")
        case .finish: return UIImage(named: "ending_point")
        case .current: return nil
        case .spot: return UIImage(named: "edit_camera")
        }
    }
}

protocol GMSMapViewDelegate: MKMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool)
}

extension GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool { false }
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {}
}

final class GMSMapView: MKMapView, MKMapViewDelegate {
    private weak var gmsDelegate: GMSMapViewDelegate?
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
            renderer.strokeColor = Theme.pathColor
            renderer.lineWidth = 4
            return renderer
        }
        return MKOverlayRenderer(overlay: overlay)
    }
    
    private func span(for zoom: Float) -> MKCoordinateSpan {
        let delta = max(0.005, 360.0 / pow(2.0, Double(zoom)))
        return MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
    }
    
    func mapView(_ mapView: MKMapView, viewFor annotation: any MKAnnotation) -> MKAnnotationView? {
        if let title = annotation.title,
           let annotation = MapAnnotation(rawValue: title ?? ""),
           let image = annotation.image {
            let new = MKAnnotationView()
            new.image = image
            return new
        }
        
        return nil
    }
}

extension MKMapType {
    static var none: MKMapType { .standard }
}
