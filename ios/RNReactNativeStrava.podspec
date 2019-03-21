
Pod::Spec.new do |s|
  s.name         = "RNReactNativeStrava"
  s.version      = "1.0.0"
  s.summary      = "RNReactNativeStrava"
  s.description  = <<-DESC
                  RNReactNativeStrava
                   DESC
  s.homepage     = "https://github.com/valerit/react-native-strava"
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "valeritsert@gmail.com" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/valerit/react-native-strava.git", :tag => "master" }
  s.source_files  = "*.{h,m,mm}", "lib/usr/local/include/*"
  s.requires_arc = true
  s.vendored_libraries = "lib/libFitSdkCppiOS.a"
  s.dependency "React"
  #s.dependency "others"

end

  
