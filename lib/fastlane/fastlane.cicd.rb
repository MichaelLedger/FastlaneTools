# This file contains the fastlane.tools configuration
# You can find the documentation at https://docs.fastlane.tools
#
# For a list of all available actions, check out
#
#     https://docs.fastlane.tools/actions
#
# For a list of all available plugins, check out
#
#     https://docs.fastlane.tools/plugins/available-plugins
#

# Uncomment the line if you want fastlane to automatically update itself
# update_fastlane

default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

platform :ios do

  desc "Build and push a new beta build to TestFlight"
  desc "Samples: fastlane ios beta configuration:<Staging/Release/Debug/Preproduction> skip_waiting:<true/false>"
  lane :beta do |options|
    configuration = options[:configuration]
    if configuration.nil?
      configuration = "Release"
    end

    skip_waiting = options[:skip_waiting]
    if skip_waiting.nil?
      skip_waiting = true
    end

    bump_build_number

    build(configuration: configuration, export_method: "app-store", skip_archive: false)

    upload_itc(skip_waiting:skip_waiting)

    if !skip_waiting 
      upload_itc_dSYM_to_bugly
    end
  end
  
  desc "Build and push a new build to Appcenter"
  desc "Samples: fastlane ios appcenter_lane configuration:<Staging/Release/Debug/Preproduction> export_method:<enterprise/ad-hoc>"
  lane :appcenter_lane do |options|
    configuration = options[:configuration]
    export_method = options[:export_method]

    bump_build_number

    build(configuration: configuration, export_method: export_method, skip_archive: false)

    upload_appcenter

    upload_local_dSYM_to_bugly
  end

  desc "Build and push a new beta build to fir.im"
  desc "Samples: fastlane ios fir_lane configuration:<Staging/Release/Debug/Preproduction> export_method:<enterprise/ad-hoc>"
  lane :fir_lane do |options|
    configuration = options[:configuration]
    export_method = options[:export_method]
    
    bump_build_number

    build(configuration: configuration, export_method: export_method, skip_archive: false)

    upload_fir

    upload_local_dSYM_to_bugly
  end

  desc "Build and push a new staging build to Pgyer"
  desc "Samples: fastlane ios pgyer_lane configuration:<Staging/Release/Debug/Preproduction> export_method:<enterprise/ad-hoc>"
  lane :pgyer_lane do |options|
    configuration = options[:configuration]
    export_method = options[:export_method]

    bump_build_number

    build(configuration: configuration, export_method: export_method, skip_archive: false)

    upload_pgyer

    upload_local_dSYM_to_bugly
  end

end
