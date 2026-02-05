# 25_HEG-ARC-Open_Data_Science_Groupe3
Activity 7 and more

## Projects

### SNOMED CT Neo4j Project
A complete Python/Neo4j project for populating a SNOMED CT graph database with Synthea-generated healthcare data.

**Location:** `snomed_neo4j/`

**Features:**
- Python initialization script using py2neo
- Cypher scripts for importing CSV data (patients, allergies, conditions, devices)
- Relationship creation scripts (HAS, USED, UNDERWENT)
- Automatic labeling of SNOMED CT concepts by FSN suffix
- Comprehensive documentation with Neo4j configuration (4GB heap) and CSV import settings

See `snomed_neo4j/README.md` for detailed usage instructions.
