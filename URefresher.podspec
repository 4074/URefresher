
Pod::Spec.new do |spec|
  spec.name         = "URefresher"
  spec.version      = "0.1.0"
  spec.authors      = { "4074" => "fourzerosevenfour@gmail.com" }
  spec.homepage     = "https://github.com/4074/URefresher"
  spec.summary      = "URefresher in Swift"
  spec.source       = { :git => "https://github.com/4074/URefresher.git" }
  spec.license      = { :type => "MIT", :file => "LICENSE" }
  spec.platform     = :ios, '8.0'
  spec.source_files = "URefresher/*.swift"

  spec.requires_arc = true

  spec.ios.deployment_target = '8.0'
  spec.ios.frameworks = ['UIKit', 'Foundation']
end