
app_plist_path = ENV['APP_PLIST_PATH']
app_name = ENV['APP_NAME']
project = ENV['PROJECT']
scheme = ENV['APP_SCHEME']
target_name = ENV['TARGET_NAME']
team_id =  ENV['TEAM_ID']
output_path = ENV['OUTPUT_PATH']
binary_path = ENV['BINARY_PATH']

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

# Firebase
gsp_path = ENV['GSP_PATH']
firebase_app_id = ENV['FIREBASE_APP_ID']
firebase_credentials_file = ENV['FIREBASE_CREDENTIALS_FILE']
firebase_groups = ENV['FIREBASE_GROUPS']

# Amplitude
app_amplitude_appcenter_key = ENV['APP_APMLITUDE_APPCENTER_KEY']
app_amplitude_appstore_key = ENV['APP_APMLITUDE_APPSTORE_KEY']

# Ding Talk
access_token = ENV["DING_TALK_ACCESS_TOKEN"]
secret = ENV['DING_TALK_SECRET']
isAtAll = ENV['IS_AT_ALL']
atList = ENV['AT_LIST'].split(",")

workspace = File.expand_path("..", Dir.pwd)
puts("Current dir ==> #{Dir.pwd}")
puts("Workspace dir ==> #{workspace}")

export_method_ad_hoc = "ad-hoc"
export_method_app_store = "app-store"

adhoc_build_configuration = "Release"
test_flight_build_configuration = "TestFlight"


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

    desc "Push a adhoc build to Firebase and a release build to the App Store"
    desc "Sample: fastlane both"
    lane :firebase_and_app_store do
        firebase
        release
    end

    desc "Push a adhoc build to Firebase/AppCenter and a release build to the App Store"
    desc "Sample: fastlane both"
    lane :adhoc_and_app_store do
        all_ad_hoc
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

        build_adhoc_ipa

        push_pgyer if upload_to_pgy == "true"

        notify_dingtalk if upload_to_pgy == "true"

	    push_appcenter

        upload_adhoc_dSYM_to_crashlytics
    end

    desc "Push a new build to the Firebase"
    desc "Sample: fastlane firebase"
    lane :firebase do
        
        # pod_install
        
        authenticating_with_apple_services

        bump_build_number_for_target

        write_build_info_to_file

        fill_amplitude_id(value: app_amplitude_appcenter_key)

        match_adhoc(readonly: true)

        build_adhoc_ipa

        push_pgyer if upload_to_pgy == "true"

        notify_dingtalk if upload_to_pgy == "true"

	    push_firebase

        upload_adhoc_dSYM_to_crashlytics
    end

    desc "Push a new build to the Firebase"
    desc "Sample: fastlane firebase"
    lane :all_ad_hoc do
        
        # pod_install
        
        authenticating_with_apple_services

        bump_build_number_for_target

        write_build_info_to_file

        fill_amplitude_id(value: app_amplitude_appcenter_key)

        match_adhoc(readonly: true)

        build_adhoc_ipa

        push_pgyer if upload_to_pgy == "true"

        notify_dingtalk if upload_to_pgy == "true"

	    push_firebase

        push_appcenter

        upload_adhoc_dSYM_to_crashlytics
    end

    desc "Build the ipa for app store"
    desc "Sample fastlane build_app_store"
    lane :build_app_store do
        gym(
            clean: true,
            project: project,
		    scheme: scheme,
            output_directory: "#{output_path}/#{export_method_app_store}",
		    export_options: {
                method: export_method_app_store,
                thinning: "<thin-for-all-variants>",
		        include_symbols: true,
		        include_bitcode: false
		    },
            output_name: "#{app_name}.ipa",
            configuration: test_flight_build_configuration
	    )
    end

    desc "Build the ipa for appcenter"
    desc "Sample: fastlane build_adhoc_ipa"
    lane :build_adhoc_ipa do
        gym(
            clean: true,
            project: project,
            scheme: scheme,
            output_directory: "#{output_path}/#{export_method_ad_hoc}",
            export_options: {
		        method: export_method_ad_hoc,
		        thinning: "<none>",
		        include_symbols: false,
		        include_bitcode: false
            },
            output_name: "#{app_name}.ipa",
            configuration: adhoc_build_configuration
        )
    end

    desc "Push a new analyze "
    desc "Sample: fastlane analyze"
    
    lane :analyze do
        
        # pod_install
        
        authenticating_with_apple_services

        fill_amplitude_id(value: app_amplitude_appstore_key)

        match_appstore(readonly: true)

        build_and_analyze
    end

    desc "Push a new build to Firebase"
    lane :push_firebase do
      firebase_app_distribution(
            # googleservice_info_plist_path: gsp_path, (not working, will use this later)
            app: firebase_app_id,
            service_credentials_file: firebase_credentials_file,
            ipa_path: "#{output_path}/#{export_method_ad_hoc}/#{app_name}.ipa",
            release_notes: lane_context[SharedValues::FL_CHANGELOG],
            groups: firebase_groups,
            debug: true,
      )
    end

    desc "Upload the ipa and dSYM to AppCenter"
    desc "Sample: fastlane push_appcenter"
    lane :push_appcenter do
        appcenter_upload(
            api_token: appcenter_api_token,
            owner_name: appcenter_owner_name,
            app_name: appcenter_app_name,
            file: "#{output_path}/#{export_method_ad_hoc}/#{app_name}.ipa",
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
        puts("AmplitudeApiKey is ==> #{value}")
        set_info_plist_value(path: app_plist_path, key: "AmplitudeApiKey", value: value)
    end

    desc "Upload adhoc dSYM.zip to Crashlytics"
    desc "Sample: fastlane upload_adhoc_dSYM_to_crashlytics"
    lane :upload_adhoc_dSYM_to_crashlytics do
        filepath = "#{output_path}/#{export_method_ad_hoc}/#{app_name}.app.dSYM.zip"
        upload_symbols_to_crashlytics(dsym_path: filepath, gsp_path:gsp_path, binary_path: binary_path)
    end

    desc "Upload local dSYM.zip to Crashlytics"
    desc "Sample: fastlane upload_local_dSYM_to_crashlytics"
    lane :upload_local_dSYM_to_crashlytics do
        filepath = "#{output_path}/#{export_method_app_store}/#{app_name}.app.dSYM.zip"
        upload_symbols_to_crashlytics(dsym_path: filepath, gsp_path:gsp_path, binary_path: binary_path)
    end
    
    desc "Build and analyze the project"
    lane :build_and_analyze do
        gym(
            scheme: scheme,
            project: project,
            clean: true,
            xcargs: "analyze",
            export_options: {
                  compileBitcode: false,
                  method: export_method_app_store,
                  exportPath: "#{output_path}/#{export_method_app_store}"
                }
            )
    end

    desc "Push a message to ding talk"
    lane :notify_dingtalk do
  
      build_number_input = get_build_number_from_plist(target: target_name, plist_build_setting_support: true)
      version_number_input = get_version_number_from_plist(target: target_name, plist_build_setting_support: true)
      build_info_input = "#{target_name} #{version_number_input} (#{build_number_input})"
  
      dingtalk_msg(
        access_token: access_token,                        # Replace with your DingTalk webhook token
        secret: secret,                                    # Optional: security signature token for DingTalk
        atList: atList,                                    # Optional: Mention specific users
        atAll: isAtAll,                                    # Optional: Mention all users (default: false)
        message: "iOS #{build_info_input.to_s} completed successfully!",               # Your message
      )
    end

end
