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

    var unit_conv = true
    var measurements_string: [String:String] = [:]
    var measurements_conv:[String:String] = [:]
    
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
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.borderWidth = 3
        view.layer.borderColor = UIColor.white.cgColor
        view.image = #imageLiteral(resourceName: "SmartMirror")
        return view
    }()
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        //v.backgroundColor = UIColor.mainPurple()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    let tableView = UITableView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        authenticateUserAndConfigureView()
        
        // TODO: to be removed
        print("opencv2 version: \(OpenCVWrapper.openCVVersionString())")
        
        tableView.dataSource = self
        
    }
    
    @objc func handleSignOut(){
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to sign out?", preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: "Sign Out", style: .destructive, handler: { (_) in
            self.signOut()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleUnitConversion(){
        if(!unit_conv){
            unit_conv = true
        }else{
            unit_conv = false
        }
        //TODO: do unit conversion
        //loadUserData()
        var temp = measurements_string
        measurements_string = measurements_conv
        measurements_conv = temp
        
        self.tableView.reloadData()

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
        
        //TODO: grab from the measurements
        let neck = "11"
        let shoulder = "36.7"
        let chest = "80"
        let arm = "88"
        let waist = "63"
        let hip = "86"
        let inseam = "80"
        
        
        let values = ["neck":neck, "shoulder":shoulder, "chest":chest, "arm":arm, "waist":waist, "hip":hip, "inseam":inseam, ]
        
        Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: {(error, ref) in
            if let error = error {
                print("Failed to update databasewith error: ",error.localizedDescription)
                return
            }
            
        })
    }
    

    
    func assign_measurement (weight: String, height: String, neck: String, shoulder: String, chest: String, arm: String, waist: String, hip: String, inseam: String, length_unit: String){
        
        let weightD = Double(weight) as! Double
        let heightD = Double(height) as! Double
        let neckD = Double(neck) as! Double
        let shoulderD = Double(shoulder) as! Double
        let chestD = Double(chest) as! Double
        let armD = Double(arm) as! Double
        let waistD = Double(waist) as! Double
        let hipD = Double(hip) as! Double
        let inseamD = Double(inseam) as! Double
        
        if(length_unit == "cm" ){ // assign ft and lb
            //kg* 2.2046
            self.measurements_conv["Weight"] = String(format:"%.1f", weightD*2.2046) + " lb"
            //cm / 30.48
            self.measurements_conv["Height"] = String(format:"%.1f", heightD/30.48) + " ft"
            self.measurements_conv["Neck"] = String(format:"%.1f", neckD/30.48) + " ft"
            self.measurements_conv["Shoulder"] = String(format:"%.1f", shoulderD/30.48) + " ft"
            self.measurements_conv["Chest"] = String(format:"%.1f", chestD/30.48) + " ft"
            self.measurements_conv["Arm"] = String(format:"%.1f", armD/30.48) + " ft"
            self.measurements_conv["Waist"] = String(format:"%.1f", waistD/30.48) + " ft"
            self.measurements_conv["Hip"] = String(format:"%.1f", hipD/30.48) + " ft"
            self.measurements_conv["Inseam"] = String(format:"%.1f", inseamD/30.48) + " ft"
        }else{
           // lb/2.2046
            self.measurements_conv["Weight"] = String(format:"%.1f", weightD/2.2046) + " kg"
            //cm * 30.48
            self.measurements_conv["Height"] = String(format:"%.1f", heightD*30.48) + " cm"
            self.measurements_conv["Neck"] = String(format:"%.1f", neckD*30.48) + " cm"
            self.measurements_conv["Shoulder"] = String(format:"%.1f", shoulderD*30.48) + " cm"
            self.measurements_conv["Chest"] = String(format:"%.1f", chestD*30.48) + " cm"
            self.measurements_conv["Arm"] = String(format:"%.1f", armD*30.48) + " cm"
            self.measurements_conv["Waist"] = String(format:"%.1f", waistD*30.48) + " cm"
            self.measurements_conv["Hip"] = String(format:"%.1f", hipD*30.48) + " cm"
            self.measurements_conv["Inseam"] = String(format:"%.1f", inseamD*30.48) + " cm"
        }
        
    }
    
    func loadUserData() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        Database.database().reference().child("users").child(uid).observeSingleEvent(of: .value) { (snapshot) in
            //get user value
            guard let value = snapshot.value as? NSDictionary else { return }
            guard let username = value["username"] as? String else { return }
            self.nameLabel.text = "\(username)"
            guard let weight = value["weight"] as? String else { return }
            //self.weightLabel.text = "Weight :    \(weight) kg"
            guard let height = value["height"] as? String else { return }
            //self.heightLabel.text = "Height :    \(height) cm"
            guard let weight_unit = value["weight_unit"] as? String else { return }
            guard let length_unit = value["length_unit"] as? String else { return }
            
            self.unit_conv = true //always true. only for switching
            
            //measurements
            guard let neck = value["neck"] as? String else { return }
            guard let shoulder = value["shoulder"] as? String else { return }
            guard let chest = value["chest"] as? String else { return }
            guard let arm = value["arm"] as? String else { return }
            guard let waist = value["waist"] as? String else { return }
            guard let hip = value["hip"] as? String else { return }
            guard let inseam = value["inseam"] as? String else { return }
                    
            self.measurements_string["Weight"] = weight + " " + weight_unit
            self.measurements_string["Height"] = height +  " " + length_unit
            if(!neck.isEmpty){
                self.measurements_string["Neck"] = neck + " " +  length_unit
                self.measurements_string["Shoulder"] = shoulder + " " +  length_unit
                self.measurements_string["Chest"] = chest + " " +  length_unit
                self.measurements_string["Arm"] = arm + " " +  length_unit
                self.measurements_string["Waist"] = waist + " " +  length_unit
                self.measurements_string["Hip"] = hip + " " +  length_unit
                self.measurements_string["Inseam"] = inseam + " " + length_unit
            }
            
            //for conversion
            self.assign_measurement(weight: weight, height: height, neck: neck, shoulder: shoulder, chest: chest, arm: arm, waist: waist, hip: hip, inseam: inseam, length_unit: length_unit)
            
            self.tableView.reloadData()
            
            print("measurement info " + "\(neck) \(shoulder) \(chest) \(arm) \(waist) \(hip) \(inseam)")
            
            let weightDouble:Double = Double(weight) as! Double
            let heightDouble:Double = Double(height) as! Double
            
            print("\(weightDouble) \(heightDouble)")
            
//            let BMI:Double = weightDouble/(heightDouble/100)/(heightDouble/100)
//            var result:String = ""
//
//            if(BMI < 18.5){
//                result = "underweight"
//            }else if(BMI >= 18.5 && BMI < 25 ){
//                result = "normal"
//            }else if(BMI >= 25 && BMI < 30){
//                result = "overweight"
//            }else if(BMI >= 30){
//                result = "obese"
//            }
//
//            self.BMILabel.text = "BMI : " + String(format: "%.1f", BMI) + " is " + result
                        
            UIView.animate(withDuration: 0.3, animations: {
                self.nameLabel.alpha = 1
                self.weightLabel.alpha = 1
                self.heightLabel.alpha = 1
                self.BMILabel.alpha = 1

            })
        }
    }
    
    func setupTableView() {
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 50).isActive = true
        tableView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 10).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.rightAnchor.constraint(equalTo: view.rightAnchor,constant: -10).isActive = true
        tableView.backgroundColor = UIColor.mainPurple()
        tableView.separatorColor = .white
        
        tableView.register(MeasurementTableViewCell.self, forCellReuseIdentifier: "cell")

    }
    
    func configureViewComponents(){
        view.backgroundColor = UIColor.mainPurple()
        
        setupNavigationBar()
        
        
        // add the scroll view to self.view
//        view.addSubview(scrollView)
//        // constrain the scroll view to 8-pts on each side
//        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
//        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
//        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
//        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
//
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.anchor(top: view.topAnchor, paddingTop: 100, width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120/2
        
        view.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 20)
        
        setupTableView()
//

//
//        scrollView.addSubview(summaryLabel)
//        summaryLabel.anchor(top: nameLabel.bottomAnchor, left: scrollView.leftAnchor, paddingTop: 20,
//                            paddingLeft: 30)
//
//        scrollView.addSubview(heightContainerView)
//        heightContainerView.anchor(top: summaryLabel.bottomAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingRight: 30, width: 0, height: 80)
//        heightContainerView.layer.cornerRadius = 10
//
//        scrollView.addSubview(weightContainerView)
//        weightContainerView.anchor(top: heightContainerView.bottomAnchor, left: scrollView.leftAnchor, right: scrollView.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingRight: 30, height: 100)
//        weightContainerView.layer.cornerRadius = 10
//
//
//        scrollView.addSubview(BMIContainerView)
//        BMIContainerView.anchor(top: weightContainerView.bottomAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor, paddingTop: 10, paddingLeft: 30, paddingBottom: 20, paddingRight: 30, height: 100)
//        BMIContainerView.layer.cornerRadius = 10
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
        
        let switchButton = UIBarButtonItem(
            image: #imageLiteral(resourceName: "arrow"),
            style: .plain,
            target: self,
            action: #selector(handleUnitConversion)
        )
                
        navigationItem.leftBarButtonItem = moreButton
        navigationItem.rightBarButtonItem = switchButton
        
        moreButton.tintColor = .white
        switchButton.tintColor = .white
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
        }else if setting.name == "Logout"{
            handleSignOut()
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
    
    let settingLauncher = SettingsLauncher()
    @objc func handleMore(){
        settingLauncher.homeController = self
        settingLauncher.showSettings()
    }
    

}

//extension HomeController: UIPickerViewDelegate, UIPickerViewDataSource

extension HomeController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return measurements_string.count
    //return 7
  }
    
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MeasurementTableViewCell

    cell.nameLabel.text = Array(measurements_string)[indexPath.row].key
    cell.measurementLabel.text = Array(measurements_string)[indexPath.row].value

    cell.backgroundColor = UIColor.mainPurple()
    return cell
  }
}
