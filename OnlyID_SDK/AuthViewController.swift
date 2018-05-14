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
    static let myUrl = "https://oauth.onlyid.net/"
    static let redirectUri = myUrl + "default_redirect_uri"
    static let clientUrl = myUrl + "clients"
    static let tokenUrl = myUrl + "token"
    var delegate: AuthDelegate!, clientId: String, state: String, clientSecret: String?
    var progressView = UIProgressView(progressViewStyle: .default)
    var webView: WKWebView!
    var authResponse: AuthResponse!
    var themeDark = false
    var viewZoomed = false
    
    private static let  darkThemeColor = UIColor(red:0.29, green:0.31, blue:0.27, alpha:1.0)
    
    init(clientId: String,clientSecret: String?, state: String, delegate: AuthDelegate) {
        self.clientId = clientId
        self.state = state
        
        super.init(nibName: nil, bundle: nil)
        self.delegate = delegate
        self.clientSecret = clientSecret
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("call init(clientId: String,clientSecret: String?, state: String, delegate: AuthDelegate)")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 不延伸到navigation bar
        edgesForExtendedLayout = .bottom
        
        navigationItem.leftBarButtonItem = UIBarButtonItem.init(title: "返回", style: .done, target: self, action: #selector(AuthViewController.cancel))
        var frame = progressView.frame
        progressView.frame = CGRect(x: 0, y: 44 - frame.height, width: view.frame.width, height: frame.height)
        navigationController?.navigationBar.addSubview(progressView)
        
        
        frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.height - 64)
        
        let webConfiguration = WKWebViewConfiguration()
//        webView = WKWebView(frame: CGRect.zero, configuration: webConfiguration)
        webView = WKWebView(frame: frame, configuration: webConfiguration)
        webView.frame = frame
        webView.navigationDelegate = self
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)
        view.addSubview(webView)

        var queryString = [String: String]()
        queryString["theme_dark"] = String(themeDark)
        queryString["view_zoomed"] = String(viewZoomed)
        queryString["response_type"] = "code"
        queryString["client_id"] = clientId
        queryString["state"] = state
        queryString["redirect_uri"] = AuthViewController.redirectUri
        let authorizeUrl = AuthViewController.myUrl + "authorize?" + queryString.toHttpParams()
        print(authorizeUrl)
        let url = URL(string: authorizeUrl)
        let request = URLRequest(url: url!)
        webView.load(request)
        if themeDark {
            webView.backgroundColor = AuthViewController.darkThemeColor
            webView.scrollView.backgroundColor = AuthViewController.darkThemeColor
        }
    }

    private func requestAccessToken(authResponse: AuthResponse) {
        if let clientSecret = clientSecret {
            let url = URL(string: AuthViewController.tokenUrl)
            var request = URLRequest(url: url!)
            let code = authResponse.authCode ?? ""
            var body = [String: String]()
            body["client_id"] = clientId
            body["client_secret"] = clientSecret
            body["redirect_uri"] = AuthViewController.redirectUri
            body["grant_type"] = "authorization_code"
            body["code"] = code
            let params = body.toHttpParams().data(using: .utf8)
            request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
            request.httpMethod = "POST"
            request.httpBody = params
            let task = URLSession.shared.dataTask(with: request) { [weak self]  (data, response, error) in
                if error != nil {
                    self?.authResponse = AuthResponse(.networkErr )
                }else if let data = data,
                    let ret = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any],
                    let ret2 = ret {
                    if let accessToken = ret2["access_token"] as? String {
                        self?.authResponse = AuthResponse(.ok, accessToken: accessToken, state: authResponse.state )
                    } else {
                        self?.authResponse = AuthResponse(.authFail )
                    }
                }else { // Impossible here
                    self?.authResponse = AuthResponse(.otherErr)
                }
                self?.dismiss(animated: true, completion: self?.didDismiss)
            }
            task.resume()
        }
    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if (keyPath == "estimatedProgress") {
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        }
    }
    
    @objc func cancel(button: UIBarButtonItem) {
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
            authResponse = AuthResponse(.ok, authCode: dict["code"], state: dict["state"])
            if clientSecret != nil { // One more step: get access token
                requestAccessToken(authResponse: authResponse)
                return
            }
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
