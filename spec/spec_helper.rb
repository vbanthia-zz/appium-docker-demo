# -*- coding: utf-8 -*-

require 'appium_lib'

# support files
SPEC_ROOT = File.expand_path(File.dirname(__FILE__))
Dir[File.expand_path('support/**/*.rb', SPEC_ROOT)].each { |f| require f }

app_path = ENV['APP_PATH'] || File.join(Bundler.root, 'apks', 'android-sample-app.apk')
device_serial = ENV['DEVICE_SERIAL'] || raise('please specify device serial by setting ENV["DEVICE_SERIAL"]')

RSpec.configure do |config|

  config.include ::Screenshot

  config.before(:suite) do
    driver_caps = {
      platformName: :android,
      deviceName: '',
      newCommandTimeout: '9999',
      androidPackage: 'jp.peroli.mery',
      app: app_path,
      udid: device_serial
    }

    Appium::Driver.new(caps: driver_caps).start_driver
  end

  config.after(:suite) do
    $driver.driver_quit
  end
end
