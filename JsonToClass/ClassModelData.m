//
//  ClassModelData.m
//  JsonToClass
//
//  Created by pkh on 2017. 5. 31..
//  Copyright © 2017년 pkh. All rights reserved.
//

#import "ClassModelData.h"
#import "NSString+Helper.h"

#define DATE_FORMAT @"yyyy. MM. dd.."

@implementation ClassModelData

+ (ClassModelData*)allocWithDictionary:(NSDictionary*)dic className:(NSString*)className parentName:(NSString*)parentName perfix:(NSString*)perfix {
 
    return [[ClassModelData alloc] initWithDictionary:dic className:className parentName:parentName perfix:perfix];
}

- (id)initWithDictionary:(NSDictionary *)dic className:(NSString*)className parentName:(NSString*)parentName perfix:(NSString*)perfix {
    self = [super init];
    if(self)
    {
        self.perfix = [perfix upercaseFirstChar];
        if ([self.perfix isValid]) {
            self.name = [NSString stringWithFormat:@"%@%@",self.perfix, [className upercaseFirstChar]];
        } else {
            self.name = [className upercaseFirstChar];
        }
        self.parentName = [parentName upercaseFirstChar];
        self.propertyList = [NSMutableArray<PropertyModelData*> new];
        [self setSerialize:dic];
    }
    return self;
}

- (void)setSerialize:(NSDictionary *)dic {
    
    for (NSString *key in [dic allKeys])
    {
        NSObject *value = [dic objectForKey:key];
        //        NSLog(@"key = %@, value = %@, value class = %@", key, value, [value className]);
        
        PropertyModelData *propertyModelData = [PropertyModelData allocWithKey:key object:value perfix:self.perfix];
        [self.propertyList addObject:propertyModelData];
    }
    
    
}

- (NSString *)getStringObjectCHeader {
    
    NSMutableString *result = [NSMutableString new];
    NSMutableString *propertyResult = [NSMutableString new];
    
    for (PropertyModelData *propertyModelData in self.propertyList) {
        [propertyResult appendString:[propertyModelData getStringObjectC]];
    }
    
    [result appendString:[self makeClassAnnotate]];
    [result appendString:[self getImportHeaderFiles]];
    [result appendString:[self getClassStart]];
    [result appendString:propertyResult];
    [result appendString:[self getFunctionObjectCHeader]];
    [result appendString:[self getClassEnd]];
    
    return result;
}

- (NSString *)getStringObjectCImplementation {
    
    NSMutableString *result = [NSMutableString new];
    
    [result appendString:[self makeImplementationAnnotate]];
    [result appendString:[self getImplementationStart]];
    [result appendString:[self makeImplementationAllocWithDictionary]];
    [result appendString:[self makeImplementationInitWithDictionary]];
    [result appendString:[self makeImplementationSetSerialize]];
    [result appendString:[self makeImplementationDescription]];
    [result appendString:[self getImplementationEnd]];
    
    return result;
}

- (NSString*)getStringSwift {
    NSMutableString *result = [NSMutableString new];
    
    NSMutableString *propertyResult = [NSMutableString new];
    
    for (PropertyModelData *propertyModelData in self.propertyList) {
        [propertyResult appendString:[propertyModelData getStringSwif]];
    }

    
    [result appendString:[self makeClassAnnotateSwift]];
    [result appendString:[self getImportHeaderFilesSwift]];
    [result appendString:[self getClassStartSwift]];
    [result appendString:propertyResult];
    [result appendString:[self makeImpInitFunctionSwift]];
    [result appendString:[self makeSetSerializeSwift]];
    [result appendString:[self getClassEndSwift]];
    
    [result appendString:[self makeDescriptionSwift]];
    
    return result;
}


- (NSString *)makeClassAnnotate
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:DATE_FORMAT];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *dateString = [format stringFromDate:now];
    NSString *str = [NSString stringWithFormat:@"/*\n    JsonToClass pkh\n    %@.h\n\n    Created by %@ on %@\n*/\n", self.name, NSUserName(), dateString];
    return str;
}

- (NSString *)makeClassAnnotateSwift
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:DATE_FORMAT];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *dateString = [format stringFromDate:now];
    
    NSString *str = [NSString stringWithFormat:@"/*\n    JsonToClass pkh\n    %@.swift\n\n    Created by %@ on %@\n*/\n", self.name, NSUserName(), dateString];

    return str;
}


