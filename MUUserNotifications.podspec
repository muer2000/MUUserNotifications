Pod::Spec.new do |s|
  s.name         = "MUUserNotifications"
  s.version      = "0.1"
  s.license      = "MIT"
  s.summary      = "MUUserNotifications API similar to iOS 10 UserNotifications.framework."
  s.homepage     = "https://github.com/muer2000/MUUserNotifications"
  s.author       = { "muer" => "muer2000@gmail.com" }
  s.platform     = :ios, "5.0"
  s.ios.deployment_target = "5.0"
  s.source       = { :git => "https://github.com/muer2000/MUUserNotifications.git", :tag => s.version }
  s.source_files  = "MUUserNotifications/*.{h,m}"
  s.requires_arc = true
end
