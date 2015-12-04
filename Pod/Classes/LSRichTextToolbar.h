/*!
 * This file is part of LSTextEditor.
 *
 * Copyright © 2015 LShift Services GmbH
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 * Authors:
 * - Peter Lieder <peter@lshift.de>
 *
 */

#import <UIKit/UIKit.h>
#import "LSRichTextConfiguration.h"

/*!
 *  @protocol LSRichTextToolbarDelegate
 *
 *  @brief The LSRichTextToolbarDelegate protocol
 *
 *  It's a delegate definition for toolbar button handlers notifying
 *  for each feature the activity status.
 */
@protocol LSRichTextToolbarDelegate <NSObject>

- (void)richTextToolbarDidSelectBold:(BOOL)isActive;
- (void)richTextToolbarDidSelectItalic:(BOOL)isActive;
- (void)richTextToolbarDidSelectUnderlined:(BOOL)isActive;
- (void)richTextToolbarDidSelectStrikeThrough:(BOOL)isActive;

@end

/*!
 *  @interface LSRichTextToolbar
 *
 *  @brief The rich text toolbar component of LSTextEditor
 *
 *  @discussion LSRichTextToolbar provides the formatting buttons
 *              for controlling changes on text selections and actual typing
 *              attributes. It's set is controlled by the global 
 *              LSRichTextConfiguration object.
 *
 *  @superclass Superclass: UIView\n
 */
@interface LSRichTextToolbar : UIView

/*!
 *  Keeps an instance of LSRichTextToolbarDelegate.
 */
@property (nonatomic, weak) id <LSRichTextToolbarDelegate> delegate;

/*!
 *  Keeps an LSRichTextConfiguration object containing all component settings.
 */
@property (nonatomic, weak) LSRichTextConfiguration *richTextConfiguration;

/*!
 *  @brief The extended intitializer.
 *
 *  An extended intitializer to pass in a LSRichTextToolbarDelegate and
 *  LSRichTextConfiguration object.
 *
 *  @param frame         CGRect the frame to draw the toolbar in.
 *  @param delegate      LSRichTextToolbarDelegate the delegate for toolbar handlers.
 *  @param configuration LSRichTextConfiguration the configuration object for setting up the toolbar.
 *
 *  @return instancestype an instance of LSRichTextToolbar.
 */
- (instancetype)initWithFrame:(CGRect)frame withDelegate:(id <LSRichTextToolbarDelegate>)delegate andConfiguration:(LSRichTextConfiguration *)configuration;

/*!
 *  @brief Updates the toolbar state
 *
 *  Updates the current toolbar state of buttons etc. based on the attributes
 +  that are passed in.
 *
 *  @param attributes NSDictionary the set of attributes of the new state.
 */
- (void)updateStateWithAttributes:(NSDictionary *)attributes;

@end