- (NSString *)makeImplementationAnnotate
{
    NSDateFormatter *format = [[NSDateFormatter alloc] init];
    [format setDateFormat:DATE_FORMAT];
    
    NSDate *now = [[NSDate alloc] init];
    
    NSString *dateString = [format stringFromDate:now];
    
    NSString *str = [NSString stringWithFormat:@"/*\n    JsonToClass pkh\n    %@.m\n\n    Created by %@ on %@\n*/\n", self.name, NSUserName(), dateString];
    return str;
}

- (NSMutableString*)getImportHeaderFiles {
    NSMutableString *result = [NSMutableString new];
    
    [result appendString:@"\n#import <Foundation/Foundation.h>"];
     
    if ([self.parentName isEqualToString:@"NSObject"] == NO)
    {
        [result appendString:[NSString stringWithFormat:@"\n#import \"%@.h\"" ,self.parentName]];
    }
    
    for (PropertyModelData *propertyModelData in self.propertyList) {
        NSString *importName = [propertyModelData isImportClass];
        if (importName != nil) {
            [result appendString:importName];
        }

    }
    return result;
}

- (NSString*)getImportHeaderFilesSwift {
    return @"\nimport Foundation\n";
}


- (NSString*)getClassStart {
    
    return [NSString stringWithFormat:@"\n\n@interface %@ : %@ \n", self.name, self.parentName];
}

- (NSString*)getClassStartSwift {
    NSMutableString *result = [NSMutableString new];
    
//    [result appendString:[NSString stringWithFormat:@"\n\n@objc(%@)", self.name]];
    if ([self.parentName isValid]) {
        [result appendString:[NSString stringWithFormat:@"\nclass %@ : %@ { \n", self.name, self.parentName]];
    } else {
        [result appendString:[NSString stringWithFormat:@"\nclass %@ { \n", self.name]];
    }
    
    
    
    return result;
}


- (NSString*)getClassEnd {
    return @"\n\n@end";
}

- (NSString*)getClassEndSwift {
    return @"\n\n}";
}

- (NSString*)getFunctionObjectCHeader {
    
    return @"\n\n+ (id)allocWithDictionary:(NSDictionary *)dic;"
           @"\n\n- (id)initWithDictionary:(NSDictionary *)dic;"
           @"\n\n- (void)setSerialize:(NSDictionary *)dic;";
}

- (NSString*)getFunctionObjectCImplementation {
    
    return @"\n\n+ (id)allocWithDictionary:(NSDictionary *)dic;"
           @"\n\n- (id)initWithDictionary:(NSDictionary *)dic;"
           @"\n\n- (void)setSerialize:(NSDictionary *)dic;";
}


- (NSString*)getImplementationStart {
    return [NSString stringWithFormat:@"\n#import \"%@.h\""
                                      @"\n\n@implementation %@", self.name , self.name];
}

- (NSString*)getImplementationEnd {
    return @"\n\n@end";
}


- (NSString *)makeImplementationAllocWithDictionary
{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [str appendFormat:@"\n\n+ (id)allocWithDictionary:(NSDictionary *)dic"
                      @"\n{"
                      @"\n    if (dic == nil || [dic isEqual:[NSNull null]] || [dic isKindOfClass:[NSDictionary class]] == NO || dic.count == 0) return nil;"
                      @"\n    return [[%@ alloc] initWithDictionary:dic];"
                      @"\n}", self.name];
    
    return str;
}

- (NSString *)makeImpInitFunctionSwift
{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [str appendString:@"\n"
                      @"\n"
                      @"\n    init(_ dic: [String: Any]?) {"
                      @"\n        guard let dic = dic else { return }"
                      @"\n        self.setSerialize(dic)"
                      @"\n    }"];
    
    return str;
}


- (NSString *)makeImplementationInitWithDictionary
{
    return @"\n\n- (id)initWithDictionary:(NSDictionary *)dic"
           @"\n{"
           @"\n    self = [super init];"
           @"\n    if(self)"
           @"\n    {"
           @"\n        [self setSerialize:dic];"
           @"\n    }"
           @"\n    return self;"
           @"\n}";
}

- (NSString *)makeImplementationSetSerialize
{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [str appendFormat:
     @"\n\n- (void)setSerialize:(NSDictionary *)dic"
     @"\n{"
     @"\n    if (dic == nil || [dic isEqual:[NSNull null]] || [dic isKindOfClass:[NSDictionary class]] == NO || dic.count == 0) return;"
     @"\n"
     @"%@"
     @"\n}",
     [self makeImplementationParser]];
    
    return str;
}

