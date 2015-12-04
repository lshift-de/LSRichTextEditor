//
//  LSViewController.m
//  LSTextEditor
//
//  Created by Peter Lieder on 11/29/2015.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

#import "LSViewController.h"
#import "LSRichTextView.h"

@interface LSViewController ()

@property (weak, nonatomic) IBOutlet LSRichTextView *richTextView;

@end

@implementation LSViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.richTextView setText:@"This is just an example text..."];
    [self adjustTextFieldStyle:self.richTextView];

    // adding the second rich text view programmatically
    LSRichTextConfiguration *configuration = [[LSRichTextConfiguration alloc] initWithConfiguration:LSRichTextFeaturesAll];
    CGRect frame = CGRectMake(self.richTextView.frame.origin.x, self.richTextView.frame.origin.y + self.richTextView.frame.size.height + 20, self.richTextView.frame.size.width, self.richTextView.frame.size.height);

    LSRichTextView *textView = [[LSRichTextView alloc] initWithFrame:frame andConfiguration:configuration];
    [self adjustTextFieldStyle:textView];
    [textView setText:@"This text view is created programmatically"];

    [self.view addSubview:textView];
}

- (void)adjustTextFieldStyle:(LSRichTextView *)textView
{
    CALayer *layer = [textView layer];

    [layer setMasksToBounds:YES];
    [layer setCornerRadius:8.0f];
    [layer setBorderWidth:1.0f];
    [layer setBorderColor:[[UIColor colorWithRed:205.0f / 255.0f green:205.0f / 255.0f blue:205.0f / 255.0f alpha:1.0f] CGColor]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
