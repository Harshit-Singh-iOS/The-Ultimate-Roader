//
//  GoogleMapViewController.swift
//  Firebase Roader Demo
//
//  Created by Harshit Singh on 10/20/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import CoreLocation


class StartDrivingViewController: BaseViewController, MarkSpotProtocol {
    
    let vm = StartDrivingViewModel()
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapModeButton: UIButton!
    
    private var locationManager = CLLocationManager()
    private var iskeepFocus: Bool = true
    private var polyline = GMSPolyline()
    private var gmsPath = GMSMutablePath()
    private var animated_marker = GMSMarker()
    private var uuid: String?

    private var distance: Double = 0.0
    private var timer = Timer()

    private var color: UIColor?
    private var spotIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "You are driving."
        setUpLocationServices()
        SwiftMessageBar.setSharedConfig(Theme.barConfig)
        gmsPath.removeAllCoordinates()
        vm.startTrip()
        
        animated_marker.icon = UIImage.animatedImage(with: Constants.animationImage, duration: 3.0)
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { [weak self] _ in
            self?.update_label()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        polyline.map = mapView
    }
    
    deinit {
        stopTrackingPath()
        print("************* deinit drive controller")
    }
    
    func setUpLocationServices() {
        changemapModeAction(mapModeButton)
        locationManager.delegate = self
        mapView.delegate = self
        locationManager.requestAlwaysAuthorization()
        locationManager.requestWhenInUseAuthorization()
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        animated_marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        animated_marker.map = mapView
        locationManager.startUpdatingLocation()
    }
    
    @IBAction func keep_focus_btn(_ sender: UIButton) {
        iskeepFocus = true
    }
    
    @IBAction func finishTripAction(_ sender: UIButton) {
        
        if vm.time > 59 || vm.length > 0.1 {
            stopTrackingPath()
            setMapBounds()
            createMarker(loc: (vm.path?.track.last)!, name: "ending_point")
            SwiftMessageBar.showMessageWithTitle("Trip Complete!!", message: "Fill information.", type: .success)
            vm.createPathTableInFire {
                DispatchQueue.main.async { [weak self] in
                    let alertController = UIAlertController.init(title: "Complete Drive!", message: "Go to next.", preferredStyle: .alert)
                    let action = UIAlertAction(title: "Ok", style: .default, handler: { (alert) in
                        let storyboard = UIStoryboard(name: "PathNavigation", bundle: nil)
                        if let controller = storyboard.instantiateViewController(withIdentifier: "SaveDriveViewController") as? SaveDriveViewController {
                            controller.path = self?.vm.path
                            self?.navigationController?.pushViewController(controller, animated: true)
                        }
                    })
                    alertController.addAction(action)
                    self?.present(alertController, animated: true, completion: nil)
                }
            }
        } else {
            SwiftMessageBar.showMessageWithTitle("Warning", message: "Drive should be 0.1 km or 1 min", type: .info)
        }
    }
    
    @IBAction func share_cordinates_action(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "PathNavigationMore", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ShareLocViewController") as? ShareLocViewController {
            if let lat = vm.path?.track.last?.coordinate.latitude, let lng = vm.path?.track.last?.coordinate.longitude {
                controller.cord_val = "(\(String(format: "%.04f", lat)), \(String(format: "%.04f", lng)))"
            }
            controller.sheetPresentationController?.detents = [.medium()]
            DispatchQueue.main.async {
                self.present(controller, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func changemapModeAction(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        if sender.isSelected {
            mapView.mapType = .standard
        } else {
            mapView.mapType = .hybrid
        }
    }
    
    @IBAction func markCurrentSpot(_ sender: UIButton) {
        let storyboard = UIStoryboard(name: "PathNavigationMore", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "MarkSpotViewController") as? MarkSpotViewController {
            controller.loc = vm.path?.track.last
            controller.delegate = self
            controller.sheetPresentationController?.detents = [.medium()]
            self.present(controller, animated: true)
        }
    }
    
    private func stopTrackingPath() {
        timer.invalidate()
        locationManager.stopUpdatingLocation()
        
        if let pathID = vm.path?.pathID {
            ManagePathManager.sharedinstance.addEndpath(pathId: pathID)
        }
        
        animated_marker.icon = nil
        animated_marker.map = nil
        polyline.map = nil
        gmsPath.removeAllCoordinates()
    }
    
    func createMarker(loc: CLLocation, name: String) {
        let marker = GMSMarker()
        marker.position = loc.coordinate
        marker.title = name.contains("start") ? "Start" : "Finish"
        marker.map = mapView
        marker.isDraggable = true
        marker.icon = UIImage(named: name)
    }
    
    func addRouteToPath(loc: CLLocation) {
        ManagePathManager.sharedinstance.addCordinateTopath(latidude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        polyline.strokeColor = Theme.path_color
        polyline.strokeWidth = Theme.pathWidth
        polyline.zIndex = 10
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = mapView
        CATransaction.commit()
        
        distance = gmsPath.length(of: .geodesic)
    }
    
    func addSpotMarker(spot: Path.Spot) {
        let marker = GMSMarker(position: (spot.location?.coordinate)!)
        marker.map = mapView
        marker.title = "\(spotIndex)"
        spotIndex += 1
        marker.snippet = spot.spotDescription
        marker.iconView = UIImageView(image: UIImage(named: "edit_camera"))
        vm.path?.spotArray.append(spot)
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: gmsPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        mapView.moveCamera(update)
        mapView.setMinZoom(self.mapView.minZoom, maxZoom: self.mapView.maxZoom)
    }
    
    @objc func update_label() {
        self.vm.time += 1
        
        let hours = self.vm.time / 3600
        let minutes = self.vm.time / 60
        let seconds = self.vm.time % 60
        
        DispatchQueue.main.async { [unowned self] in
            self.timeLabel.text = String(format: "%02d", hours) + ":"
            + String(format: "%02d", minutes) + ":"
            + String(format: "%02d", seconds)
        }
    }
}

extension StartDrivingViewController: CLLocationManagerDelegate, GMSMapViewDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            if (vm.path?.track.isEmpty)! {
                createMarker(loc: loc, name: "starting_point")
            }
            animated_marker.position = loc.coordinate
            
            if iskeepFocus && vm.path?.track.isEmpty == false {
                let cameraPosition = GMSCameraPosition.camera(withTarget: loc.coordinate, zoom: 15, bearing: vm.getBearingBetweenTwoPoints((vm.path?.track.last)!, point2: loc), viewingAngle: mapView.gmsCamera.viewingAngle)
                mapView.animate(to: cameraPosition)
            }
            
            vm.path?.track.append(loc)
            addRouteToPath(loc: loc)
            
            vm.length = distance / 1000
            DispatchQueue.main.async { [unowned self] in
                self.distanceLabel.text = String(format: "%.01f", self.vm.length)+" km"
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, willMove gesture: Bool) {
        //        if gesture == true {
        //            iskeepFocus = false
        //        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let storyboard = UIStoryboard(name: "PathNavigationMore", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ShowSpotViewController") as? ShowSpotViewController {
            controller.spot = vm.path?.spotArray[Int(marker.title!)!]
            controller.spotIndex = Int(marker.title!)
            controller.userId = vm.path?.userId
            controller.delegate = self
            controller.sheetPresentationController?.detents = [.medium()]
            DispatchQueue.main.async {
                self.present(controller, animated: true, completion: nil)
            }
        }
        return true
    }
}

extension StartDrivingViewController: ShowSpotVCDelegate {
    func didPressRemoveSpotAt(index: Int) {
        vm.removeSpot(at: index)
    }
}
