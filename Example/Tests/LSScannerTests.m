//
//  LSScannerTests.m
//  LSTextEditor
//
//  Created by Peter Lieder on 16/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LSParser.h"
#import "LSToken.h"
#import "LSNode.h"

@interface LSParser (Test)

- (NSMutableArray *)scan:(NSString *)string error:(NSError **)error;
- (LSNode *)parseTokens:(NSMutableArray *)tokens;
- (NSMutableAttributedString *)buildString:(NSMutableArray *)items;

@end

@interface LSScannerTests : XCTestCase

@property (nonatomic, strong) NSString *testString;
@property (nonatomic, strong) LSParser *testParser;

@end

@implementation LSScannerTests

- (void)setUp {
    [super setUp];
    
    self.testString = @"this is [b][i][u id=\"bla\" img=\"http:://blablub.de\"]just another \n 3 and 4 € [/u][/u]rich [/i]text [/b][s]formatted[/s]  dough!";
    self.testParser = [[LSParser alloc] init];
}

- (void)tearDown {

    [super tearDown];
}

#pragma mark - scan tests

- (void)testSimpleCascadeScan
{
    NSString *testString = @"this is [b][i] just[/i] [/b]text";
    NSString *expectedString = @":4-this is ::1-b::1-i::4- just::2-i::4- ::2-b::4-text:";

    NSMutableArray *tokens = [self.testParser scan:testString error:nil];
    NSString *resultString = [LSParser debugScannedString:tokens];

    XCTAssert(resultString > 0, @"Scanned string is empty!");
    XCTAssertEqualObjects(resultString, expectedString, @"Scanned token result isn't correct!");
}

- (void)testWrongCascadeScan
{
    NSString *testString = @"this is [b][i] just[/b] [/i]text";
    NSString *expectedString = @":4-this is ::1-b::1-i::4- just::2-b::4- ::2-i::4-text:";

    NSMutableArray *tokens = [self.testParser scan:testString error:nil];
    NSString *resultString = [LSParser debugScannedString:tokens];

    XCTAssert(resultString > 0, @"Scanned string is empty!");
    XCTAssertEqualObjects(resultString, expectedString, @"Scanned token result isn't correct!");
}

- (void)testScanSimpleCascadeWithNewline
{
    NSString *testString = @"this is\n [b][i] just[/i] \n [/b]text";
    NSString *expectedString = @":4-this is::8-\n::4- ::1-b::1-i::4- just::2-i::4- ::8-\n::4- ::2-b::4-text:";

    NSMutableArray *tokens = [self.testParser scan:testString error:nil];
    NSString *resultString = [LSParser debugScannedString:tokens];

    XCTAssert(resultString > 0, @"Scanned string is empty!");
    XCTAssertEqualObjects(resultString, expectedString, @"Scanned token result isn't correct!");

    NSLog(@"==> rebuilt string: %@ ", [LSParser debugScannedString:tokens]);
}

#pragma mark - parse tests

- (void)testParseSimpleTokens
{
    NSString *testString = @"this is [b][i] just[/i] [/b]text";
    NSString *expectedString = @":(null)-this is *ROOT *::b-(null)*ROOT b *::i-(null)*ROOT b i *::(null)- just*ROOT b i *::(null)- *ROOT b *::(null)-text*ROOT *:";

    NSMutableArray *results = [self.testParser scan:testString error:nil];
    LSNode *rootNode = [self.testParser parseTokens:results];
    NSString *resultString = [LSParser debugParsedString:rootNode];

    XCTAssert(resultString > 0, @"Parsed string is empty!");
    XCTAssertEqualObjects(resultString, expectedString, @"Parsed token result isn't correct!");
}

