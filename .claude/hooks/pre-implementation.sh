#!/bin/bash
# Pre-Implementation Hook
# Prevents version conflicts in package.json before Edit/Write operations
# Trigger: PreToolUse event

set -euo pipefail

# Debug logging
LOG_FILE="/tmp/claude-hook-debug.log"
DEBUG_ENABLED=false

log_debug() {
    if [ "$DEBUG_ENABLED" = true ]; then
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
    fi
}

# JSON input from Claude
INPUT=$(cat)

log_debug "=== PreToolUse Hook Called ==="
log_debug "RAW INPUT: $INPUT"

TOOL=$(echo "$INPUT" | jq -r '.tool_name // .tool // ""')
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // .tool_input.filePath // ""')

log_debug "PARSED TOOL: $TOOL"
log_debug "PARSED FILE_PATH: $FILE_PATH"

# Only validate package.json changes
if [[ ! "$FILE_PATH" =~ package\.json$ ]]; then
    log_debug "SKIP: Not a package.json file"
    exit 0
fi

log_debug "VALIDATING: package.json detected"

# Find project root
find_project_root() {
    local file_path="$1"
    local current_dir=$(dirname "$file_path")

    while [ "$current_dir" != "/" ]; do
        if [ -f "$current_dir/package.json" ] || [ -f "$current_dir/tsconfig.json" ]; then
            echo "$current_dir"
            return 0
        fi
        current_dir=$(dirname "$current_dir")
    done

    dirname "$file_path"
}

PROJECT_ROOT=$(find_project_root "$FILE_PATH")
PROJECT_NAME=$(basename "$PROJECT_ROOT")

# Extract new content (for Write) or changes (for Edit)
if [ "$TOOL" = "Write" ]; then
    NEW_CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // ""')
elif [ "$TOOL" = "Edit" ]; then
    NEW_STRING=$(echo "$INPUT" | jq -r '.tool_input.new_string // ""')
    OLD_STRING=$(echo "$INPUT" | jq -r '.tool_input.old_string // ""')

    # Read existing package.json and simulate the change
    if [ -f "$FILE_PATH" ]; then
        EXISTING_CONTENT=$(cat "$FILE_PATH")
        NEW_CONTENT=$(echo "$EXISTING_CONTENT" | sed "s|$(echo "$OLD_STRING" | sed 's/[&/\]/\\&/g')|$(echo "$NEW_STRING" | sed 's/[&/\]/\\&/g')|g")

        # If JSON parsing fails, do basic validation on new_string only
        if ! echo "$NEW_CONTENT" | jq empty 2>/dev/null; then
            # Check for frozen versions defined in CLAUDE.md
            # Customize this section for your project's frozen dependencies
            exit 0
        fi
    else
        exit 0
    fi
else
    exit 0
fi

# Parse package.json to extract dependencies
if [ -z "$NEW_CONTENT" ]; then
    exit 0
fi

# Extract dependency versions from new content
get_dep_version() {
    local dep_name="$1"
    local content="$2"
    echo "$content" | jq -r ".dependencies[\"$dep_name\"] // .devDependencies[\"$dep_name\"] // .peerDependencies[\"$dep_name\"] // \"\""
}