- (NSString *)makeSetSerializeSwift
{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [str appendFormat:
     @"\n\n    func setSerialize(_ dic: [String: Any]?) {"
     @"\n        guard let dic = dic, dic.count > 0 else { return }"
     @"\n"
     @"%@"
     @"\n    }",
     [self makeSetSerializeParserSwift]];
    
    return str;
}

- (NSString *)makeImplementationParser
{
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (PropertyModelData *propertyModelData in self.propertyList)
    {
        NSString *key = propertyModelData.key;
        NSObject *value = propertyModelData.value;
        NSString *subClassName = [NSString stringWithFormat:@"%@%@",self.perfix, [key upercaseFirstChar]];
        NSString *arraySubClassName = [NSString stringWithFormat:@"%@%@%@",self.perfix, [key upercaseFirstChar], ARRAY_INNER_CLASS_TAIL_PIX];
        //        NSLog(@"key = %@, value = %@, value class = %@", key, value, [value className]);
        
        if ([value isKindOfClass:[NSString class]])
        {
            [str appendFormat:@"\n    self.%@ = [dic objectForKey:@\"%@\"];", key, key];
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            [str appendFormat:@"\n    %@", [self makeMClassParserNumberType:CFNumberGetType((CFNumberRef)value) key:key]];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            NSArray *array = (NSArray *)value;
            
            if ([array count] > 0)
            {
                NSObject *obj = [array objectAtIndex:0];
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    [str appendFormat:@"\n    if ([[dic objectForKey:@\"%@\"] isKindOfClass:[NSArray class]]) {", key];
                    [str appendFormat:@"\n        self.%@ = [[NSMutableArray<%@*> alloc] init];", key, arraySubClassName];
                    [str appendFormat:@"\n        for (NSDictionary *arrayItem  in [dic objectForKey:@\"%@\"])"
                                      @"\n        {"
                                      @"\n            %@ *obj =  [%@ allocWithDictionary:arrayItem];"
                                      @"\n            if (obj != nil)"
                                      @"\n                [self.%@ addObject:obj];"
                                      @"\n        }",
                     key, arraySubClassName, arraySubClassName, key];
                    [str appendFormat:@"\n    }"];
                }
                else
                {
                    [str appendFormat:@"\n    self.%@ = [dic objectForKey:@\"%@\"];", key, key];
                }
                
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            [str appendFormat:@"\n    self.%@ = [%@ allocWithDictionary:[dic objectForKey:@\"%@\"]];", key, subClassName, key];
        }
        else
        {
            [str appendFormat:@"\n    self.%@ =  %@; //type error %@", key, NSStringFromClass([value class]), NSStringFromClass([value class])];
        }
    }
    
    return str;
}

- (NSString *)makeSetSerializeParserSwift
{
    
    NSMutableString *str = [[NSMutableString alloc] init];
    
    for (PropertyModelData *propertyModelData in self.propertyList)
    {
        NSString *key = propertyModelData.key;
        NSObject *value = propertyModelData.value;
        NSString *subClassName = [NSString stringWithFormat:@"%@%@",self.perfix, [key upercaseFirstChar]];
        NSString *arraySubClassName = [NSString stringWithFormat:@"%@%@%@",self.perfix, [key upercaseFirstChar], ARRAY_INNER_CLASS_TAIL_PIX];
        //        NSLog(@"key = %@, value = %@, value class = %@", key, value, [value className]);
        
        if ([value isKindOfClass:[NSString class]])
        {
            [str appendFormat:@"\n        if let data = dic[\"%@\"] as? String { self.%@ = data }", key, key];
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            [str appendFormat:@"\n        %@", [self makeMClassParserNumberTypeSwift:CFNumberGetType((CFNumberRef)value) key:key]];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            NSArray *array = (NSArray *)value;
            
            if ([array count] > 0)
            {
                NSObject *obj = [array objectAtIndex:0];
                
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    [str appendFormat:@"\n        if let data = dic[\"%@\"] as? [Any] {", key];
                    [str appendFormat:@"\n            for case let subItem as [String: Any] in data {"
                                      @"\n                let obj : %@ = %@(subItem)"
                                      @"\n                self.%@.append(obj)"
                                      @"\n            }",
                     arraySubClassName, arraySubClassName, key];
                    [str appendFormat:@"\n        }"];
                }
                else if ([obj isKindOfClass:[NSString class]])
                {
                    [str appendFormat:@"\n        if let data = dic[\"%@\"] as? [String] { self.%@ = data }", key, key];
                }
                else
                {
                    [str appendFormat:@"\n        if let data = dic[\"%@\"] as? [Any] { self.%@ = data }", key, key];
                }
                
                
                
            }
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            [str appendFormat:@"\n        if let data = dic[\"%@\"] as? [String: Any] { self.%@ = %@(data) }", key, key, subClassName];
        }
        else
        {
            [str appendFormat:@"\n        self.%@ =  %@; //type error %@", key, NSStringFromClass([value class]), NSStringFromClass([value class])];
        }
    }
    
    return str;
}

