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
    
    static func getTheme(_ clientId: String, callback: @escaping (Bool) -> Void ) {
        let url = URL(string: AuthViewController.clientUrl + "/" + clientId)
        let task = URLSession.shared.dataTask(with: url!) {  (data, response, error) in
            var themeDark = false
            if let data = data,
                let ret = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                let ret2 = ret,
                let client = ret2["client"] as? [String: Any],
                let isThemeDark = client["themeDark"] as? Bool {
                    themeDark = isThemeDark
            }
            callback(themeDark)
        }
        task.resume()
    }
    
    static public func auth(_ clientId: String, clientSecret: String? = nil, state: String = defaultState, delegate: AuthDelegate) {
        let viewController = AuthViewController(clientId: clientId, clientSecret: clientSecret, state: state, delegate: delegate)
        
        let navigationController = UINavigationController(rootViewController: viewController)
        
        guard let window = UIApplication.shared.keyWindow, let rootViewController = window.rootViewController else {
            fatalError("keyWindow或rootViewController为nil")
        }
        getTheme(clientId) { themeDark in
            viewController.themeDark = themeDark
            if let currentViewController = rootViewController.presentedViewController {
                currentViewController.present(navigationController, animated: true, completion: nil)
            }
            else {
                rootViewController.present(navigationController, animated: true, completion: nil)
            }
        }
    }
    
}

@objc public protocol AuthDelegate {
    func didReceiveAuthResponse(authResponse: AuthResponse)
}

public class AuthResponse: NSObject {
    public let code: ErrCode, authCode: String?, state: String?, accessToken: String?
    // TODO: An error message is needed??
    init(_ code: ErrCode, authCode: String? = nil, accessToken: String? = nil, state: String? = nil) {
        self.code = code
        self.authCode = authCode
        self.state = state
        self.accessToken = accessToken
    }
    
    override public var description: String {
        return "\(code.description)  \(String(describing: authCode)) \(String(describing: accessToken))  \(String(describing: state)) "
    }
}

@objc public enum ErrCode: Int {
    case ok, networkErr, cancel, serverError, authFail
    public var description: String {
        switch self {
        case .ok: return "OK"
        case .networkErr: return "Network error"
        case .cancel: return "Cancelled"
        case .serverError: return "Server error"
        case .authFail: return "Authorization failed"
        }
    }
}
