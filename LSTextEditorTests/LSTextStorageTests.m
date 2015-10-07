//
//  LSTextStorageTests.m
//  LSTextEditor
//
//  Created by Peter Lieder on 01/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "LSTextStorage.h"
#import "LSRichTextView.h"

@interface LSTextStorageTests : XCTestCase

@property (nonatomic) LSTextStorage *testTextStorage;
@property (nonatomic) UITextView *testTextView;
@property (nonatomic) UIFont *testPreconditionFont;

@end

@interface LSTextStorage (Test)

- (void)applyStylesToRange:(NSRange)searchRange;

@end

@implementation LSTextStorageTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    self.testTextStorage = [[LSTextStorage alloc] init];
    [self initTextView];
    
    self.testTextStorage.delegate = self.testTextView;
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)initTextView
{
    self.testTextView = [[UITextView alloc] init];
    self.testPreconditionFont = [UIFont fontWithName:@"Georgia" size:18];
    self.testTextView.font = self.testPreconditionFont;
}

- (void)testApplyStylesToRangeNormalString
{
    NSString *inputString = @"This [b]is our[/b] [i]input string[/i]";
    NSString *expectedString = @"This is our input string";
    [self.testTextStorage appendAttributedString:[[NSAttributedString alloc] initWithString:inputString attributes:@{NSFontAttributeName:self.testPreconditionFont}]];

    [self.testTextStorage applyStylesToRange:NSMakeRange(0, inputString.length)];

    XCTAssert(self.testTextStorage.string.length < inputString.length, @"TextStorage backing string isn't reduced in size!");
    XCTAssert(self.testTextStorage.string.length == (inputString.length - 14), @"TextStorage backing string tags aren't reduced correctly!");
    XCTAssertEqualObjects(self.testTextStorage.string, expectedString, @"extStorage backing string result string isn't correct!");

    [self verifyFontNotChanged];
}

- (void)testApplyStylesToRangeNormalStringCascaded
{
    NSString *inputString = @"[b]This is [i]our [s]input [u]string[/u][/s][/i][/b]";
    NSString *expectedString = @"This is our input string";
    [self.testTextStorage appendAttributedString:[[NSAttributedString alloc] initWithString:inputString attributes:@{NSFontAttributeName:self.testPreconditionFont}]];

    [self.testTextStorage applyStylesToRange:NSMakeRange(0, inputString.length)];

    XCTAssert(self.testTextStorage.string.length < inputString.length, @"TextStorage backing string isn't reduced in size!");
    XCTAssert(self.testTextStorage.string.length == (inputString.length - 28), @"TextStorage backing string tags aren't reduced correctly!");
    XCTAssertEqualObjects(self.testTextStorage.string, expectedString, @"extStorage backing string result string isn't correct!");

    [self verifyFontNotChanged];
}

- (void)testApplyStylesToRangeNormalStringWithLinebreaks
{
    NSString *inputString = @"[b]This is [i]our \n[s]input \n[u]string[/u][/s][/i][/b]";
    NSString *expectedString = @"This is our \ninput \nstring";
    [self.testTextStorage appendAttributedString:[[NSAttributedString alloc] initWithString:inputString attributes:@{NSFontAttributeName:self.testPreconditionFont}]];
    
    [self.testTextStorage applyStylesToRange:NSMakeRange(0, inputString.length)];
    
    XCTAssert(self.testTextStorage.string.length < inputString.length, @"TextStorage backing string isn't reduced in size!");
    XCTAssert(self.testTextStorage.string.length == (inputString.length - 28), @"TextStorage backing string tags aren't reduced correctly!");
    XCTAssertEqualObjects(self.testTextStorage.string, expectedString, @"extStorage backing string result string isn't correct!");

    [self verifyFontNotChanged];
}

- (void)verifyFontNotChanged
{
    for (NSUInteger index = 0; index < self.testTextStorage.string.length; index++) {
        NSDictionary *attributes = [self.testTextStorage attributesAtIndex:index effectiveRange:nil];
        NSMutableDictionary *mutableAttributes = [NSMutableDictionary dictionaryWithDictionary:attributes];
        UIFont *font = [mutableAttributes objectForKey:NSFontAttributeName];
        
        XCTAssert([font.fontName hasPrefix:self.testPreconditionFont.fontName], "Font name was changed during parsing!");
        XCTAssertEqual(font.pointSize, self.testPreconditionFont.pointSize, "Font size was changed during parsing!");
    }
}

@end
