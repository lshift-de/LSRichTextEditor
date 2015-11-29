//
//  LSOutputFormatterTests.m
//  LSTextEditor
//
//  Created by Peter Lieder on 15/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "LSRichTextView.h"
#import "LSTextStorage.h"
#import "LSRichTextConfiguration.h"

@interface LSOutputFormatter_Tests : XCTestCase

@property (nonatomic) LSTextStorage *testTextStorage;
@property (nonatomic) LSRichTextView *testTextView;
@property (nonatomic) UIFont *testPreconditionFont;
@property (nonatomic) NSMutableAttributedString *testString;

@end

@interface LSTextStorage (Test)

- (NSString *)createOutputStringFromStore:(NSMutableAttributedString *)backingStore;

@end

@implementation LSOutputFormatter_Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [self initTextView];

    self.testTextStorage = [[LSTextStorage alloc] initWithTextView:self.testTextView];
    self.testTextStorage.delegate = self.testTextView;
    
    [self populateBackingStore];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)initTextView
{
    self.testPreconditionFont = [UIFont fontWithName:@"Helvetica Neue" size:18];
    
    LSRichTextConfiguration *configuration = [OCMockObject mockForClass:[LSRichTextConfiguration class]];
    OCMStub([configuration configurationFeatures]).andReturn(LSRichTextFeaturesAll);
    
    self.testTextView = [OCMockObject mockForClass:[LSRichTextView class]];
    OCMStub([self.testTextView font]).andReturn(self.testPreconditionFont);
    OCMStub([self.testTextView richTextConfiguration]).andReturn(configuration);
    OCMStub([self.testTextView hasText]).andReturn(YES);
}

- (void)populateBackingStore
{
    UIFontDescriptor *basicDescriptor = [self.testPreconditionFont fontDescriptor];

    UIFontDescriptor *fontDescriptorBold = [basicDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFontDescriptor *fontDescriptorItalic = [basicDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitItalic];
    UIFontDescriptor *fontDescriptorBoldItalic = [basicDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold | UIFontDescriptorTraitItalic];

    self.testString = [[NSMutableAttributedString alloc] initWithString:@"just another rich text formatted"
                                                             attributes:@{NSFontAttributeName:self.testPreconditionFont}];
    
    [self.testString addAttributes:@{NSFontAttributeName:[UIFont fontWithDescriptor:fontDescriptorItalic size:0],
                                     NSUnderlineStyleAttributeName: [NSNumber numberWithInt:1]}
                                     range:NSMakeRange(0, 12)];
    [self.testString addAttributes:@{NSFontAttributeName:[UIFont fontWithDescriptor:fontDescriptorBoldItalic size:0]}
                                     range:NSMakeRange(13, 4)];
    [self.testString addAttributes:@{NSFontAttributeName:[UIFont fontWithDescriptor:fontDescriptorBold size:0]}
                                     range:NSMakeRange(18, 4)];
    [self.testString addAttributes:@{NSStrikethroughStyleAttributeName: [NSNumber numberWithInt:1]}
                                     range:NSMakeRange(23, 9)];
}

- (void)testcreateOutputStringFromStore
{
    NSString *expectedString = @"[u][i]just another[/i][/u] [i][b]rich[/b][/i] [b]text[/b] [s]formatted[/s]";

    NSString *formatResult = [self.testTextStorage createOutputStringFromStore:self.testString];

    XCTAssert(self.testString.length < formatResult.length, @"Formatted string isn't expanded in size!");
    XCTAssert(formatResult.length == (self.testString.length + 42), @"Formatted string tags aren't expanded correctly!");
    XCTAssertEqualObjects(formatResult, expectedString, @"Formatted string result string isn't correct!");
}

@end
