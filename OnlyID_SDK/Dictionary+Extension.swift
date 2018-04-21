//
//  Dictionary+Extension.swift
//  OnlyID_SDK
//
//  Created by Alex on 2018/4/21.
//  Copyright © 2018年 onlyID. All rights reserved.
//

import Foundation

extension Dictionary where Key == String, Value == String {
    func toHttpParams() -> String {
        var arr: [String] = []
        for (k, v) in self {
            arr.append("\(k)=\(v)")
        }
        return arr.joined(separator: "&")
    }
}
