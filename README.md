# system_breakdown

## Build-Abhängigkeiten

# Linux:   `sudo apt install automake libtool build-essential`
# macOS:   `xcode-select --install` 
#        automake
#        libtool
#        pkgconf  
#        hwloc  
# in Pod file UNTEN einintegrieren: (es dürfen keine zwei post_install do exisieren )

# post_install do |installer|
#  installer.pods_project.targets.each do |target|
#     target.build_configurations.each do |config|

#       config.build_settings['LIBRARY_SEARCH_PATHS'] ||= ['$(inherited)']
      config.build_settings['LIBRARY_SEARCH_PATHS'] << '/opt/homebrew/lib'

#       config.build_settings['OTHER_LDFLAGS'] ||= ['$(inherited)']
#       config.build_settings['OTHER_LDFLAGS'] << '-lhwloc'
#       config.build_settings['OTHER_LDFLAGS'] << '-framework OpenDirectory'
#       config.build_settings['OTHER_LDFLAGS'] << '-framework CoreFoundation'
#       config.build_settings['OTHER_LDFLAGS'] << '-framework IOKit'
#     end
#  end
# end



# danach 

# flutter clean
# cargo clean

# rm -rf macos/Pods
# rm -rf macos/Podfile.lock

# flutter pub get

# cd macos
# pod install
# cd ..



# Windows: Visual Studio mit C++-Workload + cmake
