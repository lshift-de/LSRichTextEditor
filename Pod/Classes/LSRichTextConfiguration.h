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

/*!
 * @typedef LSRichTextFeatures
 *
 * @brief The rich text features type.
 *
 * @discussion The value of this type represent the features of the rich text view
 *             field and the the rich text toolbar. It also defines which formatting
 *             features are used.
 *
 * @field LSRichTextFeaturesNone No feature selected, component acts like a UITextView only
 * @field LSRichTextFeaturesPlainText Just plain text is shown, no markup is converted
 * @field LSRichTextFeaturesReadonly Markup conversion is enabled, interactive formatting is 
 *                                   disabled
 * @field LSRichTextFeaturesBold Enables bold formatting from markup and by toolbar
 * @field LSRichTextFeaturesItalic Enables italic formatting from markup and by toolbar
 * @field LSRichTextFeaturesUnderlined Enables underlined formatting from markup and by toolbar
 * @field LSRichTextFeaturesStrikeThrough Enables strike through formatting from markup and by toolbar
 * @field LSRichTextFeaturesAll Enables all formatting and parsing features
 */
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

/*!
 *  @brief The global configuration object for rich text component.
 *
 *  @discussion The configuration object is created during initialization phase of
 *              LSRichTextView and is used for global setup. Several editor components
 *              using it for conditional execution.
 */
@interface LSRichTextConfiguration : NSObject

/*!
 * Keeps the enum type for configuration features.
 */
@property (nonatomic, assign) LSRichTextFeatures configurationFeatures;

/*!
 * Keeps the value of activated text checking types - NSTextCheckingType
 */
@property (nonatomic, assign) NSTextCheckingType textCheckingTypes;

/*!
 * A backing field for initially set text formatting attributes to save the
 * values set by interface builder.
 */
@property (nonatomic, strong) NSMutableDictionary *initialTextAttributes;

/*!
 * Sets the default text color.
 */
@property (nonatomic, weak) UIColor *defaultTextColor;

/*!
 * Sets the highlighted text color used by e.g. link detection.
 */
@property (nonatomic, weak) UIColor *highlightColor;

/*!
 * @brief Initializer for configuration object.
 * 
 * Initializes a configuration object with an initial feature set. Feature names are
 * defined in LSRichTextFeatures type and can be aggregated bitwise.
 *
 * @param LSRichTextFeatures The given feature type.
 */
- (instancetype)initWithTextFeatures:(LSRichTextFeatures)configurationFeatures;

/*!
 * @brief Sets the initial text attributes.
 *
 * A setter for backing up the text formatting attributes set initially set by the 
 * interface builder or programmatically. This method fetches actively the parameters 
 * from the initialized text view component.
 *
 * @param UITextView The text view component containing the parameters.
 */
- (void)setInitialAttributesFromTextView:(UITextView *)textView;

/*!
 * @brief Sets the text checking type.
 *
 * A setter for backing up the initially set data detector types.
 *
 * @param UIDataDetectorTypes The data detector types as they are used by IB.
 */
- (void)setTextCheckingType:(UIDataDetectorTypes)dataDetectorTypes;

@end
