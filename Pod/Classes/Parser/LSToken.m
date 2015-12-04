//
//  LSToken.m
//  LSTextEditor
//
//  Created by Peter Lieder on 19/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import "LSToken.h"

@implementation LSToken

+ (instancetype)tokenWithType:(LSTokenType)type andValue:(NSString *)value andAttributes:(NSDictionary *)attributes
{
    LSToken *token = [LSToken new];
    
    token.type = type;
    token.value = value;
    token.attributes = attributes;
    
    return token;
}

- (NSString *)string
{
    NSString *type = @"";
    switch (self.type) {
        case LSTokenTypeOpenTag:
            type = @"LSTokenTypeOpenTag";
            break;
        case LSTokenTypeCloseTag:
            type = @"LSTokenTypeCloseTag";
            break;
        case LSTokenTypeContent:
            type = @"LSTokenTypeContent";
            break;
        case LSTokenTypeNewline:
            type = @"LSTokenTypeNewline";
            break;
        default:
            break;
    }

    return [NSString stringWithFormat:@"type: %@, value: %@, attributes: %@", type, self.value, self.attributes];
}

- (NSString *)debugString
{
    NSMutableString *output = [NSMutableString stringWithFormat:@":%lu-%@", (unsigned long)self.type, self.value];
    
    if (self.attributes.count > 0) {
        [output appendString:@"["];
        [self.attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [output appendString:[NSMutableString stringWithFormat:@"%@=%@ ",(NSString *)key, (NSString *)obj]];
        }];
        [output appendString:@"]"];
    }
    [output appendString:@":"];

    return output;
}

@end
