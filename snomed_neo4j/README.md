# SNOMED CT Neo4j Project with Synthea Data

This project provides a complete solution for populating a Neo4j graph database with SNOMED CT (Systematized Nomenclature of Medicine -- Clinical Terms) data from Synthea-generated healthcare datasets.

## Overview

This project includes:
- Python script (`init_db.py`) using py2neo to initialize the Neo4j database
- Cypher scripts to import CSV files (patients, allergies, conditions, devices)
- Cypher scripts to create relationships (HAS, USED, UNDERWENT)
- Cypher script to label ObjectConcept nodes based on FSN (Fully Specified Name) suffixes
- Configuration guidelines for optimal Neo4j performance

## Prerequisites

- Neo4j 5.x installed and running (scripts use the newer `:auto` syntax)
  - For Neo4j 4.x, modify import scripts to use `USING PERIODIC COMMIT` instead
- Python 3.8 or higher
- Synthea-generated CSV files (patients.csv, allergies.csv, conditions.csv, devices.csv)
- At least 4GB of RAM allocated to Neo4j

## Neo4j Configuration

### Heap Memory Configuration (4GB)

To ensure optimal performance when working with large datasets, configure Neo4j to use 4GB of heap memory:

1. Locate your Neo4j configuration file:
   - Linux/Mac: `$NEO4J_HOME/conf/neo4j.conf`
   - Windows: `%NEO4J_HOME%\conf\neo4j.conf`

2. Add or update the following settings:

```properties
# Initial heap size
dbms.memory.heap.initial_size=4G

# Maximum heap size
dbms.memory.heap.max_size=4G

# Page cache size (recommended: ~1GB for small datasets, scale up for larger ones)
dbms.memory.pagecache.size=1G
```

3. Restart Neo4j for changes to take effect:
```bash
neo4j restart
```

### CSV Import Settings

Configure Neo4j for CSV import:

1. **Set the import directory** in `neo4j.conf`:
```properties
# Uncomment to set the default import directory
dbms.directories.import=import

# Allow file:/// URLs to access any path (use with caution in production)
# dbms.security.allow_csv_import_from_file_urls=true
```

2. **Place your CSV files** in the Neo4j import directory:
   - Default location: `$NEO4J_HOME/import/`
   - Linux/Mac: `/var/lib/neo4j/import/`
   - Windows: `C:\Users\{username}\.Neo4jDesktop\relate-data\dbmss\{dbms-id}\import\`

3. **Enable APOC procedures** (optional, for advanced operations):
```properties
dbms.security.procedures.unrestricted=apoc.*
dbms.security.procedures.allowlist=apoc.*
```

## Installation

1. Clone this repository:
```bash
git clone <repository-url>
cd snomed_neo4j
```

2. Install Python dependencies:
```bash
pip install -r requirements.txt
```

3. Ensure Neo4j is running:
```bash
neo4j status
# If not running:
neo4j start
```

## Usage

### Step 1: Initialize the Database

Run the Python initialization script to set up constraints and indexes:

```bash
python init_db.py --uri bolt://localhost:7687 --user neo4j --password your_password
```

Options:
- `--uri`: Neo4j connection URI (default: bolt://localhost:7687)
- `--user`: Database username (default: neo4j)
- `--password`: Database password (default: password)
- `--clear`: Clear existing data before initialization (use with caution!)

Example with clearing existing data:
```bash
python init_db.py --uri bolt://localhost:7687 --user neo4j --password mypassword --clear
```

### Step 2: Prepare Your CSV Files

Place the following Synthea CSV files in the Neo4j import directory:
- `patients.csv`
- `allergies.csv`
- `conditions.csv`
- `devices.csv`

**Expected CSV formats:**

**patients.csv:**
```
Id,BIRTHDATE,DEATHDATE,SSN,DRIVERS,PASSPORT,PREFIX,FIRST,LAST,SUFFIX,MAIDEN,MARITAL,RACE,ETHNICITY,GENDER,BIRTHPLACE,ADDRESS,CITY,STATE,COUNTY,ZIP,LAT,LON,HEALTHCARE_EXPENSES,HEALTHCARE_COVERAGE
```

**allergies.csv:**
```
START,STOP,PATIENT,ENCOUNTER,CODE,SYSTEM,DESCRIPTION,TYPE,CATEGORY,REACTION1,DESCRIPTION1,SEVERITY1,REACTION2,DESCRIPTION2,SEVERITY2
```

**conditions.csv:**
```
START,STOP,PATIENT,ENCOUNTER,CODE,DESCRIPTION
```

**devices.csv:**
```
START,STOP,PATIENT,ENCOUNTER,CODE,DESCRIPTION,UDI
```

### Step 3: Import CSV Data

Run the Cypher scripts in the Neo4j Browser or using cypher-shell:

#### Using Neo4j Browser:
1. Open Neo4j Browser at http://localhost:7474
2. Copy and paste each script from the `cypher/` directory
3. Execute in this order:

```cypher
// 1. Import Patients
:source cypher/import_patients.cypher

// 2. Import Allergies
:source cypher/import_allergies.cypher

// 3. Import Conditions
:source cypher/import_conditions.cypher

