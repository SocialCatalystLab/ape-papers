#!/usr/bin/env python3
"""
Paper 75: The Making of a City
02_check_status.py - Check and download IPUMS extracts

Monitors extract status and downloads when complete.
"""

import os
import json
import time
from datetime import datetime
from pathlib import Path

try:
    from ipumspy import IpumsApiClient
except ImportError:
    print("Installing ipumspy...")
    os.system("pip install ipumspy")
    from ipumspy import IpumsApiClient

# ============================================================================
# Configuration
# ============================================================================

DATA_DIR = Path("output/paper_75/data")

# Load API key
IPUMS_API_KEY = os.environ.get("IPUMS_API_KEY")
if not IPUMS_API_KEY:
    raise ValueError("IPUMS_API_KEY not set. Run: source .env")

client = IpumsApiClient(IPUMS_API_KEY)

# ============================================================================
# Functions
# ============================================================================

def load_extract_ids():
    """Load previously submitted extract IDs."""
    extract_file = DATA_DIR / "extract_ids.json"
    if not extract_file.exists():
        print("No extract IDs found. Run 01_fetch_data.py first.")
        return None
    with open(extract_file) as f:
        return json.load(f)


def check_status(extract_id, collection="usa"):
    """Check status of an extract."""
    try:
        info = client.get_extract_info(int(extract_id), collection=collection)
        return info.get('status', 'unknown')
    except Exception as e:
        return f"error: {e}"


def download_extract(extract_id, collection="usa"):
    """Download a completed extract."""
    try:
        client.download_extract(int(extract_id), download_dir=str(DATA_DIR), collection=collection)
        return True
    except Exception as e:
        print(f"Download error: {e}")
        return False


def main():
    print("=" * 60)
    print(f"IPUMS Extract Status Check - {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("=" * 60)

    # Load extract IDs
    data = load_extract_ids()
    if not data:
        return

    print(f"\nSubmitted at: {data['submitted_at']}")
    print("\n" + "-" * 60)

    all_complete = True
    for name, extract_id in data["extracts"].items():
        status = check_status(extract_id)
        status_str = status if isinstance(status, str) else status

        if status_str in ("completed", "published"):
            emoji = "✓"
            print(f"{emoji} {name}: {status_str} (ID: {extract_id})")

            # Check if already downloaded
            expected_file = DATA_DIR / f"usa_{int(extract_id):05d}.csv.gz"
            if expected_file.exists():
                print(f"   Already downloaded: {expected_file}")
            else:
                print(f"   Downloading...")
                if download_extract(extract_id):
                    print(f"   Downloaded successfully")
                else:
                    print(f"   Download failed")
        elif status_str in ("queued", "started", "processing"):
            emoji = "⏳"
            print(f"{emoji} {name}: {status_str} (ID: {extract_id})")
            all_complete = False
        elif "error" in str(status_str):
            emoji = "✗"
            print(f"{emoji} {name}: {status_str}")
            all_complete = False
        else:
            emoji = "?"
            print(f"{emoji} {name}: {status_str} (ID: {extract_id})")
            all_complete = False

    print("-" * 60)

    if all_complete:
        print("\n✓ All extracts complete and downloaded!")
        print("\nNext steps:")
        print("  1. Run R script: Rscript 03_process_pilot.R")
    else:
        print("\n⏳ Some extracts still processing.")
        print("   Full-count extracts may take 2-6 hours.")
        print("   Run this script again to check status.")


if __name__ == "__main__":
    main()
