#!/usr/bin/env python3
"""
01_fetch_data.py
Fetch Swiss referendum data at municipality level
"""

import requests
import json
import csv
from datetime import datetime, timedelta
from pathlib import Path
import time

# Create data directory
Path("../data").mkdir(exist_ok=True)

# =============================================================================
# 1. Fetch Swissvotes metadata
# =============================================================================

print("Fetching Swissvotes metadata...")

swissvotes_url = "https://swissvotes.ch/page/dataset/swissvotes_dataset.csv"
resp = requests.get(swissvotes_url, timeout=60)
resp.encoding = 'utf-8-sig'

# Parse CSV with semicolon delimiter
lines = resp.text.strip().split('\n')
reader = csv.DictReader(lines, delimiter=';')
swissvotes_rows = list(reader)

# Filter and extract relevant columns
swissvotes = []
for row in swissvotes_rows:
    try:
        # Parse date (format: DD.MM.YYYY)
        date_str = row.get('datum', '')
        if not date_str or date_str == '.':
            continue
        vote_date = datetime.strptime(date_str, '%d.%m.%Y')

        # Only include votes from 2010 onwards
        if vote_date < datetime(2010, 1, 1):
            continue

        # Check if passed
        annahme = row.get('annahme', '0')
        passed = annahme == '1'

        swissvotes.append({
            'vote_id': row.get('anr', ''),
            'vote_date': vote_date.strftime('%Y-%m-%d'),
            'title_de': row.get('titel_kurz_d', ''),
            'policy_domain': row.get('d1e1', ''),
            'passed': passed,
            'yes_pct_national': row.get('volkja-proz', ''),
            'turnout_national': row.get('bet', '')
        })
    except Exception as e:
        continue

print(f"Found {len(swissvotes)} federal referendums since 2010")

# Save metadata
with open('../data/swissvotes_metadata.csv', 'w', newline='', encoding='utf-8') as f:
    writer = csv.DictWriter(f, fieldnames=['vote_id', 'vote_date', 'title_de',
                                            'policy_domain', 'passed',
                                            'yes_pct_national', 'turnout_national'])
    writer.writeheader()
    writer.writerows(swissvotes)

# =============================================================================
# 2. Get list of vote dates with passed referendums
# =============================================================================

print("\nIdentifying referendum dates...")

vote_dates = sorted(set(v['vote_date'] for v in swissvotes if v['passed']))
print(f"Found {len(vote_dates)} voting days with passed referendums")

# =============================================================================
# 3. Fetch municipal-level results
# =============================================================================

def fetch_vote_results(vote_date_str):
    """Fetch municipal results for a single vote date"""
    date_obj = datetime.strptime(vote_date_str, '%Y-%m-%d')
    date_fmt = date_obj.strftime('%Y%m%d')
    url = f"https://ogd-static.voteinfo-app.ch/v1/ogd/sd-t-17-02-{date_fmt}-eidgAbstimmung.json"

    try:
        resp = requests.get(url, timeout=30)
        if resp.status_code != 200:
            return []

        data = resp.json()
        schweiz = data.get('schweiz', {})
        vorlagen = schweiz.get('vorlagen', [])

        results = []
        for vorlage in vorlagen:
            vorlage_id = vorlage.get('vorlagenId', '')
            vorlage_title = vorlage.get('vorlagenTitel', '')
            vorlage_accepted = vorlage.get('vorlageAngenommen', False)

            # Skip if not accepted (we only want passed referendums)
            if not vorlage_accepted:
                continue

            kantone = vorlage.get('kantone', [])
            for kanton in kantone:
                kanton_id = kanton.get('geoLevelnummer', '')
                kanton_name = kanton.get('geoLevelname', '')
                gemeinden = kanton.get('gemeinden', [])

                for gemeinde in gemeinden:
                    resultat = gemeinde.get('resultat', {})
                    if not resultat.get('gebietAusgezaehlt', False):
                        continue

                    results.append({
                        'vote_date': vote_date_str,
                        'vorlage_id': vorlage_id,
                        'vorlage_title': vorlage_title,
                        'vorlage_accepted': vorlage_accepted,
                        'kanton_id': kanton_id,
                        'kanton_name': kanton_name,
                        'gemeinde_id': gemeinde.get('geoLevelnummer', ''),
                        'gemeinde_name': gemeinde.get('geoLevelname', ''),
                        'yes_pct': resultat.get('jaStimmenInProzent'),
                        'yes_count': resultat.get('jaStimmenAbsolut'),
                        'no_count': resultat.get('neinStimmenAbsolut'),
                        'turnout_pct': resultat.get('stimmbeteiligungInProzent'),
                        'eligible_voters': resultat.get('anzahlStimmberechtigte'),
                        'valid_votes': resultat.get('gueltigeStimmen')
                    })

        return results

    except Exception as e:
        print(f"Error fetching {date_fmt}: {e}")
        return []

print("\nFetching municipal results...")

all_results = []
for i, vote_date in enumerate(vote_dates):
    if (i + 1) % 10 == 0:
        print(f"  Fetched {i + 1}/{len(vote_dates)} vote dates...")

    results = fetch_vote_results(vote_date)
    all_results.extend(results)
    time.sleep(0.2)  # Rate limiting

print(f"\nFetched {len(all_results)} municipality-proposal observations")

# Save results
if all_results:
    with open('../data/municipal_results_raw.csv', 'w', newline='', encoding='utf-8') as f:
        writer = csv.DictWriter(f, fieldnames=all_results[0].keys())
        writer.writeheader()
        writer.writerows(all_results)

# =============================================================================
# 4. Summary statistics
# =============================================================================

print("\n=== Summary Statistics ===")
n_votes = len(set(r['vote_date'] for r in all_results))
n_proposals = len(set((r['vote_date'], r['vorlage_id']) for r in all_results))
n_municipalities = len(set(r['gemeinde_id'] for r in all_results))

yes_pcts = [r['yes_pct'] for r in all_results if r['yes_pct'] is not None]
turnouts = [r['turnout_pct'] for r in all_results if r['turnout_pct'] is not None]

print(f"Vote dates: {n_votes}")
print(f"Proposals: {n_proposals}")
print(f"Municipalities: {n_municipalities}")
print(f"Total observations: {len(all_results)}")
if yes_pcts:
    print(f"Mean yes %: {sum(yes_pcts)/len(yes_pcts):.1f}")
if turnouts:
    print(f"Mean turnout %: {sum(turnouts)/len(turnouts):.1f}")
close_votes = sum(1 for y in yes_pcts if abs(y - 50) < 10)
print(f"Close votes (within 10pp of 50%): {close_votes} ({100*close_votes/len(yes_pcts):.1f}%)")

print("\nData saved to ../data/")
print("Done.")
