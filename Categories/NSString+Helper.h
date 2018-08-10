//
//  NSString+Helper.h
//  ChatOnClient
//
//  Created by lambert on 2014. 5. 9..
//
//

#import <Foundation/Foundation.h>

#define ARRAY_INNER_CLASS_TAIL_PIX @"Item"

@interface NSString (Helper)

- (BOOL)isValid;

- (NSString *)trim;


- (NSString *)remainNumberCharactersOnly;

- (NSString *)upercaseFirstChar;
@end
