//
//  CameraController.swift
//  SmartMirror
//
//  Created by Jiwoo Lim on 2020-01-09.
//  Copyright © 2020 Team 2019053. All rights reserved.
//

import UIKit

class CameraController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var frontImage = UIImage(named: "image")
    var sideImage = UIImage(named: "image")
    
    var frontSelected = false
    var sideSelected = false
    
    var frontLabel: UILabel = {
        let label = UILabel()
        label.text = "Take Front Picture"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    var sideLabel: UILabel = {
        let label = UILabel()
        label.text = "Take Side Picture"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        return label
    }()
    
    let startButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Click to Start Measurement!", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 23)
        button.setTitleColor(UIColor.white, for: .normal)
        button.addTarget(self, action: #selector(handleStart), for: .touchUpInside)
        return button
    }()
    
    @objc func handleStart(){
        //TODO: check if the image is loaded
        self.showSpinner(onView: self.view)
        print("processing the mesaurements")
        //self.removeSpinner()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureViewComponents()
    }
    
    func camera()
    {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .camera
            self.present(imagePickerController, animated: true, completion: nil)
        }

    }
    
    func photoLibrary()
    {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = self
            imagePickerController.sourceType = .photoLibrary
            self.present(imagePickerController, animated: true, completion: nil)
        }
    }
    
    @objc func frontButton(){
        frontSelected = true
        sideSelected = false
        showActionSheet()
    }
    
    @objc func sideButton(){
        frontSelected = false
        sideSelected = true
        showActionSheet()
    }
    
    func showActionSheet() {
        let actionSheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)

        actionSheet.addAction(UIAlertAction(title: "Camera", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.camera()
        }))

        actionSheet.addAction(UIAlertAction(title: "Gallery", style: .default, handler: { (alert:UIAlertAction!) -> Void in
            self.photoLibrary()
        }))

        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))

        self.present(actionSheet, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            //get an image
            if frontSelected == true {
                frontImage = pickedImage
            }else{
                sideImage = pickedImage
            }
            configureViewComponents()
        }
     
        dismiss(animated: true, completion: nil)
    }


    func makeFrontButton() -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 100, y: 80, width: 180, height: 230)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.5
        button.setImage(frontImage, for: .normal)
        button.addTarget(self, action: #selector(frontButton), for: .touchUpInside)
        return button
    }
    
    func makesideButton() -> UIButton {
        let button = UIButton(type: UIButton.ButtonType.custom)
        button.frame = CGRect(x: 100, y: 350, width: 180, height: 230)
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1.5
        button.setImage(sideImage, for: .normal)
        button.addTarget(self, action: #selector(sideButton), for: .touchUpInside)
        return button
    }
    
    func configureViewComponents() {
        view.backgroundColor = UIColor.mainPurple()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .white
        
        let frontButton = makeFrontButton()
        view.addSubview(frontButton)
        
        view.addSubview(frontLabel)
        frontLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        frontLabel.anchor(top: frontButton.bottomAnchor, paddingTop: 5)
        
        let sideButton = makesideButton()
        view.addSubview(sideButton)
        
        view.addSubview(sideLabel)
        sideLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        sideLabel.anchor(top: sideButton.bottomAnchor, paddingTop: 5)
        
        view.addSubview(startButton)
        startButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        startButton.anchor(top: sideButton.bottomAnchor,bottom: view.bottomAnchor, paddingTop: 5, paddingBottom: 2)
        
        
        
    }
}