// 4. Import Devices
:source cypher/import_devices.cypher
```

#### Using cypher-shell:
```bash
cat cypher/import_patients.cypher | cypher-shell -u neo4j -p your_password
cat cypher/import_allergies.cypher | cypher-shell -u neo4j -p your_password
cat cypher/import_conditions.cypher | cypher-shell -u neo4j -p your_password
cat cypher/import_devices.cypher | cypher-shell -u neo4j -p your_password
```

### Step 4: Create Relationships

Create relationships between patients and their associated data:

```bash
cat cypher/create_has_relationships.cypher | cypher-shell -u neo4j -p your_password
cat cypher/create_used_relationships.cypher | cypher-shell -u neo4j -p your_password
cat cypher/create_underwent_relationships.cypher | cypher-shell -u neo4j -p your_password
```

### Step 5: Label SNOMED CT Concepts

If you have SNOMED CT ObjectConcept nodes with Fully Specified Names, run the labeling script:

```bash
cat cypher/label_concepts_by_fsn.cypher | cypher-shell -u neo4j -p your_password
```

This script adds semantic labels to ObjectConcept nodes based on their FSN suffixes:
- `(disorder)` → `Disorder` label
- `(finding)` → `Finding` label
- `(procedure)` → `Procedure` label
- `(body structure)` → `BodyStructure` label
- And many more...

## Project Structure

```
snomed_neo4j/
├── init_db.py                          # Python script to initialize Neo4j database
├── requirements.txt                    # Python dependencies
├── cypher/                             # Cypher scripts directory
│   ├── import_patients.cypher          # Import patients from CSV
│   ├── import_allergies.cypher         # Import allergies from CSV
│   ├── import_conditions.cypher        # Import conditions from CSV
│   ├── import_devices.cypher           # Import devices from CSV
│   ├── create_has_relationships.cypher # Create HAS relationships
│   ├── create_used_relationships.cypher # Create USED relationships
│   ├── create_underwent_relationships.cypher # Create UNDERWENT relationships
│   └── label_concepts_by_fsn.cypher    # Label ObjectConcept nodes by FSN suffix
├── scripts/                            # Additional utility scripts (if any)
└── data/                               # Sample data directory (optional)
```

## Graph Schema

The resulting graph database has the following structure:

### Nodes
- **Patient**: Represents individual patients
- **Allergy**: Represents allergies
- **Condition**: Represents medical conditions
- **Device**: Represents medical devices
- **ObjectConcept**: SNOMED CT concepts (with semantic labels like Disorder, Finding, etc.)

### Relationships
- **(Patient)-[HAS]->(Allergy)**: Patient has an allergy
- **(Patient)-[USED]->(Device)**: Patient used a device
- **(Patient)-[UNDERWENT]->(Condition)**: Patient underwent/experienced a condition
- **(Allergy|Condition|Device)-[CODED_AS]->(ObjectConcept)**: Medical entity coded with SNOMED CT

## Example Queries

### Find all patients with a specific condition:
```cypher
MATCH (p:Patient)-[:UNDERWENT]->(c:Condition)
WHERE c.description CONTAINS 'Diabetes'
RETURN p.name, c.description, c.start
```

### Find patients who have used a specific device:
```cypher
MATCH (p:Patient)-[:USED]->(d:Device)
WHERE d.description CONTAINS 'Pacemaker'
RETURN p.name, d.description, d.start, d.stop
```

### Find all disorders linked to patients:
```cypher
MATCH (p:Patient)-[:UNDERWENT]->(c:Condition)-[:CODED_AS]->(o:ObjectConcept:Disorder)
RETURN p.name, c.description, o.fullySpecifiedName
LIMIT 10
```

### Count patients by gender:
```cypher
MATCH (p:Patient)
RETURN p.gender, count(p) as count
ORDER BY count DESC
```

### Find patients with multiple conditions:
```cypher
MATCH (p:Patient)-[:UNDERWENT]->(c:Condition)
WITH p, count(c) as conditionCount
WHERE conditionCount > 3
RETURN p.name, conditionCount
ORDER BY conditionCount DESC
```

## Performance Optimization

### For Large Datasets:

1. **Batch Processing**: The import scripts use `PERIODIC COMMIT` for memory efficiency
2. **Constraints**: Unique constraints are created for faster lookups
3. **Indexes**: Indexes are created on frequently queried properties
4. **Heap Size**: 4GB heap allocation prevents OutOfMemory errors

### Monitoring Performance:

```cypher
// Check constraint status
SHOW CONSTRAINTS

// Check index status
SHOW INDEXES

// Query execution plan
EXPLAIN MATCH (p:Patient) RETURN p

// Profile query performance
PROFILE MATCH (p:Patient)-[:UNDERWENT]->(c:Condition) RETURN count(*)
```

## Troubleshooting

### Common Issues:

1. **"Couldn't load the external resource"**
   - Ensure CSV files are in the Neo4j import directory
   - Check file permissions (files should be readable by neo4j user)
   - Verify the import directory setting in neo4j.conf

2. **OutOfMemoryError**
   - Increase heap size to 4GB as described above
   - Use PERIODIC COMMIT for large imports
   - Import data in smaller batches

3. **Connection refused**
   - Verify Neo4j is running: `neo4j status`
   - Check the connection URI (default: bolt://localhost:7687)
   - Verify credentials

4. **Slow imports**
   - Create constraints and indexes before importing
   - Use PERIODIC COMMIT with appropriate batch sizes
   - Allocate more heap memory if available

## Data Sources

- **Synthea**: Synthetic patient generator: https://github.com/synthetichealth/synthea
- **SNOMED CT**: Clinical terminology: https://www.snomed.org/

## License

This project is provided as-is for educational and research purposes.

## Contributing

Contributions are welcome! Please feel free to submit issues or pull requests.

## Support

For issues or questions:
1. Check the Troubleshooting section
2. Review Neo4j documentation: https://neo4j.com/docs/
3. Check py2neo documentation: https://py2neo.org/
