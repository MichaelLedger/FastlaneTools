
default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

# global appconnect variables
k_team_id = ENV["TEAM_ID"]
k_itc_team_id = ENV['ITC_TEAM_ID']
k_fastlane_user = ENV["FASTLANE_USER"]

k_default_enable_services = {
  #access_wifi: "on",             # Valid values: "on", "off"
  #app_group: "off",               # Valid values: "on", "off"
  #apple_pay: "off",               # Valid values: "on", "off"
  #associated_domains: "off",      # Valid values: "on", "off"
  #auto_fill_credential: "on",    # Valid values: "on", "off"
  #data_protection: "complete",   # Valid values: "complete", "unlessopen", "untilfirstauth",
  #game_center: "off",             # Valid values: "on", "off"
  #health_kit: "off",              # Valid values: "on", "off"
  #home_kit: "off",                # Valid values: "on", "off"
  #hotspot: "off",                 # Valid values: "on", "off"
  #icloud: "cloudkit",            # Valid values: "legacy", "cloudkit"
  #in_app_purchase: "off",         # Valid values: "on", "off"
  #inter_app_audio: "off",         # Valid values: "on", "off"
  #passbook: "off",                # Valid values: "on", "off"
  #multipath: "off",               # Valid values: "on", "off"
  #network_extension: "off",       # Valid values: "on", "off"
  #nfc_tag_reading: "off",         # Valid values: "on", "off"
  #personal_vpn: "off",            # Valid values: "on", "off"
  #passbook: "off",                # Valid values: "on", "off" (deprecated)
  push_notification: "on",       # Valid values: "on", "off"
  #siri_kit: "off",                # Valid values: "on", "off"
  #vpn_configuration: "off",       # Valid values: "on", "off" (deprecated)
  #wallet: "off",                  # Valid values: "on", "off"
  #wireless_accessory: "off",      # Valid values: "on", "off"
}

platform :ios do

  desc "Register Devices"
  desc "Sample: fastlane ios add_devices"
  lane :add_devices do
    register_devices(
      team_id: k_team_id, 
      username: k_fastlane_user, 
      devices_file: "fastlane/devices.txt"
    )
  end 

  desc "Create an app on Apple Developer and App Store Connect sites"
  desc "Sample: fastlane ios create_app"
  lane :create_app do
    app_name = ENV['APP_NAME']
    company_name = ENV['COMPANY_NAME']
    app_identifier = ENV['BUNDLE_IDENTIFIER']
    is_enterprise = ENV['IS_ENTERPRISE']

    if is_enterprise.nil?
      produce(
        team_id: k_team_id, 
        itc_team_id: k_itc_team_id,
        username: k_fastlane_user, 
        app_name: app_name,
        app_identifier: app_identifier,
        sku: app_identifier,
        enable_services: k_default_enable_services
      )
    else 
      produce(
        team_id: k_team_id, 
        itc_team_id: k_itc_team_id,
        username: k_fastlane_user, 
        app_name: app_name,
        app_identifier: app_identifier,
        sku: app_identifier,
        skip_itc: is_enterprise,
        enable_services: k_default_enable_services
      )
    end
    
  end

  desc "Create one or more app extensions on Apple Developer and App Store Connect sites"
  desc "Sample: fastlane ios create_app_extensions"
  lane :create_app_extensions do
    app_name = ENV['APP_NAME']
    extension_identifiers = ENV['EXTENSION_BUNDLE_INDENTIFIERS'].split(",")
    extension_identifiers.each do |extension_identifier|
      extension_name = "#{extension_identifier}".split(".").last
      produce(
        team_id: k_team_id, 
        username: k_fastlane_user, 
        app_name: "#{app_name} #{extension_name}",
        app_identifier: extension_identifier,
        skip_itc: true,
        enable_services: k_default_enable_services
      )
    end
  end


  desc "Create an app and its extensions on Apple Developer and App Store Connect sites"
  desc "Sample: fastlane ios create_app_and_extensions"
  lane :create_app_and_extensions do
    create_app
    create_app_extensions
  end
end
