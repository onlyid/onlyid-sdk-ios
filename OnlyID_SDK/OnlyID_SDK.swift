//
//  OnlyID_SDK.swift
//  OnlyID_SDK
//
//  Created by 梁庭宾 on 2017/9/19.
//  Copyright © 2017年 onlyID. All rights reserved.
//

import Foundation
import UIKit

let defaultState = "default_state"

public func auth(_ clientId: String, state: String = defaultState, delegate: AuthDelegate) {
    let viewController = AuthViewController(clientId: clientId, state: state, delegate: delegate)
    
    let navigationController = UINavigationController(rootViewController: viewController)
    
    guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
        fatalError("keyWindow或rootViewController为nil")
    }
    
    if let currentViewController = rootViewController.presentedViewController {
        currentViewController.present(navigationController, animated: true, completion: nil)
    }
    else {
        rootViewController.present(navigationController, animated: true, completion: nil)
    }
}

public protocol AuthDelegate {
    func didReceiveAuthResponse(authResponse: AuthResponse)
}

public class AuthResponse {
    public let code: ErrCode, authCode: String?, state: String?
    
    init(_ code: ErrCode, authCode: String? = nil, state: String? = nil) {
        self.code = code
        self.authCode = authCode
        self.state = state
    }
}

public enum ErrCode {
    case OK, networkErr, cancel
}
