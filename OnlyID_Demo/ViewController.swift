//
//  ViewController.swift
//  OnlyID_Demo
//
//  Created by Alex on 2018/4/20.
//  Copyright © 2018年 onlyID. All rights reserved.
//

import UIKit
import OnlyID_SDK

class ViewController: UIViewController {

    @IBOutlet weak var resultLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func authBtnTapped(_ sender: Any) {
        resultLabel.text = "Unauthorized"
        OnlyID.auth("5ad9df29904be93f3f621000", delegate: self)
    }
    
}

extension ViewController: AuthDelegate {
    func didReceiveAuthResponse(authResponse: AuthResponse) {
        resultLabel.text =  authResponse.code.description
        print("authCode:\(authResponse.authCode)")
    }
    
    
    
}
