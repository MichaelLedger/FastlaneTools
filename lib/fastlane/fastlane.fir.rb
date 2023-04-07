
default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

platform :ios do

  desc "Push a new build to fir"
  lane :upload_fir do
  	app_name = ENV['APP_NAME']
    build_output_directory = "fastlane/#{ENV['BUILD_OUTPUT_DIRECTORY']}" 
    fir_token = ENV['FIR_API_TOKEN']
    firim(
      firim_api_token: fir_token,
      ipa: "#{build_output_directory}/#{app_name}.ipa"
    )
  end
  
end

