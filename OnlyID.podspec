#
# Be sure to run `pod lib lint OnlyID.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'OnlyID'
  s.version          = '1.0.0'
  s.summary          = 'sdk for onlyid'
  s.description      = <<-DESC
  sdk for onlyid
                       DESC

  s.homepage         = 'https://www.onlyid.net'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'ltb' => 'liangtb@qq.com' }
  s.source           = { :git => 'git@github.com:onlyid/onlyid-sdk-ios.git', :tag => s.version.to_s }

  s.ios.deployment_target = '10.0'

  s.swift_version = '5.0'

  s.source_files = 'OnlyID/Classes/**/*'

  s.resource_bundles = {
    'OnlyID' => ['OnlyID/Assets/*.png']
  }
end
