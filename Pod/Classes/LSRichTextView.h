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
 *  The rich text view component of LSTextEditor
 *
 *  @discussion LSRichTextView is the main class of LSTextEditor and is acting as a
 *              single UI component managing the editor functionalities.
 *
 */
@interface LSRichTextView : UITextView <NSTextStorageDelegate>

/*!
 *  Keeps an instance of LSRichTextConfiguration containing all component settings.
 */
@property (nonatomic, strong, readonly) LSRichTextConfiguration *richTextConfiguration;

/*!
 *  It returns the current text view content as raw text without any encoding.
 *
 *  @return NSString The content as raw text string.
 */
- (NSString *)plainText;

/*!
 *  It returns the current text view content as encoded text.
 *
 *  @return NSString The content as encoded text string.
 */
- (NSString *)encodedText;

/*!
 *  An additional initializer to inject frame and configuration.
 *
 *  @param frame         CGRect the frame to draw the text view in.
 *  @param configuration LSRichTextConfiguration the configuration object for setting up.
 *
 *  @return instancetype the new instance of rich text view.
 */
- (instancetype)initWithFrame:(CGRect)frame andConfiguration:(LSRichTextConfiguration *)configuration;

/*!
 *  The overridden setter of UITextView component.
 *
 *  @param text NSString the new text to be set in the editor. It can be raw text as well as
 *              encoded text of the corresponding encoding type
 *
 *  Note: Currently only BB code is supported as encoding type.
 */
- (void)setText:(NSString *)text;

/*!
 *  Resetsall text attributes.
 *
 *  @discussion Resets all text attributes of the currently set text in the view component to
 *              the initial text attributes.
 */
- (void)resetTextFormatting;

/*!
 *  Sets the highlighting color.
 *
 *  @discussion Sets the so called tint color in all text view functionalities.
 *
 *  @param color UIColor the new color object to be set.
 */
- (void)setHighlightColor:(UIColor *)color;

@end
