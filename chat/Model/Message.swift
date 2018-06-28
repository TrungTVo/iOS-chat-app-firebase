//
//  Message.swift
//  chat
//
//  Created by Trung Vo on 6/27/18.
//  Copyright © 2018 Trung Vo. All rights reserved.
//

import UIKit
import Firebase

class Message: NSObject {
    var fromId: String?
    var timestamp: NSNumber?
    var text: String?
    var toId: String?
    
    func chatPartnerId() -> String? {
        if self.fromId == Auth.auth().currentUser?.uid {
            return toId
        } else {
            return fromId
        }
    }
}
