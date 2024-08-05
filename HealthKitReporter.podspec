#
# Be sure to run `pod lib lint HealthKitReporter.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name                  = 'HealthKitReporter'
  s.version               = '3.1.0'
  s.summary               = 'HealthKitReporter. A wrapper for HealthKit framework.'
  s.swift_versions        = '5.3'
  s.description           = 'Helps to write or read data from Apple Health via HealthKit framework.'
  s.homepage              = 'https://github.com/VictorKachalov/HealthKitReporter'
  s.license               = { :type => 'MIT', :file => 'LICENSE' }
  s.author                = { 'Victor Kachalov' => 'victorkachalov@gmail.com' }
  s.source                = { :git => 'https://github.com/VictorKachalov/HealthKitReporter.git', :tag => s.version.to_s }
  s.social_media_url      = 'https://www.facebook.com/profile.php?id=1700091944'
  s.platform              = :ios, '9.0'
  s.ios.deployment_target = '9.0'
  s.source_files          = 'Sources/**/*'

  s.test_spec 'Tests' do |t|
      t.source_files = 'Tests/*.swift'
  end
end
