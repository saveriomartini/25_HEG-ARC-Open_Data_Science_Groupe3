// Create HAS relationships between Patients and their Allergies
// This script creates HAS relationships linking patients to their allergies
//
// Usage: Run this script after importing both patients and allergies

// Create HAS relationships from Patient to Allergy
MATCH (p:Patient)
MATCH (a:Allergy)
WHERE a.patientId = p.id
MERGE (p)-[r:HAS]->(a)
ON CREATE SET r.createdAt = datetime()

RETURN count(r) as hasRelationshipsCreated;
