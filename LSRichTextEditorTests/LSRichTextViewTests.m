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
- (void)setText:(NSString *)text;

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

    // we need to keep a strong reference to text view otherwise it's released by ARC
    _richTextView = [[LSRichTextView alloc] initWithFrame:CGRectZero];
    self.richTextPartialMock = [OCMockObject partialMockForObject:_richTextView];
    OCMStub([self.richTextPartialMock createTextStorage]).andReturn(self.mockTextStorage);
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEmptyTextSetNilValue
{
    OCMStub([self.mockTextStorage string]).andReturn(@"");
    OCMStub([_richTextView selectedRange]).andReturn(NSMakeRange(0, 0));
        
    // UI event needs to be called during preparation phase to init text storage
    [_richTextView willMoveToSuperview:nil];

    [_richTextView setText:nil];
    
    OCMVerify([self.mockTextStorage replaceCharactersInRange:NSMakeRange(0, 0) withString:@""]);
    OCMVerify([self.richTextPartialMock setSelectedRange:NSMakeRange(0, 0)]);
}

- (void)testExistingTextSetNilValue
{
    OCMStub([self.mockTextStorage string]).andReturn(@"This is an existing text");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(12, 0));
    
    // UI event needs to be called during preparation phase to init text storage
    [_richTextView willMoveToSuperview:nil];
    
    [_richTextView setText:nil];
    
    OCMVerify([self.mockTextStorage replaceCharactersInRange:NSMakeRange(0, 24) withString:@""]);
    OCMVerify([[self.richTextPartialMock reject ] setSelectedRange:NSMakeRange(12, 0)]);
}

- (void)testExistingTextSetNilWithSelectionOutside
{
    OCMStub([self.mockTextStorage string]).andReturn(@"This is an existing text");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(30, 0));
    
    // UI event needs to be called during preparation phase to init text storage
    [_richTextView willMoveToSuperview:nil];
    
    [_richTextView setText:nil];
    
    OCMVerify([self.mockTextStorage replaceCharactersInRange:NSMakeRange(0, 24) withString:@""]);
    OCMVerify([self.richTextPartialMock setSelectedRange:NSMakeRange(0, 0)]);
}

- (void)testExistingTextSetNewTextWithSelectionOutside
{
    OCMStub([self.mockTextStorage string]).andReturn(@"This is an existing text");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(10, 0));
    
    // UI event needs to be called during preparation phase to init text storage
    [_richTextView willMoveToSuperview:nil];
    
    [_richTextView setText:@"Reply..."];
    
    OCMVerify([self.mockTextStorage replaceCharactersInRange:NSMakeRange(0, 24) withString:@"Reply..."]);
    OCMVerify([self.richTextPartialMock setSelectedRange:NSMakeRange(7, 0)]);
}

- (void)testExistingTextSetNewTextWithSelectionInside
{
    OCMStub([self.mockTextStorage string]).andReturn(@"This is an existing text");
    OCMStub([self.richTextPartialMock selectedRange]).andReturn(NSMakeRange(6, 0));
    
    // UI event needs to be called during preparation phase to init text storage
    [_richTextView willMoveToSuperview:nil];
    
    [_richTextView setText:@"Reply..."];
    
    OCMVerify([self.mockTextStorage replaceCharactersInRange:NSMakeRange(0, 24) withString:@"Reply..."]);
    
    // in this case selected range shouldn't be changed!
    OCMVerify([[self.richTextPartialMock reject] setSelectedRange:NSMakeRange(7, 0)]);
}

@end
