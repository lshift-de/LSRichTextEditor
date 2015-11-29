//
//  LSNode.h
//  LSTextEditor
//
//  Created by Peter Lieder on 19/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LSNode : NSObject

@property (nonatomic, strong) NSString *tagName;
@property (nonatomic, strong) NSMutableArray *tagNames;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, weak) LSNode *parentNode;

+ (instancetype)nodeWithTagName:(NSString *)tagName andContent:(NSString *)content andAttributes:(NSDictionary *)attributes;
- (NSString *)debugString;

- (instancetype)nodeFromParentNode:(NSString *)tagName andContent:(NSString *)content andAttributes:(NSDictionary *)attributes;
- (void)addChildNode:(LSNode *)node;

@end
