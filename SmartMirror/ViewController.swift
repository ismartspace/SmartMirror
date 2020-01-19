//
//  ViewController.swift
//  SmartMirror
//
//  Created by Jiwoo Lim on 2019-09-15.
//  Copyright © 2019 Team 2019053. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var body: UIImageView!
    
    @IBOutlet weak var head: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }


    

    @IBAction func see(_ sender: Any) {
        head.text = "Head: xxx cm"
    }
    
}

