
default_platform(:ios)
#xcode_select(ENV["XCODE_SELECT"])

target_name = ENV["TARGET_NAME"]

platform :ios do

  desc "Increase app version of bump_type: major, minor, patch"
  desc "Sample 1: fastlane ios bump_app_version"
  desc "Sample 2: fastlane ios bump_app_version bump_type:<bump_type>"
  desc "Sample 3: fastlane ios bump_app_version version_number:<version_number>"
  lane :bump_app_version do |options|
    #ensure_git_status_clean
    bump_type = options[:bump_type]
    version_number = options[:version_number]

    if version_number.nil?
      v = increment_version_number(bump_type: bump_type)
    else
      v = increment_version_number(version_number: version_number)
    end

    git_commit(path: "*", message: "[CI] Bump app version to #{v}")
  end

  desc "Increase app version of bump_type: (major, minor, patchr) for specific target"
  desc "Sample: fastlane bump_version_number_for_target"
  desc "Sample 2: fastlane ios bump_version_number_for_target bump_type:<bump_type>"
  desc "Sample 3: fastlane ios bump_version_number_for_target version_number:<version_number>"
   lane :bump_version_number_for_target do |options|
    #ensure_git_status_clean

    bump_type = options[:bump_type]
    version_number = options[:version_number]

    if version_number.nil?
        if bump_type.nil?
            v = increment_version_number_in_xcodeproj(target: target_name, omit_zero_patch_version: true)
            increment_version_number_in_xcodeproj(target: "#{target_name}NotificationExtension", omit_zero_patch_version: true)
            increment_version_number_in_xcodeproj(target: "#{target_name}NotificationContentExtension", omit_zero_patch_version: true)
          else
            v = increment_version_number_in_xcodeproj(bump_type: bump_type, target: target_name, omit_zero_patch_version: true)
            increment_version_number_in_xcodeproj(bump_type: bump_type, target: "#{target_name}NotificationExtension", omit_zero_patch_version: true)
            increment_version_number_in_xcodeproj(bump_type: bump_type, target: "#{target_name}NotificationContentExtension", omit_zero_patch_version: true)
          end
    else
      v = increment_version_number_in_xcodeproj(version_number: version_number, target: target_name, omit_zero_patch_version: true)
      increment_version_number_in_xcodeproj(version_number: version_number, target: "#{target_name}NotificationExtension", omit_zero_patch_version: true)
      increment_version_number_in_xcodeproj(version_number: version_number, target: "#{target_name}NotificationContentExtension", omit_zero_patch_version: true)
    end

    git_commit(path: "*", message: "[CI] #{target_name} bump app version to #{v}")
    push_to_git_remote
  end

  desc "Increase build number"
  desc "Sample 1: fastlane ios bump_timestamp_build_number"
  desc "Sample 2: fastlane ios bump_timestamp_build_number tag:<tag>"
  desc "Sample 3: fastlane ios bump_timestamp_build_number build_number:<build_number>"
  desc "Sample 4: fastlane ios bump_timestamp_build_number build_number:<build_number> tag:<tag>"
  lane :bump_timestamp_build_number do |options|
    #ensure_git_status_clean
    new_build_number = options[:build_number]
    tag = options[:tag]

    if new_build_number.nil?

      timestamp = Time.now.utc
      new_build_number = "%d%02d%02d%02d%02d%02d" % [
        timestamp.year,
        timestamp.month,
        timestamp.day,
        timestamp.hour,
        timestamp.min,
        timestamp.sec
      ]
    end

    if not tag.nil?
      new_build_number = "#{tag}-#{new_build_number}"
    end 

    n = increment_build_number(
      build_number: new_build_number
    )
    git_commit(path: "*", message: "[CI] Bump build number to #{n}")
    
  end

  desc "Increase build number"
  desc "Sample 1: fastlane ios bump_build_number"
  desc "Sample 2: fastlane ios bump_build_number build_number:<build_number>"
  lane :bump_build_number do |options|
    #ensure_git_status_clean
    new_build_number = options[:build_number]

    if new_build_number.nil?
      n = increment_build_number
    else 
      n = increment_build_number(build_number: new_build_number)
    end
    git_commit(path: "*", message: "[CI] Bump build number to #{n}")
    push_to_git_remote
  end

  desc "Increase build number for specific target"
  desc "Sample: fastlane bump_build_number_for_target"
   lane :bump_build_number_for_target do
    #ensure_git_status_clean

    version_number = get_version_number_from_xcodeproj(target: target_name)
    build_number = increment_build_number_in_xcodeproj(target: target_name)
    increment_build_number_in_xcodeproj(target: "#{target_name}NotificationExtension")
    increment_build_number_in_xcodeproj(target: "#{target_name}NotificationContentExtension")
    
    git_commit(path: "*", message: "[CI] #{target_name} #{version_number} bump build number to #{build_number}")
    push_to_git_remote
  end

  # desc "Increase build number automatically"
  # desc "Update build number to next one available"
  # lane :auto_bump_build_number do
  #   version = get_version_number(
  #     target: ENV['SCHEME']
  #   )
    
  #   current_build_number = latest_testflight_build_number(version: version) + 1

  #   n = increment_build_number(
  #     build_number: current_build_number
  #   )
  #   git_commit(path: "*", message: "[CI] Bump build number to #{n}")
  # end

end

