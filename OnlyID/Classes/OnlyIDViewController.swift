//
//  OnlyIDViewController.swift
//  OnlyID
//
//  Created by Jarvis on 2020/6/20.
//

import UIKit
import WebKit

@objc
public protocol OnlyIDOAuthDelegate: NSObjectProtocol {
    @objc func onComplete(code: String, state: String?)
    @objc func onError(error: NSError)
    @objc func onCancel()
}

public enum OnlyIDMethod: String {
    case setTitle = "setTitle"
    case onCode = "onCode"
}

public enum OnlyIDError: String {
    case noNetwork = "网络错误，请检查"
    case unknown = "Unknown Error"
}

class OnlyIDViewController: UIViewController {

    let TAG: String = "OnlyID";
    let MY_URL: String = "https://www.onlyid.net/oauth";
    
    let webview: WKWebView = WKWebView();
    
    var config: OnlyIDOAuthConfig?
    var delegate: OnlyIDOAuthDelegate?
    
    convenience init(config: OnlyIDOAuthConfig, delegate: OnlyIDOAuthDelegate?) {
        self.init()
        
        self.config = config
        self.delegate = delegate
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        prepareUI()
        configWebView()
    }
    
    private func prepareUI() {
        view.backgroundColor = UIColor.white
        
        if let bundleUrl = Bundle(for: OnlyID.self).url(forResource: "OnlyID", withExtension: "bundle"), let bundle = Bundle(url: bundleUrl) {
            let backIcon = UIImage(named: "icon_back.png", in: bundle, compatibleWith: nil)
            let closeIcon = UIImage(named: "icon_close.png", in: bundle, compatibleWith: nil)
            let backItem = UIBarButtonItem(image: backIcon, style: .plain, target: self, action: #selector(onBack))
            let closeItem = UIBarButtonItem(image: closeIcon, style: .plain, target: self, action: #selector(onClose))
            navigationItem.leftBarButtonItem = backItem
            navigationItem.rightBarButtonItem = closeItem
        }
        
        view.addSubview(webview)
        webview.frame = view.frame
    }
    
    private func configWebView() {
        guard let _config = config else {
            webview.loadHTMLString("Not found oauth config, please check your code.", baseURL: nil)
            return
        }
        
        webview.configuration.userContentController.add(self, name: "ios")
        
        var urlString = MY_URL
        if let clientId = _config.clientId {
            urlString += "?client-id=\(clientId)"
        }
        
        if let boundleId = Bundle.main.bundleIdentifier {
            urlString += "&bundle-id=\(boundleId)"
        }
        
        if let theme = _config.theme {
            urlString += "&theme=\(theme)"
        }
        
        if let view = _config.view {
            urlString += "&view=\(view)"
        }
        
        if let state = _config.state {
            urlString += "&state=\(state)"
        }
        
        if let url = URL(string: urlString) {
            debugPrint("[\(TAG)] request url: \(url)")
            let request = URLRequest(url: url)
            webview.load(request)
        }
    }

    //MARK: event actions
    @objc private func onBack() {
        if webview.canGoBack {
            webview.goBack()
        } else {
            onClose()
        }
    }
    
    @objc private func onClose() {
        dismiss(animated: true) {
            if let d = self.delegate {
                d.onCancel()
            }
        }
    }
}

//MARK: WKNavigationDelegate
extension OnlyIDViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        debugPrint("[\(TAG)] webView didFail: \(error)")
        if let d = self.delegate {
            let error = NSError(domain: MY_URL, code: 1, userInfo: ["message": OnlyIDError.noNetwork])
            d.onError(error: error)
        }
    }
}

//MARK: WKUIDelegate
extension OnlyIDViewController: WKUIDelegate {
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        debugPrint("[\(TAG)] runJavaScriptAlertPanelWithMessage")
    }
}

//MARK: WKScriptMessageHandler
extension OnlyIDViewController: WKScriptMessageHandler {
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else {
            debugPrint("[\(TAG)] Message body is empty: \(message)")
            return
        }
        debugPrint("[\(TAG)] Message body: \(body)")
        
        if let method = body["method"] as? String {
            dispatch(method, arguments: body["data"] as? [String: Any])
        }
    }
    
    private func dispatch(_ method: String, arguments: [String: Any]?) {
        if method == OnlyIDMethod.setTitle.rawValue {
            if let args = arguments, let newTitle = args["title"] as? String {
                self.title = newTitle
            }
        } else if method == OnlyIDMethod.onCode.rawValue {
            debugPrint("[\(TAG)] onCode: \(String(describing: arguments))")
            if let args = arguments, let code = args["code"] as? String {
                if let d = delegate {
                    d.onComplete(code: code, state: args["state"] as? String)
                }
            }
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
}
