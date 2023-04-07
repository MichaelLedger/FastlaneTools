# coding: utf-8

require 'fastools'

default_platform(:ios)
xcode_select(ENV["XCODE_SELECT"])

platform :ios do

    desc "Verify the validity limit of certificate."
    desc "host:<string required url> path:<string required file path> expired_in:<intger optional default is 30>"
    desc "Samples1: fastlane ios verify_cert path:/Users/xxx/Desktop/test.cer expired_in:100"
    desc "Samples2: fastlane ios verify_cert url:https://google.com"
    lane :verify_cert do |options|
        cert = Fastools::Cert.new
        cert.verify(options)
    end

end