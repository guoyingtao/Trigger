#
#  Be sure to run `pod spec lint EchoPriceTagLabel.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
s.name         = "Trigger"
  s.version      = "0.1.0"
  s.summary      = "Trigger is used to easily check if some events should be trigged by executing times."

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
  s.source_files  = "Trigger/Trigger.swift","Trigger/TriggerModel.xcdatamodeld"

end
