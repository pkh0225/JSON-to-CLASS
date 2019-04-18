//
//  PropertyModelData.swift
//  JsonToClass
//
//  Created by pkh on 17/04/2019.
//  Copyright © 2019 pkh. All rights reserved.
//

import Foundation

let ARRAY_INNER_CLASS_TAIL_PIX = "Item"


func numberType(_ value: Any?) -> Any? {
    if let number = value as? NSNumber {
        switch CFNumberGetType(number) {
        case .charType: //Bool
            return value as! Bool
        case .sInt8Type, .sInt16Type, .sInt32Type, .sInt64Type, .shortType, .intType, .longType, .longLongType, .cfIndexType, .nsIntegerType: //Int
            return value as! Int
        case .float32Type, .float64Type, .floatType, .doubleType, .cgFloatType: //Double
            return value as! CGFloat
        default:
            return value
        }
    }
    return value
}

class PropertyModelData {
    var value: Any?
    var key = ""
    var perfix = ""
    
    init(key: String, object: Any?, perfix: String) {
        setKey(key, object: object, perfix: perfix)
    }
    
    func setKey(_ key: String, object: Any?, perfix: String) {
        self.key = key
        self.value = object
        self.perfix = perfix
    }
    
    func getStringObjectC() -> String {
        
        var directive = "strong"
        var className: String = ""
        var keyName = "*\(key)"
        
        if numberType(value) is Int {
            directive = "assign"
            keyName = key
            className = "NSInteger"
        }
        else if numberType(value) is CGFloat {
            directive = "assign"
            keyName = key
            className = "CGFloat"
        }
        else if numberType(value) is Bool {
            directive = "assign"
            keyName = key
            className = "BOOL"
        }
        else if value is String {
            className = "NSString"
        }
        else if let obj = value as? [Any] {
            if (obj.first is String) {
                className = "NSMutableArray<NSString*>"
            } else {
                className = "NSMutableArray<\(perfix)\(key.capitalizedFirst())\(ARRAY_INNER_CLASS_TAIL_PIX)*>"
            }
        }
        else if value is [String : Any] {
            className = "\(perfix)\(key.capitalizedFirst())"
        }
        else  {
            className = "unknow"
        }
        
        return "\n@property (nonatomic, \(directive)) \(className) \(keyName);"
        
    }
    
    func getStringSwif() -> String {
        
        if numberType(value) is Int {
            return "\n    var \(key): Int = 0"
        }
        else if numberType(value) is CGFloat {
            return "\n    var \(key): CGFloat = 0.0"
        }
        else if numberType(value) is Bool {
            return "\n    var \(key): Bool = false"
        }
        else if numberType(value) is String {
            return "\n    var \(key): String = \"\""
        }
        else if let obj = value as? [Any] {
            if (obj.first is String) {
                return "\n    var \(key) = [String]()"
            } else {
                return "\n    var \(key) = [\(perfix)\(key.capitalizedFirst())\(ARRAY_INNER_CLASS_TAIL_PIX)]()"
            }
        }
        else if value is [String : Any] {
            return "\n    var \(key): \(perfix)\(key.capitalizedFirst())?"
        }
        else {
            return "\n    var \(key): unknow??"
        }
    }
    

    func isImportClass() -> String? {
        var className: String? = nil
        
        if let obj = value as? [Any], obj.count > 0 {
            let item = obj.first as? NSObject
            if item is [String : Any] {
                className = "\n#import \"\(perfix)\(key.capitalizedFirst())\(ARRAY_INNER_CLASS_TAIL_PIX).h\""
            }
        } else if (value is [String : Any]) {
            className = "\n#import \"\(perfix)\(key.capitalizedFirst()).h\""
        }
        
        return className
    }

}
