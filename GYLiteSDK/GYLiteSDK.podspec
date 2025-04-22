Pod::Spec.new do |spec|
  spec.name         = "GYLiteSDK"
  spec.version      = "1.0.1"
  spec.summary      = "GYLite工具SDK"
  spec.homepage     = "https://github.com/GYCocoa/GYLiteSDK"
  spec.license      = "MIT"
  spec.author             = { "GYZ" => "gycocoa@gmail.com" }
  spec.platform     = :ios, "11.0"
  spec.source       = { :git => "https://github.com/GYCocoa/GYLiteSDK.git", :tag => spec.version }
  spec.source_files  = "GYLiteSDK", "GYLiteSDK/GYLiteSDK/SDK/*.{h,m}"
  spec.frameworks = "UIKit"
  spec.vendored_frameworks = "GYLiteSDK/GYLiteSDK/SDK/GYLiteFramework/GYLiteFramework.framework"


  spec.requires_arc = true
  spec.ios.deployment_target = '11.0'

  spec.pod_target_xcconfig = { 'VALID_ARCHS' => 'x86_64 armv7 arm64' }


end

