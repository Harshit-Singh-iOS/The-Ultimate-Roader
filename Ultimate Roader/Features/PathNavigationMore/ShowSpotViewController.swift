//
//  ShowSpotViewController.swift
//  Ultimate Roader
//
//  Created by Harshit Singh on 11/15/17.
//  Copyright © 2017 RJT. All rights reserved.
//

import UIKit
import FirebaseAuth
import SVProgressHUD

protocol ShowSpotVCDelegate: AnyObject {
    func didPressRemoveSpotAt(index: Int)
}

class ShowSpotViewController: UIViewController {

    @IBOutlet weak var descTypeLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var spotImageView: UIImageView!
    @IBOutlet weak var deleteBtn: UIButton!
    weak var delegate: ShowSpotVCDelegate?
    var spot: Path.Spot?
    var spotIndex: Int?
    var userId: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        descTypeLabel.text = spot?.cat
        descriptionLabel.text = spot?.spotDescription
        deleteBtn.layer.cornerRadius = 20
        fetchImage()
    }
    
    func fetchImage() {
        SVProgressHUD.show()
        DispatchQueue.global(qos: .background).async {[weak self] in
            if let urlStr = self?.spot?.spotImageUrl,
               let url = URL(string: urlStr),
               let imgData = try? Data.init(contentsOf: url) {
                DispatchQueue.main.async { [weak self] in
                    self?.spotImageView.image = UIImage(data: imgData)
                    SVProgressHUD.dismiss()
                }
            } else {
                SVProgressHUD.dismiss()
            }
        }
    }
    
    @IBAction func deleteAction(_ sender: UIButton) {
        if userId == Auth.auth().currentUser?.uid {
            delegate?.didPressRemoveSpotAt(index: spotIndex!)
            dismiss(animated: true, completion: nil)
        } else {
            let alertCont = UIAlertController(title: "Not Allowed", message: "Cannot delete someone else's path.", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "Ok", style: .default, handler: nil)
            alertCont.addAction(okAction)
            present(alertCont, animated: true, completion: nil)
        }
    }
    
    @IBAction func closeAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
}
