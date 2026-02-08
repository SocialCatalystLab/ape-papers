#!/usr/bin/env python3
"""
Paper 110: The Price of Distance
03_compute_driving_times.py - Compute driving times from crash locations to nearest dispensary
"""

import numpy as np
import pandas as pd
from pathlib import Path
from scipy.spatial import cKDTree
from math import radians, sin, cos, sqrt, atan2

# Project paths
PROJ_DIR = Path(__file__).parent.parent
DATA_DIR = PROJ_DIR / "data"


def haversine_distance(lat1, lon1, lat2, lon2):
    """Calculate great-circle distance in km between two points."""
    R = 6371  # Earth's radius in km

    lat1, lon1, lat2, lon2 = map(radians, [lat1, lon1, lat2, lon2])
    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = sin(dlat / 2) ** 2 + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
    c = 2 * atan2(sqrt(a), sqrt(1 - a))

    return R * c


def estimate_drive_time(distance_km, road_type="highway"):
    """
    Estimate driving time in minutes from distance.

    Assumptions:
    - Highway (interstate): 100 km/h average (62 mph)
    - Primary road: 80 km/h average (50 mph)
    - Rural: 70 km/h average (43 mph)

    These are conservative (lower speeds mean longer times),
    accounting for stops, turns, and non-straight routes.
    """
    # Use average speed of 65 km/h for cross-border trips
    # (mix of highway and rural roads)
    avg_speed_kmh = 65

    # Add 30% for non-straight-line routing
    routing_factor = 1.3

    return (distance_km * routing_factor / avg_speed_kmh) * 60


def find_nearest_dispensary(crash_lat, crash_lon, disp_tree, disp_coords, disp_df):
    """Find nearest dispensary to a crash location."""
    if pd.isna(crash_lat) or pd.isna(crash_lon):
        return None, None, None

    # Query KD-tree for nearest neighbor
    # Note: KD-tree uses Euclidean distance, so we need to convert to proper coords
    # For accuracy at these latitudes, we use a simple projection

    # Convert to approximate local coordinates (km from reference point)
    ref_lat, ref_lon = 40.0, -110.0  # Roughly center of study region
    crash_x = (crash_lon - ref_lon) * 111 * cos(radians(crash_lat))
    crash_y = (crash_lat - ref_lat) * 111

    _, idx = disp_tree.query([crash_x, crash_y])

    # Get actual dispensary
    nearest_disp = disp_df.iloc[idx]

    # Calculate true distance
    dist_km = haversine_distance(
        crash_lat, crash_lon, nearest_disp["latitude"], nearest_disp["longitude"]
    )

    # Estimate drive time
    drive_time = estimate_drive_time(dist_km)

    return dist_km, drive_time, nearest_disp["state"]


def main():
    print("=" * 60)
    print("Computing driving times to nearest dispensary")
    print("=" * 60)

    # Load crashes
    crashes_path = DATA_DIR / "fars_crashes.rds"
    if not crashes_path.exists():
        print("Error: Run 01_fetch_fars.R first!")
        return

    # Load crashes via pyreadr
    import pyreadr

    crashes_rds = pyreadr.read_r(str(crashes_path))
    crashes = list(crashes_rds.values())[0]
    print(f"Loaded {len(crashes)} crashes")

    # Load dispensaries
    disp_path = DATA_DIR / "dispensaries_osm.csv"
    if not disp_path.exists():
        print("Error: Run 02_fetch_dispensaries.py first!")
        return

    dispensaries = pd.read_csv(disp_path)
    print(f"Loaded {len(dispensaries)} dispensaries")

    # Build KD-tree for dispensaries
    ref_lat, ref_lon = 40.0, -110.0
    disp_coords = []
    for _, row in dispensaries.iterrows():
        x = (row["longitude"] - ref_lon) * 111 * cos(radians(row["latitude"]))
        y = (row["latitude"] - ref_lat) * 111
        disp_coords.append([x, y])

    disp_tree = cKDTree(disp_coords)
    print("Built spatial index for dispensaries")

    # Filter to illegal-state crashes with coordinates
    illegal_states = ["ID", "WY", "NE", "KS", "UT", "AZ", "MT", "NM"]
    crashes_illegal = crashes[
        (crashes["state_abbr"].isin(illegal_states)) & (crashes["has_coords"] == True)
    ].copy()
    print(f"Processing {len(crashes_illegal)} crashes in illegal states with coordinates")

    # Compute nearest dispensary for each crash
    results = []
    for i, (idx, row) in enumerate(crashes_illegal.iterrows()):
        if i % 10000 == 0:
            print(f"  Processing crash {i}/{len(crashes_illegal)}")

        dist_km, drive_time, nearest_state = find_nearest_dispensary(
            row["latitude"], row["longitude"], disp_tree, disp_coords, dispensaries
        )

        results.append(
            {
                "st_case": row["st_case"],
                "year": row["year"],
                "dist_to_disp_km": dist_km,
                "drive_time_min": drive_time,
                "nearest_disp_state": nearest_state,
            }
        )

    results_df = pd.DataFrame(results)

    # Merge back to crashes
    crashes_with_dist = crashes_illegal.merge(
        results_df, on=["st_case", "year"], how="left"
    )

    # Summary statistics
    print("\n=== Distance to Dispensary Summary ===")
    print(f"Crashes with computed distance: {crashes_with_dist['dist_to_disp_km'].notna().sum()}")
    print("\nBy state:")
    print(
        crashes_with_dist.groupby("state_abbr")
        .agg(
            {
                "dist_to_disp_km": ["mean", "median", "std"],
                "drive_time_min": ["mean", "median"],
            }
        )
        .round(1)
    )

    # Save
    output_path = DATA_DIR / "crashes_with_distance.csv"
    crashes_with_dist.to_csv(output_path, index=False)
    print(f"\nSaved to: {output_path}")


if __name__ == "__main__":
    main()
