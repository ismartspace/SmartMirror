//
//  SignUpController.swift
//  SmartMirror
//
//  Created by Jiwoo Lim on 2019-09-15.
//  Copyright © 2019 Team 2019053. All rights reserved.
//

import UIKit
import Firebase

class SignUpController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //To move keyboard up and down
   @objc func keyboardWillShow(notification: NSNotification) {
       guard let userInfo = notification.userInfo else {return}
       guard let keyboardSize = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else {return}
       let keyboardFrame = keyboardSize.cgRectValue
       if self.view.frame.origin.y == 0{
           self.view.frame.origin.y -= keyboardFrame.height
            self.view.frame.origin.y += 50
       }
   }
   @objc func keyboardWillHide(notification: NSNotification) {
       if self.view.frame.origin.y != 0{
        self.view.frame.origin.y = 0
       }
        view.endEditing(true)
   }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        configureViewComponents()
        
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(SignUpController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        
        //Hide keyboard when background is touched
        self.view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(keyboardWillHide)))
        
        //unit conversion
        self.lengthPicker.delegate = self as UIPickerViewDelegate
        self.lengthPicker.dataSource = self as UIPickerViewDataSource
        self.weightPicker.delegate = self as UIPickerViewDelegate
        self.weightPicker.dataSource = self as UIPickerViewDataSource
    }
    
    @objc func handleSignUp() {
        guard let email = emailTextField.text else{return}
        guard let password = passwordTextField.text else {return}
        guard let username = usernameTextField.text else {return}
        guard let weight = weightTextField.text else {return}
        guard let height = heightTextField.text else {return}
        
        let weight_unit = weightData[weightPicker.selectedRow(inComponent: 0)]
        let length_unit = lengthData[lengthPicker.selectedRow(inComponent: 0)]
        
        
        createUser(withEmail: email, password: password, username: username, weight: weight, height:height, weight_unit: weight_unit, length_unit: length_unit)
    }
    
    @objc func handleShowLogin() {
        navigationController?.popViewController(animated: true)
    }
    
    func createUser(withEmail email: String, password: String, username: String, weight: String, height:String, weight_unit: String, length_unit: String){
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
        
        Auth.auth().createUser(withEmail: email, password: password) { (result, error) in
            if let error = error {
                print("failed to create user with error:", error.localizedDescription)

                let alertController = UIAlertController(title: "Sign Up Unsuccessful", message: error.localizedDescription, preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            //gurad provides protection if the value of uid is nil
            guard let uid = result?.user.uid else {return}
            
            let values = ["email":email, "username":username, "weight":weight, "height":height, "weight_unit":weight_unit, "length_unit":length_unit]
            
            Database.database().reference().child("users").child(uid).updateChildValues(values, withCompletionBlock: {(error, ref) in
                if let error = error {
                    print("Failed to update databasewith error: ",error.localizedDescription)
                    return
                }

                print("Sign Up Successful")

                let navController = UINavigationController(rootViewController: HomeController())
                guard let controller = navController.viewControllers[0] as? HomeController else { return }
                controller.loadUserData()
                controller.configureViewComponents()
                
                
                self.navigationController?.pushViewController(HomeController(), animated: true)
                self.navigationController?.navigationBar.isHidden = false
            })
        }
    }
    
    // MARK: - Properties
    
    let lengthPicker = UIPickerView()
    let lengthData = ["cm", "ft"]
    
    let weightPicker = UIPickerView()
    let weightData = ["kg", "lb"]
    
    let logoImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = #imageLiteral(resourceName: "SmartMirror")
        return iv
    }()
    
    lazy var emailContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "ic_mail_outline_white_2x-1"), emailTextField)
    }()
    
    lazy var usernameContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "ic_person_outline_white_2x"), usernameTextField)
    }()
    
    lazy var passwordContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "ic_lock_outline_white_2x"), passwordTextField)
    }()
    
    lazy var weightContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "add"), weightTextField)
    }()
    
    lazy var heightContainerView: UIView = {
        let view = UIView()
        return view.textContainerView(view: view, #imageLiteral(resourceName: "add"), heightTextField)
    }()
    
    lazy var emailTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Email", isSecureTextEntry: false)
    }()
    
    lazy var usernameTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Username", isSecureTextEntry: false)
    }()
    
    lazy var passwordTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Password", isSecureTextEntry: true)
    }()
    
    lazy var weightTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Weight", isSecureTextEntry: false)
    }()
    
    lazy var heightTextField: UITextField = {
        let tf = UITextField()
        return tf.textField(withPlaceolder: "Height", isSecureTextEntry: false)
    }()
    
    
    let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("SIGN UP", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.setTitleColor(UIColor.mainPurple(), for: .normal)
        button.backgroundColor = .white
        button.addTarget(self, action: #selector(handleSignUp), for: .touchUpInside)
        button.layer.cornerRadius = 5
        return button
    }()
    
    let dontHaveAccountButton: UIButton = {
        let button = UIButton(type: .system)
        let attributedTitle = NSMutableAttributedString(string: "Already have an account?  ", attributes: [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white])
        attributedTitle.append(NSAttributedString(string: "Sign In", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: UIColor.white]))
        button.setAttributedTitle(attributedTitle, for: .normal)
        button.addTarget(self, action: #selector(handleShowLogin), for: .touchUpInside)
        return button
    }()
    
    // MARK: - Helper Functions
    
    func configureViewComponents() {
        view.backgroundColor = UIColor.mainPurple()
        navigationController?.navigationBar.isHidden = true
        navigationController?.navigationBar.tintColor = .white
        
        view.addSubview(logoImageView)
        logoImageView.anchor(top: view.topAnchor, left: nil, bottom: nil, right: nil, paddingTop: 60, paddingLeft: 0, paddingBottom: 0, paddingRight: 0, width: 150, height: 150)
        logoImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        view.addSubview(emailContainerView)
        emailContainerView.anchor(top: logoImageView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(usernameContainerView)
        usernameContainerView.anchor(top: emailContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(passwordContainerView)
        passwordContainerView.anchor(top: usernameContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(weightContainerView)
        weightContainerView.anchor(top: passwordContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 150, width: 0, height: 50)
        
        view.addSubview(weightPicker)
        weightPicker.anchor(top: passwordContainerView.bottomAnchor, left: weightContainerView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 5, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
        
        view.addSubview(heightContainerView)
        heightContainerView.anchor(top: weightContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 32, paddingBottom: 0, paddingRight: 150, width: 0, height: 50)
        
        view.addSubview(lengthPicker)
        lengthPicker.anchor(top: weightContainerView.bottomAnchor, left: heightContainerView.rightAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 16, paddingLeft: 5, paddingBottom: 0, paddingRight: 20, width: 0, height: 50)
        
        view.addSubview(loginButton)
        loginButton.anchor(top: heightContainerView.bottomAnchor, left: view.leftAnchor, bottom: nil, right: view.rightAnchor, paddingTop: 24, paddingLeft: 32, paddingBottom: 0, paddingRight: 32, width: 0, height: 50)
        
        view.addSubview(dontHaveAccountButton)
        dontHaveAccountButton.anchor(top: loginButton.bottomAnchor, left: view.leftAnchor, bottom: view.bottomAnchor, right: view.rightAnchor, paddingTop: 0, paddingLeft: 32, paddingBottom: 12, paddingRight: 32, width: 0, height: 50)
        
    }
    
    
       // Number of columns of data
    func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
       
   // The number of rows of data
   func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if(pickerView == lengthPicker){
            return lengthData.count
        }else{
            return weightData.count
        }
    }
   
   // The data to return for the row and component (column) that's being passed in
   func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
       if(pickerView == lengthPicker){
           return lengthData[row]
       }else{
           return weightData[row]
       }
   }
    
}
