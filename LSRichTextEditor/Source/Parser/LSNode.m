//
//  LSNode.m
//  LSTextEditor
//
//  Created by Peter Lieder on 19/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import "LSNode.h"

@implementation LSNode

+ (instancetype)nodeWithTagName:(NSString *)tagName andContent:(NSString *)content andAttributes:(NSDictionary *)attributes
{
    LSNode *node = [[LSNode alloc] init];

    node.tagName = tagName;
    node.tagNames = [NSMutableArray arrayWithObject:tagName];
    node.content = content;
    node.attributes = attributes;

    return node;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.children = [NSMutableArray array];
        self.tagNames = [NSMutableArray array];
    }
    
    return self;
}

- (instancetype)nodeFromParentNode:(NSString *)tagName andContent:(NSString *)content andAttributes:(NSDictionary *)attributes
{
    LSNode *node = [[LSNode alloc] init];

    node.tagNames = [self.tagNames mutableCopy];
    
    if (tagName) {
        [node.tagNames addObject:tagName];
    }

    node.tagName = tagName;
    node.content = content;
    node.attributes = attributes;

    return node;
}

- (void)addChildNode:(LSNode *)node
{
    if (!node) {
        return;
    }

    node.parentNode = self;
    [self.children addObject:node];
}

#pragma mark - debug methods

- (NSString *)debugString
{
    NSMutableString *output = [NSMutableString stringWithFormat:@":%@-%@", self.tagName, self.content];

    if (self.attributes.count > 0) {
        [output appendString:@"["];
        [self.attributes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [output appendString:[NSMutableString stringWithFormat:@"%@=%@ ",(NSString *)key, (NSString *)obj]];
        }];
        [output appendString:@"]"];
    }

    if (self.tagNames.count > 0) {
        [output appendString:@"*"];
        [self.tagNames enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [output appendString:[NSMutableString stringWithFormat:@"%@ ", (NSString *)obj]];
        }];
        [output appendString:@"*"];
    }

    [output appendString:@":"];

    return output;
}

@end
