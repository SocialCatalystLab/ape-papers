# Human Initialization
Timestamp: 2026-02-04T00:00:43Z

## Contributor (Immutable)

**GitHub User:** @SocialCatalystLab

This field is captured at initialization and MUST match at publish time.

## System Information

- **Claude Model:** claude-opus-4-5

## Questions Asked

1. **Policy domain:** What policy area interests you?
   - Options: Surprise me, Health & public health, Labor & employment, Criminal justice, Housing & urban, Custom

2. **Method:** Which identification method?
   - Options: DiD, RDD, DR (Doubly Robust), Surprise me

3. **Data era:** Modern or historical data?
   - Options: Modern, Historical (1850-1950), Either

4. **API keys:** Did you configure data API keys?
   - Options: Yes, No

5. **External review:** Include external model reviews?
   - Options: Yes, No

6. **Risk appetite:** Exploration vs exploitation?
   - Options: Safe, Novel angle, Novel policy, Novel data, Full exploration

7. **Other preferences:** Any other preferences or constraints?
   - Open-ended

## User Responses

1. **Custom** - Marijuana legalization effects on labor markets
2. **Spatial RDD** - User specified Spatial RDD with GIS running variables, comparing border counties
3. **Modern** - QWI data 2014-2023 covering legalization wave
4. **Yes** - API keys configured
5. **Yes** - External reviews enabled
6. **Novel angle** - Classic policy (marijuana legalization) + novel method (Spatial RDD with GIS) + novel data (QWI industry-level)
7. **Detailed specifications provided:**
   - Use GIS data for running variables (distance to state border)
   - Exploit county × quarter × sex × industry level QWI data
   - Multiple placebos in pre-legalization quarters
   - Post-legalization Spatial RDD estimates by quarter
   - Multiple hypothesis adjustment (FDR/Benjamini-Hochberg) across 20+ industries
   - Economic model of labor supply/demand with marijuana access as shifter
   - Use David Dorn's commuting zone data for geographic structure
   - Sharp, conceptually tight paper about weed effects on labor market equilibria

## Setup Results

- **Domain:** Labor & employment (marijuana legalization effects)
- **Method:** Spatial RDD (with GIS-based running variables)
- **Data era:** Modern (2014-2023)
- **Risk appetite:** Novel angle
- **Other preferences:** Industry heterogeneity analysis with FDR correction, economic model, commuting zone integration
