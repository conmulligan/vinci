Pod::Spec.new do |s|
    s.name             = 'Vinci'
    s.version          = '0.2.2'
    s.license          = { :type => 'MIT', :file => 'LICENSE' }
    s.summary          = 'Asynchronous image downloader and cache for iOS.'
    s.homepage         = 'https://github.com/conmulligan/Vinci'
    s.author           = { 'conmulligan' => 'conmulligan@gmail.com' }
    s.source           = { :git => 'https://github.com/conmulligan/Vinci.git', :tag => s.version.to_s }
    s.social_media_url = 'https://twitter.com/conmulligan'
    
    s.swift_version = '5.0'
    s.ios.deployment_target = '10.0'
    
    s.source_files = 'Vinci/Classes/**/*'
    
    s.frameworks = 'UIKit'
    
    s.description = <<-DESC
        An synchronous image loader and disk cache for iOS.
    DESC
end
