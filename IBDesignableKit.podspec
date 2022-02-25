#
#  Be sure to run `pod spec lint IBDesignableKit.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see https://guides.cocoapods.org/syntax/podspec.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |spec|
  spec.name         = "IBDesignableKit"
  spec.version      = "1.0.0"
  spec.summary      = "IBDesignableKit"
  spec.description  = <<-DESC
  No description
  DESC
  
  spec.homepage     = "https://github.com/winddpan"
  spec.license      = "MIT"
  spec.platform = :ios, '10.0' 
  spec.swift_version = '5.5'

  spec.author       = { "PAN" => "winddpan@126.com" }
  spec.source       = { :git => "hhttps://github.com/winddpan/IBDesignableKit.git" }
  spec.source_files  = "Sources/**/*.{swift}"
end
