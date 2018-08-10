//
//  NSString+Helper.m
//  ChatOnClient
//
//  Created by lambert on 2014. 5. 9..
//
//

#import "NSString+Helper.h"

@implementation NSString (Helper)

- (BOOL)isValid
{
    if (((NSNull *)self == [NSNull null]) || (self == nil) || ([self length] == 0) || ([[self trim] length] == 0) || [self isEqualToString:@"(null)"] || [self isEqualToString:@"null"])
    {
        return NO;
    }
    
    return YES;
}

- (NSString *)trim
{
	return [self stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}


- (NSString *)remainNumberCharactersOnly
{
    return [[self componentsSeparatedByCharactersInSet:[[NSCharacterSet characterSetWithCharactersInString:@"0123456789"] invertedSet]] componentsJoinedByString:@""];
}

- (NSString *)upercaseFirstChar
{
    NSMutableString *className = [NSMutableString stringWithString:self];
    if(className.length > 1) {
        NSString *temp = [className substringToIndex:1];
    
        [className replaceCharactersInRange:NSMakeRange(0 /* start */, 1 /* end */) withString:[temp uppercaseString]];
    }
    
    return className;
}

@end
