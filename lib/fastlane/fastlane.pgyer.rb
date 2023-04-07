
default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

platform :ios do
    
    desc "Push a new build to pgyer"
    lane :upload_pgyer do
        build_output_directory = "fastlane/#{ENV['BUILD_OUTPUT_DIRECTORY']}"
        oversea = ENV["OVERSEA"]
        app_name = ENV["APP_NAME"]
        pgyer_api_key = ENV['PGYER_API_KEY']
        pgyer(
              oversea: oversea,
              api_key: pgyer_api_key,
              ipa: "#{build_output_directory}/#{app_name}.ipa"
              )
    end
    
end

