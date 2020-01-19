//
//  SettingController.swift
//  SmartMirror
//
//  Created by Jiwoo Lim on 2020-01-18.
//  Copyright © 2020 Team 2019053. All rights reserved.
//

import UIKit
import Firebase


class SettingController : UIViewController{
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureViewComponents()
    }
    
    let scrollView: UIScrollView = {
        let v = UIScrollView()
        v.backgroundColor = UIColor.mainPurple()
        v.translatesAutoresizingMaskIntoConstraints = false
        return v
    }()
    
    lazy var weightTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "weight", isSecureTextEntry: false)
    }()
    
    lazy var heightTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "height", isSecureTextEntry: false)
    }()
    
    lazy var weightContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "add"), weightTextField)
    }()
    
    lazy var heightContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "add"), heightTextField)
    }()
    
    func updateUserMeasurement(weight: String, height:String){
        if((weight as NSString).doubleValue < 20 || (weight as NSString).doubleValue > 180 || (weight as NSString).doubleValue.isNaN){
            let alertController = UIAlertController(title: "Sign Up Unsuccessful", message: "weight should be within 20kg and 180kg", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        if((height as NSString).doubleValue < 100 || (height as NSString).doubleValue > 220 || (height as NSString).doubleValue.isNaN){
            let alertController = UIAlertController(title: "Sign Up Unsuccessful", message: "height should be within 100cm and 220cm", preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            self.present(alertController, animated: true, completion: nil)
            return
        }
        
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let values = ["weight":weight, "height":height]
        
        Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: {(error, ref) in
            if let error = error {
                print("Failed to update databasewith error: ",error.localizedDescription)
                return
            }
            
        })
        
        print("Update Successful")
        let alertController = UIAlertController(title: "Sign Up Successful", message: "Please login with your email and password", preferredStyle: .alert)
        
        //self.present(alertController, animated: true, completion: nil)
        //alertController.dismiss(animated: true, completion: nil)
        
        guard let navController = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController else { return }
        guard let controller = navController.viewControllers[0] as? HomeController else { return }
        controller.loadUserData()
        controller.configureViewComponents()
        //self.navigationController?.pushViewController(HomeController(), animated: true)
        
        self.navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func handleUpdate() {
        guard let weight = weightTextField.text else {return}
        guard let height = heightTextField.text else {return}
        
        updateUserMeasurement(weight: weight, height:height)
    }
    
    let updateButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("UPDATE", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainPurple(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleUpdate), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()

    func configureViewComponents(){
        view.backgroundColor = UIColor.mainPurple()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .white
        
        // constrain the scroll view to 8-pts on each side
//        view.addSubview(scrollView)
//        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
//        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
//        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
//        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
        
        view.addSubview(weightContainerView)
        weightContainerView.anchor(top: view.topAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 100, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(heightContainerView)
        heightContainerView.anchor(top: weightContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(updateButton)
        updateButton.anchor(top: heightContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
    }
}


