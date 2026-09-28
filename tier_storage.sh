#!/bin/bash
# tier_storage.sh
# Automated data tiering from ZFS flash to mergerfs bulk storage with SnapRAID parity execution.

# --- Configuration Variables ---
HOT_STORAGE_POOL="/mnt/ssd-pool/data/"
COLD_STORAGE_ARRAY="/mnt/storage/archive/"
AGE_THRESHOLD="+30" # Move files older than 30 days
HA_WEBHOOK_URL="http://<HOME_ASSISTANT_IP>:8123/api/webhook/<YOUR_WEBHOOK_ID>"

# --- Execution ---
echo "Starting data tiering process..."

# 1. Identify and sync aging files from hot ZFS pool to cold mechanical array
find "$HOT_STORAGE_POOL" -type f -mtime "$AGE_THRESHOLD" -print0 | rsync -0 -av --remove-source-files --files-from=- / "$COLD_STORAGE_ARRAY"

if [ $? -eq 0 ]; then
    echo "Rsync completed successfully. Initiating SnapRAID sync."
    
    # 2. Update parity on the cold storage array
    snapraid sync
    
    if [ $? -eq 0 ]; then
        # 3. Fire success webhook to Home Assistant telemetry dashboard
        curl -X POST -H "Content-Type: application/json" -d '{"status":"success", "message":"Storage tiering and parity sync complete."}' "$HA_WEBHOOK_URL"
        echo "Process complete. Telemetry updated."
    else
        # Fire failure webhook for SnapRAID error
        curl -X POST -H "Content-Type: application/json" -d '{"status":"error", "message":"SnapRAID sync failed."}' "$HA_WEBHOOK_URL"
        echo "Error: SnapRAID sync failed."
    fi
else
    # Fire failure webhook for Rsync error
    curl -X POST -H "Content-Type: application/json" -d '{"status":"error", "message":"Rsync migration failed."}' "$HA_WEBHOOK_URL"
    echo "Error: Rsync migration failed."
fi
