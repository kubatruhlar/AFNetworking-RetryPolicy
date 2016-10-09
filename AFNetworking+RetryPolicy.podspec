Pod::Spec.new do |spec|
  spec.name             = 'AFNetworking+RetryPolicy'
  spec.version          = '1.0.2'
  spec.summary          = 'AFNetworking+RetryPolicy is an objective-c category that adds the ability to set the retry logic for requests made with AFNetworking.'
  spec.description      = 'If a request timed out, you usually have to call that request again by yourself. AFNetworking+RetryPolicy is an objective-c category that adds the ability to set the retry logic for requests made with AFNetworking.'
  spec.homepage         = 'https://github.com/kubatruhlar/AFNetworking-RetryPolicy'
  spec.screenshots      = 'https://raw.githubusercontent.com/kubatruhlar/AFNetworking-RetryPolicy/master/Images/logo.png'
  spec.license          = {:type => 'MIT', :file => 'LICENSE.md'}
  spec.author           = 'Jakub Truhlar'
  spec.social_media_url = 'http://kubatruhlar.cz'
  spec.platform         = :ios, '7.0'
  spec.source           = {:git => 'https://github.com/kubatruhlar/AFNetworking-RetryPolicy.git', :tag => '1.0.2'}
  spec.source_files     = 'AFNetworking+RetryPolicy/*.{h,m}'
  spec.framework        = 'Foundation'
  spec.requires_arc     = true
  # Dependencies (Operators =, >=, >, <=, < and ~>)
  spec.dependency       'AFNetworking', '~> 3.0'
  spec.dependency       'ObjcAssociatedObjectHelpers', '2.0.1'
end
