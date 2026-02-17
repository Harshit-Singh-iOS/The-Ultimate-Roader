//
//  SaveDriveViewController.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 10/24/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import CoreLocation
import FirebaseDatabase
import FirebaseStorage
import FirebaseAuth

class SaveDriveViewController: UIViewController {

    @IBOutlet weak var map_view: GMSMapView!
    var polyline = GMSPolyline()
    var gmsPath = GMSMutablePath()
    var animated_marker = GMSMarker()
    var path: Path!
    var databaseRef: DatabaseReference?
    @IBOutlet weak var save_btn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Finish Drive"
        map_view.mapType = .standard
        databaseRef = Database.database().reference()
        SwiftMessageBar.setSharedConfig(Theme.barConfig)
        // Do any additional setup after loading the view.
    }

    override func viewWillAppear(_ animated: Bool) {
        if let track = path?.track{
            for loc in track{
                addRouteToPath(loc: loc)
            }
            createMarker(loc: track.first!, name: "starting_point")
            createMarker(loc: track.last!, name: "ending_point")
        }
        setMapBounds()
    }
    
    func createMarker(loc: CLLocation, name: String) {
        let marker = GMSMarker()
        marker.position = loc.coordinate
        marker.title = name.contains("start") ? "Start" : "Finish"
        marker.map = map_view
        marker.isDraggable = true
        marker.icon = UIImage(named: name)
    }
    
    func setMapBounds() {
        let bounds = GMSCoordinateBounds(path: gmsPath)
        let update = GMSCameraUpdate.fit(bounds, withPadding: 80.0)
        map_view.moveCamera(update)
        map_view.setMinZoom(self.map_view.minZoom, maxZoom: self.map_view.maxZoom)
    }
    func addRouteToPath(loc: CLLocation) {
        gmsPath.add(loc.coordinate)
        polyline.path = gmsPath
        polyline.strokeColor = Theme.path_color
        polyline.strokeWidth = Theme.pathWidth
        CATransaction.begin()
        CATransaction.setAnimationDuration(2.0)
        polyline.map = map_view
        CATransaction.commit()
    }
    
    @IBAction func save_btn_action(_ sender: UIButton) {
        if path?.pathName?.isEmpty == false {
            databaseRef?.child("Paths").child((path?.pathID)!).updateChildValues(["pathName": path?.pathName ?? "New drive", "pathType": path?.pathType.rawValue ?? "public", "difficulty": path?.difficulty.rawValue ?? "easy"])
        
            SwiftMessageBar.showMessageWithTitle("Success", message: "Drive saved successfully.", type: .success)
            navigationController?.popToRootViewController(animated: true)
        } else {
            SwiftMessageBar.showMessageWithTitle("Drive name empty.", message: "Enter drive name.", type: .error)
        }
    }
}

extension SaveDriveViewController: ModifyPathDetailsViewControllerDelegate {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let controller = segue.destination as? ModifyPathDetailsViewController {
            controller.path = path
            controller.delegate = self
        }
    }
    
    func didUpdatePath(path: Path) {
        self.path = path
    }
}
