
default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

platform :ios do

  desc "Push a new build to Appcenter"
  lane :upload_appcenter do
    build_output_directory = "fastlane/#{ENV['BUILD_OUTPUT_DIRECTORY']}" 
    app_name = ENV['APP_NAME']
    appcenter_api_token = ENV['APPCENTER_API_TOKEN']
    appcenter_owner_name = ENV['APPCENTER_OWNER_NAME']
    appcenter_upload(
      api_token: appcenter_api_token,
      owner_name:appcenter_owner_name,
      app_name: app_name,
      ipa: "#{build_output_directory}/#{app_name}.ipa"
    )
  end
  
end

