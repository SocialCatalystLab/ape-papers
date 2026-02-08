#!/usr/bin/env python3
"""
Paper 108: Geocoded Atlas of US Traffic Fatalities 2001-2023
02_fetch_osm.py - Extract OSM road networks for Western states
"""

import os
import warnings
from pathlib import Path

import geopandas as gpd
import pandas as pd
import osmnx as ox

# Suppress warnings
warnings.filterwarnings('ignore')

# Configure osmnx
ox.settings.use_cache = True
ox.settings.log_console = True
ox.settings.cache_folder = Path("output/paper_108/data/osm_roads/cache")
ox.settings.cache_folder.mkdir(parents=True, exist_ok=True)

# Directories
DATA_DIR = Path("output/paper_108/data")
OSM_DIR = DATA_DIR / "osm_roads"
OSM_DIR.mkdir(parents=True, exist_ok=True)

# Western states with abbreviations
WESTERN_STATES = {
    "Colorado": "CO",
    "Washington": "WA",
    "Oregon": "OR",
    "California": "CA",
    "Nevada": "NV",
    "Alaska": "AK",
    "Wyoming": "WY",
    "Nebraska": "NE",
    "Kansas": "KS",
    "Idaho": "ID",
    "Utah": "UT",
    "Arizona": "AZ",
    "New Mexico": "NM",
    "Montana": "MT"
}

# Key border regions for detailed extraction
BORDER_REGIONS = {
    "CO_WY": {
        "north": 41.5,
        "south": 40.0,
        "east": -103.0,
        "west": -106.5,
        "description": "Colorado-Wyoming border (I-25 corridor)"
    },
    "WA_ID": {
        "north": 47.8,
        "south": 46.0,
        "east": -116.0,
        "west": -118.5,
        "description": "Washington-Idaho border (I-90 corridor)"
    },
    "OR_ID": {
        "north": 45.5,
        "south": 43.0,
        "east": -116.0,
        "west": -118.5,
        "description": "Oregon-Idaho border (I-84 corridor)"
    },
    "CA_AZ": {
        "north": 35.0,
        "south": 32.5,
        "east": -113.5,
        "west": -117.0,
        "description": "California-Arizona border (I-10/I-8)"
    },
    "NV_UT": {
        "north": 41.0,
        "south": 36.0,
        "east": -113.5,
        "west": -115.5,
        "description": "Nevada-Utah border (I-15 corridor)"
    },
    "DENVER_METRO": {
        "north": 40.1,
        "south": 39.5,
        "east": -104.5,
        "west": -105.3,
        "description": "Denver metropolitan area"
    }
}

def fetch_road_network(bbox, region_name, network_type="drive"):
    """
    Fetch road network for a bounding box from OpenStreetMap.

    Parameters
    ----------
    bbox : dict
        Bounding box with keys: north, south, east, west
    region_name : str
        Name for saving files
    network_type : str
        OSM network type (drive, walk, bike, all)

    Returns
    -------
    G : networkx.MultiDiGraph
        Road network graph
    """
    print(f"\nFetching road network for {region_name}...")
    print(f"  Bbox: N={bbox['north']}, S={bbox['south']}, E={bbox['east']}, W={bbox['west']}")

    try:
        # Get road network
        G = ox.graph_from_bbox(
            bbox=bbox,
            network_type=network_type,
            simplify=True,
            retain_all=False,
            truncate_by_edge=True,
            custom_filter=None
        )

        print(f"  Nodes: {len(G.nodes):,}")
        print(f"  Edges: {len(G.edges):,}")

        # Convert to GeoDataFrame
        nodes, edges = ox.graph_to_gdfs(G)

        # Save to files
        edges_file = OSM_DIR / f"roads_{region_name}.gpkg"
        nodes_file = OSM_DIR / f"nodes_{region_name}.gpkg"

        edges.to_file(edges_file, driver="GPKG")
        nodes.to_file(nodes_file, driver="GPKG")

        print(f"  Saved to {edges_file}")

        return G, edges, nodes

    except Exception as e:
        print(f"  Error: {e}")
        return None, None, None


def fetch_state_highways(state_name, state_abbr):
    """
    Fetch major highways (Interstate, US Highway, State Highway) for a state.

    This uses a custom filter to get only major roads, which is much faster
    than downloading the full network.
    """
    print(f"\nFetching major highways for {state_name} ({state_abbr})...")

    try:
        # Custom filter for major roads only
        # highway: motorway (Interstate), trunk (US Highway), primary (State Highway)
        cf = '["highway"~"motorway|motorway_link|trunk|trunk_link|primary|primary_link"]'

        G = ox.graph_from_place(
            f"{state_name}, USA",
            network_type="drive",
            custom_filter=cf,
            simplify=True
        )

        print(f"  Nodes: {len(G.nodes):,}")
        print(f"  Edges: {len(G.edges):,}")

        # Convert to GeoDataFrame
        nodes, edges = ox.graph_to_gdfs(G)

        # Save
        edges_file = OSM_DIR / f"highways_{state_abbr}.gpkg"
        edges.to_file(edges_file, driver="GPKG")

        print(f"  Saved to {edges_file}")

        return edges

    except Exception as e:
        print(f"  Error fetching {state_name}: {e}")
        return None


