//
//  AppDelegate.m
//  JsonToClass
//
//  Created by pkh on 2014. 8. 26..
//  Copyright (c) 2014년 ___FULLUSERNAME___. All rights reserved.
//

#import "AppDelegate.h"
#import "NSString+Helper.h"
#import "ClassModelData.h"


@interface AppDelegate()
{
    NSString *_strPrefix;
    NSString *tempParentClassName;
}

@property (nonatomic, strong) NSMutableArray<ClassModelData*> *classModelDataList;


@end
@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSArray *directoryPaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectoryPath = [directoryPaths objectAtIndex:0];
    _m_tfPath.stringValue = documentsDirectoryPath;
    _strPrefix = @"";
    tempParentClassName = @"NSObject";
}
- (IBAction)swiftButton:(NSButton *)sender {
    if (sender.state == NO) {

        _m_tfParentClassName.stringValue = tempParentClassName;
    } else {
        tempParentClassName = [_m_tfParentClassName.stringValue copy];
        _m_tfParentClassName.stringValue = @"";
    }
}

- (IBAction)onMakeFile:(NSButton *)sender
{
    _strPrefix = @"";
    self.classModelDataList = [NSMutableArray<ClassModelData*> new];
    if (_m_btnPrefixCheck.state && [_m_tfPrefix.stringValue isValid]) {
        _strPrefix = [_m_tfPrefix.stringValue copy];
    } 
    m_stringData = [_m_textView.string copy];
    NSData *jsonData = [_m_textView.string dataUsingEncoding:NSUTF8StringEncoding];

    NSError *error = nil;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    if (error != nil)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:@"Error"];
        [alert setInformativeText:[error description]];

        [alert beginSheetModalForWindow:_window
                          modalDelegate:self
                         didEndSelector:nil
                            contextInfo:nil];
        return;
    }

    if ([[dic allKeys] count] < 1)
        return;

    NSFileManager *fileManager = [[NSFileManager alloc] init];
    BOOL isDirectory = NO;
    BOOL exists = [fileManager fileExistsAtPath:_m_tfPath.stringValue isDirectory:&isDirectory];
    if (!exists || !isDirectory)
    {
        NSAlert *alert = [[NSAlert alloc] init];
        [alert setAlertStyle:NSInformationalAlertStyle];
        [alert setMessageText:@"Error Directory"];
        [alert setInformativeText:@"Directory가 존재 하지 않습니다.\n다시 설정해 주세요! "];

        [alert beginSheetModalForWindow:_window
                          modalDelegate:self
                         didEndSelector:nil
                            contextInfo:nil];
        return;
    }

    NSString *className = _m_tfClassName.stringValue;
    NSString *parentClassName = _m_tfParentClassName.stringValue;
    NSInteger swiftCheck = _m_SwifCheck.state;
    
    if ([className isValid] == NO)
    {
        className = @"Test";
    }
    if ([parentClassName isValid] == NO && swiftCheck == NO)
    {
        parentClassName = @"NSObject";
    }
    
    [self makeHClassFile:dic className:className parentClassName:parentClassName];
    
    if (sender.tag == 1)
    {
        
        NSDateFormatter *format = [[NSDateFormatter alloc] init];
        [format setDateFormat:@"yyyy-MM-dd HH:mm:ss"];

        NSDate *now = [[NSDate alloc] init];

        NSString *dateString = [format stringFromDate:now];

        folderFilePath = [NSString stringWithFormat:@"%@/%@%@", _m_tfPath.stringValue, @"JsonToClass_", dateString];
        [[NSFileManager defaultManager] createDirectoryAtPath:folderFilePath withIntermediateDirectories:YES attributes:nil error:nil];

        for (ClassModelData *data in self.classModelDataList) {
            if (swiftCheck == NO) {
                [self createFile:[data getStringObjectCHeader] fileName:[NSString stringWithFormat:@"%@.h", data.name]];
                [self createFile:[data getStringObjectCImplementation] fileName:[NSString stringWithFormat:@"%@.m", data.name]];
            } else {
                [self createFile:[data getStringSwift] fileName:[NSString stringWithFormat:@"%@.swift", data.name]];
            }
            
        }
        
        [[NSWorkspace sharedWorkspace] selectFile:nil inFileViewerRootedAtPath:folderFilePath];
    }
    else
    {
        _m_textViewPreview.string = @"";
        
        if (swiftCheck == 0) {
            for (ClassModelData *data in self.classModelDataList) {
                _m_textViewPreview.string = [NSString stringWithFormat:@"%@\n\n%@\n\n%@", _m_textViewPreview.string, [data getStringObjectCHeader], [data getStringObjectCImplementation]];
            }
        } else {
            for (ClassModelData *data in self.classModelDataList) {
                _m_textViewPreview.string = [NSString stringWithFormat:@"%@\n\n%@", _m_textViewPreview.string, [data getStringSwift]];
            }
        }

    }
}

