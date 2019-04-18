
import Foundation

extension String {
    
    public func trim() -> String {
        let str = self.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        return str
    }
    
    public var isValid: Bool {
        if self.isEmpty || self.count == 0 || self.trim().count == 0 || self == "(null)" || self == "null" || self == "nil" {
            return false
        }
        
        return true
    }
    
    public func capitalizedFirst() -> String {
        guard self.count > 0 else { return self }
        var result = self
        
        result.replaceSubrange(startIndex...startIndex, with: String(self[startIndex]).capitalized)
        return result
    }
}
