//
//  OnlyID_SDK.swift
//  OnlyID_SDK
//
//  Created by 梁庭宾 on 2017/9/19.
//  Copyright © 2017年 onlyID. All rights reserved.
//

import Foundation
import UIKit

public class OnlyID: NSObject {
    static let defaultState = "default_state"

    static public func auth(_ clientId: String, state: String = defaultState, delegate: AuthDelegate) {
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
    
}

@objc public protocol AuthDelegate {
    func didReceiveAuthResponse(authResponse: AuthResponse)
}

public class AuthResponse: NSObject {
    public let code: ErrCode, authCode: String?, state: String?
    
    init(_ code: ErrCode, authCode: String? = nil, state: String? = nil) {
        self.code = code
        self.authCode = authCode
        self.state = state
    }
    
    override public var description: String {
        return "\(code.description)  \(String(describing: authCode))  \(String(describing: state)) "
    }
}

@objc public enum ErrCode: Int {
    case ok, networkErr, cancel
    public var description: String {
        switch self {
        case .ok: return "OK"
        case .networkErr: return "Network error"
        case .cancel: return "Cancelled"
        }
    }
}