- (NSString *)makeMClassParserNumberType:(CFNumberType)type key:(NSString *)key
{
    switch (type)
    {
        case kCFNumberSInt64Type:
        case kCFNumberSInt32Type:
            return [NSString stringWithFormat:@"self.%@ = [[dic objectForKey:@\"%@\"] integerValue];", key, key];
            break;
        case kCFNumberCharType:
            return [NSString stringWithFormat:@"self.%@ = [[dic objectForKey:@\"%@\"] boolValue];", key, key];
            break;
        case kCFNumberFloat32Type:
        case kCFNumberFloat64Type:
            return [NSString stringWithFormat:@"self.%@ = [[dic objectForKey:@\"%@\"] floatValue];", key, key];
            break;
            
        default:
            return [NSString stringWithFormat:@"CFNumberType error : %ld", (long)type] ;
            break;
    }
    
}

- (NSString *)makeMClassParserNumberTypeSwift:(CFNumberType)type key:(NSString *)key
{
    switch (type)
    {
        case kCFNumberSInt64Type:
        case kCFNumberSInt32Type:
            return [NSString stringWithFormat:@"if let data = dic[\"%@\"] as? Int { self.%@ = data }", key, key];
            break;
        case kCFNumberCharType:
            return [NSString stringWithFormat:@"if let data = dic[\"%@\"] as? Bool { self.%@ = data }", key, key];
            break;
        case kCFNumberFloat32Type:
        case kCFNumberFloat64Type:
            return [NSString stringWithFormat:@"if let data = dic[\"%@\"] as? Float { self.%@ = data }", key, key];
            break;
            
        default:
            return [NSString stringWithFormat:@"CFNumberType error : %ld", (long)type] ;
            break;
    }
}


- (NSString *)makeMClassDescriptionNumberType:(CFNumberType)type
{
    switch (type)
    {
        case kCFNumberSInt32Type:
        case kCFNumberSInt64Type:
            return @"ld";
            break;
        case kCFNumberCharType:
            return @"d";
            break;
        case kCFNumberFloat32Type:
        case kCFNumberFloat64Type:
            return @"f";
            break;
            
        default:
            return @"@";
            break;
    }
}

