Pod::Spec.new do |spec|
  spec.name             = 'AFNetworking+RetryPolicy'
  spec.version          = '1.0.0'
  spec.summary          = 'Nice category that adds the ability to set the retry interval, retry count and progressive.'
  spec.description      = 'If the request timed out, you usually have to call the request again by yourself. AFNetworking+RetryPolicy handles that for you. Adds the ability to set the retry interval, retry count and progressive.'
  spec.homepage         = 'https://github.com/kubatru/AFNetworking-RetryPolicy'
  spec.screenshots      = 'https://raw.githubusercontent.com/kubatru/AFNetworking-RetryPolicy/master/Images/logo.png'
  spec.license          = {:type => 'MIT', :file => 'LICENSE.md'}
  spec.author           = 'Jakub Truhlar'
  spec.social_media_url = 'http://kubatruhlar.cz'
  spec.platform         = :ios, '7.0'
  spec.source           = {:git => 'https://github.com/kubatru/AFNetworking-RetryPolicy.git', :tag => '1.0.0'}
  spec.source_files     = 'AFNetworking+RetryPolicy/*.{h,m}'
  spec.framework        = 'Foundation'
  spec.requires_arc     = true
  # Dependencies (Operators =, >=, >, <=, < and ~>)
  spec.dependency       'AFNetworking', '~> 3.0'
  spec.dependency       'ObjcAssociatedObjectHelpers', '2.0.1'
end
