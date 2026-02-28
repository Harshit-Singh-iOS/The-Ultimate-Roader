//
//  FollowPathViewController.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 10/30/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import CoreLocation
import SVProgressHUD
import FirebaseDatabase

enum buttonName: String {
    case StartTrip = "start"
    case StopTrip = "stop"
}

class FollowPathViewController: UIViewController, CLLocationManagerDelegate, GMSMapViewDelegate, ShowSpotVCDelegate {

    var FollowPathDistanceDelta: CLLocationDistance = 5 //meters
    @IBOutlet weak var map_view: GMSMapView!
    var locationManager = CLLocationManager()
    @IBOutlet weak var start_following_btn: UIButton!
    
    var polyline = GMSPolyline()
    var polylineFollow = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var gmsFollowPath = GMSMutablePath()
    var animated_marker = GMSMarker(annotationType: .current)
    var myTrack: [CLLocation] = []
    var pathToFollow: Path?
    var location: CLLocation?
    var start_following: Bool = false
    var follow_btn_case: buttonName = .StartTrip
    
    var currentLocation : CLLocation? {
        didSet {
            self.currentLocationDidSet()
        }
    }
    
    var isFinished : Bool {
        if let finishLocation = pathToFollow?.track.last, let loc = currentLocation {
            let distance = loc.distance(from: finishLocation)
            return distance < FollowPathDistanceDelta
        }
        return false
    }
    
    var isAway : Bool {
        if let finishLocation = pathToFollow?.track.first, let loc = currentLocation {
            let distance = loc.distance(from: finishLocation)
            return distance > FollowPathDistanceDelta
        }
        return false
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Following Path"
        map_view.mapType = .standard
        locationManager.delegate = self
        map_view.delegate = self
        locationManager.startUpdatingLocation()
        start_following_btn.isEnabled = false
        DispatchQueue.main.async {
            self.setMapBounds()
            SVProgressHUD.dismiss()
        }
        animated_marker.groundAnchor = CGPoint(x: 0.5, y: 0.5)
        animated_marker.map = map_view
        animationImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        createMarker(loc: (pathToFollow?.track.first)!, name: .start)
        createMarker(loc: (pathToFollow?.track.last)!, name: .finish)
        map_view.gmsCamera = GMSCameraPosition(target: (pathToFollow?.track.first?.coordinate)!, zoom: 10, bearing: 0, viewingAngle: 0)
        
        for cord in (pathToFollow?.track)! {
            addRouteToPath(loc: cord)
        }
        
        var i = 0
        for spot in (pathToFollow?.spotArray)! {
            let marker = GMSMarker(annotationType: .spot, position: (spot.location!.coordinate))
            marker.map = map_view
            marker.spotTitle = "\(i)"
            i += 1
            marker.snippet = spot.spotDescription
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            return
        }

        currentLocation = location
        animated_marker.position = location.coordinate
        if start_following {
            myTrack.append(location)
            createMarker(loc: myTrack.first!, name: .start)
            addRouteToPath2(loc: location)
        }
        
        if !isAway {
            SwiftMessageBar.showMessageWithTitle("Start reached.", message: "Press start trip.", type: .info)
            start_following_btn.isEnabled = true
        }
        
        if isFinished {
            start_following = false
            createMarker(loc: myTrack.last!, name: .finish)
            popUpForPathComplete()
        }
    }
    
    func currentLocationDidSet() {
        guard currentLocation!.timestamp.timeIntervalSinceNow < 10.0 else {
            return
        }
        animated_marker.position = (self.currentLocation?.coordinate)!
        
        if isAway == false {
            print("Start")
        }
    }

    @IBAction func follow_path_action(_ sender: UIButton) {
        if follow_btn_case == .StartTrip {
            DispatchQueue.main.async {
                self.start_following_btn.setTitle("STOP FOLLOWING", for: .normal)
            }
            follow_btn_case = .StopTrip
            start_following = true
            
        } else if follow_btn_case == .StopTrip {
            start_following = false
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let storyboard = UIStoryboard(name: "PathNavigationMore", bundle: nil)
        if let controller = storyboard.instantiateViewController(withIdentifier: "ShowSpotViewController") as? ShowSpotViewController {
            controller.spot = pathToFollow?.spotArray[Int(marker.spotTitle!)!]
            controller.spotIndex = Int(marker.spotTitle!)
            controller.delegate = self
            controller.userId = pathToFollow?.userId
            controller.sheetPresentationController?.detents = [.medium()]
            DispatchQueue.main.async {
                self.present(controller, animated: true, completion: nil)
            }
        }
        return true
    }
    
    func didPressRemoveSpotAt(index: Int) {
        let spot = pathToFollow?.spotArray[index]
        pathToFollow?.spotArray.remove(at: index)
        let ref = Database.database().reference()
        ref.child(Firebase.Table.Paths).child((pathToFollow?.pathID)!).child(Firebase.Table.SpotList).child((spot?.id)!).removeValue()
        ref.child(Firebase.Table.SpotList).child((spot?.id)!).removeValue()
    }
    
    func createMarker(loc: CLLocation, name: MapAnnotation) {
        let marker = GMSMarker(annotationType: name)
        marker.position = loc.coordinate
        marker.map = map_view
        marker.isDraggable = true
    }
    
    func addRouteToPath(loc: CLLocation) {
        gmsFollowPath.add(loc.coordinate)
        polylineFollow.path = gmsFollowPath
        polylineFollow.strokeColor = Theme.pathColor
        polylineFollow.strokeWidth = Theme.pathWidth
        polylineFollow.zIndex = 10
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polylineFollow.map = map_view
        CATransaction.commit()
    }
    
    func addRouteToPath2(loc: CLLocation) {
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        polyline.strokeColor = UIColor.red
        polyline.strokeWidth = Theme.pathWidth
        polyline.zIndex = 10
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = map_view
        CATransaction.commit()
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: gmsFollowPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        map_view.moveCamera(update)
        map_view.setMinZoom(self.map_view.minZoom, maxZoom: self.map_view.maxZoom)
    }
    
    func animationImage() {
        animated_marker.icon = UIImage.animatedImage(with: Constants.animationImage, duration: 3.0)
    }
    
    func popUpForPathComplete() {
        ManagePathManager.sharedinstance.addFollowedUser(path: pathToFollow!)
        let alert = UIAlertController(title: "Trip complete!!", message: "You have reach destination.", preferredStyle: .alert)
        let action = UIAlertAction(title: "Ok", style: .default) { [weak self] (act) in
            self?.locationManager.stopUpdatingLocation()
            DispatchQueue.main.async {
                self?.navigationController?.popToRootViewController(animated: true)
            }
        }
        alert.addAction(action)
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func putSpots() {
        for spot in pathToFollow!.spotArray {
            let marker = GMSMarker(annotationType: .spot, position: spot.location!.coordinate)
            marker.map = map_view
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

