#!/usr/bin/env python3
"""
Paper 75: Wait for IPUMS extracts
Polls every 15 minutes for full-count extracts per r_ipums.md guidelines.
"""

import os
import json
import time
from datetime import datetime
from pathlib import Path

from ipumspy import IpumsApiClient

# ============================================================================
# Configuration
# ============================================================================

DATA_DIR = Path("output/paper_75/data")
POLL_INTERVAL = 900  # 15 minutes for full-count extracts

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


def check_and_download(extract_id, name, collection="usa"):
    """Check status and download if complete."""
    try:
        info = client.get_extract_info(int(extract_id), collection=collection)
        status = info.get('status', 'unknown')
        links = info.get('downloadLinks', {})

        print(f"[{datetime.now().strftime('%H:%M:%S')}] {name} (ID {extract_id}): {status}")

        if status == "completed" and links:
            # Check if already downloaded
            expected_file = DATA_DIR / f"usa_{int(extract_id):05d}.csv.gz"
            if expected_file.exists():
                print(f"  Already downloaded: {expected_file}")
                return True
            else:
                print(f"  Downloading...")
                try:
                    client.download_extract(int(extract_id), download_dir=str(DATA_DIR), collection=collection)
                    print(f"  ✓ Download complete!")
                    return True
                except Exception as e:
                    print(f"  Download error: {e}")
                    return False
        elif status == "failed":
            print(f"  ✗ Extract failed!")
            return True  # Don't keep waiting for failed extract
        else:
            return False

    except Exception as e:
        print(f"  Error checking status: {e}")
        return False


def main():
    print("=" * 60)
    print("IPUMS Extract Poller - Full-Count Data")
    print("Polling every 15 minutes per r_ipums.md guidelines")
    print("=" * 60)

    data = load_extract_ids()
    if not data:
        return

    print(f"\nMonitoring {len(data['extracts'])} extracts...")
    print(f"Started at: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    print("-" * 60)

    # Track which extracts are done
    completed = set()

    while len(completed) < len(data['extracts']):
        for name, extract_id in data['extracts'].items():
            if name in completed:
                continue

            if check_and_download(extract_id, name):
                completed.add(name)

        # Check if all done
        if len(completed) >= len(data['extracts']):
            break

        # Wait before next poll
        remaining = len(data['extracts']) - len(completed)
        print(f"\n{remaining} extract(s) still processing. Waiting {POLL_INTERVAL // 60} minutes...")
        print(f"Next check at: {datetime.fromtimestamp(time.time() + POLL_INTERVAL).strftime('%H:%M:%S')}")
        time.sleep(POLL_INTERVAL)
        print()

    print("\n" + "=" * 60)
    print("✓ ALL EXTRACTS COMPLETE!")
    print("=" * 60)
    print("\nDownloaded files:")
    for f in DATA_DIR.glob("usa_*.csv.gz"):
        size_gb = f.stat().st_size / (1024**3)
        print(f"  {f.name}: {size_gb:.2f} GB")
    print("\nNext steps:")
    print("  Rscript output/paper_75/code/03_process_data.R")


if __name__ == "__main__":
    main()
