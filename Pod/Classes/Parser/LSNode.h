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

#import <Foundation/Foundation.h>

@interface LSNode : NSObject

@property (nonatomic, strong) NSString *tagName;
@property (nonatomic, strong) NSMutableArray *tagNames;
@property (nonatomic, strong) NSString *content;
@property (nonatomic, strong) NSMutableArray *children;
@property (nonatomic, strong) NSDictionary *attributes;
@property (nonatomic, weak) LSNode *parentNode;

+ (instancetype)nodeWithTagName:(NSString *)tagName andContent:(NSString *)content andAttributes:(NSDictionary *)attributes;
- (NSString *)debugString;

- (instancetype)nodeFromParentNode:(NSString *)tagName andContent:(NSString *)content andAttributes:(NSDictionary *)attributes;
- (void)addChildNode:(LSNode *)node;

@end
