
app_plist_path = ENV['APP_PLIST_PATH']
app_name = ENV['APP_NAME']
scheme = ENV['APP_SCHEME']
target_name = ENV['TARGET_NAME']
team_id =  ENV['TEAM_ID']
itc_team_id = ENV['ITC_TEAM_ID']
app_identifier = ENV['BUNDLE_IDENTIFIER']
app_extension_id = ENV['EXTENSION_BUNDLE_INDENTIFIERS']
output_path = ENV['OUTPUT_PATH']
gsp_path = ENV['GSP_PATH']

# App store connect
connect_key_id = ENV['CONNECT_KEY_ID']
connect_issuer_id = ENV['CONNECT_ISSUER_ID']
connect_key_filepath = ENV['CONNECT_KEY_FILEPATH']

# AppCenter
appcenter_app_name = ENV['APPCENTER_APP_NAME']
appcenter_owner_name = ENV['APPCENTER_OWNER_NAME']
appcenter_api_token = ENV['APPCENTER_API_TOKEN']

# PGYER
upload_to_pgy = ENV['UPLOAD_TO_PGY']
pgyer_api_key = ENV['PGYER_API_KEY']
oversea = ENV["OVERSEA"]

# Amplitude
app_amplitude_appcenter_key = ENV['APP_APMLITUDE_APPCENTER_KEY']
app_amplitude_appstore_key = ENV['APP_APMLITUDE_APPSTORE_KEY']

workspace = File.expand_path("..", Dir.pwd)
puts("Current dir ==> #{Dir.pwd}")
puts("Workspace dir ==> #{workspace}")

export_method_ad_hoc = "ad-hoc"
export_method_app_store = "app-store"

default_platform(:ios)
#xcode_select(ENV["XCODE_SELECT"])

