//
//  ViewController.swift
//  OnlyID_SDK
//
//  Created by 梁庭宾 on 2017/9/15.
//  Copyright © 2017年 OnlyID. All rights reserved.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate, WKScriptMessageHandler {
    static let authUrl = "https://m.my.onlyid.net/#/auth"
    static let themeDarkColor = UIColor(red:0.87, green:0.87, blue:0.87, alpha:1.0)
    let delegate: AuthDelegate, clientId: String
    let state: String, themeDark: Bool, viewZoomed: Bool, scene: String
    let progressView = UIProgressView(progressViewStyle: .bar)
    var webView: WKWebView!
    
    init(clientId: String, delegate: AuthDelegate, state: String, themeDark: Bool, viewZoomed: Bool, scene: String) {
        self.clientId = clientId
        self.delegate = delegate
        self.state = state
        self.themeDark = themeDark
        self.viewZoomed = viewZoomed
        self.scene = scene
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("do not use this initializer")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        switch scene {
        case "login":
            title = "登录"
        case "bind":
            title = "绑定手机号"
        case "change":
            title = "更换手机号"
        default:
            title = "验证手机号"
        }
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "返回", style: .done, target: self, action: #selector(AuthViewController.cancel))
        view.backgroundColor = UIColor.black
        
        var frame = progressView.frame
        progressView.frame = CGRect(x: 0, y: 64, width: view.frame.width, height: frame.height)
        view.addSubview(progressView)
        
        frame = CGRect(x: 0, y: 64, width: view.frame.width, height: view.frame.height - 64)
        let contentController = WKUserContentController()
        contentController.add(self, name: "iOS")
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = contentController
        webView = WKWebView(frame: frame, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        if themeDark {
            webView.backgroundColor = AuthViewController.themeDarkColor
        }
        view.addSubview(webView)
        view.bringSubview(toFront: progressView)

        let url = URL(string: AuthViewController.authUrl + "/" + clientId + "/" + state + "/ios/" + String(themeDark) + "/" + String(viewZoomed) + "/" + scene)!
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let body = message.body as! [String: Any]
        let code = body["code"] as? String
        let state = body["state"] as? String
        delegate.didReceiveAuthResp(errCode: .ok, code: code, state: state == "empty" ? nil : state)
        dismiss(animated: true, completion: nil)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    @objc func cancel(button: UIBarButtonItem) {
        delegate.didReceiveAuthResp(errCode: .cancel, code: nil, state: nil)
        dismiss(animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        progressView.isHidden = true
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        delegate.didReceiveAuthResp(errCode: .networkErr, code: nil, state: nil)
        dismiss(animated: true, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
}
