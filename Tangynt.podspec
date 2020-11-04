#
# Be sure to run `pod lib lint Tangynt.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Tangynt'
  s.version          = '0.1.0'
  s.summary          = 'The official Swift SDK for integration with the Tangynt API.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Tangynt helps devs more easily access the Tangynt API by using pre-built methods which does most of the work for them
                       DESC

  s.homepage         = 'Tangynt.com'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Tangynt LLC' => 'support@tangynt.com' }
  s.source           = { :git => 'https://github.com/Tangynt-LLC/tangynt-ios-sdk.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'

  s.source_files = 'Tangynt/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Tangynt' => ['Tangynt/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
