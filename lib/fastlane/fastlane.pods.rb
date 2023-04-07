
default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

platform :ios do
  
  desc "pod install"
  desc "Sample 1: fastlane ios pod_install"
  desc "Sample 2: fastlane ios pod_install podfile:<podfile>"
  lane :pod_install do |options|
    podfile = options[:podfile]
    cocoapods(
      clean_install: true,
      repo_update: true,
      podfile: podfile,
      verbose: true
    )
  end

  desc "pod repo add <spec-name> <spec-git-url>"
  desc "Sample: fastlane ios pod_repo_add"
  lane :pod_repo_add do
    repo_name    = ENV['REPO_NAME']
    repo_git_url = ENV['REPO_GIT_URL']
    sh "pod repo add #{repo_name} #{repo_git_url}"
  end

  desc "git_fetch_tag_force"
  desc "Samples:fastlane ios git_fetch_tag_force"
  lane :git_fetch_tag_force do
    UI.message("start fetch tags from remote")
    cmd = 'git fetch --tags -f'
    `#{cmd}`
    UI.message("fetch tags from remote finished")
  end

  desc "pod lib lint"
  desc "Sample: fastlane ios lint"
  lane :lint do
    target_project = ENV['FRAMEWORK_NAME']
    spec_path = "#{target_project}.podspec"
    sources = ENV['SOURCES']
    use_libraries = ENV['USE_LIBRARIES']

    if ENV.has_key?("SUBSPECS")
      subspecs = ENV['SUBSPECS'].split(",")
      subspecs.each do |subspec|
        pod_lib_lint(
        podspec:spec_path,
        sources: sources,
        subspec: subspec,
        use_libraries: use_libraries,
        allow_warnings: true,
        verbose: true)
      end
    else
      pod_lib_lint(
        podspec:spec_path,
        sources: sources,
        use_libraries: use_libraries,
        allow_warnings: true,
        verbose: false)
    end
  end

  desc "Bump podspec file version, bump_type: major, minor, patch"
  desc "Samples: fastlane ios bump_tag type:major"
  desc "Samples: fastlane ios bump_tag version:x.x.x"
  lane :bump_tag do |options|
    target_project = ENV['FRAMEWORK_NAME']
    tag_prefix = ENV['TAG_PREFIX']
    target_version = options[:version]
    bump_type = options[:type]
    spec_path = "#{target_project}.podspec"
    # 确认所有都已经提交
    ensure_git_status_clean

    # 修改 spec 为即将发布的版本
    if ["patch", "minor", "major"].include? bump_type
      target_version = version_bump_podspec(path: spec_path, bump_type: bump_type)
    else
      target_version = version_bump_podspec(path: spec_path, version_number: target_version)
    end
    UI.message("Bump podspec version to '#{target_version}'")

    # 提交代码到远程仓库
    git_add(path: '.')
    git_commit(path: '.', message: "[CI] Bump podspec version to '#{target_version}'")
    push_to_git_remote

    # 添加 tag
    add_git_tag(tag: "#{tag_prefix}-#{target_version}")

    # 提交 tag
    push_git_tags
  end

  desc "pod repo push"
  desc "Samples: fastlane ios repo_push"
  lane :repo_push do
    xcode_select(ENV['XCODE_SELECT'])
    target_repo    = ENV['REPO_NAME']
    target_project = ENV['FRAMEWORK_NAME']
    spec_path = "#{target_project}.podspec"
    sources = ENV['SOURCES']
    use_libraries = ENV['USE_LIBRARIES']

    # 检查是否传了 repo 参数
    if target_repo
      # pod repo push 'target_repo' 'spec_path'
      pod_push(
        use_bundle_exec: true,
        sources: sources,
        path: spec_path,
        repo: target_repo,
        use_libraries: use_libraries,
        allow_warnings: true,
        skip_import_validation: true,
        skip_tests: true,
        verbose: false)
    else
      # pod trunk push 'spec_path'
      pod_push(
        use_bundle_exec: true,
        path: spec_path,
        use_libraries: use_libraries,
        allow_warnings: true,
        skip_import_validation: true,
        skip_tests: true,
        verbose: false)
    end
  end

  desc "Release a private pod"
  desc "Samples 1: fastlane ios release_pod type:major"
  desc "Samples 2: fastlane ios release_pod version:x.x.x"
  lane :release_pod do |options|
    lint
    bump_tag(options)
    repo_push
  end

end