- (IBAction)onPath:(NSButton *)sender
{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed

    NSInteger clicked = [panel runModal];

    if (clicked == NSFileHandlingPanelOKButton)
    {
        for (NSURL *url in [panel URLs])
        {
            _m_tfPath.stringValue = url.path;
        }
    }
}

- (IBAction)onTree:(NSButton *)sender
{
    if (sender.tag == 0)
    {
        m_stringData = [_m_textView.string copy];
        sender.tag = 1;
        [sender setImage:[NSImage imageNamed:@"treeno"]];

        NSData *jsonData = [_m_textView.string dataUsingEncoding:NSUTF8StringEncoding];

        NSError *error = nil;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
        if (error != nil)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert setMessageText:@"Error"];
            [alert setInformativeText:[error description]];

            [alert beginSheetModalForWindow:_window
                              modalDelegate:self
                             didEndSelector:nil
                                contextInfo:nil];
            return;
        }
        NSData *data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
        if (error != nil)
        {
            NSAlert *alert = [[NSAlert alloc] init];
            [alert setAlertStyle:NSInformationalAlertStyle];
            [alert setMessageText:@"Error"];
            [alert setInformativeText:[error description]];

            [alert beginSheetModalForWindow:_window
                              modalDelegate:self
                             didEndSelector:nil
                                contextInfo:nil];
            return;
        }

        _m_textView.string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        return;
    }
    else
    {
        sender.tag = 0;
        [sender setImage:[NSImage imageNamed:@"tree"]];
        _m_textView.string = [[m_stringData trim] stringByReplacingOccurrencesOfString:@"\n" withString:@""];
        return;
    }
}

- (void)makeHClassFile:(NSDictionary *)dic className:(NSString *)className parentClassName:(NSString *)parentClassName
{
    ClassModelData *classModelData = [ClassModelData allocWithDictionary:dic className:className parentName:parentClassName perfix:_strPrefix] ;
    [self.classModelDataList addObject:classModelData];
    
    
    for (NSString *key in [dic allKeys])
    {
        NSObject *value = [dic objectForKey:key];
        
        if ([value isKindOfClass:[NSArray class]])
        {
            NSArray *array = (NSArray *)value;
            
            if ([array count] > 0)
            {
                NSObject *obj = [array objectAtIndex:0];
                
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    if (_m_SwifCheck.state == NO) {
                        [self makeHClassFile:(NSDictionary*)obj className:[NSString stringWithFormat:@"%@%@",key,ARRAY_INNER_CLASS_TAIL_PIX] parentClassName:parentClassName];
                    } else {
                        [self makeHClassFile:(NSDictionary*)obj className:[NSString stringWithFormat:@"%@%@",key,ARRAY_INNER_CLASS_TAIL_PIX] parentClassName:parentClassName];
                    }
                    
                }
                
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            if (_m_SwifCheck.state == NO) {
                [self makeHClassFile:(NSDictionary*)value className:key parentClassName:parentClassName];
            } else {
                [self makeHClassFile:(NSDictionary*)value className:key parentClassName:parentClassName];
            }
            
            
        }
    }

}

- (BOOL)createFile:(NSString *)stringData fileName:(NSString *)fileName
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    NSString *filePath = [NSString stringWithFormat:@"%@/%@", folderFilePath, fileName];

    if ([fileManager fileExistsAtPath:filePath] == YES)
    {
        NSLog(@"File exists");
    }
    else
    {
        [fileManager createFileAtPath:filePath contents:[stringData dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    }

    return YES;
}


- (NSString *)inputBox: (NSString *)prompt defalut:(NSString*)defalut
{
    NSAlert *alert = [NSAlert alertWithMessageText: prompt
                                     defaultButton:@"OK"
                                   alternateButton:nil
                                       otherButton:nil
                         informativeTextWithFormat:@""];
    
    NSTextField *input = [[NSTextField alloc] initWithFrame:NSMakeRect(0, 0, 200, 24)];
    [input setStringValue:defalut];
    [alert setAccessoryView:input];
    NSInteger button = [alert runModal];
    if (button == NSAlertDefaultReturn) {
        [input validateEditing];
        return [input stringValue];
    }
    else if (button == NSAlertAlternateReturn) {
        return nil;
    }
    else {
        return nil;
    }
}
@end
