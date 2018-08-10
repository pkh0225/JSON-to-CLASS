//
//  ClassModelData.h
//  JsonToClass
//
//  Created by pkh on 2017. 5. 31..
//  Copyright © 2017년 pkh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PropertyModelData.h"

@interface ClassModelData : NSObject

@property (nonatomic, strong) NSString* name;
@property (nonatomic, strong) NSString* parentName;
@property (nonatomic, strong) NSString* perfix;
@property (nonatomic, strong) NSMutableArray<PropertyModelData*> *propertyList;



+ (ClassModelData*)allocWithDictionary:(NSDictionary*)dic className:(NSString*)className parentName:(NSString*)parentName perfix:(NSString*)perfix;
- (id)initWithDictionary:(NSDictionary *)dic className:(NSString*)className parentName:(NSString*)parentName perfix:(NSString*)perfix;
- (void)setSerialize:(NSDictionary *)dic;

- (NSString *)getStringObjectCHeader;
- (NSString *)getStringObjectCImplementation;

- (NSString*)getStringSwift;
@end
