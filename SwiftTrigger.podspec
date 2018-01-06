#
#  Be sure to run `pod spec lint Trigger.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

`echo "4.0" > .swift-version`

Pod::Spec.new do |s|
  s.name         = "SwiftTrigger"
  s.version      = "0.1.6"
  s.summary      = "SwiftTrigger is used to easily check if some events should be trigged by executing times."

  s.description  = <<-DESC
        The event can be trigged by following cases
        * The first time run
        * The N time run
        * every N times run
        * every N times run but stop after repeating M times
                   DESC

  s.homepage     = "https://github.com/guoyingtao/Trigger"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author             = { "Yingtao Guo" => "guoyingtao@outlook.com" }
  s.social_media_url   = "http://twitter.com/guoyingtao"
  s.platform     = :ios
  s.ios.deployment_target = '10.0'
  s.source       = { :git => "https://github.com/guoyingtao/Trigger.git", :tag => "#{s.version}" }
  s.source_files  = "SwiftTrigger/SwiftTrigger.swift"
  s.resources = "SwiftTrigger/SwiftTriggerModel.xcdatamodeld"

end
