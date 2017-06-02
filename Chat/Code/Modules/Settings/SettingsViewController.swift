//
//  SettingsViewController.swift
//  Chat
//
//  Created by Borja Igartua Pastor on 2/6/17.
//  Copyright © 2017 Borja Igartua Pastor. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var saveButton: UIButton!
    
    var interactor = SettingsInteractor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.saveButton.alpha = 0
        
        self.userImageView.layer.cornerRadius = 87
        self.userImageView.isUserInteractionEnabled = true
        self.userImageView.layer.masksToBounds = true
        
        let tapToImageGestureRecognizer = UITapGestureRecognizer(target: self,
                                                                 action: #selector(SettingsViewController.userImagePressed))
        tapToImageGestureRecognizer.cancelsTouchesInView = false
        self.userImageView.addGestureRecognizer(tapToImageGestureRecognizer)

        let userData = self.interactor.retriveUserData()
        usernameTextField.placeholder = userData.name
        usernameTextField.delegate = self
        
        var image: UIImage?
        if let imageData = userData.image {
            image = UIImage(data: imageData)
            
        } else {
            image = UIImage(named: "user.png")
        }
        
        userImageView.image = image
    }
    

//MARK: - User interaction
    
    func userImagePressed() {
        
        let imagePickerViewController = UIImagePickerController()
        imagePickerViewController.delegate = self
        
        let alertController = UIAlertController()
        let imageAction = UIAlertAction(title: "Album",
                                        style: UIAlertActionStyle.default) { [weak self] (action) in
            imagePickerViewController.sourceType = UIImagePickerControllerSourceType.photoLibrary
            self?.present(imagePickerViewController, animated: true, completion: nil)
        }
        
        let cameraAction = UIAlertAction(title: "Camera",
                                         style: UIAlertActionStyle.default) { [weak self] (action) in
            imagePickerViewController.sourceType = UIImagePickerControllerSourceType.camera
            self?.present(imagePickerViewController, animated: true, completion: nil)
        }
        
        alertController.addAction(imageAction)
        alertController.addAction(cameraAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func saveButtonPressed(_ sender: Any) {
        
        if let username = self.usernameTextField.text {
            self.interactor.saveUserName(username)
            self.usernameTextField.placeholder = username
            self.usernameTextField.text = nil
            self.saveButton.alpha = 0
        }
    }
    
//MARK: - Image Picker delegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true) { [unowned self] in
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.userImageView.image = image
                self.interactor.saveUserImage(image)
            }
        }
    }
    
//MARK: - UITextField delegate
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        let nsString = textField.text as NSString?
        let newString = nsString?.replacingCharacters(in: range, with: string)
        
        let save = newString?.isEmpty ?? true
        if save {
            self.saveButton.alpha = 0
            
        } else {
            self.saveButton.alpha = 1
        }
        
        return true
    }

}
