# Introduction

In this tutorial, I am going to explain how you can dockerize your [Appium](http://appium.io/) automated tests without any pain. I believe that you have a fair experience in writing Appium tests and at least know a little about [Docker](https://www.docker.com/). Even if you don't know anything about these tools and follow all the instructions, you will still be able to run sample demo tests in docker container.

**NOTE: If you are too lazy to read the whole document and just wanna see how it works, you can check [Easy Setup](./docs/EASY_SETUP.md). But don't forget to come back here.**

Below, I am going to write a very brief introduction about appium and docker, if you already know them, feel free to skip this part and directly go to the next section.

## What is Appium?
Appium is an automation test framework for native, hybrid and mobile web apps. It uses [WebDriver](http://www.seleniumhq.org/projects/webdriver/) protocol for its apis, so people with [Selenium](http://www.seleniumhq.org/) background can easily start writing mobile tests using it. It also provides various client libraries in different languages, so you can choose anyone of your choice. You can read more about it [here](http://appium.io/tutorial.html).

## What is docker?
Docker helps you in containerising your application or any piece of code likes UI tests. It guarantees that it will always run the same, regardless of the environment it is running in. One of the biggest advantage of using this is that, it is very light weight. You can run multiple containers in the same machine without much overload because of docker. You can read more about it at [docker's home page](https://www.docker.com/). It has very good [tutorials](https://docs.docker.com/) for beginners.

# Why should I Dockerize my tests?
As soon as you start writing appium tests and as soon as tests start growing, you will realise that mobile tests take so much time compare to browser tests. And there are so many devices and OS Versions to cover. The only way to reduce run time is by parallelisation. Many people are doing this by using Virtual Machines but that is much heavier and slower compare to Docker.If you use docker, you can run test parallel very easily and fast. All you need to do is launch a new container which is only a single command. Rest docker will take care.

One more big advantage of using docker is that, you don't need to worry about your environment. Node version, Appium version, client language version etc etc. If your docker image is correct, it will run same on any machine.

# About this repository
Below is the directory structure of important files and directories for this demo project. Here, I will explain them in brief

```
├── android/
├── apks/
├── spec/
├──── features/
├────── addition_spec.rb
├────── division_spec.rb
├────── multiplication_spec.rb
├────── subtraction_spec.rb
├──── spec_helper.rb
├── Rakefile
├── scripts
├──── run_integration_test.sh
├── Dockerfile
```

### android
This is a very simple calculator app, which I made only for this tutorial. It has features such as adding, subtracting, multiplication and division of two numbers. This is how it looks like.

![calculator_app](./docs/calculator_app.png)

### apks
Binary file of the above test application. Ideally it should be created before test run so that you have latest application binary. But for simplicity, I am keeping this in repo itself.

### spec
Here, I have wrote appium tests for the calculator application. I have written tests in ruby but you can use any appium supported client language.

As you can see, I have divided the test cases according to feature. I have four sets of test cases for features such as addition, division, multiplication and subtraction. I did this, so that I can run test parallel.

I also advise you to keep your test cases separate according to the feature, which will also make them easy to maintain.

### Rakefile
I am using [ruby's rake tasks](https://github.com/ruby/rake) to implement short commands to run tests. This is how all the tasks look like

```bash
➜  appium-docker-test git:(master) ✗ bundle exec rake -T
rake spec                 # Run all test
rake spec:addition        # Run test for addition feature
rake spec:division        # Run test for division feature
rake spec:multiplication  # Run test for multiplication feature
rake spec:subtraction     # Run test for subtraciton feature
```

So, if you want to run test for only addition feature, you can run it by below command,

```bash
➜  appium-docker-test git:(master) ✗ DEVICE_SERIAL=xxxx bundle exec rake spec:addition
```

You can also see above that I am setting an env variable `DEVICE_SERIAL` while running tests. This is how, you can set which device to use while running tests.

### Dockerfile
This is the [Dockerfile](https://docs.docker.com/engine/reference/builder/) which is going to dockerize all our test. I will explain about this in detail later. For now just ignore it.

### scripts/run_integration_test.sh
This is a very small script which starts appium server at the beginning of test and then run test by running rake task. I wrote this as and entry point for Docker container, so when the docker container is launched this script will run. This is how you can run test using this script.

```bash
DEVICE_SERIAL=xxxx FEATURE=additions sh ./scripts/run_integration_test.sh
```

## How to run above test without docker?
In order to run these tests on your machine, first you have to meet all the requirements to run appium test, which means install these things

- Android sdks
- NodeJS
- Appium
- Ruby

Once you are done with installing above requirements, you need to install all the required gems. After this, you can run test with below command.

```bash
DEVICE_SERIAL=xxxx FEATURE=addition ./scripts/run_integration_test.sh
```

Next, if you want to run another set of tests parallel on the same machine using below command,

```bash
DEVICE_SERIAL=yyyy FEATURE=addition ./scripts/run_integration_test.sh
```

**Test will fail**

Tests are failing, because appium server cannot have multiple webdriver sessions. In order to run test parallel you need to modify `./scripts/run_integration_test.sh` script so that it can take new arguments such as `--appium-port`, `--bootstrap-port`, `--chromedriver-port` etc etc as described [here](https://github.com/appium/appium/blob/master/docs/en/writing-running-appium/server-args.md). And also, you have to initialise appium webdriver session according to those new ports. Pain isn't!

Also, if you want more parallel test then you will have to increase physical machines and then you will have to install all the requirements to run appium such as NodeJS, android sdk etc etc. which is again pain.

# How to dockerize test
If you dockerize your tests, the only requirement to run test on any machines is `docker`. And it is very easy to install. You can install it using using this [doc](https://docs.docker.com/).

In order to dockerize test, first we need to make a docker image for our test cases with all the required dependencies installed. It is only one time task. And I have already done most of the part, so you only need to copy it.

First, I have created an [appium-base](https://github.com/vbanthia/docker-appium/blob/master/appium-base/Dockerfile) image. This is how it looks,

```Dockerfile
FROM ubuntu:15.04
MAINTAINER Vishal Banthia <vishal.banthia.vb@gmail.com>

#=================================
# Customize sources for apt-get
#=================================
RUN  echo "deb http://archive.ubuntu.com/ubuntu vivid main universe\n" > /etc/apt/sources.list \
  && echo "deb http://archive.ubuntu.com/ubuntu vivid-updates main universe\n" >> /etc/apt/sources.list

#=============================================
# Install Android SDK's and Platform tools
#=============================================
RUN export DEBIAN_FRONTEND=noninteractive \
  && dpkg --add-architecture i386 \
  && apt-get update -y \
  && apt-get -y --no-install-recommends install \
    libc6-i386 \
    lib32stdc++6 \
    lib32gcc1 \
    lib32ncurses5 \
    lib32z1 \
    wget \
    curl \
    unzip \
    openjdk-7-jre-headless \
  && wget --progress=dot:giga -O /opt/adt.tgz \
    https://dl.google.com/android/android-sdk_r24.3.4-linux.tgz \
  && tar xzf /opt/adt.tgz -C /opt \
  && rm /opt/adt.tgz \
  && echo y | /opt/android-sdk-linux/tools/android update sdk --all --filter platform-tools,build-tools-23.0.1 --no-ui --force \
  && apt-get -qqy clean \
  && rm -rf /var/cache/apt/*

#================================
# Set up PATH for Android Tools
#================================
ENV PATH $PATH:/opt/android-sdk-linux/platform-tools:/opt/android-sdk-linux/tools
ENV ANDROID_HOME /opt/android-sdk-linux

#==========================
# Install Appium Dependencies
#==========================
RUN curl -sL https://deb.nodesource.com/setup_0.12 | bash - \
  && apt-get -qqy install \
    nodejs \
    python \
    make \
    build-essential \
    g++

#=====================
# Install Appium
#=====================
ENV APPIUM_VERSION 1.4.16

RUN mkdir /opt/appium \
  && cd /opt/appium \
  && npm install appium@$APPIUM_VERSION \
  && ln -s /opt/appium/node_modules/.bin/appium /usr/bin/appium

EXPOSE 4723

#==========================
# Run appium as default
#==========================
CMD /usr/bin/appium
```

As you can see, this docker image comes with following things installed

- ubuntu:15.04 as base OS
- Android sdks and platform tools
- NodeJS
- Appium v1.4.16

I am calling this image as appium-base because it has only appium installed. It does not support any appium client library except Java. In order to run test you will also need to install client language. In our case, it is ruby. I have already created an image called [appium-ruby](https://github.com/vbanthia/docker-appium/blob/master/appium-ruby/Dockerfile). It comes with following things,

- Appium v1.4.16
- Ruby 2.2
- bundler gem

Next, we need create a docker image for our tests. You can see [Dockerfile](./Dockerfile) for this demo project. This is how it looks,

```Dockerfile

# https://github.com/vbanthia/docker-appium/tree/master/appium-ruby/onbuild/Dockerfile
FROM vbanthia/appium-ruby:1.4.16

RUN bundle config --global frozen 1 \
  && mkdir -p /usr/src

WORKDIR /usr/src

COPY Gemfile /usr/src/
COPY Gemfile.lock /usr/src/
COPY package.json /usr/src/

RUN bundle install

COPY . /usr/src

# Run following script on docker run
ENTRYPOINT ["./scripts/run_integration_test.sh"]
```

As you can see, this image is copying all the files into container and then running `bundle install`. ENTRYPOINT field means what it will run when you start this container using `docker run` command. It will run `run_integration_test.sh` script at run, which is our test-runner script.


### Building docker image
You can build the docker image with only a single command

```bash
docker build -t appium-test:latest ./Dockerfile
```

Above command will build a new docker image for our test with name "appium-test" and "latest" tag. One important thing is, you only need to build this image once. You can run any number of container using same image. If you want to run containers on different machines then you can host your docker image on some docker hosting services such as [docker-hub](https://hub.docker.com/) or [create your own private registry](https://docs.docker.com/registry/deploying/) and pull it from there to keep image consistent.

### Running test in docker container
Next, you can run test with just a single command.

```bash
docker run -d --privileged -v /dev/bus/usb:/dev/bus/usb -e "DEVICE_SERIAL=xxxx" -e "FEATURE=addition" --name device1-addition appium-test:latest
```

You need to give this container --privileged access, so that it can access real device. Oh, I forget to mention that, you need to connect some real android device to run these tests.

If you want to start another container with different device, just start it with

```bash
docker run -d --privileged -v /dev/bus/usb:/dev/bus/usb -e "DEVICE_SERIAL=yyyy" -e "FEATURE=addition" --name device2-addition appium-test:latest
```

See, you don't need to think about `--appium-port`, `--bootstrap-port` etc etc. Docker is taking care of it by creating a new sandboxed environment.

The only requirement to run these container on any machine is `docker`, which is very very easy to install on any linux machine.


### Getting test results

You can extract test results from container after test finishes using command

```bash
docker cp appium-test:/usr/src/result.html ./
```

You can destroy the container after test finished using,

```bash
docker rm device1-addition
docker rm device2-addition
```

# Summary
As you can see how powerful can it be if you dockerize your appium test. It will be so easy to scale them. Test will be more robust and you can trust your test environment.

# Future Work

You can do lots of amazing things by using this approach. I could not explain all of them because this tutorial is already getting too long. I will just list them here. If you have any doubt regarding these feel free to create a new issue, I would love to answer you.

- Running test using CI Tools such as Jenkins by creating different jobs for different features and devices
- Creating pipelines, between your server release, mobile app release and appium tests using Jenkins
- Instead of attaching real devices to your machines, use tools such as [openstf](https://github.com/openstf/stf) and its [APIs](https://github.com/openstf/stf/blob/2.0.0/doc/API.md) which will solve your problems to manage real devices.

**PS: There are many things in this blog which I could not explain thoroughly because of time and length of this tutorial. Feel free to ask anything and it is open to all for contribution**
