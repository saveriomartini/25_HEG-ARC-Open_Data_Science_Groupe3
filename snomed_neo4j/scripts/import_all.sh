#!/bin/bash
# Master import script for SNOMED CT Neo4j database
# This script orchestrates the complete data import process

set -e  # Exit on error

# Configuration
NEO4J_USER="${NEO4J_USER:-neo4j}"
NEO4J_PASSWORD="${NEO4J_PASSWORD:-password}"
NEO4J_URI="${NEO4J_URI:-bolt://localhost:7687}"

echo "================================================"
echo "SNOMED CT Neo4j Import Script"
echo "================================================"
echo ""
echo "Configuration:"
echo "  Neo4j URI: $NEO4J_URI"
echo "  Username: $NEO4J_USER"
echo ""

# Check if cypher-shell is available
if ! command -v cypher-shell &> /dev/null; then
    echo "ERROR: cypher-shell not found. Please ensure Neo4j is installed."
    exit 1
fi

# Function to run a Cypher script
run_cypher() {
    local script=$1
    local description=$2
    
    echo "→ $description"
    if cat "$script" | cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" --format plain > /dev/null 2>&1; then
        echo "  ✓ Success"
    else
        echo "  ✗ Failed"
        exit 1
    fi
    echo ""
}

# Step 1: Import CSV data
echo "Step 1: Importing CSV data..."
echo "----------------------------"
run_cypher "cypher/import_patients.cypher" "Importing patients"
run_cypher "cypher/import_allergies.cypher" "Importing allergies"
run_cypher "cypher/import_conditions.cypher" "Importing conditions"
run_cypher "cypher/import_devices.cypher" "Importing devices"

# Step 2: Create relationships
echo "Step 2: Creating relationships..."
echo "--------------------------------"
run_cypher "cypher/create_has_relationships.cypher" "Creating HAS relationships (Patient-Allergy)"
run_cypher "cypher/create_used_relationships.cypher" "Creating USED relationships (Patient-Device)"
run_cypher "cypher/create_underwent_relationships.cypher" "Creating UNDERWENT relationships (Patient-Condition)"

# Step 3: Label SNOMED concepts (optional, only if ObjectConcept nodes exist)
echo "Step 3: Labeling SNOMED CT concepts..."
echo "--------------------------------------"
echo "→ Labeling ObjectConcept nodes by FSN suffix"
if cat "cypher/label_concepts_by_fsn.cypher" | cypher-shell -u "$NEO4J_USER" -p "$NEO4J_PASSWORD" --format plain > /dev/null 2>&1; then
    echo "  ✓ Success (or no ObjectConcept nodes found)"
else
    echo "  ⚠ Warning: Labeling step had issues (this is OK if you don't have SNOMED CT concepts)"
fi
echo ""

echo "================================================"
echo "Import completed successfully!"
echo "================================================"
echo ""
echo "Next steps:"
echo "  1. Open Neo4j Browser at http://localhost:7474"
echo "  2. Run example queries from the README"
echo "  3. Explore your data!"
