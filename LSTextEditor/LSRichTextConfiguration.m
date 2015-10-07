//
//  LSRichTextConfiguration.m
//  LSTextEditor
//
//  Created by Peter Lieder on 22/09/15.
//  Copyright (c) 2015 Peter Lieder. All rights reserved.
//

#import "LSRichTextConfiguration.h"

@implementation LSRichTextConfiguration

- (instancetype)initWithConfiguration:(LSRichTextFeatures)configurationFeatures
{
    if (self = [super init])
    {
        self.configurationFeatures = configurationFeatures;
    }
    
    return self;
}

- (instancetype)init
{
    return [self initWithConfiguration:LSRichTextFeaturesNone];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
