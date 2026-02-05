# Quick Start Guide

This is a quick reference for getting started with the SNOMED CT Neo4j project.

## 5-Minute Setup

1. **Install dependencies:**
   ```bash
   pip install -r requirements.txt
   ```

2. **Start Neo4j and configure heap:**
   Edit `neo4j.conf`:
   ```properties
   dbms.memory.heap.initial_size=4G
   dbms.memory.heap.max_size=4G
   ```

3. **Initialize database:**
   ```bash
   python init_db.py --user neo4j --password your_password
   ```

4. **Place CSV files in Neo4j import directory:**
   - patients.csv
   - allergies.csv
   - conditions.csv
   - devices.csv

5. **Run import:**
   ```bash
   # Using Python
   python scripts/import_all.py --user neo4j --password your_password
   
   # OR using Bash
   NEO4J_PASSWORD=your_password ./scripts/import_all.sh
   ```

## Quick Test Query

After import, test your data:

```cypher
// Count all nodes
MATCH (n) RETURN labels(n), count(n)

// View sample patient with relationships
MATCH (p:Patient)-[r]->(x)
RETURN p.name, type(r), labels(x)
LIMIT 5
```

## Common Commands

**Cypher-shell:**
```bash
cypher-shell -u neo4j -p password < cypher/import_patients.cypher
```

**Neo4j Browser:**
- Open: http://localhost:7474
- Connect with credentials
- Paste and run Cypher scripts

## Directory Structure

```
snomed_neo4j/
├── init_db.py           # Initialize database
├── cypher/              # All Cypher scripts
│   ├── import_*.cypher  # Import CSVs
│   ├── create_*.cypher  # Create relationships
│   └── label_*.cypher   # Label concepts
└── scripts/             # Automation scripts
    ├── import_all.py    # Python orchestrator
    └── import_all.sh    # Bash orchestrator
```

## Troubleshooting

**Import fails:**
- Check CSV files are in Neo4j import directory
- Verify Neo4j is running: `neo4j status`
- Check heap size is set to 4GB

**Out of memory:**
- Increase heap size in neo4j.conf
- Restart Neo4j: `neo4j restart`

**Connection refused:**
- Verify bolt://localhost:7687 is accessible
- Check credentials are correct

For more details, see the main README.md
