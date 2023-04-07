
default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

# global appconnect variables
k_team_id = ENV["TEAM_ID"]
k_itc_team_id = ENV['ITC_TEAM_ID']
k_fastlane_user = ENV["FASTLANE_USER"]

platform :ios do

  desc "Push a new beta build to TestFlight"
  desc "Samples: fastlane ios upload_itc skip_waiting:true"
  lane :upload_itc do |options|
    skip_waiting = options[:skip_waiting]
    if skip_waiting.nil?
      skip_waiting = true
    end

    app_name = ENV['APP_NAME']

    app_identifier = ENV['BUNDLE_IDENTIFIER']

    build_output_directory = "fastlane/#{ENV['BUILD_OUTPUT_DIRECTORY']}" 

    upload_to_testflight(
      team_id: k_itc_team_id,
      username: k_fastlane_user, 
      ipa:"#{build_output_directory}/#{app_name}.ipa",
      skip_waiting_for_build_processing:skip_waiting,
      uses_non_exempt_encryption: true
    )
  end

  desc "Donwload dSYM from itunes connect"
  desc "Samples: fastlane download_itc_dsyms build_number:<build_number> app_version:<app_version>"
  lane :download_itc_dsyms do |options|
    #ensure_git_status_clean
    build_number = options[:build_number]
    if build_number.nil?
      build_number = get_build_number
    end

    app_version = options[:app_version]
    if app_version.nil?
      app_version = get_version_number(
        target: ENV['APP_SCHEME']
      )
    end

    app_identifier = ENV['BUNDLE_IDENTIFIER']

    dysm_output_directory = "fastlane/#{ENV['DYSM_OUTPUT_DIRECTORY']}" 

    download_dsyms(
      team_id: k_itc_team_id,
      username: k_fastlane_user, 
      app_identifier: app_identifier,
      version: app_version,
      build_number: build_number,
      wait_for_dsym_processing: true,
      output_directory: dysm_output_directory
    )
  end
  
end

