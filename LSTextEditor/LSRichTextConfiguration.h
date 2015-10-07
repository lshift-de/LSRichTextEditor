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
    LSRichTextFeaturesReadonly      = 1 << 1,
    LSRichTextFeaturesBold          = 1 << 2,
    LSRichTextFeaturesItalic        = 1 << 3,
    LSRichTextFeaturesUnderlined    = 1 << 4,
    LSRichTextFeaturesStrikeThrough = 1 << 5,
    LSRichTextFeaturesAll           = 1 << 20
};

@interface LSRichTextConfiguration : NSObject

@property (nonatomic, assign) LSRichTextFeatures configurationFeatures;

- (instancetype)initWithConfiguration:(LSRichTextFeatures)configurationFeatures;

@end
