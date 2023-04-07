
require 'fileutils'
require 'json'

default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

k_bugly_app_id = ENV['BUGLY_APP_ID']
k_bugly_app_key = ENV['BUGLY_APP_KEY']

platform :ios do

  desc "Upload beta dSYM.zip to Bugrly"
  desc "Samples: fastlane ios upload_itc_dSYM_to_bugly build_number:<build_number> app_version:<app_version>"
  lane :upload_itc_dSYM_to_bugly do |options|
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

    bundle_id = ENV['BUNDLE_IDENTIFIER']

    dysm_output_directory = ENV['DYSM_OUTPUT_DIRECTORY']

    FileUtils.mkdir_p "#{dysm_output_directory}"

    filepath = "#{dysm_output_directory}/#{bundle_id}-#{app_version}-#{build_number}.dSYM.zip"

    download_itc_dsyms(build_number:build_number, app_version:app_version)
    upload_bugly_dSYM(filepath:filepath)
  end

  desc "Upload adhoc dSYM.zip to Bugrly"
  desc "Samples: fastlane upload_adhoc_dSYM_to_bugly"
  lane :upload_local_dSYM_to_bugly do
    app_name = ENV['APP_NAME']
    build_output_directory = ENV['BUILD_OUTPUT_DIRECTORY']

    filepath = "#{build_output_directory}/#{app_name}.app.dSYM.zip"
    upload_bugly_dSYM(filepath:filepath)
  end

  desc "Upload dSYM.zip to Bugrly"
  desc "Samples: fastlane upload_bugly_dSYM filepath:build-app-store/app.app.dSYM.zip"
  lane :upload_bugly_dSYM do |options|
    filepath = options[:filepath]

    bundle_id = ENV['BUNDLE_IDENTIFIER']

    app_version = get_version_number(
      target: ENV['APP_SCHEME']
    )

    build_number = get_build_number

    product_version = "#{build_number}@#{app_version}"

    upload_bugly(
      bundle_id: bundle_id, 
      filepath: filepath, 
      product_version: product_version)
  end

  private_lane :upload_bugly do |options|
    bundle_id = options[:bundle_id]
    filepath = options[:filepath]
    product_version = options[:product_version]

    UI.message "upload dSYM.zip to bugly ..."

    json_file = 'upload_app_to_bugly_result.json'
    cmd = "curl -k \"https://api.bugly.qq.com/openapi/file/upload/symbol?app_key=#{k_bugly_app_key}&app_id=#{k_bugly_app_id}\" --form \"api_version=1\" --form \"app_id=#{k_bugly_app_id}\" --form \"app_key=#{k_bugly_app_key}\" --form \"symbolType=2\" --form \"bundleId=#{bundle_id}\" --form \"productVersion=#{product_version}\" --form \"channel=fastlane\" --form \"fileName=#{filepath}\" --form \"file=@#{filepath}\" -o " + json_file + " --verbose"
    UI.message cmd
    sh(cmd)
    res = JSON.parse(File.read(json_file))

    UI.message "#{res}"

    ret = res['rtcode']
    msg = res['msg']

    if ret == 0
      UI.message "upload success"
    else
      UI.message "upload failed,result is #{msg}"
    end
  end
end
