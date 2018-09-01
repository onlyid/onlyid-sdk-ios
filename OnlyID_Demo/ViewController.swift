//
//  ViewController.swift
//  OnlyID_Demo
//
//  Created by Alex on 2018/4/20.
//  Copyright © 2018年 OnlyID. All rights reserved.
//

import UIKit
import OnlyID_SDK

class ViewController: UIViewController, AuthDelegate {
    @IBOutlet weak var resultLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func login(_ sender: Any) {
        OnlyID.auth("5adac916904be93f3f621003", delegate: self)
    }
    
    func didReceiveAuthResp(errCode: ErrCode, code: String?, state: String?) {
        switch errCode {
        case .cancel:
            resultLabel.text = "用户取消"
        case .networkErr:
            resultLabel.text = "网络错误"
        default:
            resultLabel.text = "code= " + code! + ", state= " + (state ?? "")
        }
    }
}
