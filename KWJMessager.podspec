#
# Be sure to run `pod lib lint KWJMessager.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'KWJMessager'
  s.version          = '0.1.0'
  s.summary          = 'IM即时消息独立组件.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
IM即时消息独立组件，可快速组装至项目中应用
                       DESC

  s.homepage         = 'https://github.com/GithubXkw1573/KWJMessager'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'GithubXkw1573' => '1074030698@qq.com' }
  s.source           = { :git => 'https://github.com/GithubXkw1573/KWJMessager.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'KWJMessager/Classes/**/*'
  
  # s.resource_bundles = {
  #   'KWJMessager' => ['KWJMessager/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'KWBaseViewController', '~> 0.1.3'
  s.dependency 'KWHttpManager'
  s.dependency 'AMap3DMap-NO-IDFA', '~> 6.2.0'
  s.dependency 'AMapSearch-NO-IDFA', '~> 6.1.1'
  s.dependency 'AMapLocation-NO-IDFA', '~> 2.6.0'
  s.dependency 'TZImagePickerController', '~> 1.9.8'
  s.dependency 'JMessage'
  s.dependency 'SDWebImage', '~> 4.0.0'
end
