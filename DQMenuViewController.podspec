#
# Be sure to run `pod lib lint DQMenuViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'DQMenuViewController'
  s.version          = '1.0.1'
  s.summary          = 'Container for multiple UIViewControlelr'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  Container for multiple UIViewControlelr. You can use it easily.
                       DESC

  s.homepage         = 'https://github.com/Junnor/DQMenuViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Junnor' => 'dengquanzhu@gmail.com' }
#  s.source           = { :git => 'https://github.com/Junnor/DQMenuViewController.git', :tag => 1.0.1 }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '9.0'
  s.swift_version = '5.0'

  s.source       = { :git => "https://github.com/Junnor/DQMenuViewController", :commit => "7a3ea2855be5c144b170cdd68c1ae93ec53f1058" }
  s.source_files = 'DQMenuViewController/Classes/**/*'

  # s.resource_bundles = {
  #   'DQMenuViewController' => ['DQMenuViewController/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
