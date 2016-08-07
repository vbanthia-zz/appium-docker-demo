#!/bin/bash
set -e

if [ "$DEVICE_SERIAL" == "" ]; then
  echo "Please provide $DEVICE_SERIAL"
  exit
fi

# Run appium server
echo "Starting appium server"
(appium &) > /dev/null 2>&1
sleep 15


# Run tests
if [ "$FEATURE" == "" ]; then
 echo "Running all tests"
 bundle exec rake spec
else
 echo "Running $FEATURE tests"
 bundle exec rake spec:$FEATURE
fi

echo "Test finished!"
