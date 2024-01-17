# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

# Comment the next line if you don't want to use dynamic frameworks
use_frameworks!

target 'LoaTool' do
  # Pods for LoaTool

  # HTTP Network
  pod 'Alamofire'
  
  # JSON Parsing
  pod 'SwiftyJSON'
  
  # Image
  pod 'Kingfisher', '~> 7.6.2'
  
  # HTTP Parsing
  pod 'SwiftSoup'
  
  # Locale Datebase
  # pod 'RealmSwift'
  
  # Animate transitions
  pod 'Hero'
  
  # CollectionView Layout
  # pod "BouncyLayout"
  
  # Pop Tip
  # pod 'AMPopTip'
  
  # Pop view
  # pod 'MIBlurPopup'
  
  # Text Slider
  pod 'TGPControls'
  
  # Page Control
  # pod 'CHIPageControl/Jaloro'

  # UILabel drop-in
  pod 'ActiveLabel'

end

# 다음 pod install 전까지 에러 안사라지면 추가하고 pod install
# post_install do |installer|
#   installer.pods_project.targets.each do |target|
#     if target.name == 'Realm'
#       create_symlink_phase = target.shell_script_build_phases.find { |x| x.name == 'Create Symlinks to Header Folders' }
#       create_symlink_phase.always_out_of_date = "1"
#     end
#   end
# end

post_install do |installer|
    installer.generated_projects.each do |project|
          project.targets.each do |target|
              target.build_configurations.each do |config|
                  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '13.0'
               end
          end
   end
end
