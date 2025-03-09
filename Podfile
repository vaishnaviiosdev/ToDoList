# Uncomment the next line to define a global platform for your project
# platform :ios, '15.0'

target 'ToDoList' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!

  # Pods for ToDoList
  pod 'lottie-ios'
  pod 'DropDown'
  pod 'SwiftyJSON'
  pod 'Toast-Swift'

post_install do |installer|
    
    installer.generated_projects.each do |project|
      project.targets.each do |target|
        target.build_configurations.each do |config|
          config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
        end
      end
    end
    
    installer.pods_project.targets.each do |target|
      
      target.build_configurations.each do |config|
        config.build_settings['CODE_SIGN_IDENTITY'] = ''
      end
      
      if ['MaterialCard'].include? target.name
        target.build_configurations.each do |config|
          config.build_settings['SWIFT_VERSION'] = '5.0'
        end
      end
      
    end
  end
  
end



