//
//  ViewController.swift
//  onlyID_SDK
//
//  Created by 梁庭宾 on 2017/9/15.
//  Copyright © 2017年 onlyID. All rights reserved.
//

import UIKit
import WebKit

class AuthViewController: UIViewController, WKNavigationDelegate {
    static let myUrl = "https://oauth.onlyid.net:1984/"
    static let redirectUri = myUrl + "default_redirect_uri"
    var delegate: AuthDelegate!, clientId: String!, state: String!
    var progressView = UIProgressView(progressViewStyle: .default)
    var webView: WKWebView!
    var authResponse: AuthResponse!
    
    init(clientId: String, state: String, delegate: AuthDelegate) {
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.clientId = clientId
        self.state = state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // 不延伸到navigation bar
        edgesForExtendedLayout = .bottom

        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "返回", style: .done, target: self, action: #selector(AuthViewController.cancel))
        var frame = progressView.frame
        progressView.frame = CGRect(x: 0, y: 44 - frame.height, width: view.frame.width, height: frame.height)
        navigationController?.navigationBar.addSubview(progressView)
        
        let webConfiguration = WKWebViewConfiguration()
        frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 64)
        webView = WKWebView(frame: frame, configuration: webConfiguration)
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        view.addSubview(webView)

        let authorizeUrl = AuthViewController.myUrl + "authorize?response_type=code&client_id=" + clientId + "&state=" + state + "&redirect_uri=" + AuthViewController.redirectUri
        let url = URL(string: authorizeUrl)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    func cancel(button: UIBarButtonItem) {
        authResponse = AuthResponse(.cancel)
        dismiss(animated: true, completion: didDismiss)
    }
    
    public func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
//        print("didReceiveServerRedirectForProvisionalNavigation; \(navigation)")
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
//        print("decidePolicyFor navigationResponse; allow \(navigationResponse)")
    }
    
    public func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        print("decidePolicyFor navigationAction; allow \(navigationAction)")
        decisionHandler(.allow)
        // 如果要回调redirect uri了 返回成功
        if let url = navigationAction.request.url, url.absoluteString.hasPrefix(AuthViewController.redirectUri) {
            let dict = convertQuery2Dict(query: url.query!)
            print(dict)
            authResponse = AuthResponse(.OK, authCode: dict["code"], state: dict["state"])
            dismiss(animated: true, completion: didDismiss)
        }
    }
    
    func convertQuery2Dict(query: String) -> [String:String] {
        var dict = [String:String]()
        for s in query.components(separatedBy: "&") {
            var ss = s.components(separatedBy: "=")
            dict[ss[0]] = ss[1]
        }
        return dict
    }
    
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        progressView.isHidden = false
//        print("didStartProvisionalNavigation; \(navigation)")
    }
    
    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
//        print("didCommit; \(navigation)")
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("didFinish; \(navigation)")
        progressView.isHidden = true
        progressView.progress = 0
    }
    
    public func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        print("didFail; \(navigation) \(error)")
        authResponse = AuthResponse(.networkErr)
        dismiss(animated: true, completion: didDismiss)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        print("didFailProvisionalNavigation; \(navigation) \(error)")
        authResponse = AuthResponse(.networkErr)
        dismiss(animated: true, completion: didDismiss)
    }

    func didDismiss() {
        delegate.didReceiveAuthResponse(authResponse: authResponse)
        webView.removeObserver(self, forKeyPath: "estimatedProgress")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
