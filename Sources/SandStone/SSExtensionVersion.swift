//
//  SSSirenVersion.swift
//  Siren
//
//  Created by Kyle on 2019/10/5.
//  Copyright © 2019 Sabintsev iOS Projects. All rights reserved.
//

import UIKit


public enum VersionOptionType {
    /// Forces the user to update your app (1 button alert).
    case force
    /// Presents the user with option to update app now or at next launch (2 button alert).
    case option
    /// Presents the user with option to update the app now, at next launch, or to skip this version all together (3 button alert).
    case skip
    /// Doesn't present the alert.
    /// Use this option if you would like to present a custom alert to the end-user.
    case none
}


public struct SSExtensionVersion {
    
    public var des : String?
    public var version : String
    public var versionType : VersionOptionType
    public var updateUrl : String?
}
