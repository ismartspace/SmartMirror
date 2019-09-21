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
                self.present(navController, animated: true , completion: nil)
            }
        }else{
            loadUserData()
            configureViewComponents()
            
        }
    }
    
    func signOut(){
        do {
            try Auth.auth().signOut()
            let navController = UINavigationController(rootViewController: LoginController())
            navController.navigationBar.barStyle = .black
            self.present(navController, animated: true, completion: nil)
        } catch let error {
            print("Failed to sign out with error..", error)
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
            self.weightLabel.text = "Weight :    \(weight) kg"
            guard let height = value["height"] as? String else { return }
            self.heightLabel.text = "Height :    \(height) cm"
            
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
        
        navigationItem.title = "SmartMirror"
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: #imageLiteral(resourceName: "baseline_arrow_back_white_24dp"), style: .plain, target: self, action: #selector(handleSignOut))
        navigationItem.leftBarButtonItem?.tintColor = .white
        navigationController?.navigationBar.barTintColor = UIColor.mainPurple()
        
        view.addSubview(profileImageView)
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.anchor(top: view.topAnchor, paddingTop: 120, width: 120, height: 120)
        profileImageView.layer.cornerRadius = 120/2
        
        view.addSubview(nameLabel)
        nameLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        nameLabel.anchor(top: profileImageView.bottomAnchor, paddingTop: 20)
        
        view.addSubview(summaryLabel)
        summaryLabel.anchor(top: nameLabel.bottomAnchor, left: view.leftAnchor, paddingTop: 50,
                            paddingLeft: 30)
        
        view.addSubview(weightContainerView)
        weightContainerView.anchor(top: summaryLabel.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30, height: 100)
        weightContainerView.layer.cornerRadius = 10
        
        view.addSubview(heightContainerView)
        heightContainerView.anchor(top: weightContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30, height: 100)
        heightContainerView.layer.cornerRadius = 10
        
        view.addSubview(BMIContainerView)
        BMIContainerView.anchor(top: heightContainerView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 20, paddingLeft: 30, paddingRight: 30, height: 100)
        BMIContainerView.layer.cornerRadius = 10
        

        
        
    }
    
    
}
