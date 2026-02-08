#!/usr/bin/env python3
"""
Paper 108: Geocoded Atlas of US Traffic Fatalities 2001-2023
03_snap_crashes.py - Snap all FARS crashes to nearest road segments
"""

import os
import warnings
from pathlib import Path
from concurrent.futures import ProcessPoolExecutor, as_completed

import geopandas as gpd
import numpy as np
import pandas as pd

warnings.filterwarnings('ignore')

# Directories
DATA_DIR = Path("output/paper_108/data")
OSM_DIR = DATA_DIR / "osm_roads"

# State FIPS to abbreviation mapping
FIPS_TO_ABBR = {
    "02": "AK", "04": "AZ", "06": "CA", "08": "CO",
    "16": "ID", "20": "KS", "30": "MT", "31": "NE",
    "32": "NV", "35": "NM", "41": "OR", "49": "UT",
    "53": "WA", "56": "WY"
}


def snap_batch(crashes_subset, roads_gdf, max_dist_m=200):
    """
    Snap a batch of crashes to roads.

    Parameters
    ----------
    crashes_subset : GeoDataFrame
        Subset of crashes to snap
    roads_gdf : GeoDataFrame
        Road network
    max_dist_m : float
        Maximum snap distance

    Returns
    -------
    result : GeoDataFrame
        Snapped crashes with road attributes
    """
    if len(crashes_subset) == 0:
        return crashes_subset

    # Spatial join nearest
    result = gpd.sjoin_nearest(
        crashes_subset,
        roads_gdf[['geometry', 'highway', 'name', 'maxspeed', 'lanes', 'ref']],
        how="left",
        max_distance=max_dist_m,
        distance_col="snap_dist_m"
    )

    return result


def get_roads_for_state(state_fips):
    """Load road network for a state."""
    state_abbr = FIPS_TO_ABBR.get(state_fips, None)
    if state_abbr is None:
        return None

    roads_file = OSM_DIR / f"highways_{state_abbr}.gpkg"
    if roads_file.exists():
        roads = gpd.read_file(roads_file)
        if roads.crs is None or roads.crs.is_geographic:
            roads = roads.to_crs("EPSG:5070")
        return roads

    return None


def main():
    """Main execution."""
    print("=" * 60)
    print("Snap FARS Crashes to Road Network")
    print("=" * 60)

    # Load FARS data
    fars_file = DATA_DIR / "fars_analysis_policy.csv"
    if not fars_file.exists():
        fars_file = DATA_DIR / "fars_analysis.csv"

    if not fars_file.exists():
        print(f"Error: FARS data not found at {fars_file}")
        print("Run 01_fetch_fars.R and 04_merge_policy.R first")
        return

    print(f"\nLoading FARS data from {fars_file}...")
    fars = pd.read_csv(fars_file)
    print(f"  Loaded {len(fars):,} crashes")

    # Filter to geocoded crashes
    fars = fars.dropna(subset=['latitude', 'longitude'])
    print(f"  Geocoded crashes: {len(fars):,}")

    # Convert to GeoDataFrame
    fars_gdf = gpd.GeoDataFrame(
        fars,
        geometry=gpd.points_from_xy(fars.longitude, fars.latitude),
        crs="EPSG:4326"
    )

    # Project to Albers Equal Area
    fars_gdf = fars_gdf.to_crs("EPSG:5070")
    print("  Projected to EPSG:5070 (Albers Equal Area)")

    # Process by state
    print("\n" + "-" * 60)
    print("Snapping crashes by state...")
    print("-" * 60)

    results = []

    for state_fips, state_abbr in FIPS_TO_ABBR.items():
        # Get crashes for this state
        state_crashes = fars_gdf[fars_gdf['state_fips'] == state_fips].copy()

        if len(state_crashes) == 0:
            print(f"  {state_abbr}: No crashes")
            continue

        # Load roads
        roads = get_roads_for_state(state_fips)

        if roads is None:
            print(f"  {state_abbr}: No road network available")
            # Keep crashes without road attributes
            state_crashes['snap_dist_m'] = np.nan
            state_crashes['highway'] = np.nan
            state_crashes['road_name'] = np.nan
            state_crashes['maxspeed'] = np.nan
            state_crashes['lanes'] = np.nan
            state_crashes['ref'] = np.nan
            results.append(state_crashes)
            continue

        # Snap crashes to roads
        print(f"  {state_abbr}: Snapping {len(state_crashes):,} crashes...", end=" ")

        snapped = snap_batch(state_crashes, roads, max_dist_m=200)

        # Rename columns to avoid conflicts
        if 'name' in snapped.columns:
            snapped = snapped.rename(columns={'name': 'road_name'})

        # Report stats
        n_snapped = snapped['snap_dist_m'].notna().sum()
        mean_dist = snapped['snap_dist_m'].mean()
        print(f"{n_snapped:,} snapped (mean dist: {mean_dist:.0f}m)")

        results.append(snapped)

    # Combine results
    print("\n" + "-" * 60)
    print("Combining results...")
    print("-" * 60)

    fars_snapped = pd.concat(results, ignore_index=True)

    # Clean up columns
    cols_to_keep = [c for c in fars_snapped.columns if not c.endswith('_left') and not c.endswith('_right')]
    # Remove index_right if present
    if 'index_right' in cols_to_keep:
        cols_to_keep.remove('index_right')
    fars_snapped = fars_snapped[cols_to_keep]

    # Summary statistics
    print(f"\nTotal crashes: {len(fars_snapped):,}")
    print(f"Successfully snapped: {fars_snapped['snap_dist_m'].notna().sum():,}")
    print(f"Mean snap distance: {fars_snapped['snap_dist_m'].mean():.1f} m")

    # Road type breakdown
    print("\nCrashes by road type (highway tag):")
    highway_counts = fars_snapped['highway'].value_counts(dropna=False).head(10)
    for hw, count in highway_counts.items():
        print(f"  {hw}: {count:,}")

    # Save results
    print("\n" + "-" * 60)
    print("Saving results...")
    print("-" * 60)

    # Save as GeoPackage
    output_gpkg = DATA_DIR / "fars_snapped.gpkg"
    fars_snapped.to_file(output_gpkg, driver="GPKG")
    print(f"  Saved to {output_gpkg}")

    # Also save as CSV (drop geometry)
    output_csv = DATA_DIR / "fars_snapped.csv"
    fars_df = fars_snapped.drop(columns=['geometry'])

    # Add back lat/lon
    coords = fars_snapped.to_crs("EPSG:4326").geometry
    fars_df['snap_lat'] = coords.y
    fars_df['snap_lon'] = coords.x

    fars_df.to_csv(output_csv, index=False)
    print(f"  Saved to {output_csv}")

    # Save as RDS-compatible feather
    output_feather = DATA_DIR / "fars_snapped.feather"
    fars_df.to_feather(output_feather)
    print(f"  Saved to {output_feather}")

    print("\n" + "=" * 60)
    print("Crash snapping complete!")
    print("=" * 60)


if __name__ == "__main__":
    main()
