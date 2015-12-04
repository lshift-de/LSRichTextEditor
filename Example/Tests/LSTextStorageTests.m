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
#import <OCMock/OCMock.h>

@interface LSTextStorageTests : XCTestCase

@property (nonatomic) LSTextStorage *testTextStorage;
@property (nonatomic) LSRichTextView *testTextView;
@property (nonatomic) UIFont *testPreconditionFont;

@end

@interface LSTextStorage (Test)

- (void)applyStylesToRange:(NSRange)searchRange withAttributedText:(NSAttributedString *)attributedText;

@end

@implementation LSTextStorageTests

- (void)setUp {
    [super setUp];

    [self initTextView];
    self.testTextStorage = [[LSTextStorage alloc] initWithTextView:self.testTextView];

    self.testTextStorage.delegate = self.testTextView;
}

- (void)tearDown {
    self.testTextStorage = nil;
    [super tearDown];
}

- (void)initTextView
{
    self.testPreconditionFont = [UIFont fontWithName:@"Georgia" size:18];

    LSRichTextConfiguration *configuration = [OCMockObject mockForClass:[LSRichTextConfiguration class]];
    OCMStub([configuration configurationFeatures]).andReturn(LSRichTextFeaturesAll);

    self.testTextView = [OCMockObject niceMockForClass:[LSRichTextView class]];
    OCMStub([self.testTextView font]).andReturn(self.testPreconditionFont);
    OCMStub([self.testTextView richTextConfiguration]).andReturn(configuration);
    OCMStub([self.testTextView hasText]).andReturn(YES);
}

- (void)testApplyStylesToRangeNormalString
{
    NSString *inputString = @"This [b]is our[/b] [i]input string[/i]";
    NSString *expectedString = @"This is our input string";
    NSAttributedString *inString = [[NSAttributedString alloc] initWithString:inputString attributes:@{NSFontAttributeName:self.testPreconditionFont}];

    [self.testTextStorage applyStylesToRange:NSMakeRange(0, inString.length) withAttributedText:inString];

    XCTAssert(self.testTextStorage.string.length < inputString.length, @"TextStorage backing string isn't reduced in size!");
    XCTAssert(self.testTextStorage.string.length == (inputString.length - 14), @"TextStorage backing string tags aren't reduced correctly!");
    XCTAssertEqualObjects(self.testTextStorage.string, expectedString, @"extStorage backing string result string isn't correct!");

    [self verifyFontNotChanged];
}

- (void)testApplyStylesToRangeNormalStringCascaded
{
    NSString *inputString = @"[b]This is [i]our [s]input [u]string[/u][/s][/i][/b]";
    NSString *expectedString = @"This is our input string";
    NSAttributedString *inString = [[NSAttributedString alloc] initWithString:inputString attributes:@{NSFontAttributeName:self.testPreconditionFont}];

    [self.testTextStorage applyStylesToRange:NSMakeRange(0, inString.length) withAttributedText:inString];

    XCTAssert(self.testTextStorage.string.length < inputString.length, @"TextStorage backing string isn't reduced in size!");
    XCTAssert(self.testTextStorage.string.length == (inputString.length - 28), @"TextStorage backing string tags aren't reduced correctly!");
    XCTAssertEqualObjects(self.testTextStorage.string, expectedString, @"extStorage backing string result string isn't correct!");

    [self verifyFontNotChanged];
}

- (void)testApplyStylesToRangeNormalStringCascaded2
{
    NSString *inputString = @"[b][i][u]just another [/u]rich [/i]text [/b][s]formatted[/s]";
    NSString *expectedString = @"just another rich text formatted";
    NSAttributedString *inString = [[NSAttributedString alloc] initWithString:inputString attributes:@{NSFontAttributeName:self.testPreconditionFont}];

    [self.testTextStorage applyStylesToRange:NSMakeRange(0, inString.length) withAttributedText:inString];

    XCTAssert(self.testTextStorage.string.length < inputString.length, @"TextStorage backing string isn't reduced in size!");
    XCTAssert(self.testTextStorage.string.length == (inputString.length - 28), @"TextStorage backing string tags aren't reduced correctly!");
    XCTAssertEqualObjects(self.testTextStorage.string, expectedString, @"TextStorage backing string result string isn't correct!");

    [self verifyFontNotChanged];
}

- (void)testApplyStylesToRangeDuplicatedTags
{
    NSString *inputString = @"[u][u]just another [/u][/u]rich text [s]formatted[/s]";
    NSString *expectedString = @"just another rich text formatted";
    NSAttributedString *inString = [[NSAttributedString alloc] initWithString:inputString attributes:@{NSFontAttributeName:self.testPreconditionFont}];

    [self.testTextStorage applyStylesToRange:NSMakeRange(0, inString.length) withAttributedText:inString];

    XCTAssert(self.testTextStorage.string.length < inputString.length, @"TextStorage backing string isn't reduced in size!");
    XCTAssert(self.testTextStorage.string.length == (inputString.length - 21), @"TextStorage backing string tags aren't reduced correctly!");
    XCTAssertEqualObjects(self.testTextStorage.string, expectedString, @"TextStorage backing string result string isn't correct!");

    [self verifyFontNotChanged];
}

- (void)testApplyStylesToRangeNormalStringWithLinebreaks
{
    NSString *inputString = @"[b]This is [i]our \n[s]input \n[u]string[/u][/s][/i][/b]";
    NSString *expectedString = @"This is our \ninput \nstring";
    NSAttributedString *inString = [[NSAttributedString alloc] initWithString:inputString attributes:@{NSFontAttributeName:self.testPreconditionFont}];

    [self.testTextStorage applyStylesToRange:NSMakeRange(0, inString.length) withAttributedText:inString];

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
