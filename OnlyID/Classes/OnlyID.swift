//
//  OnlyID.swift
//  OnlyID
//
//  Created by Jarvis on 2020/6/20.
//

import UIKit

/// OnlyID SDK主入口，https://www.onlyid.net/home
@objc public class OnlyID: NSObject {
    /// 发送oauth请求，弹出授权窗口
    /// - Parameters:
    ///   - config: 配置信息
    ///   - fromController: present依赖的ViewController，默认使用keyWindow的rootViewController
    ///   - delegate: 协议代理
    @objc public static func oauth(config: OnlyIDOAuthConfig, fromController: UIViewController?=nil, delegate: OnlyIDOAuthDelegate?) {
        var controller = fromController
        if (fromController == nil) {
            controller = UIApplication.shared.keyWindow?.rootViewController
        }
        let oauthVC = OnlyIDViewController(config: config, delegate: delegate)
        let navVC = UINavigationController(rootViewController: oauthVC)
        navVC.modalPresentationStyle = .fullScreen
        controller?.present(navVC, animated: true, completion: nil)
    }
}


/// OnlyID信息配置类
@objc public class OnlyIDOAuthConfig: NSObject {
    /// 注册app时生成的appid，你可以在OAuth设置中找到
    @objc public var clientId: String?
    /// 主题，默认为nil，设置dark为夜间模式
    @objc public var theme: String?
    /// 视图大小，默认nil，设置zoomed为放大模式
    @objc public var view: String?
    /// 透传信息，onComplete时回传
    @objc public var state: String?
    
    override init() {
        super.init()
    }
    
    @objc public convenience init(clientId: String, view: String?=nil, theme: String?=nil, state: String?=nil) {
        self.init()
        
        self.clientId = clientId
        self.view = view
        self.theme = theme
        self.state = state
    }
    
}