- (void)testParseSimpleTokensWrongOrder
{
    NSString *testString = @"this is [b][i] just[/b] [/i]text";
    NSString *expectedString = @":(null)-this is *ROOT *::b-(null)*ROOT b *::i-(null)*ROOT b i *::(null)- just*ROOT b i *::i-(null)*ROOT i *::(null)- *ROOT i *::(null)-text*ROOT *:";

    NSMutableArray *results = [self.testParser scan:testString error:nil];
    LSNode *rootNode = [self.testParser parseTokens:results];
    NSString *resultString = [LSParser debugParsedString:rootNode];

    XCTAssert(resultString > 0, @"Parsed string is empty!");
    XCTAssertEqualObjects(resultString, expectedString, @"Parsed token result isn't correct!");
}

- (void)testParseSimpleTokensWrongOrder2
{
    NSString *testString = @"this is [b][i][u][s] just[/b] [/i][/s][/u]text";
    NSString *expectedString = @":(null)-this is *ROOT *::b-(null)*ROOT b *::i-(null)*ROOT b i *::u-(null)*ROOT b i u *::s-(null)*ROOT b i u s *::(null)- just*ROOT b i u s *::i-(null)*ROOT i *::u-(null)*ROOT i u *::s-(null)*ROOT i u s *::(null)- *ROOT i u s *::u-(null)*ROOT u *::s-(null)*ROOT u s *::(null)-text*ROOT *:";
    
    NSMutableArray *results = [self.testParser scan:testString error:nil];
    LSNode *rootNode = [self.testParser parseTokens:results];
    NSString *resultString = [LSParser debugParsedString:rootNode];
    
    XCTAssert(resultString > 0, @"Parsed string is empty!");
    XCTAssertEqualObjects(resultString, expectedString, @"Parsed token result isn't correct!");
}

- (void)testParseTokensWithDuplicates
{
    NSString *testString = @"this is [b][i] just[/i] [/i][/i][/i][/b]text";
    NSString *expectedString = @":(null)-this is *ROOT *::b-(null)*ROOT b *::i-(null)*ROOT b i *::(null)- just*ROOT b i *::(null)- *ROOT b *::(null)-text*ROOT *:";
    
    NSMutableArray *results = [self.testParser scan:testString error:nil];
    LSNode *rootNode = [self.testParser parseTokens:results];
    NSString *resultString = [LSParser debugParsedString:rootNode];
    
    XCTAssert(resultString > 0, @"Parsed string is empty!");
    XCTAssertEqualObjects(resultString, expectedString, @"Parsed token result isn't correct!");
}

- (void)testParseTokensWithNewlines
{
    NSString *testString = @"this\n is [b][i] just[/i]\n [/b]text";
    NSString *expectedString = @":(null)-this*ROOT *::(null)-\n*ROOT *::(null)- is *ROOT *::b-(null)*ROOT b *::i-(null)*ROOT b i *::(null)- just*ROOT b i *::(null)-\n*ROOT b *::(null)- *ROOT b *::(null)-text*ROOT *:";
    
    NSMutableArray *results = [self.testParser scan:testString error:nil];
    LSNode *rootNode = [self.testParser parseTokens:results];
    NSString *resultString = [LSParser debugParsedString:rootNode];
    
    XCTAssert(resultString > 0, @"Parsed string is empty!");
    XCTAssertEqualObjects(resultString, expectedString, @"Parsed token result isn't correct!");
}

- (void)testParseSimpleTokensCascaded
{
    NSString *testString = @"[u][i][b]Dcghjjjhghhkjhjkmnhhh hhhhj[/b][/i][/u]";
    NSString *expectedString = @":u-(null)*ROOT u *::i-(null)*ROOT u i *::b-(null)*ROOT u i b *::(null)-Dcghjjjhghhkjhjkmnhhh hhhhj*ROOT u i b *:";
    
    NSMutableArray *results = [self.testParser scan:testString error:nil];
    LSNode *rootNode = [self.testParser parseTokens:results];
    NSString *resultString = [LSParser debugParsedString:rootNode];
    
    XCTAssert(resultString > 0, @"Parsed string is empty!");
    XCTAssertEqualObjects(resultString, expectedString, @"Parsed token result isn't correct!");

    NSLog(@"=+>\n\n %@\n\n", [LSParser debugParsedString:rootNode]);
}

@end
