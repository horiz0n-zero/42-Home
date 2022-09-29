platform :ios, '15.0'

source 'https://cdn.cocoapods.org/'

target 'home42' do
	
	use_frameworks! :linkage => :dynamic
	inhibit_all_warnings!
	supports_swift_versions '>= 5.0'
 
	pod 'SecureDefaults'
	pod 'SwiftDate'
	pod 'SwiftyRSA'

	#target 'widgetClusterPeoplesExtension' do
    #    inherit! :search_paths
    #end
	#target 'widgetCorrectionsExtension' do
	#	inherit! :search_paths
	#end
	#target 'widgetEventsExtension' do
	#	inherit! :search_paths
	#end
end

post_install do |installer_representation|
    installer_representation.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES'] = '$(inherited)'
			#config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = 'iOS 12.0'
			config.build_settings['DEAD_CODE_STRIPPING'] = 'YES'
        end
    end
end
