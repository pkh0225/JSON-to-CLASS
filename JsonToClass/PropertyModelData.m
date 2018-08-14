//
//  PropertyModelData.m
//  JsonToClass
//
//  Created by pkh on 2017. 5. 31..
//  Copyright © 2017년 pkh. All rights reserved.
//

#import "PropertyModelData.h"
#import "NSString+Helper.h"



@implementation PropertyModelData

+ (PropertyModelData*)allocWithKey:(NSString*)key object:(NSObject*)object perfix:(NSString*)perfix {
    return [[PropertyModelData alloc] initWithKey:key object:object perfix:perfix];
}

- (id)initWithKey:(NSString*)key object:(NSObject*)object perfix:(NSString*)perfix {
    self = [super init];
    if(self)
    {    
        [self setKey:key object:object perfix:perfix];
    }
    return self;
}

- (void)setKey:(NSString*)key object:(NSObject*)object perfix:(NSString*)perfix {
    self.key = key;
    self.value = object;
    self.perfix = perfix;
}

- (NSString*)getStringObjectC {
    
    NSString *directive = @"strong";
    NSString *className = nil;
    NSString *keyName = [NSString stringWithFormat:@"*%@", self.key];
    
    if ([self.value isKindOfClass:[NSString class]])
    {
        className = @"NSString";
    }
    else if ([self.value isKindOfClass:NSNumber.class])
    {
        directive = @"assign";
        keyName = self.key;
        className = [self getNumberClassNumberType:(NSNumber*)self.value];
    }
    else if ([self.value isKindOfClass:NSArray.class])
    {
        NSArray *obj = (NSArray*)self.value;
        NSObject *subObj = obj.firstObject;
        if ([subObj isKindOfClass:NSString.class]) {
            className = @"NSArry<NSString*>";
        }
        else {
            className = [NSString stringWithFormat:@"NSMutableArray<%@%@%@*>",self.perfix, [self.key upercaseFirstChar], ARRAY_INNER_CLASS_TAIL_PIX];
        }
    }
    else if ([self.value isKindOfClass:[NSDictionary class]])
    {
        className = [NSString stringWithFormat:@"%@%@", self.perfix, [self.key upercaseFirstChar]];
    }
    else if ([self.value isKindOfClass:[NSNull class]])
    {
        className = @"unknow";
    }
    
    return [NSString stringWithFormat:@"\n@property (nonatomic, %@) %@ %@;",directive, className, keyName];
    
}

- (NSString*)getStringSwif {
    
    NSString *className = nil;
    NSString *defaultValue = @" = 0";
    
    if ([self.value isKindOfClass:NSString.class])
    {
        className = @"String";
        defaultValue = @" = \"\"";
        return [NSString stringWithFormat:@"\n    var %@: %@%@", self.key, className, defaultValue];
    }
    else if ([self.value isKindOfClass:NSNumber.class])
    {
        className = [self getNumberClassNumberTypeSwift:(NSNumber*)self.value];
        defaultValue = [self getNumberDefaultValueNumberTypeSwift:(NSNumber*)self.value];
        return [NSString stringWithFormat:@"\n    var %@: %@%@", self.key, className, defaultValue];
    }
    else if ([self.value isKindOfClass:NSArray.class])
    {
        NSArray *obj = (NSArray*)self.value;
        NSObject *subObj = obj.firstObject;
        if ([subObj isKindOfClass:NSString.class]) {
            return [NSString stringWithFormat:@"\n    var %@ = [String]()", self.key];
        }
        else {
            className = [NSString stringWithFormat:@"[%@%@%@]",self.perfix, [self.key upercaseFirstChar], ARRAY_INNER_CLASS_TAIL_PIX];
            defaultValue =[NSString stringWithFormat:@"%@()", className];
            return [NSString stringWithFormat:@"\n    var %@ = %@", self.key, defaultValue];
        }
        
    }
    else if ([self.value isKindOfClass:NSDictionary.class])
    {
        className = [NSString stringWithFormat:@"%@%@", self.perfix, [self.key upercaseFirstChar]];
        defaultValue = [NSString stringWithFormat:@"%@?", className];
        return [NSString stringWithFormat:@"\n    var %@: %@", self.key, defaultValue];
    }
    else if ([self.value isKindOfClass:NSNull.class])
    {
        className = @"unknow??";
        return [NSString stringWithFormat:@"\n    var %@: %@", self.key, className];
    }
    else {
        return @"";
    }
    
    
    
}


- (NSString*)getNumberClassNumberType:(NSNumber*)number
{
    //            NSLog(@"key = %@, value = %@, value class = %ld", key, value, numberType);
    switch (CFNumberGetType((CFNumberRef)number))
    {
        case kCFNumberSInt64Type:
            return @"NSInteger";
            break;
        case kCFNumberCharType:
            return @"BOOL";
            break;
        case kCFNumberFloat64Type:
            return @"CGFloat";
            break;
        default:
            return @"NSNumber";
            break;
    }
}

- (NSString*)getNumberClassNumberTypeSwift:(NSNumber*)number
{
    //            NSLog(@"key = %@, value = %@, value class = %ld", key, value, numberType);
    switch (CFNumberGetType((CFNumberRef)number))
    {
        case kCFNumberSInt64Type:
            return @"Int";
            break;
        case kCFNumberCharType:
            return @"Bool";
            break;
        case kCFNumberFloat64Type:
            return @"Float";
            break;
        default:
            return @"NSNumber";
            break;
    }
}


- (NSString*)getNumberDefaultValueNumberTypeSwift:(NSNumber*)number
{
    //            NSLog(@"key = %@, value = %@, value class = %ld", key, value, numberType);
    switch (CFNumberGetType((CFNumberRef)number))
    {
        case kCFNumberSInt64Type:
            return @" = 0";
            break;
        case kCFNumberCharType:
            return @" = false";
            break;
        case kCFNumberFloat64Type:
            return @" = 0.0";
            break;
        default:
            return @" = 0";
            break;
    }
}

- (NSString*)isImportClass {
    NSString *className = nil;
    
    if ([self.value isKindOfClass:NSArray.class])
    {
        className = [NSString stringWithFormat:@"\n#import \"%@%@%@.h\"",self.perfix, [self.key upercaseFirstChar], ARRAY_INNER_CLASS_TAIL_PIX];
    }
    else if ([self.value isKindOfClass:[NSDictionary class]])
    {
        className = [NSString stringWithFormat:@"\n#import \"%@%@.h\"", self.perfix, [self.key upercaseFirstChar]];
    }
    
    return className;
}

@end
