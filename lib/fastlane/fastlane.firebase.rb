
default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

platform :ios do

  desc "Push a new build to Firebase"
  lane :upload_firebase do
    build_output_directory = "fastlane/#{ENV['BUILD_OUTPUT_DIRECTORY']}"
    app_name = ENV['APP_NAME']
    firebase_groups = ENV['FIREBASE_GROUPS']
    firebase_credentials_file = ENV['FIREBASE_CREDENTIALS_FILE']
    firebase_testers = ENV['FIREBASE_TESTERS']
    firebase_app_distribution(
        service_credentials_file: firebase_credentials_file,
        ipa_path: "#{output_path}/#{export_method_ad_hoc}/#{app_name}.ipa",
        testers: firebase_testers,
        groups: firebase_groups,
        debug: true,
    )
  end

  desc "login and upload ipa to firebase"
  lane :login_and_upload_to_firebase do |options|
      token = options[:token]
      app = options[:app]
      ipa_path = options[:ipa_path]
      release_notes = options[:release_notes]
      groups = options[:groups]
      # Step 2: Upload the IPA file to Firebase App Distribution
      UI.message("Uploading IPA to Firebase App Distribution...")

      unless File.exist?("fastlane/Pluginfile") && File.read("fastlane/Pluginfile").include?("fastlane-plugin-firebase_app_distribution")
          UI.message("Installing firebase_app_distribution plugin...")
          sh("bundle exec fastlane add_plugin firebase_app_distribution")
      end

      firebase_app_distribution(
        app: app, # Replace with your Firebase App ID
        ipa_path: ipa_path,  # Replace with the actual path to your IPA file
        groups:groups,                   # Specify the testers group
        release_notes: release_notes, # Optional release notes
        firebase_cli_token: token            # Use the token for authentication
      )
      
      # Step 3: Confirm successful upload
      UI.success("Upload completed successfully!")
  end
  
end

