//
//  GoogleMapViewController.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 10/20/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD

class StartDrivingViewController: UIViewController {
    
    let vm = StartDrivingViewModel()
    
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var mapModeButton: UIButton!
    
    private var locationManager = CLLocationManager()
    private var iskeepFocus: Bool = true
    private var polyline = GMSPolyline()
    private var gmsPath = GMSMutablePath()
    private var animated_marker = GMSMarker(annotationType: .current)
    private var uuid: String?

    private var distance: Double = 0.0
    private var timer = Timer()

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
            self?.updateLabel()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        polyline.map = mapView
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.shared.isIdleTimerDisabled = false
    }
    
    deinit {
        finishTrip(save: false)
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
            finishTrip()
            setMapBounds()
            createMarker(loc: (vm.path?.track.last)!, name: .finish)
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
            DispatchQueue.main.async { [weak self] in
                self?.present(controller, animated: true, completion: nil)
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
    
    private func finishTrip(save: Bool = true) {
        timer.invalidate()
        locationManager.stopUpdatingLocation()
        
        if save {
            SVProgressHUD.show(UIImage(), status: "Saving drive...")
            vm.saveDriveInformation {[weak self] in
                SVProgressHUD.dismiss()
                self?.completeSavingDrive()
            }
        }
        
        animated_marker.icon = nil
        animated_marker.map = nil
        polyline.map = nil
        gmsPath.removeAllCoordinates()
    }
    
    func completeSavingDrive() {
        DispatchQueue.main.async { [weak self] in
            let alertController = UIAlertController.init(
                title: "Finish Drive!",
                message: "Proceed to fill details.",
                preferredStyle: .alert)
            
            let action = UIAlertAction(title: "Proceed", style: .default, handler: { _ in
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
    
    func createMarker(loc: CLLocation, name: MapAnnotation) {
        let marker = GMSMarker(annotationType: name)
        marker.position = loc.coordinate
        marker.map = mapView
        marker.isDraggable = true
    }
    
    func addRouteToPath(loc: CLLocation) {
        ManagePathManager.sharedinstance.addCordinateTopath(latidude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        polyline.strokeColor = Theme.pathColor
        polyline.strokeWidth = Theme.pathWidth
        polyline.zIndex = 10
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = mapView
        CATransaction.commit()
        
        distance = gmsPath.length(of: .geodesic)
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: gmsPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        mapView.moveCamera(update)
        mapView.setMinZoom(self.mapView.minZoom, maxZoom: self.mapView.maxZoom)
    }
    
    @objc func updateLabel() {
        self.vm.time += 1
        
        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            let time = FTMathCalculations.timeInHoursAndMins(TimeInterval(vm.time))
            
            self.timeLabel.text = String(format: "%02d", time.hours) + ":"
            + String(format: "%02d", time.mins) + ":"
            + String(format: "%02d", time.seconds)
        }
    }
}

extension StartDrivingViewController: CLLocationManagerDelegate, GMSMapViewDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let loc = locations.last {
            if (vm.path?.track.isEmpty)! {
                createMarker(loc: loc, name: .start)
            }
            animated_marker.position = loc.coordinate
            vm.path?.track.append(loc)
            addRouteToPath(loc: loc)
            
            if iskeepFocus && vm.path?.track.isEmpty == false {
                let cameraPosition = GMSCameraPosition.camera(withTarget: loc.coordinate, zoom: 15, bearing: vm.getBearingBetweenTwoPoints((vm.path?.track.last)!, point2: loc), viewingAngle: mapView.gmsCamera.viewingAngle)
                
                UIView.animate {
                    mapView.animate(to: cameraPosition)
                }
            }
            
            vm.length = distance / 1000
            DispatchQueue.main.async { [weak self] in
                guard let self else { return }
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
            controller.spot = vm.path?.spotArray[Int(marker.spotTitle!)!]
            controller.spotIndex = Int(marker.spotTitle!)
            controller.userId = vm.path?.userId
            controller.delegate = self
            controller.sheetPresentationController?.detents = [.medium()]
            DispatchQueue.main.async { [weak self] in
                self?.present(controller, animated: true, completion: nil)
            }
        }
        return true
    }
}

extension StartDrivingViewController: ShowSpotVCDelegate, MarkSpotProtocol {
    func didPressRemoveSpotAt(index: Int) {
        vm.removeSpot(at: index)
    }
    
    func addSpotMarker(spot: Path.Spot) {
        let marker = GMSMarker(annotationType: .spot, position: (spot.location?.coordinate)!)
        marker.map = mapView
        marker.spotTitle = "\(spotIndex)"
        spotIndex += 1
        marker.snippet = spot.spotDescription
        vm.path?.spotArray.append(spot)
    }
}
