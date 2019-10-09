//
//  ExampleExtensionInfo.swift
//  Example
//
//  Created by Kyle on 2019/10/7.
//  Copyright © 2019 Sabintsev iOS Projects. All rights reserved.
//

import Siren
import UIKit

class ExampleExtensionInfo: SSExtensionInfo {
    
    override init() {
        super.init()
        self.needVersionInfo = true
        self.needCustomPopup = true
    }
    
    override func downloadExtensionInfo(success: (SSExtensionVersion?) -> Void) {
        
    }
    
    func downloadExtensionInfo() {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        let url = URL(string: String(format: "https://api.mijwed.com:8080/mijwed/app/version?phone_os=ios&app_version=%@", version!))

        let request = URLRequest(url: url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: 30)
        URLSession.shared.dataTask(with: request) { data, response, error in
            URLCache.shared.removeCachedResponse(for: request)
            self.processVersionCheckResults(withData: data, response: response, error: error)
        }.resume()
    }

    private func processVersionCheckResults(withData data: Data?,
                                            response: URLResponse?,
                                            error: Error?) {
        if let error = error {
        
        } else {
            guard let data = data else {
                return
            }
            do {
                let apiModel = try JSONSerialization.jsonObject(with: data as Data, options: .mutableContainers) as AnyObject
                
            } catch {
               
            }
        }
    }
}
