// Import Devices from CSV
// This script imports device data from a Synthea-generated CSV file
//
// Expected CSV columns: START, STOP, PATIENT, ENCOUNTER, CODE, DESCRIPTION, UDI
//
// Usage: Place your devices.csv file in the import directory and run this script

// Load devices with batching for large datasets (Neo4j 5.x compatible)
// For Neo4j 4.x, you can use USING PERIODIC COMMIT 500 instead
:auto LOAD CSV WITH HEADERS FROM 'file:///devices.csv' AS row
CALL {
  WITH row
  // Create or merge device nodes
  MERGE (d:Device {id: row.PATIENT + '_' + row.CODE + '_' + row.START})
  ON CREATE SET
      d.start = row.START,
      d.stop = row.STOP,
      d.patientId = row.PATIENT,
      d.encounterId = row.ENCOUNTER,
      d.code = row.CODE,
      d.description = row.DESCRIPTION,
      d.udi = row.UDI
  
  // Link to SNOMED CT concept if it exists
  WITH d, row
  OPTIONAL MATCH (o:ObjectConcept {conceptId: row.CODE})
  WITH d, o
  WHERE o IS NOT NULL
  MERGE (d)-[:CODED_AS]->(o)
} IN TRANSACTIONS OF 500 ROWS;
