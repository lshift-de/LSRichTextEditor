# LSRichTextEditor

[![CI Status](http://img.shields.io/travis/Peter Lieder/LSTextEditor.svg?style=flat)](https://travis-ci.org/Peter Lieder/LSTextEditor)
[![Version](https://img.shields.io/cocoapods/v/LSTextEditor.svg?style=flat)](http://cocoapods.org/pods/LSTextEditor)
[![License](https://img.shields.io/cocoapods/l/LSTextEditor.svg?style=flat)](http://cocoapods.org/pods/LSTextEditor)
[![Platform](https://img.shields.io/cocoapods/p/LSTextEditor.svg?style=flat)](http://cocoapods.org/pods/LSTextEditor)

A rich text editing feature for text input fields get more and more important in mobile applications nowadays. But why just another rich text editor? LSRichTextEditor combines the idea of getting an easy to implement component with a set of various text editing features that are flexible to set up. The rich text component extends the UITextView by adding formatting attributes to selected ranges or typed letters. A toolbar is providing buttons for the according formatting features. The additional parser implementation provides transformation feature for markup languages, currently is only BBCode supported. Additionally, a markup encoded string can be exported from the formatted text.

![](LSRichTextEditor.gif?raw=true "LSRichTextEditor screenshot")

## Requirements

Supported versions: iOS 8, 9


## Installation with CocoaPods

[CocoaPods](https://cocoapods.org/) is a dependency manager for Objective-C, which automates and simplifies the process of using 3rd-party libraries like LSTextEditor in your projects. To install it, simply add the following lines to your Podfile.

#### Podfile

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '8.0'

pod "LSRichTextEditor"
```
To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage

### Implementation as Storyboard view object

Just create an UITextView component in your target storyboard, reference the LSRichTextView class and create an IBOutlet for further access. For this strategy of initialization all rich text features are enabled and can be changed afterwards.

### Implementation from code

Create a LSRichTextView instance and initialize it like an UITextView object. See the example below.

```objective-c
LSRichTextView *textView = [[LSRichTextView alloc] initWithFrame:CGRectMake(0, 0, 300, 200) andConfiguration:[[LSRichTextConfiguration alloc] initWithConfiguration:LSRichTextFeaturesAll]];

[self.view addSubview:textView];
```

### Setup of supported features

The LSRichTextConfiguration objects provides a global setup instance used all over the rich text component.

```objective-c
[[LSRichTextConfiguration alloc] initWithConfiguration:LSRichTextFeaturesAll]]
```
The features of ```objective-c LSRichTextFeatures``` with bit operators.

### Enable Data Detection

If the rich text view component is initialized programmatically the data detection feature needs to be enabled by code as well. This can be archived by setting the according ```objective-c UIDataDetectorTypes``` type.

```objective-c
[self.richTextView.richTextConfiguration setTextCheckingType:UIDataDetectorTypeLink];
```

## Limitations and Future

Supported formatting features: Bold, Italic, Underline and Strike through.

Supported markup language: BBCode

Planned Changes:

* extending the formatting features for text size and paragraphs
* output formatter extension for handling other markup languages
* improving parser implementation for handling other markup languages
* improving parser integration to enable realtime markup detection

## Author

Peter Lieder, <peter@lshift.de>

## License

LSTextEditor is available under the Apache License Version 2.0. See the LICENSE file for more information.
