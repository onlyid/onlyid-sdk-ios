//
//  ViewController.swift
//  OnlyID
//
//  Created by sjq2150@gmail.com on 06/20/2020.
//  Copyright (c) 2020 sjq2150@gmail.com. All rights reserved.
//

import UIKit
import OnlyID

let TAG = "OnlyID"
let clientId = "73c6cce568d34a25ac426a26a1ca0c1e"
let secretId = "36c820ba83bb4944a0744208066e8bbf"

class ViewController: UITableViewController {
    
    let cellId = "onlyid_demo_cell"
    let api = API()
    var userInfos: [[String: String]] = [["key":"tips", "value":"please tap Login button to get user info"]]
    @IBOutlet weak var themeSegment: UISegmentedControl!
    @IBOutlet weak var viewSegment: UISegmentedControl!
    @IBOutlet weak var stateTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        prepareUI()
    }
    
    func prepareUI() {
        let loginItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(onLogin))
        navigationItem.rightBarButtonItem = loginItem
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    }
    
    //MARK: event actions
    @objc func onLogin() {
        oauth()
    }
    
    func oauth() {
        let theme = themeSegment.selectedSegmentIndex == 1 ? "dark" : nil
        let view = viewSegment.selectedSegmentIndex == 1 ? "zoomed" : nil
        let state = (stateTextField.text != nil) ? (stateTextField.text!.count > 0 ? stateTextField.text : nil) : nil
        debugPrint("[\(TAG)] input info: \(String(describing: theme)), \(String(describing: view)), \(String(describing: state))")
        
        let config = OnlyIDOAuthConfig(clientId: clientId, view: view, theme: theme, state: state)
        OnlyID.oauth(config: config, fromController: self, delegate: self)
    }
    
    //MARK: tableview datasource and delegate
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userInfos.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: cellId)
        if (cell == nil) {
            cell = UITableViewCell(style: .default, reuseIdentifier: cellId)
        }
        
        let userInfo = userInfos[indexPath.row]
        let text = String(format: "%@: %@", userInfo["key"]!, userInfo["value"]!)
        cell?.textLabel?.text = text
        
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
    }

}

extension ViewController: OnlyIDOAuthDelegate {
    func onComplete(code: String, state: String?) {
        
        debugPrint("[\(TAG)]onComplete: \(code), \(String(describing: state))")
        if !code.isEmpty {
            api.fetchUserInfo(code: code) { (jsonData) in
                self.userInfos.removeAll()
                for (key, value) in jsonData {
                    self.userInfos.append(["key":key, "value": "\(value)"])
                }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
    }
    
    func onError(error: NSError) {
        debugPrint("[\(TAG)]onError: \(error)")
    }
    
    func onCancel() {
        debugPrint("[\(TAG)]onCancel")
    }

}


/// 网络接口
class API {
    // OnlyID api host
    let apiHost = "https://www.onlyid.net/"
    // 获取accessToken的api
    let tokenAPI = "/api/oauth/access-token"
    // 获取活用信息的api
    let userInfoAPI = "/api/open/user-info"
    
    /// 获取用户信息
    /// 生产环境使用时，获取用户信息建议在服务端进行，以防泄露你的client secret
    /// - Parameters:
    ///   - code: 登录成功码
    ///   - onSuccess: 成功回调
    func fetchUserInfo(code: String, onSuccess: @escaping (([String: Any]) -> Void)) {
        fetchAcessToken(code: code) { (token) in
            self.fetchUserInfo(token: token, onSuccess: onSuccess)
        }
    }
    
    /// 获取用户信息
    /// - Parameters:
    ///   - token: access token
    ///   - onSuccess: 成功回调
    func fetchUserInfo(token: String, onSuccess: @escaping (([String: Any]) -> Void)) {
        let tokenURLString = apiHost + userInfoAPI
        if let url = URL(string: tokenURLString) {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            request.addValue(token, forHTTPHeaderField: "Authorization")
            let task = URLSession.shared.dataTask(with: request) { (data, resonse, error) in
                if let d = data {
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed)
                        if let json = jsonData as? [String: Any] {
                            debugPrint("[\(TAG)] jsonData: \(json)")
                            onSuccess(json)
                        }
                    }catch let e {
                        debugPrint("[\(TAG)] convert json data failed: \(e)")
                    }
                }
            }
            task.resume()
        }
    }
    
    /// 获取access token
    /// - Parameters:
    ///   - code: 登录成功码
    ///   - onSuccess: 成功回调
    func fetchAcessToken(code: String, onSuccess: @escaping ((String) -> Void)) {
        let tokenURLString = apiHost + tokenAPI
        if let url = URL(string: tokenURLString) {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            let params = ["clientSecret": secretId, "authorizationCode": code]
            request.httpBody = try? JSONSerialization.data(withJSONObject: params, options: [])
            request.addValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { (data, resonse, error) in
                if let d = data {
                    do {
                        let jsonData = try JSONSerialization.jsonObject(with: d, options: .fragmentsAllowed)
                        if let json = jsonData as? [String: Any] {
                            debugPrint("[\(TAG)] jsonData: \(json)")
                            if let token = json["accessToken"] as? String {
                                
                                onSuccess(token)
                            }
                        }
                    }catch let e {
                        debugPrint("[\(TAG)] convert json data failed: \(e)")
                    }
                }
            }
            task.resume()
        }
    }
    
}
