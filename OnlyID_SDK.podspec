Pod::Spec.new do |s|

  s.name         = "OnlyID_SDK"
  s.version      = "1.0.6"
  s.summary      = "OnlyID_SDK"
  s.description  = <<-DESC
                  用OnlyID_SDK接入onlyID
                   DESC
  s.homepage     = "https://onlyid.net"
  s.license      = "MIT"
  s.author       = { "ltb" => "liangtb@qq.com" }
  s.platform     = :ios, "8.0"
  s.source       = { :git => "https://gitee.com/lltb/onlyID_SDK_iOS.git", :tag => "1.0.6" }
  #s.source       = { :path => '.' }
  s.source_files  = "OnlyID_SDK", "OnlyID_SDK/**/*.{h,m,swift}"
  s.exclude_files = "Classes/Exclude"

end
