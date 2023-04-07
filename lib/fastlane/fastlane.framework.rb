# coding: utf-8

require 'fileutils'
require 'fastools'

default_platform(:ios)
xcode_select(ENV['XCODE_SELECT'])

platform :ios do

  desc "build frameworks for a pod"
  desc "Sample 1: fastlane ios build_frameworks configuration:Debug/Release/Staging/Preproduction skds:iphoneos,iphonesimulator"
  desc "Sample 2: fastlane ios build_frameworks"
  lane :build_frameworks do |options|
    configuration = options[:configuration]
    if configuration.nil?
      configuration = "Release"
    end

    sdks = options[:sdks]
    if sdks.nil?
      sdks = "iphoneos,iphonesimulator"
    end

    # loading evn
    framework_demo_path = ENV['FRAMEWORK_DEMO_PATH']
    framework_name = ENV['FRAMEWORK_NAME']
    framework_repo_path = ENV['FRAMEWORK_REPO_PATH'] 

    pods_project_path = "#{framework_demo_path}/Pods/Pods.xcodeproj"

    # cleaning
    FileUtils.rm_rf "../#{framework_demo_path}/build", :verbose => true

    sdks.split(",").each do |sdk|
      outputfolder = "../#{framework_demo_path}/build/#{configuration}-#{sdk}/"
      build_framework(sdk: sdk, framework_scheme: framework_name, framework_project_path: pods_project_path, configuration: configuration)
      FileUtils.mkdir_p "#{framework_repo_path}/#{sdk}/#{framework_name}.framework"
      FileUtils.cp_r "#{outputfolder}/#{framework_name}/#{framework_name}.framework", "#{framework_repo_path}/#{sdk}", :verbose => true
      Fastools::Lipo.info(
        output_framework: "#{outputfolder}/#{framework_name}/#{framework_name}.framework/#{framework_name}"
      )
    end
  end


  desc "build frameworks for a pod by skd = iphoneos"
  desc "Sample 1: fastlane ios build_iphoneos_frameworks configuration:Debug/Release/Staging/Preproduction"
  desc "Sample 2: fastlane ios build_iphoneos_frameworks"
  lane :build_iphoneos_frameworks do |options|
    configuration = options[:configuration]
    build_frameworks(configuration: configuration, sdks: "iphoneos")
  end

  desc "build frameworks for a pod by skd = iphonesimulator"
  desc "Sample 1: fastlane ios build_iphonesimulator_frameworks configuration:Debug/Release/Staging/Preproduction"
  desc "Sample 2: fastlane ios build_iphonesimulator_frameworks"
  lane :build_iphonesimulator_frameworks do |options|
    configuration = options[:configuration]
    build_frameworks(configuration: configuration, sdks: "iphonesimulator")
  end

  desc "create united frameworks"
  desc "Sample: fastlane ios create_united_frameworks sdks:iphoneos,iphonesimulator configurations:Debug,Release skip_build:true"
  lane :create_united_frameworks do |options|
    # get input parameters
    skip_build = options[:skip_build]
    sdks = options[:sdks]
    configurations = options[:configurations]
    
    # set default `skip_build` if needed
    if skip_build.nil?
      skip_build = true
    end

    if !skip_build 
      # build all frameworks
      build_all_frameworks(sdks:sdks, configurations:configurations)
    end

    # set default `skds` if needed
    if sdks.nil?
      sdks = "iphoneos,iphonesimulator"
    end
    sdks = sdks.split(",")

    # set default `configurations` if needed
    if configurations.nil?
      configurations = "Debug,Release"
    end
    configurations = configurations.split(",")

    # get host framework name
    host_framework_demo_path = ENV['FRAMEWORK_DEMO_PATH']
    pods_project_path = "#{host_framework_demo_path}/Pods/Pods.xcodeproj"
    publish_frameworks = ENV['PUBLISH_FRAMEWORKS'].split(",")

    # create `united-frameworks` floder
    united_frameworks_floder = "../#{host_framework_demo_path}/build/united-frameworks"
    FileUtils.mkdir_p united_frameworks_floder

    # copy publish_frameworks
    publish_frameworks.each do |publish_framework|
      input_frameworks = []
      
      # prepare for the published framework
      FileUtils.cp_r "../#{host_framework_demo_path}/build/#{configurations.first}-#{sdks.first}/#{publish_framework}/#{publish_framework}.framework", united_frameworks_floder, :verbose => true

      # create united framework
      sdks.each do |sdk|
        configurations.each do |configuration|
          input_frameworks.append("../#{host_framework_demo_path}/build/#{configuration}-#{sdk}/#{publish_framework}/#{publish_framework}.framework/#{publish_framework}")
        end
      end

      Fastools::Lipo.create(
        input_frameworks: input_frameworks,
        output_framework: "#{united_frameworks_floder}/#{publish_framework}.framework/#{publish_framework}"
      )
      Fastools::Lipo.info(
        output_framework: "#{united_frameworks_floder}/#{publish_framework}.framework/#{publish_framework}"
      )
    end
    
  end

  desc "build all frameworks"
  desc "Sample: fastlane ios build_all_frameworks sdks:iphoneos,iphonesimulator configurations:Debug,Release"
  lane :build_all_frameworks do |options|
    # get input parameters
    skip_build = options[:skip_build]
    sdks = options[:sdks]
    configurations = options[:configurations]

    # set default `skip_build` if needed
    if skip_build.nil?
      skip_build = false
    end

    # set default `skds` if needed
    if sdks.nil?
      sdks = "iphoneos,iphonesimulator"
    end
    sdks = sdks.split(",")

    # set default `configurations` if needed
    if configurations.nil?
      configurations = "Debug,Release"
    end
    configurations = configurations.split(",")

    # get host framework name
    host_framework_name = ENV['FRAMEWORK_NAME']
    host_framework_demo_path = ENV['FRAMEWORK_DEMO_PATH']
    pods_project_path = "#{host_framework_demo_path}/Pods/Pods.xcodeproj"

    # create `united-frameworks` floder
    united_frameworks_floder = "../#{host_framework_demo_path}/build/united-frameworks"
    FileUtils.mkdir_p united_frameworks_floder

    # build `frameworks`
    # cleaning
    FileUtils.rm_rf "../#{host_framework_demo_path}/build", :verbose => true

    sdks.each do |sdk|
      configurations.each do |configuration|
        puts "building ... #{host_framework_name}, #{sdk}, #{configuration} start ..."
        build_framework(sdk: sdk, framework_scheme: host_framework_name, framework_project_path: pods_project_path, configuration: configuration)
        puts "building ... #{host_framework_name}, #{sdk}, #{configuration} end ..."
      end
    end
  end

  desc "build a single framework for a specified project"
  desc "Sample: fastlane ios build_framework sdk:<iphoneos/iphonesimulator> framework_name:<framework_name> pods_project_path:<xxxxxxx/Pods/Pods.xcodeproj> configuration:Debug/Release/Staging/Preproduction"
  private_lane :build_framework do |options|
    skd = options[:sdk]
    configuration = options[:configuration]
    framework_scheme = options[:framework_scheme]
    framework_project_path = options[:framework_project_path]

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

    gym(
      scheme: framework_scheme,
      project: framework_project_path,
      configuration: configuration,
      include_bitcode: include_bitcode,
      clean: false,
      sdk: skd,
      skip_build_archive: false,
      skip_archive: true,
      xcargs: xcargs
    )

  end
end
