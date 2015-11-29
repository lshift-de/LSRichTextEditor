//
//  LSParser.m
//  LSTextEditor
//
//  Created by Peter Lieder on 19/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import "LSParser.h"
#import "LSToken.h"
#import "LSNode.h"

@interface LSParser ()

@property (nonatomic, strong) NSScanner *scanner;
@property (nonatomic, strong) NSArray *scannedTokens;
@property (nonatomic, strong) LSNode *parsedRootNode;

@end

@implementation LSParser


#pragma mark - lexer & parser impl

- (LSNode *)parseString:(NSString *)string error:(NSError **)error
{
    NSArray *tokens = [self scan:string error:error];

    return [self parseTokens:tokens];
}

- (LSNode *)parseTokens:(NSArray *)tokens
{
    LSNode *rootNode = [LSNode nodeWithTagName:@"ROOT" andContent:nil andAttributes:nil];
    LSNode *currentNode = rootNode;
    
    for (LSToken *token in tokens) {
        
        if (token.type == LSTokenTypeContent || token.type == LSTokenTypeNewline) {
            // newline char is handled like content at the moment
            LSNode *newContentNode = [currentNode nodeFromParentNode:nil andContent:token.value andAttributes:nil];
            [currentNode addChildNode:newContentNode];
        } else if (token.type == LSTokenTypeOpenTag) {
            LSNode *newContentNode = [currentNode nodeFromParentNode:token.value andContent:nil andAttributes:token.attributes];
            [currentNode addChildNode:newContentNode];
            currentNode = newContentNode;

        } else if (token.type == LSTokenTypeCloseTag) {
            if ([currentNode.tagName isEqual:token.value]) {
                currentNode = currentNode.parentNode;
            } else {
                if ([currentNode.tagNames containsObject:token.value]) {

                    // do a backtracing only if the closing tag has a valid context
                    LSNode *backtraceNode = nil;
                    LSNode *saveNode = nil;
                    while (currentNode.tagName && ![currentNode.tagName isEqual:token.value]) {
                        LSNode *newNode = [LSNode nodeWithTagName:currentNode.tagName andContent:nil andAttributes:currentNode.attributes];
                        [newNode addChildNode:backtraceNode];
                    
                        NSMutableArray *tagNamesCopy = [currentNode.tagNames mutableCopy];
                        [tagNamesCopy removeObject:token.value];
                        newNode.tagNames = tagNamesCopy;

                        currentNode = currentNode.parentNode;
                        backtraceNode = newNode;
                        
                        if (!saveNode) {
                            saveNode = newNode;
                        }
                    }

                    if ([currentNode.tagName isEqual:token.value]) {
                        currentNode = currentNode.parentNode;
                    }

                    [currentNode addChildNode:backtraceNode];
                    currentNode = saveNode;
                }
            }
        }
    }
    
    return rootNode;
}

#pragma mark - scan tasks

- (NSMutableArray *)scan:(NSString *)string error:(NSError **)error
{
    self.scanner = [NSScanner scannerWithString:string];
    
    // this line is needed since whitespace chars are stripped out by default
    [self.scanner setCharactersToBeSkipped:[NSCharacterSet characterSetWithCharactersInString:@""]];
    
    NSMutableArray *results = [NSMutableArray array];
    
    while (!self.scanner.isAtEnd) {
        LSTokenType key = LSTokenTypeContent;
        NSString *value = nil;
        NSDictionary *attributes = nil;
        
        BOOL didScan = [self scanNewLine:&value andKey:&key] ||
        [self scanContent:&value andKey:&key] ||
        [self scanCloseTag:&value andKey:&key] ||
        [self scanOpenTag:&value andKey:&key andAttributes:&attributes];
        
        if (!didScan) {
            NSLog(@"Couldn't parse: %lu", (unsigned long)self.scanner.scanLocation);
            return nil;
        }
        
        if (value) {
            [results addObject:[LSToken tokenWithType:key andValue:value andAttributes:attributes]];
        }
    }
    return results;
}

