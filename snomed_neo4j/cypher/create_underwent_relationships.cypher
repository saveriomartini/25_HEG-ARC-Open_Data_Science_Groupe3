// Create UNDERWENT relationships between Patients and their Conditions
// This script creates UNDERWENT relationships linking patients to conditions they have experienced
//
// Usage: Run this script after importing both patients and conditions

// Create UNDERWENT relationships from Patient to Condition
MATCH (p:Patient)
MATCH (c:Condition)
WHERE c.patientId = p.id
MERGE (p)-[r:UNDERWENT]->(c)
ON CREATE SET 
    r.createdAt = datetime(),
    r.startDate = c.start,
    r.stopDate = c.stop

RETURN count(r) as underwentRelationshipsCreated;
