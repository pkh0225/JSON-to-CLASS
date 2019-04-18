![blogimg](https://github.com/pkh0225/JSON-to-CLASS/blob/master/JsonToClass/jtc.png)

# 🚀 JTC (Mac App)

## JSON TO CLASS 
> JSON to Class Helper written in Objective-C file, Swift file for iOS developers.

![blogimg](https://github.com/pkh0225/JSON-to-CLASS/blob/master/app.png)
![blogimg](https://github.com/pkh0225/JSON-to-CLASS/blob/master/file.png)

<br>

## 목표
> 클라이언트 개발 시 json 파싱 과정에서 생기는 실수를 방지하고 불필요한 반복 작업을 줄여 파싱 과정을 효율화 하기 위해 기획된 맥용앱

<br>

## Core Functions


```
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
```
