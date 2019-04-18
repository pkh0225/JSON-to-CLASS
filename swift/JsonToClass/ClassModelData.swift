//
//  ClassModelData.swift
//  JsonToClass
//
//  Created by pkh on 17/04/2019.
//  Copyright © 2019 pkh. All rights reserved.
//

import Foundation

let DATE_FORMAT = "yyyy. MM. dd.."

class ClassModelData {
    var name = ""
    var parentName = ""
    var perfix = ""
    var propertyList: [PropertyModelData] = []
    
    init(dic: [String : Any], className: String, parentName: String, perfix: String) {
        self.perfix = perfix.capitalizedFirst()
        name = "\(self.perfix)\(className.capitalizedFirst())"
        self.parentName = parentName.capitalizedFirst()
        setPropertyList(dic)
    }
    
    func setPropertyList(_ dic: [String : Any]) {
        propertyList.removeAll()
        for key in dic.keys {
            let propertyModelData = PropertyModelData(key: key, object: dic[key], perfix: perfix)
            propertyList.append(propertyModelData)
        }
    }
    
    func getStringObjectCHeader() -> String {
        var result = ""
        var propertyResult = ""
        
        for propertyModelData in propertyList {
            propertyResult += propertyModelData.getStringObjectC()
        }
        
        result += makeClassAnnotate()
        result += getImportHeaderFiles()
        result += getClassStart()
        result += propertyResult
        result += getFunctionObjectCHeader()
        result += getClassEnd()
        
        return result
        
    }
    
    func getStringObjectCImplementation() -> String {
        var result = ""
        
        result += makeImplementationAnnotate()
        result += getImplementationStart()
        result += makeImplementationAllocWithDictionary()
        result += makeImplementationInitWithDictionary()
        result += makeImplementationSetSerialize()
        result += makeImplementationDescription()
        result += getImplementationEnd()
        
        return result

    }
    
    func getStringSwift() -> String {
        var result = ""
        var propertyResult = ""
        
        for propertyModelData in propertyList {
            propertyResult += propertyModelData.getStringSwif()
        }
        
        result += makeClassAnnotateSwift()
        result += getImportHeaderFilesSwift()
        result += getClassStartSwift()
        result += propertyResult
        result += makeImpInitFunctionSwift()
        result += makeSetSerializeSwift()
        result += getClassEndSwift()
        
        result += makeDescriptionSwift()
        
        return result

    }
    
    func makeClassAnnotate() -> String {
        let format = DateFormatter()
        format.dateFormat = DATE_FORMAT
        let dateString = format.string(from: Date())
        let str = "/*\n    JsonToClass pkh\n    \(name).h\n\n    Created by \(NSUserName()) on \(dateString)\n*/\n"
        return str
        
    }
    
    func makeClassAnnotateSwift() -> String {
        let format = DateFormatter()
        format.dateFormat = DATE_FORMAT
        let dateString = format.string(from: Date())
        let str = "/*\n    JsonToClass pkh\n    \(name).swift\n\n    Created by \(NSUserName()) on \(dateString)\n*/\n"
        return str
    }
    
    func makeImplementationAnnotate() -> String {
        let format = DateFormatter()
        format.dateFormat = DATE_FORMAT
        let dateString = format.string(from: Date())
        let str = "/*\n    JsonToClass pkh\n    \(name).m\n\n    Created by \(NSUserName()) on \(dateString)\n*/\n"
        return str
    }
    
    func getImportHeaderFiles() -> String {
        var result = "\n#import <UIKit/UIKit.h>"
        
        if (parentName == "NSObject") == false {
            result += "\n#import \"\(parentName).h\""
        }
        
        for propertyModelData in propertyList {
            if let importName = propertyModelData.isImportClass() {
                result += importName
            }
        }
        
        return result
    }
    
    func getImportHeaderFilesSwift() -> String {
        return "\nimport UIKit\n"
    }
    
    func getClassStart() -> String {
        if parentName.isValid {
            return "\n\n@interface \(name) : \(parentName) \n"
        }
        else {
            return "\n\n@interface \(name) : NSObject \n"
        }
    }
    
    func getClassStartSwift() -> String {
        var result = ""
        
        if parentName.isValid {
            result += "\nclass \(name) : \(parentName) { \n"
        }
        else {
            result += "\nclass \(name) { \n"
        }
        
        return result
    }

    
    func getClassEnd() -> String {
        return "\n\n@end"
    }
    
