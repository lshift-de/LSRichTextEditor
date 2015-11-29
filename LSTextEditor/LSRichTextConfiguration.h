//
//  LSRichTextConfiguration.h
//  LSTextEditor
//
//  Created by Peter Lieder on 22/09/15.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, LSRichTextFeatures) {
    LSRichTextFeaturesNone          = 1 << 0,
    LSRichTextFeaturesPlainText     = 1 << 1,
    LSRichTextFeaturesReadonly      = 1 << 2,
    LSRichTextFeaturesBold          = 1 << 3,
    LSRichTextFeaturesItalic        = 1 << 4,
    LSRichTextFeaturesUnderlined    = 1 << 5,
    LSRichTextFeaturesStrikeThrough = 1 << 6,
    LSRichTextFeaturesAll           = 1 << 20
};

@interface LSRichTextConfiguration : NSObject

@property (nonatomic, assign) LSRichTextFeatures configurationFeatures;
@property (nonatomic, assign) NSTextCheckingType textCheckingTypes;
@property (nonatomic, strong) NSMutableDictionary *initialTextAttributes;
@property (nonatomic, weak) UIColor *defaultTextColor;
@property (nonatomic, weak) UIColor *highlightColor;

- (instancetype)initWithConfiguration:(LSRichTextFeatures)configurationFeatures;
- (void)setInitialAttributesFromTextView:(UITextView *)textView;

- (void)setTextCheckingType:(UIDataDetectorTypes)dataDetectorTypes;

@end
