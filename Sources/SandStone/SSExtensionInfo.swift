//
//  SSInfoExtension.swift
//  Siren
//
//  Created by Kyle on 2019/10/5.
//  Copyright © 2019 Sabintsev iOS Projects. All rights reserved.
//

import UIKit

public protocol SSExtensionInfoDelegate:NSObjectProtocol {

}

open class SSExtensionInfo : NSObject {
    
    public var needVersionInfo = true
    public var needCustomPopup = true
    
    public weak var delegate :SSExtensionInfoDelegate?

    public var storeModel : Model? {
        didSet {
            self.infoAllPrepare()
        }
    }
    
    public var extensionInfo : SSExtensionVersion? {
        didSet {
            self.infoAllPrepare()
        }
    }
    
    public override init() {
        super.init()
    }
    
    public func prepareInfo() {
        if (self.needVersionInfo) {
            self.downloadExtensionInfo {[weak self] (value) in
                guard let v = value else {
                    return
                }
                self?.extensionInfo = v
            }
        }
    }
    
    open func infoAllPrepare() {
        guard let model = storeModel, let info = extensionInfo else {
            return
        }
    }
    
    open func downloadExtensionInfo(success:(SSExtensionVersion?) -> Void) {
        fatalError("\(#function) should be override ")
    }

}