- (NSString *)makeImplementationDescription
{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [str appendFormat:@"\n\n- (NSString *)description"
     @"\n{"
     @"\n    NSMutableString *str = [[NSMutableString alloc] init];"
     @"\n\n    [str appendFormat:@\"\\n==== %%@ ====\", NSStringFromClass([self class])];"];
    
    for (PropertyModelData *propertyModelData in self.propertyList)
    {
        NSString *key = propertyModelData.key;
        NSObject *value = propertyModelData.value;
        NSString *subClassName = [NSString stringWithFormat:@"%@%@",self.perfix, [key upercaseFirstChar]];
        NSString *arraySubClassName = [NSString stringWithFormat:@"%@%@%@",self.perfix, [key upercaseFirstChar], ARRAY_INNER_CLASS_TAIL_PIX];
        //        NSLog(@"key = %@, value = %@, value class = %@", key, value, [value className]);
        
        if ([value isKindOfClass:[NSString class]])
        {
            [str appendFormat:@"\n    [str appendFormat:@\"\\n %@ = %%@\", self.%@];", key, key];
        }
        else if ([value isKindOfClass:[NSNumber class]])
        {
            [str appendFormat:@"\n    [str appendFormat:@\"\\n %@ : %%%@\", self.%@];", key, [self makeMClassDescriptionNumberType:CFNumberGetType((CFNumberRef)value)], key];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            [str appendFormat:@"\n    [str appendFormat:@\"\\n %@ = NSArray\\n    ------------------------------\"];", key];
            NSArray *array = (NSArray *)value;
            
            if ([array count] > 0)
            {
                NSObject *obj = [array objectAtIndex:0];
                
                if ([obj isKindOfClass:[NSDictionary class]])
                {
                    [str appendFormat:@"\n    for (NSInteger i=0; i<self.%@.count; i++)"
                                      @"\n    {"
                                      @"\n        %@ *arrayItem = self.%@[i];"
                                      @"\n        [str appendFormat:@\"\\n[%%ld] %%@\", (long)i, arrayItem];"
                                      @"\n    }",
                     key, arraySubClassName, key];
                }
                else if ([obj isKindOfClass:[NSString class]])
                {
                    [str appendFormat:@"\n    for (NSInteger i=0; i<self.%@.count; i++)"
                                      @"\n    {"
                                      @"\n        [str appendFormat:@\"\\n[%%ld] %%@\", (long)i, self.%@[i]];"
                                      @"\n    }",
                     key, key];
                }
                else if ([obj isKindOfClass:[NSNumber class]])
                {
                    [str appendFormat:@"\n    for (NSInteger i=0; i<self.%@.count; i++)"
                                      @"\n    {"
                                      @"\n      [str appendFormat:@\"\\n[%%ld] %%%@\", (long)i, self.%@[i]];"
                                      @"\n    }",
                     key, [self makeMClassDescriptionNumberType:CFNumberGetType((CFNumberRef)value)], key];
                }
            }
            [str appendFormat:@"\n    [str appendFormat:@\"\\n    ------------------------------\"];"];
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            [str appendFormat:@"\n    [str appendFormat:@\"\\n %@ = NSObject%%@\", self.%@];", [NSString stringWithFormat:@"%@", subClassName], key];
        }
    }
    [str appendFormat:@"\n    [str appendFormat:@\"\\n============================================\"];"];
    [str appendFormat:@"\n\n    return str;"
     @"\n}"];
    return str;
}

- (NSString *)makeDescriptionSwift
{
    NSMutableString *str = [[NSMutableString alloc] init];
    
    [str appendFormat:@"\n\nextension %@ : CustomStringConvertible {", self.name];
    
    
    [str appendFormat:@"\n\n    public var description: String {"
                      @"\n        get {"
                      @"\n            var str: String = \"\""
                      @"\n\n             str += \"\\n==== ** \\(String(describing: type(of: self)) ) ** ====\" ", self.name];
    
    for (PropertyModelData *propertyModelData in self.propertyList)
    {
        NSString *key = propertyModelData.key;
        NSObject *value = propertyModelData.value;
        NSString *subClassName = [NSString stringWithFormat:@"%@%@",self.perfix, [key upercaseFirstChar]];
        NSString *arraySubClassName = [NSString stringWithFormat:@"%@%@%@",self.perfix, [key upercaseFirstChar], ARRAY_INNER_CLASS_TAIL_PIX];
        //        NSLog(@"key = %@, value = %@, value class = %@", key, value, [value className]);
        
        if ([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSNumber class]])
        {
            [str appendFormat:@"\n             str += \"\\n %@ = \\(self.%@)\" ", key, key];
        }
        else if ([value isKindOfClass:[NSArray class]])
        {
            [str appendFormat:@"\n             str += \"\\n %@ = Array(\\( self.%@.count )) ------------------------------\" ", key, key];
            NSArray *array = (NSArray *)value;
            
            if ([array count] > 0)
            {
                [str appendFormat:@"\n             for (idx, item) in self.%@.enumerated() {"
                                  @"\n                str += \"\\n\\t item: \\(idx) \\(item)\""
                                  @"\n             }",
                 key];
            }
            [str appendFormat:@"\n             str += \"\\n------------------------------------------------------------\" "];
        }
        else if ([value isKindOfClass:[NSDictionary class]])
        {
            [str appendFormat:@"\n             str += \"\\n %@ = Object \\(String(describing: self.%@))\" ", subClassName, key];
        }
    }
    [str appendFormat:@"\n             str += \"\\n--- ** \\(String(describing: type(of: self)) ) ** ------------------------------\" "];
    [str appendFormat:@"\n\n            return str"
                      @"\n        }"];
    
    [str appendString:@"\n    }"];
    [str appendString:@"\n}"];
    
    return str;
}

@end




























