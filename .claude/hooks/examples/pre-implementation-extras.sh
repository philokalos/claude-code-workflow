#!/bin/bash
# Stack-specific Pre-Implementation Extras
#
# Sourced by pre-implementation.sh when present. Holds version-pin and
# compatibility checks that are NOT universal — Firebase release matrix,
# React major-version pins, etc. Customize for your project's stack.
#
# Required globals (set by the parent hook before sourcing):
#   NEW_CONTENT     — the post-edit package.json content
#   FILE_PATH       — absolute path to the package.json being edited
#   PROJECT_NAME    — basename of the resolved project root
#   get_dep_version — helper that reads a dependency version from $NEW_CONTENT
#
# Each validator should `cat` a JSON envelope and `exit 0` to block, or
# `return 0` to pass.

# Firebase Compatibility Matrix
# Update each release: https://firebase.google.com/support/release-notes/js
validate_firebase_compatibility() {
    local firebase_version
    firebase_version=$(get_dep_version "firebase" "$NEW_CONTENT")
    local functions_version
    functions_version=$(get_dep_version "firebase-functions" "$NEW_CONTENT")
    local admin_version
    admin_version=$(get_dep_version "firebase-admin" "$NEW_CONTENT")

    if [ -z "$firebase_version" ] && [ -z "$functions_version" ] && [ -z "$admin_version" ]; then
        return 0
    fi

    local firebase_major functions_major admin_major
    firebase_major=$(echo "$firebase_version" | sed 's/[\^~]//g' | cut -d. -f1)
    functions_major=$(echo "$functions_version" | sed 's/[\^~]//g' | cut -d. -f1)
    admin_major=$(echo "$admin_version" | sed 's/[\^~]//g' | cut -d. -f1)

    local has_error=false
    local error_msg=""

    if [ "$firebase_major" = "10" ]; then
        if [ -n "$functions_major" ] && [ "$functions_major" != "4" ] && [ "$functions_major" != "5" ]; then
            has_error=true
            error_msg="Firebase 10.x requires firebase-functions 4.x or 5.x (not $functions_major.x)"
        fi
        if [ -n "$admin_major" ] && [ "$admin_major" != "12" ]; then
            has_error=true
            error_msg="${error_msg}\nFirebase 10.x requires firebase-admin 12.x (not $admin_major.x)"
        fi
    fi

    if [ "$firebase_major" = "11" ]; then
        if [ -n "$functions_major" ] && [ "$functions_major" != "5" ] && [ "$functions_major" != "6" ]; then
            has_error=true
            error_msg="Firebase 11.x requires firebase-functions 5.x or 6.x (not $functions_major.x)"
        fi
        if [ -n "$admin_major" ] && [ "$admin_major" != "12" ] && [ "$admin_major" != "13" ]; then
            has_error=true
            error_msg="${error_msg}\nFirebase 11.x requires firebase-admin 12.x or 13.x (not $admin_major.x)"
        fi
    fi

    if [ "$firebase_major" = "12" ]; then
        if [ -n "$functions_major" ] && [ "$functions_major" != "6" ]; then
            has_error=true
            error_msg="Firebase 12.x requires firebase-functions 6.x (not $functions_major.x)"
        fi
        if [ -n "$admin_major" ] && [ "$admin_major" != "13" ]; then
            has_error=true
            error_msg="${error_msg}\nFirebase 12.x requires firebase-admin 13.x (not $admin_major.x)"
        fi
    fi

    if [ -n "$functions_major" ] && [ -n "$admin_major" ]; then
        if { [ "$functions_major" = "4" ] || [ "$functions_major" = "5" ]; } && [ "$admin_major" != "12" ]; then
            has_error=true
            error_msg="${error_msg}\nfirebase-functions $functions_major.x should pair with firebase-admin 12.x (not $admin_major.x)"
        fi
        if [ "$functions_major" = "6" ] && [ "$admin_major" != "13" ]; then
            has_error=true
            error_msg="${error_msg}\nfirebase-functions 6.x should pair with firebase-admin 13.x (not $admin_major.x)"
        fi
    fi

    if [ "$has_error" = true ]; then
        cat <<EOF
{
  "continue": false,
  "systemMessage": "Firebase Version Conflict Detected\n\n$error_msg\n\nCurrent versions in package.json:\n  firebase: $firebase_version\n  firebase-functions: $functions_version\n  firebase-admin: $admin_version\n\nRecommendation: Check Firebase compatibility matrix"
}
EOF
        exit 0
    fi

    return 0
}

# React Major Version Pin
# Adjust the {current_major, blocked_major} pair to match your project's pin.
validate_react_constraints() {
    local react_version
    react_version=$(get_dep_version "react" "$NEW_CONTENT")

    if [ -z "$react_version" ]; then
        return 0
    fi

    local react_major
    react_major=$(echo "$react_version" | sed 's/[\^~]//g' | cut -d. -f1)

    if [ -f "$FILE_PATH" ]; then
        local current_react
        current_react=$(jq -r '.dependencies.react // ""' "$FILE_PATH")
        local current_major
        current_major=$(echo "$current_react" | sed 's/[\^~]//g' | cut -d. -f1)

        if [ "$current_major" = "18" ] && [ "$react_major" = "19" ]; then
            cat <<EOF
{
  "continue": false,
  "systemMessage": "React 18 to 19 Upgrade Blocked\n\nProject: $PROJECT_NAME\nCurrent: React $current_react\nAttempted: React $react_version\n\nReason: Major version upgrade requires careful testing\n- Check peer dependencies compatibility\n- Update React DOM and other React packages together\n- Verify no breaking changes affect your code\n\nRecommendation: Review React 19 migration guide first"
}
EOF
            exit 0
        fi
    fi

    return 0
}

# Run stack-specific validators
validate_firebase_compatibility
validate_react_constraints
