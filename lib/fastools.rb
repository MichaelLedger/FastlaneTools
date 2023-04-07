# coding: utf-8

require 'cocoapods'
require 'openssl'

module Fastools
  ##
  #
  class SwiftLint
    # 判断是否已经添加了"Run SwiftLint Script"
    def self.exist_run_swiftlint_script(target)
      #puts target.name
  
      target.build_phases.each do |build_phase|
        #puts "  ╟ #{build_phase}"
        #puts String(build_phase) == 'Run SwiftLint Script'
      
        if String(build_phase) == 'Run SwiftLint Script'
         return true
        end
      end
  
      return false
    end

    # 添加"Run SwiftLint Script"到build phase中
    def self.add_run_swiftlint_script(target)
      phase = target.new_shell_script_build_phase("Run SwiftLint Script")
      phase.shell_script = "${PODS_ROOT}/SwiftLint/swiftlint"
      target.build_configurations.each do |config|
     end
    end
  end
  #

  ##
  #
  class Pod
    # 将`Pods`的`schema`和`project`先进行设置
    def self.set_share_scheme(installer)
      project = installer.pods_project
      project.recreate_user_schemes(:visible => true)
      project.targets.each do |target|
        Xcodeproj::XCScheme.share_scheme(installer.sandbox.project_path, target)
      end
      project.save
    end

    # 将`Pods`的`EXCLUDED_ARCHS[sdk=iphonesimulator*] = arm64`和`project`先进行设置
    def self.set_exclude_archs(installer, sdk, archs)

      project = installer.pods_project

      project.build_configurations.each do |config|
        puts "________________________"
        config.build_settings["EXCLUDED_ARCHS[sdk=#{sdk}*]"] = archs
        puts "set EXCLUDED_ARCHS[sdk=#{sdk}*] = #{archs}"
        puts "________________________"
      end

      project.save
    end

    # 将`Installer`打印出来
    def self.show_installer(installer)
      # puts 为在终端打印方法
      puts "##### post_install start #####"
  
      # 为了打印的日志方便查看，使用╟符号修饰
      puts "╟ installer"
      # 获取属性名称列表，并遍历
      installer.instance_variables.each do |variableName|
        # 打印属性名称
        puts "  ╟ #{variableName}"
      end
  
      puts "  ╟ installer.public_methods"
      # 获取方法名称列表，并遍历
      installer.public_methods.each do |method|
        # 打印方法名称
        puts "    ┣ #{method}"
      end
      puts "##### post_install end #####"
    end
  end

  ##
  #
  class Lipo
    # lipo -create
    def self.create(options={})
      output_framework = options[:output_framework]
      input_frameworks = options[:input_frameworks]
      system("lipo -create -output #{output_framework} #{input_frameworks.join(' ')}")
    end

    # lipo -info
    def self.info(options={})
      output_framework = options[:output_framework]
      system("lipo -info #{output_framework}")
    end

    # lipo -remove
    def self.remove(options={})
      arch_type = options[:arch_type]
      framework = options[:framework]
      system("lipo -remove #{archs.join(' ')} #{framework} -o #{framework}")
    end
  end
  class Cert
        
    def verify(options={})
      path = options[:path].to_s
      host = options[:host].to_s
      expired_in = options[:expired_in].to_i
      if (path == nil && host == nil) || (path == "" && host == "")
          puts "\033[41mMissing parameter, must exist [host:xxx] or [path:xxx].\033[0m\n"  
          return
      end

      if expired_in < 1
          expired_in = 30
      end
      if host != ""
          verify_website_cert(host, expired_in)
      else
          verify_local_cert(path, expired_in)
      end
    end

    def verify_local_cert(path, expired_in)
      if !File.exist?(path)
          puts path
          puts "\033[41mThe file is not exist, pls check your path.\033[0m\n" 
      else
          begin  
              cert = OpenSSL::X509::Certificate.new File.read path
              verify_certificate(cert, expired_in)
          rescue Exception => e  
              message = e.message  
              inspect = e.backtrace.inspect  
              puts "\033[41m#{message}\033[0m\n" 
              puts inspect
          end
      end
    end

    def verify_website_cert(path, expired_in)
      url = path
      if path.length <= 4
        url = "https://" + path
      end
      if path[0, 4] != "http"
        url = "https://" + path
      end
      cert = nil
      open_timeout = 5
      read_timeout = 5
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      http.open_timeout = open_timeout
      http.read_timeout = read_timeout
      http.use_ssl = true
      http.verify_mode = OpenSSL::SSL::VERIFY_PEER
      http.verify_callback = -> (verify_ok, store_context) {
          cert = store_context.current_cert
          chain = store_context.chain
          failed_cert_reason = [store_context.error, store_context.error_string] if store_context.error != 0
          verify_ok
      }
      begin
          http.start { }
          verify_certificate(cert, expired_in)
      rescue OpenSSL::SSL::SSLError => e
          error = e.message
          puts "\n\n\033[41m#{error}\033[0m\n"
      rescue => e
          puts "\n\n\033[41mSSL certificate test failed: #{e.message}\033[0m\n"
      end
    end

    def verify_certificate(cert, expired_in)
      puts "\033[32m\n\n#{cert.public_key}\033[0m\n"
      days = (cert.not_after.to_i - Time.now.to_i) / 86400
      if days <= expired_in
          puts "\033[41mnot_after: #{cert.not_after}\033[0m\n"
          puts "\033[41mYou just have #{days} days to update your certificate.\033[0m\n" 
      end
    end
  end

end