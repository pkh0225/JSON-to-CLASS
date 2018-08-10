//
//  PropertyModelData.h
//  JsonToClass
//
//  Created by pkh on 2017. 5. 31..
//  Copyright © 2017년 pkh. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PropertyModelData : NSObject

@property (nonatomic, assign) NSObject* value;
@property (nonatomic, strong) NSString* key;
@property (nonatomic, strong) NSString* perfix;

+ (PropertyModelData*)allocWithKey:(NSString*)key object:(NSObject*)object perfix:(NSString*)perfix;
- (id)initWithKey:(NSString*)key object:(NSObject*)object perfix:(NSString*)perfix;
- (void)setKey:(NSString*)key object:(NSObject*)object perfix:(NSString*)perfix;
- (NSString*)getStringObjectC;
- (NSString*)getStringSwif;
- (NSString*)isImportClass;
@end
