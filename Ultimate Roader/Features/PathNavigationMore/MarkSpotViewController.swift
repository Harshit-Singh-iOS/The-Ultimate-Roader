//
//  MarkSpotViewController.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 11/11/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import CoreLocation
import Firebase
import FirebaseAuth
import FirebaseStorage
import FirebaseDatabase

protocol MarkSpotProtocol: AnyObject {
    func addSpotMarker(spot: Path.Spot)
}

class MarkSpotViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    weak var delegate: MarkSpotProtocol?
    var loc: CLLocation?
    var spot: Path.Spot?
    var storageRef = Storage.storage().reference()
    var ref = Database.database().reference()
    
    @IBOutlet weak var typePickerView: UIPickerView!
    @IBOutlet weak var spotDescriptionTf: UITextView!
    @IBOutlet weak var spotImageView: UIImageView!
    
    var imagePickerCont = UIImagePickerController()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Add general note."
        imagePickerCont.delegate = self
        typePickerView.delegate = self
        spot = Path.Spot()
        spot?.cat = Path.Spot.Category.allCases[0].rawValue
        spot?.category = .General
        spot?.location = loc
        
        setupUI()
    }
    
    private func setupUI() {
        typePickerView.layer.borderColor = UIColor.white.cgColor
        typePickerView.layer.borderWidth = 1
        
        spotDescriptionTf.placeholder = "Description"
        spotDescriptionTf.placeholderColor = UIColor.white
        
        if #available(iOS 26.0, *) {
            spotDescriptionTf.cornerConfiguration = .corners(radius: .containerConcentric(minimum: 24))
            typePickerView.cornerConfiguration = .corners(radius: .containerConcentric(minimum: 8))
            spotImageView.cornerConfiguration = .corners(radius: .containerConcentric(minimum: 24))
        } else {
            spotDescriptionTf.layer.cornerRadius = 24
            typePickerView.layer.cornerRadius = 8
            spotImageView.layer.cornerRadius = 24
        }
    }
    

    @IBAction func pickImageAction(_ sender: UIButton) {
        let alertController = UIAlertController(title: "", message: "Select", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Camera", style: .default) { [weak self] _ in
            guard let self else { return }
            self.imagePickerCont.sourceType = .camera
            self.present(self.imagePickerCont, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Photo Gallery", style: .default) { [weak self] _ in
            guard let self else { return }
            self.imagePickerCont.sourceType = .photoLibrary
            self.present(self.imagePickerCont, animated: true, completion: nil)
        })
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func addSpotAction(_ sender: UIButton) {
        
        spot?.spotDescription = spotDescriptionTf.text
        
        if let image = spotImageView.image {
            spot?.spotSelectedImage = image
        }
        delegate?.addSpotMarker(spot: spot!)
        dismiss(animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            spotImageView.image = image
        }
        dismiss(animated: true, completion: nil)
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return Path.Spot.Category.allCases.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        Path.Spot.Category.allCases[row].rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        var str = Path.Spot.Category.allCases[row].rawValue
        
        let type = NSAttributedString(string: str, attributes: [NSAttributedString.Key.foregroundColor: UIColor.white])
        
        return type
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        spot?.category = Path.Spot.Category.allCases[row]
        spot?.cat = spot?.category.rawValue
        title = "Add " + (spot?.cat)! + " note."
    }
}
