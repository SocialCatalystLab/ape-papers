#!/usr/bin/env python3
"""
Paper 110: The Price of Distance
02_fetch_dispensaries.py - Collect dispensary locations from OSM and state sources
"""

import json
import os
import time
from pathlib import Path

import pandas as pd
import requests
from geopy.geocoders import Nominatim

# Project paths
PROJ_DIR = Path(__file__).parent.parent
DATA_DIR = PROJ_DIR / "data"
DATA_DIR.mkdir(parents=True, exist_ok=True)


def fetch_osm_dispensaries(state_abbr: str, bbox: tuple) -> pd.DataFrame:
    """Fetch cannabis dispensaries from OpenStreetMap via Overpass API."""
    print(f"  Fetching OSM dispensaries for {state_abbr}...")

    # Overpass query for shop=cannabis
    # bbox format: (south, west, north, east)
    south, west, north, east = bbox
    query = f"""
    [out:json][timeout:120];
    (
      node["shop"="cannabis"]({south},{west},{north},{east});
      way["shop"="cannabis"]({south},{west},{north},{east});
      node["amenity"="dispensary"]({south},{west},{north},{east});
      way["amenity"="dispensary"]({south},{west},{north},{east});
    );
    out center;
    """

    url = "https://overpass-api.de/api/interpreter"

    try:
        response = requests.post(url, data={"data": query}, timeout=180)
        response.raise_for_status()
        data = response.json()

        records = []
        for element in data.get("elements", []):
            if element["type"] == "node":
                lat, lon = element["lat"], element["lon"]
            elif element["type"] == "way" and "center" in element:
                lat, lon = element["center"]["lat"], element["center"]["lon"]
            else:
                continue

            tags = element.get("tags", {})
            records.append(
                {
                    "osm_id": element["id"],
                    "name": tags.get("name", "Unknown"),
                    "latitude": lat,
                    "longitude": lon,
                    "state": state_abbr,
                    "source": "osm",
                    "addr_street": tags.get("addr:street", ""),
                    "addr_city": tags.get("addr:city", ""),
                }
            )

        df = pd.DataFrame(records)
        print(f"    Found {len(df)} dispensaries in {state_abbr}")
        return df

    except Exception as e:
        print(f"    Error fetching {state_abbr}: {e}")
        return pd.DataFrame()


# Bounding boxes for legal states (south, west, north, east)
STATE_BBOXES = {
    "CO": (36.99, -109.05, 41.00, -102.04),
    "WA": (45.54, -124.85, 49.00, -116.92),
    "OR": (41.99, -124.57, 46.29, -116.46),
    "NV": (35.00, -120.01, 42.00, -114.04),
    "CA": (32.53, -124.48, 42.01, -114.13),
    "AK": (51.21, -179.15, 71.39, -129.99),
}


def main():
    print("=" * 60)
    print("Fetching cannabis dispensary locations")
    print("=" * 60)

    all_dispensaries = []

    # Fetch from OSM for each legal state
    for state, bbox in STATE_BBOXES.items():
        df = fetch_osm_dispensaries(state, bbox)
        if len(df) > 0:
            all_dispensaries.append(df)
        time.sleep(2)  # Be nice to Overpass API

    # Combine all
    if all_dispensaries:
        dispensaries = pd.concat(all_dispensaries, ignore_index=True)
        print(f"\nTotal dispensaries collected: {len(dispensaries)}")

        # Summary by state
        print("\nBy state:")
        print(dispensaries.groupby("state").size())

        # Save
        output_path = DATA_DIR / "dispensaries_osm.csv"
        dispensaries.to_csv(output_path, index=False)
        print(f"\nSaved to: {output_path}")
    else:
        print("No dispensaries found!")


if __name__ == "__main__":
    main()
