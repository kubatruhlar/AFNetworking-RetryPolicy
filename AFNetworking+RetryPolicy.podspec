Pod::Spec.new do |s|
  s.name         = "AFNetworking+RetryPolicy"
  s.version      = "1.0.0"
  s.summary      = "Nice category that adds the ability to set the retry interval, retry count and progressive."

  s.description  = If the request timed out, you usually have to call the request again by yourself. AFNetworking+RetryPolicy handles that for you. Adds the ability to set the retry interval, retry count and progressive.

  s.homepage     = "https://github.com/kubatru/AFNetworking-RetryPolicy"
  s.screenshots  = "https://raw.githubusercontent.com/kubatru/AFNetworking-RetryPolicy/master/Images/logo.png"

  s.license      = { :type => "MIT", :file => "LICENSE.md" }
  s.author    = "Jakub Truhlar"
  s.social_media_url   = "http://kubatruhlar.cz"
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/kubatru/AFNetworking-RetryPolicy.git", :tag => "1.0.0" }
  s.source_files  = "AFNetworking+RetryPolicy/*"
  s.framework  = "Foundation"
  s.requires_arc = true
end