    func getClassEndSwift() -> String {
        return "\n\n}"
    }
    
    func getFunctionObjectCHeader() -> String {
        return """
        
        
        + (id)allocWithDictionary:(NSDictionary *)dic;
        
        - (id)initWithDictionary:(NSDictionary *)dic;
        
        - (void)setSerialize:(NSDictionary *)dic;
        """
    }
    
    func getFunctionObjectCImplementation() -> String {
        return """
        
        + (id)allocWithDictionary:(NSDictionary *)dic;
        
        - (id)initWithDictionary:(NSDictionary *)dic;
        
        - (void)setSerialize:(NSDictionary *)dic;
        """
    }
    
    func getImplementationStart() -> String {
        return """
        
        
        #import "\(name).h"
        
        @implementation \(name)
        """
    }
    
    func getImplementationEnd() -> String {
        return "\n\n@end"
    }
    
    func makeImplementationAllocWithDictionary() -> String {
        return """
        
        
        + (id)allocWithDictionary:(NSDictionary *)dic {
            if (dic == nil || [dic isEqual:[NSNull null]] || [dic isKindOfClass:[NSDictionary class]] == NO || dic.count == 0) return nil;
            return [[\(name) alloc] initWithDictionary:dic];
        }
        """
    }
    func makeImpInitFunctionSwift() -> String {
        return """
        
        
            init(_ dic: [String: Any]?) {
                guard let dic = dic else { return }
                self.setSerialize(dic)
            }
        """
    }
    func makeImplementationInitWithDictionary() -> String {
        return """
        
        
        - (id)initWithDictionary:(NSDictionary *)dic {
            self = [super init];
            if(self) {
                [self setSerialize:dic];
            }
            return self;
        }
        """
    }
    func makeImplementationSetSerialize() -> String {
        return """
        
        
        - (void)setSerialize:(NSDictionary *)dic {
            if (dic == nil || [dic isEqual:[NSNull null]] || [dic isKindOfClass:[NSDictionary class]] == NO || dic.count == 0) return;
            \(makeImplementationParser())
        }
        """
    }
    func makeSetSerializeSwift() -> String {
        return """
        
        
            func setSerialize(_ dic: [String: Any]?) {
                guard let dic = dic, dic.count > 0 else { return }
                \(makeSetSerializeParserSwift())
            }
        """
    }
    
    func makeImplementationParser() -> String {
        var str = ""
        for propertyModelData in propertyList {
            guard let value = propertyModelData.value else { continue }
            let key = propertyModelData.key
            let subClassName = "\(perfix)\(key.capitalizedFirst())"
            let arraySubClassName = "\(perfix)\(key.capitalizedFirst())\(ARRAY_INNER_CLASS_TAIL_PIX)"
            
            if (numberType(value) is Int) {
                str += "\n    if (dic[@\"\(key)\"] != nil) self.\(key) = [dic[@\"\(key)\"] integerValue];"
            }
            else if (numberType(value) is CGFloat) {
                str += "\n    if (dic[@\"\(key)\"] != nil) self.\(key) = [dic[@\"\(key)\"] floatValue];"
            }
            else if (numberType(value) is Bool) {
                str += "\n    if (dic[@\"\(key)\"] != nil) self.\(key) = [dic[@\"\(key)\"] boolValue];"
            }
            else if (value is String) {
                str += "\n    if (dic[@\"\(key)\"] != nil) self.\(key) = dic[@\"\(key)\"];"
            }
            else if let array = value as? [Any], array.count > 0 {
                if array.first is [String : Any] {
                    str += """
                        
                        if ([dic[@\"\(key)\"] isKindOfClass:NSArray.class]) {
                            self.\(key) = [NSMutableArray<\(arraySubClassName)*> new];
                            for (NSDictionary *item  in dic[@"\(key)"]) {
                                [self.\(key) addObject:[\(arraySubClassName) allocWithDictionary:item]];
                            }
                        }
                    """
                }
                else {
                    str += "\n    if (dic[@\"\(key)\"] != nil) self.\(key) = dic[@\"\(key)\"];"
                }
            }
            else if (value is [AnyHashable : Any]) {
                str += "\n    if (dic[@\"\(key)\"] != nil) self.\(key) = [\(subClassName) allocWithDictionary:dic[@\"\(key)\"]];"
            }
            else {
                str += "\n    if (dic[@\"\(key)\"] != nil) self.\(key) =  \(String(describing: value)); //type error \(String(describing: value))"
            }
        }
        
        return str
    }
        
