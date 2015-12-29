/*!
 * This file is part of LSTextEditor.
 *
 * Copyright © 2015 LShift Services GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Authors:
 * - Peter Lieder <peter@lshift.de>
 *
 */

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
