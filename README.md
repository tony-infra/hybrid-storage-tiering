# Automated Hybrid Storage Tiering 

## Overview
A custom Bash automation script designed to manage data lifecycles across a hybrid storage architecture. This script dynamically migrates aging data from a high-performance ZFS solid-state pool to a bulk-capacity mechanical array utilizing `mergerfs`, followed by an automated `SnapRAID` parity sync to ensure data integrity.

## Architecture & Logic
* **Data Migration:** Utilizes `find` and `rsync` to identify files older than a specified threshold (e.g., 30 days) on the hot ZFS pool and securely move them to the cold storage array.
* **Parity Protection:** Automatically triggers a `snapraid sync` upon successful file migration to calculate and update parity data for the mechanical drives.
* **Telemetry Integration:** Integrates directly with a self-hosted Home Assistant deployment via API webhooks. Pushes JSON payloads upon success or failure, allowing for real-time monitoring and alert generation on a custom diagnostic dashboard.

## Use Case
This automation eliminates the need for manual storage management, ensuring expensive SSD flash storage remains highly available for active applications (like Docker containers and LXC instances) while securely archiving static media and documents to cost-effective, parity-protected mechanical drives.
