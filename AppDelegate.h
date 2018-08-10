//
//  AppDelegate.h
//  JsonToClass
//
//  Created by pkh on 2014. 8. 26..
//  Copyright (c) 2014년 ___FULLUSERNAME___. All rights reserved.
//
////
#import <Cocoa/Cocoa.h>



@interface AppDelegate : NSObject <NSApplicationDelegate, NSTextViewDelegate>
{
    NSString *m_stringData;
    NSString *folderFilePath;
}

@property (assign) IBOutlet NSWindow *window;
@property (unsafe_unretained) IBOutlet NSTextView *m_textView;
@property (unsafe_unretained) IBOutlet NSTextView *m_textViewPreview;
@property (weak) IBOutlet NSTextField *m_tfClassName;
@property (weak) IBOutlet NSTextField *m_tfParentClassName;
@property (weak) IBOutlet NSTextField *m_tfPath;
@property (weak) IBOutlet NSTextField *m_tfPrefix;
@property (weak) IBOutlet NSButton *m_btnPrefixCheck;
@property (weak) IBOutlet NSButton *m_SwifCheck;

- (IBAction)onMakeFile:(NSButton *)sender;
- (IBAction)onPath:(NSButton *)sender;
- (IBAction)onTree:(NSButton *)sender;
@end