- (BOOL)scanOpenTag:(NSString **)out andKey:(LSTokenType *)key andAttributes:(NSDictionary **)attributes
{
    *key = LSTokenTypeOpenTag;
    BOOL didScan = [self.scanner scanString:@"[" intoString:NULL] &&
    [self.scanner scanUpToString:@"]" intoString:out] &&
    [self.scanner scanString:@"]" intoString:NULL];
    
    if (didScan && ([*out rangeOfString:@"="].length > 0)) {
        NSString *tagString = [*out copy];
        
        NSRange firstSeparatorRange = [tagString rangeOfString:@" "];
        if (firstSeparatorRange.length > 0) {
            *out = [tagString substringWithRange:NSMakeRange(0, firstSeparatorRange.location)];
            *attributes = [NSMutableDictionary new];

            NSString *attributesString = [tagString substringWithRange:
                                          NSMakeRange(firstSeparatorRange.location + 1, tagString.length - [*out length] - 1)];

            NSRegularExpression *regex = [NSRegularExpression
                                      regularExpressionWithPattern:@"(\\S+)=[\"']?((?:.(?![\"\']?\\s+(?:\\S+)=|[>\"']))+.)[\"']?"
                                      options:0
                                      error:nil];
        
            [regex enumerateMatchesInString:attributesString
                                options:0
                                  range:NSMakeRange(0, attributesString.length)
                             usingBlock:^(NSTextCheckingResult *match,
                                          NSMatchingFlags flags,
                                          BOOL *stop) {

                                 NSRange keyRange = [match rangeAtIndex:1];
                                 NSRange valueRange = [match rangeAtIndex:2];
                                 [*attributes setValue:[attributesString substringWithRange:valueRange]
                                                forKey:[attributesString substringWithRange:keyRange]];
                             }];
        }
    }
    
    return didScan ? YES : NO;
}

- (BOOL)scanCloseTag:(NSString **)out andKey:(LSTokenType *)key
{
    *key = LSTokenTypeCloseTag;
    BOOL didScan = [self.scanner scanString:@"[/" intoString:NULL] &&
    [self.scanner scanUpToString:@"]" intoString:out] &&
    [self.scanner scanString:@"]" intoString:NULL];
    
    return didScan ? YES : NO;
}

- (BOOL)scanNewLine:(NSString **)out andKey:(LSTokenType *)key
{
    *key = LSTokenTypeNewline;
    BOOL didScan = [self.scanner scanString:@"\n" intoString:out];

    return didScan ? YES : NO;
}

- (BOOL)scanContent:(NSString **)out andKey:(LSTokenType *)key
{
    *key = LSTokenTypeContent;
    BOOL didScan = [self.scanner scanUpToString:@"[" intoString:out];

    if (didScan && ([*out rangeOfString:@"\n"].length > 0)) {
        NSString *contentString = [*out copy];
        NSRange newlineRange = [contentString rangeOfString:@"\n"];
        self.scanner.scanLocation = self.scanner.scanLocation - (contentString.length - newlineRange.location);
        *out = [contentString substringWithRange:NSMakeRange(0, newlineRange.location)];
    }

    return didScan ? YES : NO;
}

#pragma mark - debug output

- (NSMutableAttributedString *)buildString:(NSMutableArray *)items
{
    NSMutableAttributedString *resultString = [[NSMutableAttributedString alloc] init];
    
    for (LSToken *token in items)
    {
        if (token.type == LSTokenTypeContent || token.type == LSTokenTypeNewline) {
            [resultString appendAttributedString:[[NSAttributedString alloc] initWithString:token.value]];
        }
    }
    
    return resultString;
}

+ (NSString *)debugScannedString:(NSMutableArray *)tokens
{
    NSMutableString *resultString = [[NSMutableString alloc] init];

    [tokens enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [resultString appendString:[(LSToken *)obj debugString]];
    }];

    return resultString;
}

+ (NSString *)debugParsedString:(LSNode *)rootNode
{
    __block NSMutableString *resultString = [[NSMutableString alloc] init];
    
    [rootNode.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [LSParser processParsedString:(LSNode *)obj resultString:&resultString];
    }];
    
    return resultString;
}

+ (void)processParsedString:(LSNode *)currentNode resultString:(NSMutableString **)outString
{
    __block NSMutableString *resultString = [[NSMutableString alloc] init];

    if (currentNode.tagName) {
        [resultString appendString:[currentNode debugString]];
        [currentNode.children enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [LSParser processParsedString:(LSNode *)obj resultString:&resultString];
        }];
    } else {
        [resultString appendString:[currentNode debugString]];
    }

    [*outString appendString:resultString];
}

@end
