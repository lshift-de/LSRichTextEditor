//
//  LSParser.h
//  LSTextEditor
//
//  Created by Peter Lieder on 19/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LSNode.h"

@interface LSParser : NSObject

+ (NSString *)debugScannedString:(NSMutableArray *)tokens;
+ (NSString *)debugParsedString:(LSNode *)rootNode;

- (LSNode *)parseString:(NSString *)string error:(NSError **)error;

@end
