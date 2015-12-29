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
 *  A toggle button implementation that is keeping the actual pressed status.
 */
@interface LSToggleButton : UIButton

/*!
 *  The backing field for activity status of the button
 */
@property (nonatomic, assign) BOOL isActive;

/*!
 *  Initializer for the button defining frame and button title.
 *
 *  @param frame CGRect the frame for drawing the button.
 *  @param title the button title.
 *
 *  @return <#return value description#>
 */
- (id)initWithFrame:(CGRect)frame andTitle:(NSString *)title;

@end
