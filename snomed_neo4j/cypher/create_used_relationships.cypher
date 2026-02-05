// Create USED relationships between Patients and their Devices
// This script creates USED relationships linking patients to devices they have used
//
// Usage: Run this script after importing both patients and devices

// Create USED relationships from Patient to Device
MATCH (p:Patient)
MATCH (d:Device)
WHERE d.patientId = p.id
MERGE (p)-[r:USED]->(d)
ON CREATE SET 
    r.createdAt = datetime(),
    r.startDate = d.start,
    r.stopDate = d.stop

RETURN count(r) as usedRelationshipsCreated;
