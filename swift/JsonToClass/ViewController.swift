//
//  ViewController.swift
//  JsonToClass
//
//  Created by pkh on 17/04/2019.
//  Copyright © 2019 pkh. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    @IBOutlet var textView: NSTextView!
    @IBOutlet var textViewPreview: NSTextView!
    @IBOutlet weak var rootClassNameTextField: NSTextField!
    @IBOutlet weak var parentClassNameTextField: NSTextField!
    @IBOutlet weak var pathTextField: NSTextField!
    @IBOutlet weak var prefixTextField: NSTextField!
    @IBOutlet weak var prefixCheckButton: NSButton!
    @IBOutlet weak var swifCheckButton: NSButton!
    @IBOutlet weak var parserButton: NSButton!
    
    
    
    var stringData = ""
    var folderFilePath = ""
    
    var strPrefix = ""
    var tempParentClassName = ""
    var classModelDataList: [ClassModelData] = []

    
    override func viewDidLoad() {
        super.viewDidLoad()

        var directoryPaths = NSSearchPathForDirectoriesInDomains(.desktopDirectory, .userDomainMask, true)
        let documentsDirectoryPath = directoryPaths[0]
        pathTextField.stringValue = documentsDirectoryPath
        strPrefix = ""
        tempParentClassName = "NSObject"

    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    @IBAction func onMakeFile(_ sender: NSButton) {
        
        strPrefix = ""
        classModelDataList.removeAll()
        
        if prefixCheckButton.state == NSControl.StateValue.on && prefixTextField.stringValue.isValid {
            strPrefix = prefixTextField.stringValue
        }
        stringData = textView.string
        var dic: [String : Any]? = nil
        if let jsonData: Data = textView.string.data(using: .utf8) {
            do {
                dic = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any]
            } catch {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "Error"
                alert.informativeText = "\(error)"
                alert.beginSheetModal(for: NSApplication.shared.mainWindow!, completionHandler: nil)
                return
            }
        }
        guard dic?.keys.count ?? 0 > 0 else { return }
        
        let fileManager = FileManager()
        let exists: Bool = fileManager.fileExists(atPath: pathTextField.stringValue)
        if !exists {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = "Error Directory"
            alert.informativeText = "Directory가 존재 하지 않습니다.\n다시 설정해 주세요! "
            alert.beginSheetModal(for: NSApplication.shared.mainWindow!, completionHandler: nil)
            return
        }
        
        var className = rootClassNameTextField.stringValue
        var parentClassName = parentClassNameTextField.stringValue
        let swiftCheck: Bool = swifCheckButton.state == NSControl.StateValue.on
        
        if className.isValid == false {
            className = "Test"
        }
        if parentClassName.isValid == false && swiftCheck == false {
            parentClassName = "NSObject"
        }
        
        makeHClassFile(dic!, className: className, parentClassName: parentClassName)
        
        if sender.tag == 1 {
            let format = DateFormatter()
            format.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let dateString = format.string(from: Date())
            folderFilePath = "\(pathTextField.stringValue)/\("JsonToClass_")\(dateString)"
            do {
                try FileManager.default.createDirectory(atPath: folderFilePath, withIntermediateDirectories: true, attributes: nil)
            } catch {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "Error Directory"
                alert.informativeText = "파일 생성 실패 "
                alert.beginSheetModal(for: NSApplication.shared.mainWindow!, completionHandler: nil)
                return
            }
            
            if parserButton.state == NSControl.StateValue.on {
                var stringData = ""
                for data in classModelDataList {
                    if stringData == "" {
                        stringData = "\(data.makeClassAnnotate())\(data.getImportHeaderFilesSwift())"
                    }
                    stringData = "\(stringData)\(data.getStringSwiftSSG())"
                }
                
                createFile(stringData, fileName: "\(rootClassNameTextField.stringValue).swift")
            }
            else {
                for data in classModelDataList {
                    if swiftCheck == false {
                        createFile(data.getStringObjectCHeader(), fileName: "\(data.name).h")
                        createFile(data.getStringObjectCImplementation(), fileName: "\(data.name).m")
                    } else {
                        createFile(data.getStringSwift(), fileName: "\(data.name).swift")
                    }
                }
            }
            
            
            NSWorkspace.shared.selectFile(nil, inFileViewerRootedAtPath: folderFilePath)
            
        }
        else {
            textViewPreview.string = ""
            if swiftCheck == false {
                for data in classModelDataList {
                    textViewPreview.string = "\(textViewPreview.string)\n\n\(data.getStringObjectCHeader())\n\n\(data.getStringObjectCImplementation())"
                }
            } else {
                for data in classModelDataList {
                    textViewPreview.string = "\(textViewPreview.string)\n\n\(data.getStringSwift())"
                }
            }
            
        }
        
        
    }
    
    @IBAction func onPath(_ sender: NSButton) {
        print("onPath")
        let panel = NSOpenPanel()
        panel.canChooseFiles = false
        panel.canChooseDirectories = true
        panel.allowsMultipleSelection = false // yes if more than one dir is allowed
        
        let clicked: NSApplication.ModalResponse = panel.runModal()
        
        if clicked.rawValue == NSApplication.ModalResponse.OK.rawValue {
            for url in panel.urls {
                pathTextField.stringValue = url.path
            }
        }
    }
    
    @IBAction func onTree(_ sender: NSButton) {
        print("onTree")
        if sender.tag == 0 {
            stringData = textView.string
            sender.tag = 1
            sender.image = NSImage(named: "treeno")
            
            let jsonData: Data? = textView.string.data(using: .utf8)
            
            var dic: [String : Any]? = nil
            do {
                if let jsonData = jsonData {
                    dic = try JSONSerialization.jsonObject(with: jsonData, options: .allowFragments) as? [String : Any]
                }
            } catch {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "Error"
                alert.informativeText = "\(error)"
                alert.beginSheetModal(for: NSApplication.shared.mainWindow!, completionHandler: nil)
                return
            }
            
            var data: Data? = nil
            do {
                data = try JSONSerialization.data(withJSONObject: dic!, options: .prettyPrinted)
            } catch {
                let alert = NSAlert()
                alert.alertStyle = .critical
                alert.messageText = "Error"
                alert.informativeText = "\(error)"
                alert.beginSheetModal(for: NSApplication.shared.mainWindow!, completionHandler: nil)
                return
            }
            textView.string = String(data: data!, encoding: .utf8) ?? ""
            return

            
        }
        else {
            sender.tag = 0
            sender.image = NSImage(named: "tree")
            textView.string = stringData.trim().replacingOccurrences(of: "\n", with: "")
            return
        }
        
    }
    
    @IBAction func ssgParser(_ sender: NSButton) {
        if sender.state == NSControl.StateValue.on {
            parentClassNameTextField.stringValue = "ParserObject"
            prefixTextField.stringValue = "DI_"
            prefixCheckButton.state = NSControl.StateValue.on
            swifCheckButton.state = NSControl.StateValue.on
        }
        else {
            parentClassNameTextField.stringValue = ""
            prefixTextField.stringValue = ""
            prefixCheckButton.state = NSControl.StateValue.off
        }
    }
    
    @IBAction func swiftButton(_ sender: NSButton) {
        
        if sender.state == NSControl.StateValue.off {
            parentClassNameTextField.stringValue = tempParentClassName
        } else {
            tempParentClassName = parentClassNameTextField.stringValue
            parentClassNameTextField.stringValue = ""
        }
        
    }
    
    func makeHClassFile(_ dic: [String : Any], className: String, parentClassName: String) {
        let classModelData = ClassModelData(dic: dic, className: className, parentName: parentClassName, perfix: strPrefix)
        classModelDataAdd(classModelData)
//        classModelDataList.append(classModelData)
        
        for (key, value) in dic {
            if let array = value as? [Any], array.count > 0 {
                if let dic = array.first as? [String : Any] {
                    if swifCheckButton.state == NSControl.StateValue.off {
                        makeHClassFile(dic, className: "\(key)\(ARRAY_INNER_CLASS_TAIL_PIX)", parentClassName: parentClassName)
                    } else {
                        makeHClassFile(dic, className: "\(key)\(ARRAY_INNER_CLASS_TAIL_PIX)", parentClassName: parentClassName)
                    }
                }
            }
            else if let dic = value as? [String: Any] {
                if swifCheckButton.state == NSControl.StateValue.off {
                    makeHClassFile(dic, className: key, parentClassName: parentClassName)
                } else {
                    makeHClassFile(dic, className: key, parentClassName: parentClassName)
                }
            }
        }
    }
    
    func classModelDataAdd(_ addData: ClassModelData) {
        
        let checkClassList = classModelDataList.filter { $0.name == addData.name }
        if let checkClass = checkClassList.first {
            var addProperty = [PropertyModelData]()
            for addItem in addData.propertyList {
                var check = false
                for checkItem in checkClass.propertyList {
                    if addItem.key == checkItem.key {
                        check = true
                        break
                    }
                }
                if check == false {
                    addProperty.append(addItem)
                }
            }
            checkClass.propertyList.append(contentsOf: addProperty)
        }
        else {
            classModelDataList.append(addData)
        }
    }
    
    @discardableResult
    func createFile(_ stringData: String, fileName: String) -> Bool {
        let fileManager = FileManager()
        let filePath = "\(folderFilePath)/\(fileName)"
        
        if fileManager.fileExists(atPath: filePath) == true {
            print("File exists")
        } else {
            fileManager.createFile(atPath: filePath, contents: stringData.data(using: .utf8), attributes: nil)
        }
        
        return true
    }
    
}