    func makeSetSerializeParserSwift() -> String {
        var str = ""
        for propertyModelData in propertyList {
            guard let value = propertyModelData.value else { continue }
            let key = propertyModelData.key
            let subClassName = "\(perfix)\(key.capitalizedFirst())"
            let arraySubClassName = "\(perfix)\(key.capitalizedFirst())\(ARRAY_INNER_CLASS_TAIL_PIX)"
            
            if numberType(value) is Int {
                str += "\n        if let data = dic[\"\(key)\"] as? Int { self.\(key) = data }"
            }
            else if numberType(value) is CGFloat {
                str += "\n        if let data = dic[\"\(key)\"] as? CGFloat { self.\(key) = data }"
            }
            else if numberType(value) is Bool {
                str += "\n        if let data = dic[\"\(key)\"] as? Bool { self.\(key) = data }"
            }
            else if value is String {
                str += "\n        if let data = dic[\"\(key)\"] as? String { self.\(key) = data }"
            }
            else if let array = value as? [Any], array.count > 0 {
                if array.first is [String : Any] {
                    str += """
                    
                            if let data = dic[\"\(key)\"] as? [[String: Any]] { self.\(key) = data.compactMap{ \(arraySubClassName)($0) } }
                    """
                }
                else if array.first is String {
                    str += "\n        if let data = dic[\"\(key)\"] as? [String] { self.\(key) = data }"
                }
                else {
                    str += "\n        if let data = dic[\"\(key)\"] as? [Any] { self.\(key) = data }"
                }
            }
            else if value is [String : Any] {
                str += "\n        if let data = dic[\"\(key)\"] as? [String: Any] { self.\(key) = \(subClassName)(data) }"
            } else {
                str += "\n        self.\(key) =  \(String(describing: value)); //type error \(String(describing: value))"
            }
        }
        return str
    }
    
    func makeImplementationDescription() -> String {
        return ""
    }
    
    func makeDescriptionSwift() -> String {
        
        var result = """
        
        extension \(name) : CustomStringConvertible {
            var description: String {
                return getDescription()
            }
        
            func getDescription(_ tapCount: UInt = 0, _ isArray: Bool = false) -> String {
                var tap = ""
                for _ in 0...tapCount { tap += "\\t" }
                var str: String = (tapCount == 0) ? "\\n\\n" : "\\n"
                if isArray {
                    str = \"--- ⬇️ \\(String(describing: type(of: self))) ⬇️ ---"
                }
                else {
                    str += \"\\(tap)==== *🎃* \\(String(describing: type(of: self))) *🎃* ===="
                }
        """
        
        for propertyModelData in propertyList {
            let key = propertyModelData.key
            let value = propertyModelData.value
            let subClassName = "\(perfix)\(key.capitalizedFirst())"
//            var arraySubClassName = "\(perfix)\(key.capitalizedFirst())\(ARRAY_INNER_CLASS_TAIL_PIX)"
            
            if value is String || value is NSNumber || value is [String] {
                result += "\n        str += \"\\n\\(tap) \(key) = \\(self.\(key))\" "
            }
            else if value is [Any] {
                result += "\n        str += \"\\n\\(tap) \(key) = Array(\\( self.\(key).count )) ------------------------------\" "
                if let array = value as? [Any], array.count > 0 {
                    result += """
                    
                             for (idx, item) in self.\(key).enumerated() {
                                 str += "\\n\\t\\(tap)[\\(idx)] \\(item.getDescription(tapCount + 1, true))"
                             }
                    """
                }
                result += "\n        str += \"\\n\\(tap)------------------------------------------------------------\" "
            }
            else if value is [String : Any] {
                result += """
                
                         if let item = self.\(key) {
                            str += \"\\n\\(tap) \(subClassName) = SubObject ------------------------------\\(item.getDescription(tapCount + 1))\"
                         }
                         else {
                             str += \"\\n\\(tap) \(subClassName) = nil"
                         }
                """
            }
            
        }
        
        result += """
        
                str += \"\\n\\(tap)--- ** \\(String(describing: type(of: self)) ) ** ------------------------------"
                return str
            }
        }
        
        """
        return result
    }
    
}
