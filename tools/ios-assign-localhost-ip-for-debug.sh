#!/bin/bash

# Do it only for debug configurations
if [ "${CONFIGURATION}" != "Debug" ]; then
    return 
fi

# Search for all Config.swift files in the project directory
CONFIG_FILES=$(find "../" -name "Environment.swift")

# Check if any CONFIG_FILE was found
if [ -z "$CONFIG_FILES" ]; then
  echo "No Environment.swift files found!"
  exit 1
fi

# Determine the IP address based on the target device
if [ "${PLATFORM_NAME}" == "iphonesimulator" ]; then
  IP_ADDRESS="localhost"
else
  IP_ADDRESS=$(ipconfig getifaddr en0)
fi

# Loop through each found Config.swift file and update it
for CONFIG_FILE in $CONFIG_FILES; do
  # Update the return value of getLocalhostByIp to the new IP address
  awk -v ip="$IP_ADDRESS" '
  /public static func getLocalhostByIp/ {
    func_start = 1
  }
  func_start && /return/ {
    sub(/return ".*"/, "return \"" ip "\"")
    func_start = 0
  }
  { print }
  ' "$CONFIG_FILE" > tmp && mv tmp "$CONFIG_FILE"
  echo "Updated $CONFIG_FILE with IP address: $IP_ADDRESS"
done