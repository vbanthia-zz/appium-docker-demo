# -*- mode: ruby -*-
# -*- coding: utf-8 -*-

Vagrant.require_version '>= 1.6.0'

Vagrant.configure(2) do |config|
  # always use Vagrants insecure key
  config.ssh.insert_key = false

  # Ubuntu 14.04, 64 bit
  config.vm.box         = 'ubuntu/trusty64'
  config.vm.box_version = '~> 14.04'

  # Set memory to 2048
  # Allow I/O APIC
  config.vm.provider :virtualbox do |v|
    v.name = 'appium_ubuntu'
    v.customize ['modifyvm', :id, '--memory', '2048', '--ioapic', 'on']

    # Add usb filter to attach device
    v.customize ['modifyvm', :id, '--usb', 'on']
    # Run VBoxManage list usbhost command to get vendor_id and product_id of device
    # Uncomment below line and add $VENDOR_ID and $PRODUCT_ID of your device
    # In case of multiple devices, copy and paste below line.

    # v.customize ['usbfilter', 'add', '0', '--target', :id, '--name', $ANY_NAME, '--vendorid', $VENDOR_ID, '--productid', $PRODUCT_ID]

    # This was in my case
    v.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'SONY', '--vendorid', '0x0fce', '--productid', '0x519c']

  end

  # Provisioning
  config.vm.provision :shell do |sh|
    sh.inline = <<-EOF
      export DEBIAN_FRONTEND=noninteractive;
      # Install docker
      apt-get update --assume-yes
      apt-get install docker
    EOF
  end
end