platform :ios do

    desc "Write Fastlane build info to myenv.properties"
    desc "Sample: fastlane ios write_build_info_to_file"
    lane :write_build_info_to_file do
        build_number_input = get_build_number_from_plist(target: target_name, plist_build_setting_support: true)
        version_number_input = get_version_number_from_plist(target: target_name, plist_build_setting_support: true)
        build_info_input = "#{target_name} #{version_number_input} build #{build_number_input}"
        puts("build_info ==> #{build_info_input}")
        puts("ENV File ==> #{workspace}/myenv.properties")
        File.write("#{workspace}/myenv.properties", "FASTLANE_BUILD_INFO=#{build_info_input.to_s}\n")

        commit = last_git_commit
        hash = commit[:commit_hash]
        File.write("#{workspace}/myenv.properties", "COMMIT_ID=#{hash.to_s}", mode:"a")
        puts("COMMIT_ID=#{build_info_input.to_s}==>myenv.properties")
    end

    desc "Push a adhoc build to AppCenter and a release build to the App Store"
    desc "Sample: fastlane both"
    lane :both do
      appcenter
      release
    end

    desc "Push a new release build to the App Store"
    desc "Sample: fastlane release"
    lane :release do
        
        # pod_install
        
        authenticating_with_apple_services

        fill_amplitude_id(value: app_amplitude_appstore_key)

        match_appstore(readonly: true)

        build_app_store

        push_testflight

        upload_local_dSYM_to_crashlytics

    end

    desc "Push a new build to the AppCenter"
    desc "Sample: fastlane appcenter"
    lane :appcenter do
        
        # pod_install
        
        authenticating_with_apple_services

        bump_build_number_for_target

        write_build_info_to_file

        fill_amplitude_id(value: app_amplitude_appcenter_key)

        match_adhoc(readonly: true)

        build_appcenter

	    push_appcenter

        push_pgyer if upload_to_pgy == "true"

        upload_adhoc_dSYM_to_crashlytics
    end

    desc "Build the ipa for app store"
    desc "Sample fastlane build_app_store"
    lane :build_app_store do
        gym(
            clean: true,
		    scheme: scheme,
            output_directory: "#{output_path}/#{export_method_app_store}",
		    export_options: {
                method: export_method_app_store,
                thinning: "<thin-for-all-variants>",
                iCloudContainerEnvironment: "Production",
		        uploadSymbols: true,
		        compileBitcode: false
		    },
            output_name: "#{app_name}.ipa"
	    )
    end

    desc "Build the ipa for appcenter"
    desc "Sample: fastlane build_appcenter"
    lane :build_appcenter do
        gym(
            clean: true,
            scheme: scheme,
            output_directory: "#{output_path}/#{export_method_ad_hoc}",
            export_options: {
		        method: export_method_ad_hoc,
		        thinning: "<none>",
		        iCloudContainerEnvironment: "Production",
		        uploadSymbols: true,
		        compileBitcode: false
            },
            output_name: "#{app_name}.ipa"
        )
    end


    # https://github.com/Microsoft/fastlane-plugin-appcenter
    # https://github.com/microsoft/fastlane-plugin-appcenter/blob/master/fastlane/Fastfile
    #
    # api_token: "<appcenter token>"
    # owner_name: "<appcenter account name of the owner of the app (username or organization URL name)>"
    # owner_type: "user", # Default is user - set to organization for appcenter organizations
    # app_name: "<appcenter app name (as seen in app URL)>"
    # file: "<path to android build binary>"
    # destinations: "*", # Default is 'Collaborators', use '*' for all distribution groups
    # notify_testers: true # Set to false if you don't want to notify testers of your new release (default: `false`)


    desc "Upload the ipa and dSYM to AppCenter"
    desc "Sample: fastlane push_appcenter"
    lane :push_appcenter do
        appcenter_upload(
            api_token: appcenter_api_token,
            owner_name: appcenter_owner_name,
            app_name: appcenter_app_name,
            ipa: "#{output_path}/#{export_method_ad_hoc}/#{app_name}.ipa",
            notify_testers: true,
            release_notes: lane_context[SharedValues::FL_CHANGELOG]
        )
    end

    desc "Upload the ipa to PGYER"
    desc "Sample: fastlane push_pgyer"
    lane :push_pgyer do
        pgyer(api_key: pgyer_api_key, 
            ipa: "#{output_path}/#{export_method_ad_hoc}/#{app_name}.ipa",
            oversea:oversea.to_i,
            update_description: lane_context[SharedValues::FL_CHANGELOG]  
        )
    end

    desc "Upload the ipa to TestFlight"
    desc "Sample: fastlane push_testflight"
    lane :push_testflight do

        if lane_context[SharedValues::APP_STORE_CONNECT_API_KEY].nil?
            authenticating_with_apple_services
        end

        Actions.lane_context[SharedValues::FL_CHANGELOG] = nil

        upload_to_testflight(
            team_id: team_id,
            ipa: "#{output_path}/#{export_method_app_store}/#{app_name}.ipa",
            skip_waiting_for_build_processing: true
          )
    end

    #TODO: refact changelog
    desc "generate commit messages"
    private_lane :generate_commit_msgs do
        commit_msgs = changelog_from_git_commits(
			commits_count: 10,
			pretty: "- %s",
			merge_commit_filtering: "exclude_merges"
		)
		msgArray = commit_msgs.split("\n")
		filteredNotes = ""
		msgArray.each { |item|
			strAppend = item.gsub("#comment", "")
			filteredNotes += (strAppend + "\n")
		}
    end

    desc "Authenticating with Apple services"
    private_lane :authenticating_with_apple_services do
        app_store_connect_api_key(
            key_id: connect_key_id,
            issuer_id: connect_issuer_id,
            key_filepath: connect_key_filepath,
            duration: 500, # optional (maximum 1200)
            in_house: false # optional but may be required if using match/sigh
          )
    end

    desc "Fill in id for Amplitude"
    private_lane :fill_amplitude_id do |options|
        value = options[:value]
        set_info_plist_value(path: app_plist_path, key: "AmplitudeApiKey", value: value)
    end

    desc "Upload adhoc dSYM.zip to Crashlytics"
    desc "Sample: fastlane upload_adhoc_dSYM_to_crashlytics"
    lane :upload_adhoc_dSYM_to_crashlytics do
        filepath = "#{output_path}/#{export_method_ad_hoc}/#{app_name}.app.dSYM.zip"
        upload_symbols_to_crashlytics(dsym_path: filepath, gsp_path:gsp_path)
    end

    desc "Upload local dSYM.zip to Crashlytics"
    desc "Sample: fastlane upload_local_dSYM_to_crashlytics"
    lane :upload_local_dSYM_to_crashlytics do
        filepath = "#{output_path}/#{export_method_app_store}/#{app_name}.app.dSYM.zip"
        upload_symbols_to_crashlytics(dsym_path: filepath, gsp_path:gsp_path)
    end
    
end
