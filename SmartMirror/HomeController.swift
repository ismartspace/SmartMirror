//
//  HomeController.swift
//  SmartMirror
//
//  Created by Jiwoo Lim on 2019-09-15.
//  Copyright © 2019 Team 2019053. All rights reserved.
//

import UIKit
import Firebase


class HomeController: UIViewController {

    //let weightPickerData = [String](arrayLiteral: "kg", "lb")
    
    var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 28)
        //label.translatesAutoresizingMaskIntoConstraints = false
        //label.alpha = 0
        return label
    }()
    
    var weightLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28)
        //label.translatesAutoresizingMaskIntoConstraints = false
        //label.alpha = 0
        return label
    }()
    
    var heightLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28)
        //label.translatesAutoresizingMaskIntoConstraints = false
        //label.alpha = 0
        return label
    }()
    
    var BMILabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 28)
        return label
    }()
    
    let summaryLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 30)
        label.text = "Summary"
        return label
    }()
    
    lazy var weightContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainContainerPurple()

        view.addSubview(weightLabel)
        weightLabel.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 20,
                           paddingLeft: 30)

        return view
    }()
    
    lazy var heightContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainContainerPurple()
        
        view.addSubview(heightLabel)
        heightLabel.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 20,
                           paddingLeft: 30)
        
        return view
    }()
    
    lazy var BMIContainerView : UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.mainContainerPurple()
        
        view.addSubview(BMILabel)
        BMILabel.anchor(top: view.topAnchor, left: view.leftAnchor, paddingTop: 20,
                           paddingLeft: 30)
        
        return view
    }()
    
    let profileImageView : UIView = {
        let view = UIImageView()
        view.backgroundColor = .white
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        return view
    }()
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        //v.backgroundColor = UIColor.mainPurple()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authenticateUserAndConfigureView()
    }
    
    @objc func handleSignOut(){
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    
    //MARK- API
    
    func authenticateUserAndConfigureView(){
        if Auth.auth().currentUser == nil {
            DispatchQueue.main.async {//handle it in main thread before anything happens
                
                let navController = UINavigationController(rootViewController: LoginController())
                navController.navigationBar.barStyle = .black
                //self.present(navController, animated: true , completion: nil)
                
                //UIApplication.shared.keyWindow?.rootViewController = navController
                self.navigationController?.pushViewController(LoginController(), animated: true)
            }
        }else{
            updateUserMeasurement()
            loadUserData()
            configureViewComponents()
            
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
            let navController = UINavigationController(rootViewController: LoginController())
            navController.navigationBar.barStyle = .black
            self.navigationController?.navigationBar.isHidden = true
            //self.present(navController, animated: true, completion: nil)
            self.navigationController?.pushViewController(LoginController(), animated: true)
            
        } catch let error {
            print("Failed to sign out with error..", error)
        }
    }
    
    func updateUserMeasurement(){
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let neck = "1"
        let shoulder = "2"
        let chest = "3"
        let waist = "4"
        let hip = "5"
        let inseam = "6"
        
        let values = ["neck":neck, "shoulder":shoulder, "chest":chest, "waist":waist, "hip":hip, "inseam":inseam]
        
        Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: {(error, ref) in
            if let error = error {
                print("Failed to update databasewith error: ",error.localizedDescription)
                return
            }
            
        })
    }
    
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            //get user value
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let username = value["username"] as? String else { return }
            self.nameLabel.text = "\(username)"
            guard let weight = value["weight"] as? String else { return }
            self.weightLabel.text = "Weight :    \(weight) kg"
            guard let height = value["height"] as? String else { return }
            self.heightLabel.text = "Height :    \(height) cm"
            
            let neck = value["neck"] as? String
            let shoulder = value["shoulder"] as? String
            let chest = value["chest"] as? String
            let waist = value["waist"] as? String
            let hip = value["hip"] as? String
            let inseam = value["inseam"] as? String
            
            print("logging info " + "\(neck) \(shoulder) \(chest) \(waist) \(hip) \(inseam)")
            
            let weightDouble:Double = Double(weight) as! Double
            let heightDouble:Double = Double(height) as! Double
            
            print("\(weightDouble) \(heightDouble)")
            
            let BMI:Double = weightDouble/(heightDouble/100)/(heightDouble/100)
            var result:String = ""
            
            if(BMI < 18.5){
                result = "underweight"
            }else if(BMI >= 18.5 && BMI < 25 ){
                result = "normal"
            }else if(BMI >= 25 && BMI < 30){
                result = "overweight"
            }else if(BMI >= 30){
                result = "obese"
            }
            
            self.BMILabel.text = "BMI : " + String(format: "%.1f", BMI) + " is " + result
                        
            UIView.animate(withDuration: 0.3, animations: {
                self.nameLabel.alpha = 1
                self.weightLabel.alpha = 1
                self.heightLabel.alpha = 1
                self.BMILabel.alpha = 1

            })
        }
    }
    
    func configureViewComponents(){
        view.backgroundColor = UIColor.mainPurple()
        
        setupNavigationBar()
        
        // add the scroll view to self.view
        view.addSubview(scrollView)
        // constrain the scroll view to 8-pts on each side
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
        
        scrollView.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        profileImageView.anchor(top: scrollView.topAnchor, paddingTop: 120, width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120/2
        
        scrollView.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: scrollView.centerXAnchor).isActive = true
        nameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 20)
        
        scrollView.addSubview(summaryLabel)
        summaryLabel.anchor(top: nameLabel.bottomAnchor, left: scrollView.leftAnchor, paddingTop: 20,
                            paddingLeft: 30)
        
        scrollView.addSubview(heightContainerView)
        heightContainerView.anchor(top: summaryLabel.bottomAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingRight: 30, width: 0, height: 80)
        heightContainerView.layer.cornerRadius = 10
        
        scrollView.addSubview(weightContainerView)
        weightContainerView.anchor(top: heightContainerView.bottomAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingRight: 30, height: 100)
        weightContainerView.layer.cornerRadius = 10
    
        
        scrollView.addSubview(BMIContainerView)
        BMIContainerView.anchor(top: weightContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingBottom: 20, paddingRight: 30, height: 100)
        BMIContainerView.layer.cornerRadius = 10
    }

    
    /*
     Sets up the navigation bar
     */
    func setupNavigationBar() {
        navigationItem.title = "SmartMirror"
        
        let moreButton = UIBarButtonItem(
            image: #imageLiteral(resourceName: "nav_more_icon"),
            style: .plain,
            target: self,
            action: #selector(handleMore)
        )
        
        let signOutButton = UIBarButtonItem(
            image: #imageLiteral(resourceName: "baseline_arrow_back_white_24dp"),
            style: .plain,
            target: self,
            action: #selector(handleSignOut)
        )
        
        let rightBarButton = UIBarButtonItem(
            image: #imageLiteral(resourceName: "cameraIcon"),
            style: .plain,
            target: self,
            action: #selector(enableCameraAccess)
        )
                
        navigationItem.leftBarButtonItems = [moreButton, signOutButton]
        navigationItem.rightBarButtonItem = rightBarButton
        
        moreButton.tintColor = .white
        signOutButton.tintColor = .white
        navigationItem.rightBarButtonItem?.tintColor = .white

        navigationController?.navigationBar.barTintColor = .mainPurple()
    }
    
    func showControllerForSetting(setting: Setting) {
        if setting.name == "New Measurements"{
            let navController = UINavigationController(rootViewController: CameraController())
            navController.navigationBar.barStyle = .black
            //self.present(navController, animated: true, completion: nil)
            self.navigationController?.pushViewController(CameraController(), animated: true)
        }else if setting.name == "Help"{
            let navController = UINavigationController(rootViewController: HelpController())
            navController.navigationBar.barStyle = .black
            //self.present(navController, animated: true, completion: nil)
            self.navigationController?.pushViewController(HelpController(), animated: true)
        }else if setting.name == "Settings"{
            let navController = UINavigationController(rootViewController: SettingController())
            navController.navigationBar.barStyle = .black
            //self.present(navController, animated: true, completion: nil)
            self.navigationController?.pushViewController(SettingController(), animated: true)
        }else{
            let dummySettingsViewController = UIViewController()
            dummySettingsViewController.view.backgroundColor = UIColor.white
            dummySettingsViewController.navigationItem.title = setting.name
            navigationController?.navigationBar.tintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
            navigationController?.pushViewController(dummySettingsViewController, animated: true)
        }
    }
    
    lazy var settingsLauncher: SettingsLauncher = {
        let launcher = SettingsLauncher()
        launcher.homeController = self
        return launcher
    }()
    
    /*
     Enables the camera
     */
    @objc func enableCameraAccess() {
        // TODO: Add camera feature to this function
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .camera
        self.present(imagePickerController, animated: true, completion: nil)
    }
    
    let settingLauncher = SettingsLauncher()
    @objc func handleMore(){
        settingLauncher.homeController = self
        settingLauncher.showSettings()
    }
    

}

//extension HomeController: UIPickerViewDelegate, UIPickerViewDataSource
