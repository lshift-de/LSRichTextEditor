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

@class LSRichTextView;

typedef NS_ENUM(NSInteger, LSFontStyleType) {
    LSFontStyleTypeBold,
    LSFontStyleTypeItalic,
    LSFontStyleTypeUnderlined,
    LSFontStyleTypeStrokeThrough
};


/*!
 *  LSTextStorage is a custom text storage implementation responsible for text modification and
 *  and updating of dependent text system components. It's main task is parsing the new set text,
 *  setting the attributes of the string and handle the toolbar based layout modifications.
 *
 */
@interface LSTextStorage : NSTextStorage

/*!
 *  An initializer passing in the text view itÄs owned by.
 *
 *  @param textView the related text view owning the storage instance
 *
 *  @return an instance of LSTextStorage
 */
- (instancetype)initWithTextView:(LSRichTextView *)textView;

/*!
 *  The string as raw text.
 *
 *  @return returns a NSString instance.
 */
- (NSString *)string;

/*!
 *  Creates an output string in with markup format.
 *  ATM, same as input format, BB code.
 *
 *  @return returns formatted text as NSString.
 */
- (NSString *)createOutputString;

- (NSString *)createOutputString2;

/*!
 *  Accessor to modify font trait in the defined range. This method negates the value
 *  which is set actually.
 *
 *  @param range      the range to modify the text in.
 *  @param traitValue the trait value to be set.
 */
- (void)applyTraitChangeToRange:(NSRange)range andTraitValue:(uint32_t)traitValue;

/*!
 *  Accessor to appy the underline or strike through format of text in the specified range.
 *  This method negates the value which is set actually.
 *
 *  @param range              the range to be modified.
 *  @param styleAttributeName the style attribute name to be changed.
 */
- (void)applyUnderlineChangeToRange:(NSRange)range andStyleAttributeName:(NSString *)styleAttributeName;

/*!
 *  Starts the data detection process. The process tries to find data of the specified typ set in the
 *  configuration object. Therefore, the full text range is checked.
 */
- (void)processDataDetection;

/*!
 *  An accessor for setting the attributed text from the outside.
 *
 *  @param attributedText an attributed text string.
 */
- (void)setAttributedText:(NSAttributedString *)attributedText;

@end
