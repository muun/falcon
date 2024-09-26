#!/bin/bash

# Path to the Podfile.lock
PODFILE_LOCK="Podfile.lock"
# Path to the local specs repository
SPECS_REPO="/$HOME/.cocoapods/repos/trunk/Specs"
# Path to the output file
OUTPUT_FILE="pods_dependency_registry.txt"
# Temporary file for the new output
TEMP_OUTPUT_FILE="temp_pods_dependency_registry.txt"

# Initialize arrays to hold the pod names, versions, and checksums
declare -a pod_names
declare -a pod_versions
declare -a pod_checksums

# Read the Podfile.lock line by line
while IFS= read -r line; do
    # Check if we are in the PODS section
    if [[ "$line" == "PODS:" ]]; then
        in_pods_section=true
        continue
    fi

    # Exit the loop when we reach the DEPENDENCIES section
    if [[ "$in_pods_section" == true && "$line" == "DEPENDENCIES:" ]]; then
        break
    fi

    # If we are in the PODS section, extract pod names and versions
    if [[ "$in_pods_section" == true ]]; then
        if [[ "$line" == "  -"* ]]; then
            # Extract the pod name and version
            pod_name=$(echo "$line" | awk '{print $2}' | cut -d'(' -f1 | cut -d'/' -f1)
            pod_version=$(echo "$line" | awk '{print $3}' | tr -d '():')
            # Remove any surrounding quotes from pod_name
            pod_name=$(echo "$pod_name" | tr -d '"')
            # Add to arrays if not 'core'
            if [[ "$pod_name" != "core" && ! " ${pod_names[@]} " =~ " ${pod_name} " ]]; then
                pod_names+=("$pod_name")
                pod_versions+=("$pod_version")
            fi
        fi
    fi
done < "$PODFILE_LOCK"

# Read the checksums from the Podfile.lock
while IFS= read -r line; do
    if [[ "$line" == "SPEC CHECKSUMS:" ]]; then
        in_checksums_section=true
        continue
    fi

    if [[ "$in_checksums_section" == true ]]; then
        if [[ "$line" == "  "* ]]; then
            # Extract the pod name and checksum
            pod_name=$(echo "$line" | awk '{print $1}' | tr -d ':')
            pod_checksum=$(echo "$line" | awk '{print $2}')
            # Remove any surrounding quotes from pod_name
            pod_name=$(echo "$pod_name" | tr -d '"')
            # Check if the pod is in the pod_names array
            for i in "${!pod_names[@]}"; do
                if [[ "${pod_names[$i]}" == "$pod_name" ]]; then
                    pod_checksums[$i]="$pod_checksum"
                fi
            done
        fi
    fi
done < "$PODFILE_LOCK"

# Function to find the podspec using find command
find_podspec() {
    local pod_name=$1
    local pod_version=$2
    local podspec_file="$pod_name.podspec.json"
    local search_path="$SPECS_REPO"
    local found_path=$(find "$search_path" -path "*/$pod_version/$podspec_file" -print -quit)
    if [[ -n "$found_path" ]]; then
        echo "$found_path"
    else
        echo ""
    fi
}

# Function to calculate the checksum of the podspec
calculate_podspec_checksum() {
    local podspec_path=$1
    if [[ -f "$podspec_path" ]]; then
        checksum=$(shasum "$podspec_path" | awk '{print $1}')
        echo "$checksum"
    else
        echo ""
    fi
}

# Function to extract git URL from the podspec
extract_git_url() {
    local podspec_path=$1
    if [[ -f "$podspec_path" ]]; then
        git_url=$(jq -r '.source.git // empty' "$podspec_path" 2>/dev/null)
        if [[ -z "$git_url" ]]; then
            # Handle http and other formats
            git_url=$(jq -r '.source.http // empty' "$podspec_path" 2>/dev/null)
        fi
        echo "$git_url"
    else
        echo ""
    fi
}

# Print the pod names, git URLs, and checksums to a temporary file
for i in "${!pod_names[@]}"; do
    podspec_path=$(find_podspec "${pod_names[$i]}" "${pod_versions[$i]}")
    git_url=$(extract_git_url "$podspec_path")
    podspec_checksum=$(calculate_podspec_checksum "$podspec_path")
    echo "${pod_names[$i]}: $git_url, Checksum: $podspec_checksum" >> "$TEMP_OUTPUT_FILE"
done

# Update the output file regardless of changes
mv "$TEMP_OUTPUT_FILE" "$OUTPUT_FILE"

# Print the content of the output file
cat "$OUTPUT_FILE"
