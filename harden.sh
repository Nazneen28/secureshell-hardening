#!/opt/homebrew/bin/bash

set -euo pipefail

# ============================================================
# SecureShell Hardening Auditor
# Day 35 - Cloud Engineering Journey
# ============================================================

FIX_MODE=false

# ------------------------------------------------------------
# Argument handling
# ------------------------------------------------------------

if [ "${1:-}" = "--fix" ]; then
    FIX_MODE=true
    SSHD_CONFIG="${2:-/etc/ssh/sshd_config}"
else
    SSHD_CONFIG="${1:-/etc/ssh/sshd_config}"
fi

# ------------------------------------------------------------
# Configuration
# ------------------------------------------------------------

LOG_FILE="hardening.log"
REPORT_JSON="report.json"

SCORE=0
MAX_SCORE=0

declare -A RESULTS

# ------------------------------------------------------------
# Logging
# ------------------------------------------------------------

log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# ------------------------------------------------------------
# Security check function
# ------------------------------------------------------------

check() {
    local name="$1"
    local passed="$2"
    local points="$3"

    MAX_SCORE=$((MAX_SCORE + points))

    if [ "$passed" = "true" ]; then
        SCORE=$((SCORE + points))
        RESULTS["$name"]="PASS"
        log "[PASS] $name"
    else
        RESULTS["$name"]="FAIL"
        log "[FAIL] $name"
    fi
}

# ------------------------------------------------------------
# Auto-remediation
# ------------------------------------------------------------

remediate() {

    if [ "$FIX_MODE" != true ]; then
        return
    fi

    log "Starting remediation on $SSHD_CONFIG..."

    # Create backup before modifying the configuration
    cp "$SSHD_CONFIG" "${SSHD_CONFIG}.bak"

    # macOS sed syntax is used because development is being done
    # on macOS. This logic targets the Linux sshd_config format.
    sed -i '' \
        -e 's/^PermitRootLogin.*/PermitRootLogin no/' \
        -e 's/^PasswordAuthentication.*/PasswordAuthentication no/' \
        -e 's/^PermitEmptyPasswords.*/PermitEmptyPasswords no/' \
        -e 's/^X11Forwarding.*/X11Forwarding no/' \
        -e 's/^MaxAuthTries.*/MaxAuthTries 4/' \
        -e 's/^ClientAliveInterval.*/ClientAliveInterval 300/' \
        -e 's/^AllowTcpForwarding.*/AllowTcpForwarding no/' \
        "$SSHD_CONFIG"

    log "Remediation complete."
    log "Backup created: ${SSHD_CONFIG}.bak"
}

# ------------------------------------------------------------
# Validate configuration file
# ------------------------------------------------------------

if [ ! -f "$SSHD_CONFIG" ]; then
    log "[ERROR] Config file not found: $SSHD_CONFIG"
    log "This tool targets Linux SSH servers such as AWS EC2 Ubuntu/RHEL."
    exit 1
fi

log "Auditing $SSHD_CONFIG"

# ------------------------------------------------------------
# Run remediation if --fix was supplied
# ------------------------------------------------------------

remediate

# ------------------------------------------------------------
# SSH Security Checks
# Total SSH points = 80
# ------------------------------------------------------------

# ------------------------------------------------------------
# SSH Security Checks
# Total SSH points = 80
# ------------------------------------------------------------

if grep -Eq '^PermitRootLogin[[:space:]]+no' "$SSHD_CONFIG"; then
    check "PermitRootLogin disabled" "true" 15
else
    check "PermitRootLogin disabled" "false" 15
fi

if grep -Eq '^PasswordAuthentication[[:space:]]+no' "$SSHD_CONFIG"; then
    check "PasswordAuthentication disabled" "true" 15
else
    check "PasswordAuthentication disabled" "false" 15
fi

if grep -Eq '^PermitEmptyPasswords[[:space:]]+no' "$SSHD_CONFIG"; then
    check "PermitEmptyPasswords disabled" "true" 10
else
    check "PermitEmptyPasswords disabled" "false" 10
fi

if grep -Eq '^X11Forwarding[[:space:]]+no' "$SSHD_CONFIG"; then
    check "X11Forwarding disabled" "true" 10
else
    check "X11Forwarding disabled" "false" 10
fi

if grep -Eq '^MaxAuthTries[[:space:]]+[1-4]$' "$SSHD_CONFIG"; then
    check "MaxAuthTries <= 4" "true" 10
else
    check "MaxAuthTries <= 4" "false" 10
fi

if grep -Eq '^ClientAliveInterval[[:space:]]+[1-9][0-9]*' "$SSHD_CONFIG"; then
    check "ClientAliveInterval configured" "true" 10
else
    check "ClientAliveInterval configured" "false" 10
fi

if grep -Eq '^AllowTcpForwarding[[:space:]]+no' "$SSHD_CONFIG"; then
    check "AllowTcpForwarding disabled" "true" 10
else
    check "AllowTcpForwarding disabled" "false" 10
fi
# ------------------------------------------------------------
    
# ------------------------------------------------------------
# Security Score
# ------------------------------------------------------------

percentage=$(( SCORE * 100 / MAX_SCORE ))

log "=========================================="
log "SECURITY SCORE: $SCORE / $MAX_SCORE (${percentage}%)"
log "=========================================="

# ------------------------------------------------------------
# JSON Report
# ------------------------------------------------------------

{
    echo "{"
    echo "  \"score\": $SCORE,"
    echo "  \"max_score\": $MAX_SCORE,"
    echo "  \"percentage\": $percentage,"
    echo "  \"timestamp\": \"$(date '+%Y-%m-%d %H:%M:%S')\","
    echo "  \"checks\": {"

    first=true

    for key in "${!RESULTS[@]}"; do

        if [ "$first" = true ]; then
            first=false
        else
            echo ","
        fi

        echo -n "    \"$key\": \"${RESULTS[$key]}\""

    done

    echo ""
    echo "  }"
    echo "}"
} > "$REPORT_JSON"

log "Report saved: $REPORT_JSON"