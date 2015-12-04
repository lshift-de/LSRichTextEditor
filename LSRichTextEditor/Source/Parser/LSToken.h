//
//  LSToken.h
//  LSTextEditor
//
//  Created by Peter Lieder on 19/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, LSTokenType) {
    LSTokenTypeOpenTag          = 1 << 0,
    LSTokenTypeCloseTag         = 1 << 1,
    LSTokenTypeContent          = 1 << 2,
    LSTokenTypeNewline          = 1 << 3
};

@interface LSToken : NSObject

@property (nonatomic, assign) LSTokenType type;
@property (nonatomic, strong) NSString *value;
@property (nonatomic, strong) NSDictionary *attributes;

+ (instancetype)tokenWithType:(LSTokenType)type andValue:(NSString *)value andAttributes:(NSDictionary *)attributes;
- (NSString *)string;
- (NSString *)debugString;

@end
