//
//  LSRichTextViewTests.m
//  LSTextEditor
//
//  Created by Peter Lieder on 02/10/15.
//  Copyright (c) 2015 LShift Services GmbH. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import <OCMock/OCMock.h>
#import "LSTextStorage.h"
#import "LSRichTextView.h"

@interface LSRichTextViewTests : XCTestCase

@property (nonatomic, strong) id mockTextStorage;
@property (nonatomic, strong) id richTextPartialMock;

@end

@interface LSRichTextView (Test)

- (LSTextStorage *)createTextStorage;
- (LSTextStorage *)customTextStorage;
- (void)setText:(NSString *)text;
- (LSRichTextConfiguration *)richTextConfiguration;
- (void)commonSetup:(NSTextContainer *)textContainer;

@end

@interface LSTextStorage (Test)

- (void)replaceCharactersInRange:(NSRange)range withString:(NSString *)str;

@end

@implementation LSRichTextViewTests {
    LSRichTextView *_richTextView;
}

- (void)setUp {
    [super setUp];

    self.mockTextStorage = [OCMockObject niceMockForClass:[LSTextStorage class]];
    OCMStub([self.mockTextStorage processDataDetection]);
    OCMStub([self.mockTextStorage setAttributedText:[OCMArg any]]);

    // we need to keep a strong reference to text view otherwise it's released by ARC
    _richTextView = [[LSRichTextView alloc] initWithFrame:CGRectZero];
    self.richTextPartialMock = [OCMockObject partialMockForObject:_richTextView];

    OCMStub([self.richTextPartialMock customTextStorage]).andReturn(self.mockTextStorage);
    OCMStub([self.richTextPartialMock textStorage]).andReturn(self.mockTextStorage);

    _richTextView.richTextConfiguration.textCheckingTypes = NSTextCheckingTypeLink;
}

- (void)tearDown {
    [super tearDown];
}

- (void)testEmptyTextSetNilValue
{
    OCMStub([self.mockTextStorage string]).andReturn(@"");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(0, 0));

    [self.richTextPartialMock setText:nil];
    
    OCMVerify([self.mockTextStorage processDataDetection]);
    OCMVerify([self.richTextPartialMock setSelectedRange:NSMakeRange(0, 0)]);
}

- (void)testExistingTextSetNilValue
{
    OCMStub([self.mockTextStorage string]).andReturn(@"This is an existing text");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(12, 0));

    [_richTextView setText:nil];
    
    OCMVerify([self.mockTextStorage processDataDetection]);
    OCMVerify([[self.richTextPartialMock reject ] setSelectedRange:NSMakeRange(12, 0)]);
}

- (void)testExistingTextSetNilWithSelectionOutside
{
    OCMStub([self.mockTextStorage string]).andReturn(@"This is an existing text");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(30, 0));

    [_richTextView setText:nil];
    
    OCMVerify([self.mockTextStorage processDataDetection]);
    OCMVerify([self.richTextPartialMock setSelectedRange:NSMakeRange(0, 0)]);
}

- (void)testExistingTextSetNewTextWithSelectionOutside
{
    OCMStub([self.mockTextStorage string]).andReturn(@"This is an existing text");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(10, 0));

    [_richTextView setText:@"Reply..."];

    OCMVerify([self.richTextPartialMock setSelectedRange:NSMakeRange(7, 0)]);
}

- (void)testExistingTextSetNewTextWithSelectionInside
{
    OCMStub([self.mockTextStorage string]).andReturn(@"This is an existing text");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(6, 0));

    [_richTextView setText:@"Reply..."];

    OCMVerify([self.mockTextStorage processDataDetection]);

    // in this case selected range shouldn't be changed!
    OCMVerify([[self.richTextPartialMock reject] setSelectedRange:NSMakeRange(7, 0)]);
}

- (void)testExistingTextSetValidTextWithoutDataDetection
{
    OCMStub([self.mockTextStorage string]).andReturn(@"This is an existing text");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(6, 0));
    _richTextView.richTextConfiguration.textCheckingTypes = NSTextCheckingTypeOrthography;

    [_richTextView setText:@"This is a valid text..."];

    // in this test case link detection and selected range shouldn't be called!
    OCMVerify([[self.mockTextStorage reject] processDataDetection]);
    OCMVerify([[self.richTextPartialMock reject] setSelectedRange:NSMakeRange(7, 0)]);
}

@end
