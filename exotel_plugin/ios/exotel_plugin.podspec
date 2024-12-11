#
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html.
# Run `pod lib lint exotel_plugin.podspec` to validate before publishing.
#
Pod::Spec.new do |s|
  s.name             = 'exotel_plugin'
  s.version          = '1.0.10'
  s.summary          = 'A new Flutter plugin project.'
  s.description      = <<-DESC
A new Flutter plugin project.
                       DESC
  s.homepage         = 'http://example.com'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files = 'Classes/**/*'
  s.dependency 'Flutter'
  s.platform = :ios, '12.0'

# Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64 i386' }
  s.swift_version = '5.0'

  s.preserve_paths = "ExotelVoice.xcframework"
  s.vendored_frameworks = 'ExotelVoice.xcframework'
  s.xcconfig = { 'OTHER_LDFLAGS' => '-framework ExotelVoice' }
end
