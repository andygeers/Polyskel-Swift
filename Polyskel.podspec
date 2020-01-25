#
# Be sure to run `pod lib lint Polyskel.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Polyskel'
  s.version          = '0.1.1'
  s.summary          = 'A Swift implementation of the Polyskel Python library to find Straight Skeletons of polygons'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
Polyskel is a Python library for finding the Straight Skeleton of a polygon, as described by Felkel and Obdržálek in their 1998 conference paper Straight skeleton implementation. This is a port to Swift.
                       DESC

  s.homepage         = 'https://github.com/andygeers/Polyskel-Swift'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'andygeers' => 'andy@geero.net' }
  s.source           = { :git => 'https://github.com/andygeers/Polyskel-Swift.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/andygeers'

  s.ios.deployment_target = '10.0'
  s.swift_versions = '4.0'

  s.source_files = 'Polyskel/Classes/**/*'
  
  # s.resource_bundles = {
  #   'Polyskel' => ['Polyskel/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  s.dependency 'Euclid', "~> 0.3.0"
end