# Firebase Compatibility Matrix
validate_firebase_compatibility() {
    local firebase_version=$(get_dep_version "firebase" "$NEW_CONTENT")
    local functions_version=$(get_dep_version "firebase-functions" "$NEW_CONTENT")
    local admin_version=$(get_dep_version "firebase-admin" "$NEW_CONTENT")

    # Skip if no Firebase dependencies
    if [ -z "$firebase_version" ] && [ -z "$functions_version" ] && [ -z "$admin_version" ]; then
        return 0
    fi

    # Extract major version numbers (remove ^ and ~ prefixes)
    firebase_major=$(echo "$firebase_version" | sed 's/[\^~]//g' | cut -d. -f1)
    functions_major=$(echo "$functions_version" | sed 's/[\^~]//g' | cut -d. -f1)
    admin_major=$(echo "$admin_version" | sed 's/[\^~]//g' | cut -d. -f1)

    local has_error=false
    local error_msg=""

    # Firebase 10.x requires functions 4.x-5.x and admin 12.x
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

    # Firebase 11.x requires functions 5.x-6.x and admin 12.x-13.x
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

    # Firebase 12.x requires functions 6.x and admin 13.x
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

    # Functions/admin pairing
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

# React Major Version Upgrade Protection
validate_react_constraints() {
    local react_version=$(get_dep_version "react" "$NEW_CONTENT")

    if [ -z "$react_version" ]; then
        return 0
    fi

    local react_major=$(echo "$react_version" | sed 's/[\^~]//g' | cut -d. -f1)

    # Block React major version upgrades (18→19) without explicit approval
    if [ -f "$FILE_PATH" ]; then
        local current_react=$(jq -r '.dependencies.react // ""' "$FILE_PATH")
        local current_major=$(echo "$current_react" | sed 's/[\^~]//g' | cut -d. -f1)

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

# Lock File Consistency Check
check_lock_file_consistency() {
    local project_root="$PROJECT_ROOT"

    if [ -f "$project_root/pnpm-lock.yaml" ] && [ -f "$project_root/package-lock.json" ]; then
        cat <<EOF
{
  "continue": false,
  "systemMessage": "Conflicting Lock Files Detected\n\nFound both:\n  - pnpm-lock.yaml\n  - package-lock.json\n\nIssue: Different package managers will produce different dependency trees\n\nRecommendation: Remove one of the lock files"
}
EOF
        exit 0
    fi

    return 0
}

# Node.js Engine Version Check
validate_node_engine() {
    local engines_node=$(echo "$NEW_CONTENT" | jq -r '.engines.node // ""')

    if [ -z "$engines_node" ]; then
        return 0
    fi

    if echo "$engines_node" | grep -qE "^(14|16)"; then
        cat <<EOF
{
  "continue": false,
  "systemMessage": "Outdated Node.js Version\n\nSpecified: $engines_node\n\nNode 14/16 reached EOL.\nRecommendation: Use Node 18 or 20\n\nUpdate engines.node to: >=18"
}
EOF
        exit 0
    fi

    return 0
}

# TypeScript Version Compatibility
validate_typescript_version() {
    local ts_version=$(get_dep_version "typescript" "$NEW_CONTENT")

    if [ -z "$ts_version" ]; then
        return 0
    fi

    local ts_major=$(echo "$ts_version" | sed 's/[\^~]//g' | cut -d. -f1)

    # Block TypeScript downgrade from 5.x to 4.x
    if [ "$ts_major" = "4" ] && [ -f "$FILE_PATH" ]; then
        local current_ts=$(jq -r '.devDependencies.typescript // .dependencies.typescript // ""' "$FILE_PATH")
        local current_major=$(echo "$current_ts" | sed 's/[\^~]//g' | cut -d. -f1)

        if [ "$current_major" = "5" ]; then
            cat <<EOF
{
  "continue": false,
  "systemMessage": "TypeScript Downgrade Blocked\n\nCurrent: TypeScript $current_ts\nAttempted: TypeScript $ts_version\n\nDowngrading from TS 5.x to 4.x may cause:\n- Loss of const type parameters\n- Loss of satisfies operator\n- Incompatible type definitions\n\nRecommendation: Keep TypeScript 5.x"
}
EOF
            exit 0
        fi
    fi

    return 0
}

# Duplicate Dependency Check
check_duplicate_dependencies() {
    local deps=$(echo "$NEW_CONTENT" | jq -r '.dependencies // {} | keys[]' 2>/dev/null)
    local devDeps=$(echo "$NEW_CONTENT" | jq -r '.devDependencies // {} | keys[]' 2>/dev/null)

    for dep in $deps; do
        if echo "$devDeps" | grep -qx "$dep"; then
            cat <<EOF
{
  "continue": false,
  "systemMessage": "Duplicate Dependency Detected\n\nPackage '$dep' found in both:\n  - dependencies\n  - devDependencies\n\nThis can cause version conflicts and unexpected behavior.\n\nRecommendation: Remove from one of the sections"
}
EOF
            exit 0
        fi
    done

    return 0
}

# Run all validations
validate_firebase_compatibility
validate_react_constraints
check_lock_file_consistency
validate_node_engine
validate_typescript_version
check_duplicate_dependencies

# All checks passed - silent success
exit 0
