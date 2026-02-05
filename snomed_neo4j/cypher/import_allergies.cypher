// Import Allergies from CSV
// This script imports allergy data from a Synthea-generated CSV file
//
// Expected CSV columns: START, STOP, PATIENT, ENCOUNTER, CODE, SYSTEM, DESCRIPTION, TYPE, CATEGORY,
//                       REACTION1, DESCRIPTION1, SEVERITY1, REACTION2, DESCRIPTION2, SEVERITY2
//
// Usage: Place your allergies.csv file in the import directory and run this script

// Load allergies with batching for large datasets (Neo4j 5.x compatible)
// For Neo4j 4.x, you can use USING PERIODIC COMMIT 500 instead
:auto LOAD CSV WITH HEADERS FROM 'file:///allergies.csv' AS row
CALL {
  WITH row
  // Create or merge allergy nodes
  MERGE (a:Allergy {id: row.PATIENT + '_' + row.CODE + '_' + row.START})
  ON CREATE SET
      a.start = row.START,
      a.stop = row.STOP,
      a.patientId = row.PATIENT,
      a.encounterId = row.ENCOUNTER,
      a.code = row.CODE,
      a.system = row.SYSTEM,
      a.description = row.DESCRIPTION,
      a.type = row.TYPE,
      a.category = row.CATEGORY,
      a.reaction1 = row.REACTION1,
      a.description1 = row.DESCRIPTION1,
      a.severity1 = row.SEVERITY1,
      a.reaction2 = row.REACTION2,
      a.description2 = row.DESCRIPTION2,
      a.severity2 = row.SEVERITY2
  
  // Link to SNOMED CT concept if it exists
  WITH a, row
  OPTIONAL MATCH (o:ObjectConcept {conceptId: row.CODE})
  WITH a, o
  WHERE o IS NOT NULL
  MERGE (a)-[:CODED_AS]->(o)
} IN TRANSACTIONS OF 500 ROWS;
