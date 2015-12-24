This is very easy setup to see how this work.

## Requirements
- docker

### Linux
If you are on linux machine you can easily install it using [docker docs](https://docs.docker.com)

### Mac OSX
In case you are on OSX, you can use [vagrant](https://www.vagrantup.com/). I have wrote a simple [Vagrantfile](../Vagrantfile) for this demo.

#### Add USB filters
In order to access real devices from VMs, it is necessary to create usb filters. Update [Vagrantfile](../Vagrantfile) for this. Instructions are written in file itself.

1. Connect the android device or devices to your OS X and check if they are properly connected by running `adb devices`
2. Get vendor_id and product_id of devices using `VBoxManage list usbhost` command. It will display something like this

  ```
  UUID:               e7757772-3030-44a3-ac14-00e53e9e32f8
  VendorId:           0x0fce (0FCE)
  ProductId:          0x519e (519E)
  Revision:           2.50 (0250)
  Port:               2
  USB version/speed:  0/High
  Manufacturer:       Sony
  Product:            SOL23
  SerialNumber:       CB5125LBYM
  Address:            p=0x519e;v=0x0fce;s=0x0001f3695ada4522;l=0x14200000
  Current State:      Busy
  ```

3. Uncomment the usbfilter line in [Vagrantfile](../coreos/Vagrantfile) and rewrite it like this.

  From:
  ```sh
  v.customize ['usbfilter', 'add', '0', '--target', :id, '--name', $ANY_NAME, '--vendorid', $VENDOR_ID, '--productid', $PRODUCT_ID]
  ```
  To:
  ```sh
  v.customize ['usbfilter', 'add', '0', '--target', :id, '--name', 'Sony SOL23', '--vendorid', '0x0fce', '--productid', '0x519e']
  ```

  In case you have more devices, add additional filters for them.

  Ref:
    * https://www.virtualbox.org/manual/ch03.html#idp47384979772560
    * http://spin.atomicobject.com/2014/03/21/smartcard-virtualbox-vm/

#### Start VM

```bash
vagrant up
vagrant ssh
```

#### Install docker

```bash
sudo apt-get update
sudo apt-get install docker
```

## Run appium tests

```bash
docker run -d --privileged -v /dev/bus/usb:/dev/bus/usb -e "DEVICE_SERIAL=xxxx" -e "FEATURE=addition" --name device1-addition vbanthia/appium-docker-test:latest
```

You need to add your device serial in `DEVICE_SERAIL` env variable. It will take few minutes to download docker image for the first time.
