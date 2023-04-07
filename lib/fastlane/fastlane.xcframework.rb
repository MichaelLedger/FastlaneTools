# coding: utf-8

require 'fileutils'
require 'fastools'

default_platform(:ios)
xcode_select(ENV['XCODE_SELECT'])

platform :ios do

  lane :pod_update do |options|
    podfile_dir = options[:podfile_dir]

    puts("podfile_dir -> #{podfile_dir}")
    cocoapods(
      use_bundle_exec: true,
      clean_install: true,
      repo_update: true,
      podfile: podfile_dir
    )
  end

  desc "build a single framework for a specified project"
  desc "Sample: fastlane ios build_framework sdk:<iphoneos/iphonesimulator> framework_name:<framework_name> pods_project_path:<xxxxxxx/Pods/Pods.xcodeproj> configuration:Debug/Release/Staging/Preproduction"
  private_lane :build_framework do |options|
    sdk = options[:sdk]
    configuration = options[:configuration]
    clean = options[:clean]
    framework_scheme = options[:framework_scheme]
    framework_project_path = options[:framework_project_path]

    # set default `clean` if needed
    if clean.nil?
      clean = false
    end

    if configuration.nil?
      configuration = "Release"
    end

    include_bitcode = true
    xcargs = {
      :DEPLOYMENT_POSTPROCESSING => "YES",
      :OTHER_CFLAGS => "-fembed-bitcode",
      :BITCODE_GENERATION_MODE => "bitcode"
    }

    # option out bitcode if needed
    if configuration == "Debug"
      xcargs = nil
      include_bitcode = false
    end

    puts("SDK = #{sdk}")

    gym(
      scheme: framework_scheme,
      project: framework_project_path,
      configuration: configuration,
      include_bitcode: include_bitcode,
      clean: clean,
      sdk: sdk,
      skip_build_archive: false,
      skip_archive: true,
      xcargs: xcargs
    )
  end

  desc "build a xcframework for Release/Debug"
  desc "Sample: fastlane ios build_xcframework configuration:Debug/Release/Staging/Preproduction"
  lane :build_xcframework do |options|
    configurations = options[:configurations]
    # set default `configurations` if needed
    if configurations.nil?
      configurations = "Debug,Release"
    end

    build_frameworks_for_iphoneos(configurations:configurations)
    build_frameworks_for_iphonesimulator(configurations:configurations)

    project_dir = ENV['PROJECT_DIR']

    publish_frameworks_path = ENV['PUBLISH_FRAMEWORKS_PATH']
    publish_frameworks = ENV['PUBLISH_FRAMEWORKS'].split(",")
    publish_frameworks.each do |publish_framework|
      configurations.split(",").each do |configuration|
        create_xcframework(
            frameworks: [
              "#{project_dir}/iphonesimulator/build/#{configuration}-iphonesimulator/#{publish_framework}/#{publish_framework}.framework",
              "#{project_dir}/iphoneos/build/#{configuration}-iphoneos/#{publish_framework}/#{publish_framework}.framework"
            ],
            output: "#{publish_frameworks_path}/#{configuration}/#{publish_framework}.xcframework"
        )
      end
    end
  end

  lane :build_frameworks_for_iphoneos do |options|
    configurations = options[:configurations]
    # set default `configurations` if needed
    if configurations.nil?
      configurations = "Debug,Release"
    end

    project_dir = ENV['PROJECT_DIR']
    sdk = "iphoneos"
    podfile_dir = "#{project_dir}/#{sdk}"
    pod_update(podfile_dir: podfile_dir)
    build_frameworks(configurations:configurations, sdk:sdk)
  end

  lane :build_frameworks_for_iphonesimulator do |options|
    configurations = options[:configurations]
    # set default `configurations` if needed
    if configurations.nil?
      configurations = "Debug,Release"
    end

    project_dir = ENV['PROJECT_DIR']
    sdk = "iphonesimulator"
    podfile_dir = "#{project_dir}/#{sdk}"
    pod_update(podfile_dir: podfile_dir)
    build_frameworks(configurations:configurations, sdk:sdk)
  end

  lane :build_frameworks do |options|

    configurations = options[:configurations]
     # set default `configurations` if needed
     if configurations.nil?
      configurations = "Debug,Release"
    end
    configurations = configurations.split(",")

    sdk = options[:sdk]

    project_dir = ENV['PROJECT_DIR']
    podfile_dir = "#{project_dir}/#{sdk}"
    pods_project_path = "#{podfile_dir}/Pods/Pods.xcodeproj"

    publish_frameworks = ENV['PUBLISH_FRAMEWORKS'].split(",")
    publish_frameworks.each do |publish_framework|
      configurations.each do |configuration|
        build_framework(
        sdk:sdk,
        configuration: configuration,
        clean: false,
        framework_scheme: publish_framework,
        framework_project_path: pods_project_path
      )
      end

      # Fastools::Lipo.create(
      #   input_frameworks: input_frameworks,
      #   output_framework: "#{united_frameworks_floder}/#{publish_framework}.framework/#{publish_framework}"
      # )
      # Fastools::Lipo.info(
      #   output_framework: "#{united_frameworks_floder}/#{publish_framework}.framework/#{publish_framework}"
      # )
    end
  end

end



#------- ENV Example ------------------

# Assign your target's Podfile
#PROJECT_DIR = './Example'

# FRAMEWORK_NAME, separated by ',' without space
#PUBLISH_FRAMEWORKS = "MirrorWechatSDK"
#PUBLISH_FRAMEWORKS_PATH = "Mirror"

