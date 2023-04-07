default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

# global appconnect variables
k_team_id = ENV["TEAM_ID"]
k_itc_team_id = ENV['ITC_TEAM_ID']
k_fastlane_user = ENV["FASTLANE_USER"]
k_is_enterprise = ENV['IS_ENTERPRISE']

platform :ios do

  desc "Development Build"
  desc "Samples 1: fastlane ios building_development configuration:<Staging/Release/Debug/Preproduction>"
  desc "Samples 2: fastlane ios building_development"
  lane :build_development do |options|
    configuration = options[:configuration]
    if configuration.nil?
      configuration = "Debug"
    end
    match_development(readonly: true)
    build(configuration: configuration, export_method: "development", skip_archive: true)
  end

  desc "App-Store Build"
  desc "Samples: fastlane ios building_appstore configuration:<Staging/Release/Debug/Preproduction>"
  lane :build_appstore do |options|
    configuration = options[:configuration]
    if configuration.nil?
      configuration = "Release"
    end
    match_store(readonly: true)
    build(configuration: configuration, export_method: "app-store", skip_archive: false)
  end

  desc "Ad-hoc Build"
  desc "Samples: fastlane ios building_adhoc configuration:<Staging/Release/Debug/Preproduction>"
  lane :build_adhoc do |options|
    configuration = options[:configuration]
    match_adhoc(readonly: true)
    build(configuration: configuration, export_method: "ad-hoc", skip_archive: false)
  end

  desc "Enterprise Build"
  desc "Samples: fastlane ios building_enterprise configuration:<Staging/Release/Debug/Preproduction>"
  lane :build_enterprise do |options|
    configuration = options[:configuration]
    if configuration.nil?
      configuration = "Release"
    end
    match_enterprise(readonly: true)
    build(configuration: configuration, export_method: "enterprise", skip_archive: false)
  end

  desc "Build"
  desc "Samples: fastlane ios build configuration:<Staging/Release/Debug/Preproduction> export_method:<enterprise/ad-hoc/app-store> skip_archive:<true/false>"
  lane :build do |options| 
    skip_archive = options[:skip_archive]
    export_method = options[:export_method] 
    configuration = options[:configuration]
    app_scheme = ENV['APP_SCHEME']
    app_name = ENV['APP_NAME']
    app_ota_url = ENV['APP_OTA_URL']
    display_image_url = ENV['DISPLAY_IMAGE_URL']
    full_size_image_url = ENV['FULL_SIZE_IMAGE_URL']

    configuration = "Release" if configuration.nil?

    app_ota_url = "https://app-ota-url-is-missing" if app_ota_url.nil? || app_ota_url.empty?

    display_image_url = "https://display-image-url-is-missing" if display_image_url.nil? || display_image_url.empty?

    full_size_image_url = "https://display-image-url-is-missing" if full_size_image_url.nil? || full_size_image_url.empty?

    build_output_directory = "fastlane/#{ENV['BUILD_OUTPUT_DIRECTORY']}" 

    sh("rm -rf {build_output_directory}")

    gym(
      clean: true,
      export_method: export_method,
      configuration: configuration,
      output_directory: build_output_directory,
      output_name: "#{app_name}.ipa",
      scheme: app_scheme,
      include_symbols: true,
      skip_archive: skip_archive,
      export_options: {
        manifest: {
          appURL: app_ota_url,
          displayImageURL: display_image_url,
          fullSizeImageURL: full_size_image_url
        },
        iCloudContainerEnvironment: 'Production',
      }
    )
  end

end