def snap_crashes_to_roads(crashes_gdf, roads_gdf, max_dist_m=100):
    """
    Snap crash points to nearest road segment.

    Parameters
    ----------
    crashes_gdf : GeoDataFrame
        Crash locations with geometry
    roads_gdf : GeoDataFrame
        Road network edges
    max_dist_m : float
        Maximum snap distance in meters

    Returns
    -------
    snapped : GeoDataFrame
        Crashes with road attributes joined
    """
    print(f"\nSnapping {len(crashes_gdf):,} crashes to roads...")

    # Ensure both are in projected CRS (meters)
    if crashes_gdf.crs is None or crashes_gdf.crs.is_geographic:
        crashes_gdf = crashes_gdf.to_crs("EPSG:5070")  # Albers Equal Area

    if roads_gdf.crs is None or roads_gdf.crs.is_geographic:
        roads_gdf = roads_gdf.to_crs("EPSG:5070")

    # Spatial join with nearest
    snapped = gpd.sjoin_nearest(
        crashes_gdf,
        roads_gdf,
        how="left",
        max_distance=max_dist_m,
        distance_col="snap_dist_m"
    )

    print(f"  Successfully snapped: {snapped['snap_dist_m'].notna().sum():,}")
    print(f"  Mean snap distance: {snapped['snap_dist_m'].mean():.1f} m")

    return snapped


def main():
    """Main execution."""
    print("=" * 60)
    print("OSM Road Network Extraction")
    print("=" * 60)

    # 1. Fetch road networks for key border regions
    print("\n" + "=" * 60)
    print("STEP 1: Fetching border region road networks")
    print("=" * 60)

    border_roads = {}
    for region_name, bbox in BORDER_REGIONS.items():
        print(f"\n--- {bbox['description']} ---")
        G, edges, nodes = fetch_road_network(bbox, region_name)
        if edges is not None:
            border_roads[region_name] = edges

    # 2. Fetch major highways for Western states
    print("\n" + "=" * 60)
    print("STEP 2: Fetching state-level major highways")
    print("=" * 60)

    state_highways = {}
    for state_name, state_abbr in WESTERN_STATES.items():
        # Skip Alaska for now (too large/complex)
        if state_abbr == "AK":
            print(f"\n--- Skipping Alaska (too large for OSM query) ---")
            continue

        highways = fetch_state_highways(state_name, state_abbr)
        if highways is not None:
            state_highways[state_abbr] = highways

    # 3. Load FARS data and test snapping (if available)
    print("\n" + "=" * 60)
    print("STEP 3: Testing crash snapping")
    print("=" * 60)

    fars_file = DATA_DIR / "fars_analysis.csv"
    if fars_file.exists():
        print(f"\nLoading FARS data from {fars_file}...")
        fars = pd.read_csv(fars_file)

        # Filter to CO-WY border region for testing
        co_wy_bbox = BORDER_REGIONS["CO_WY"]
        fars_test = fars[
            (fars['latitude'] >= co_wy_bbox['south']) &
            (fars['latitude'] <= co_wy_bbox['north']) &
            (fars['longitude'] >= co_wy_bbox['west']) &
            (fars['longitude'] <= co_wy_bbox['east'])
        ].copy()

        if len(fars_test) > 0:
            print(f"  Found {len(fars_test):,} crashes in CO-WY border region")

            # Convert to GeoDataFrame
            fars_gdf = gpd.GeoDataFrame(
                fars_test,
                geometry=gpd.points_from_xy(fars_test.longitude, fars_test.latitude),
                crs="EPSG:4326"
            )

            # Snap to roads
            if "CO_WY" in border_roads:
                snapped = snap_crashes_to_roads(fars_gdf, border_roads["CO_WY"])

                # Save snapped crashes
                snapped_file = DATA_DIR / "fars_snapped_co_wy.gpkg"
                snapped.to_file(snapped_file, driver="GPKG")
                print(f"  Saved snapped crashes to {snapped_file}")
    else:
        print(f"\nFARS data not found at {fars_file}")
        print("Run 01_fetch_fars.R first, then re-run this script for snapping")

    print("\n" + "=" * 60)
    print("OSM extraction complete!")
    print("=" * 60)

    # Summary
    print(f"\nFiles created in {OSM_DIR}:")
    for f in sorted(OSM_DIR.glob("*.gpkg")):
        size_mb = f.stat().st_size / 1024 / 1024
        print(f"  {f.name}: {size_mb:.1f} MB")


if __name__ == "__main__":
    main()
