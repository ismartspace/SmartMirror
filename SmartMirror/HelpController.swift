//
//  HelpController.swift
//  SmartMirror
//
//  Created by Jiwoo Lim on 2020-01-18.
//  Copyright © 2020 Team 2019053. All rights reserved.
//

import UIKit

class HelpController : UIViewController{
    
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
    
    let ImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.image = UIImage(named: "cda")
        return iv
    }()

    func configureViewComponents(){
        view.backgroundColor = UIColor.mainPurple()
        navigationController?.navigationBar.isHidden = false
        navigationController?.navigationBar.tintColor = .white
        
        // constrain the scroll view to 8-pts on each side
        view.addSubview(scrollView)
        scrollView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 8.0).isActive = true
        scrollView.topAnchor.constraint(equalTo: view.topAnchor, constant: 8.0).isActive = true
        scrollView.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -8.0).isActive = true
        scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8.0).isActive = true
        
        scrollView.addSubview(ImageView)
        ImageView.anchor(top: scrollView.topAnchor, left: scrollView.leftAnchor, bottom: scrollView.bottomAnchor, right: scrollView.rightAnchor)
    }
}


