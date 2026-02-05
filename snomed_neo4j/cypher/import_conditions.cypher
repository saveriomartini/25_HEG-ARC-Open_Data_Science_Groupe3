// Import Conditions from CSV
// This script imports condition data from a Synthea-generated CSV file
//
// Expected CSV columns: START, STOP, PATIENT, ENCOUNTER, CODE, DESCRIPTION
//
// Usage: Place your conditions.csv file in the import directory and run this script

// Load conditions with PERIODIC COMMIT for large datasets
USING PERIODIC COMMIT 500
LOAD CSV WITH HEADERS FROM 'file:///conditions.csv' AS row

// Create or merge condition nodes
MERGE (c:Condition {id: row.PATIENT + '_' + row.CODE + '_' + row.START})
ON CREATE SET
    c.start = row.START,
    c.stop = row.STOP,
    c.patientId = row.PATIENT,
    c.encounterId = row.ENCOUNTER,
    c.code = row.CODE,
    c.description = row.DESCRIPTION

// Link to SNOMED CT concept if it exists
WITH c, row
OPTIONAL MATCH (o:ObjectConcept {conceptId: row.CODE})
WITH c, o
WHERE o IS NOT NULL
MERGE (c)-[:CODED_AS]->(o)

RETURN count(c) as conditionsCreated;
