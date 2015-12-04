#
# Be sure to run `pod lib lint LSRichTextEditor.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = "LSRichTextEditor"
  s.version          = "0.0.1"
  s.summary          = "An iOS rich text editor with markup code parsing component."

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!  
  s.description      = <<-DESC
The rich text component extends the UITextView by adding formatting attributes to selected ranges or typed letters. A toolbar is providing buttons for the according formatting features. The additional parser implementation provides transformation feature for markup languages, currently is only BBCode supported. Additionally, a markup encoded string can be exported from the formatted text.
                       DESC

  s.homepage         = "https://www.lshift.de"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'Apache2'
  s.author           = { "Peter Lieder" => "peter@lshift.de" }
  s.source           = { :git => "https://github.com/lshift-de/LSRichTextEditor.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '8.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes/**/*'
  s.resource_bundles = {
    'LSRichTextEditor' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
