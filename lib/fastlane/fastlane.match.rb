default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

# global appconnect variables
team_id = ENV["TEAM_ID"]
is_enterprise = ENV['IS_ENTERPRISE']
devices_path = ENV['DEVICES_PATH']
development_certs_git_url = ENV["DEVELOPMENT_CERTS_GIT_URL"]
distribution_certs_git_url = ENV["DISTRIBUTION_CERTS_GIT_URL"]
git_branch = ENV["GIT_BRANCH"]
app_identifier = ENV['BUNDLE_IDENTIFIER']
extension_identifiers = ENV['EXTENSION_BUNDLE_INDENTIFIERS'].split(",")

platform :ios do
  desc "Register Devices"
  desc "Sample: fastlane ios add_devices"
  lane :add_devices do
    if lane_context[SharedValues::APP_STORE_CONNECT_API_KEY].nil?
      authenticating_with_apple_services
    end
    register_devices(devices_file: devices_path)
  end 

   desc "Match for appstore/enterprise/adhoc/development"
   desc "Samples: fastlane ios match_lane type:<development//adhoc/appstore/enterprise> readonly:<true/false> force_for_new_devices:<true/false>"
   lane :match_lane do |options|
     readonly = options[:readonly]
     certs_git_url = options[:certs_git_url]
     type = options[:type]
     force_for_new_devices = options[:force_for_new_devices]
     if force_for_new_devices.nil?
       force_for_new_devices = false
     end
 
     app_identifiers = extension_identifiers.insert(0, app_identifier)
     
     if lane_context[SharedValues::APP_STORE_CONNECT_API_KEY].nil?
                 authenticating_with_apple_services
     end
 
     match(
       team_id: team_id,
       git_url: certs_git_url,
       git_branch: git_branch,
       app_identifier: app_identifiers,
       type: type,
       shallow_clone: false,
       fail_on_name_taken: true,
       force_for_new_devices: force_for_new_devices,
       readonly: readonly,
       include_mac_in_profiles: true,
       verbose: true,
     )
   end
 
   desc "Match for appstore"
   desc "Samples: fastlane ios match_appstore readonly:<true/false>"
   lane :match_appstore do |options|
     readonly = options[:readonly]
     match_lane(type: 'appstore', readonly:readonly, certs_git_url: distribution_certs_git_url, force_for_new_devices: false)
   end
 
   desc "Match for adhoc"
   desc "Samples: fastlane ios match_adhoc readonly:<true/false>"
   lane :match_adhoc do |options|
     readonly = options[:readonly]
     match_lane(type: 'adhoc', readonly:readonly, certs_git_url: distribution_certs_git_url, force_for_new_devices: true)
   end
 
   desc "Match for development"
   desc "Samples: fastlane ios match_development readonly:<true/false>"
   lane :match_development do |options|
     readonly = options[:readonly]
     match_lane(type: 'development', readonly:readonly, certs_git_url: development_certs_git_url, force_for_new_devices: true)
   end
 
   desc "Match for enterprise"
   desc "Samples: fastlane ios match_enterprise readonly:<true/false>"
   lane :match_enterprise do |options|
     readonly = options[:readonly]
     match_lane(type: 'enterprise', readonly:readonly, certs_git_url: development_certs_git_url, force_for_new_devices: false)
   end
   
   desc "Match for appstore, adhoc and development"
   desc "Samples: fastlane ios match_all readonly:<true/false>"
   lane :match_all do |options|
     readonly = options[:readonly]

     #add_devices()

     match_development(readonly:readonly)
 
     UI.message "Current Apple Developer Acccount is enterprise account: #{is_enterprise}"
 
     if is_enterprise.nil?
       match_adhoc(readonly:readonly)
       match_appstore(readonly:readonly)
     elsif is_enterprise == "true"
       match_enterprise(readonly:readonly)
     else
       match_adhoc(readonly:readonly)
       match_appstore(readonly:readonly)
     end
 
   end
 
 end
