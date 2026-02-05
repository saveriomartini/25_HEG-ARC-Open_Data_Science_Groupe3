// Label ObjectConcept nodes based on their Fully Specified Name (FSN) suffixes
// SNOMED CT uses FSN suffixes to indicate the semantic type of a concept
// Common suffixes include: (disorder), (finding), (procedure), (body structure), 
// (substance), (pharmaceutical / biologic product), (organism), (physical object), etc.
//
// This script adds additional labels to ObjectConcept nodes based on their FSN suffixes
// for easier querying and better semantic organization

// Label Disorder concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(disorder)'
SET o:Disorder
RETURN count(o) as disordersLabeled;

// Label Finding concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(finding)'
SET o:Finding
RETURN count(o) as findingsLabeled;

// Label Procedure concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(procedure)'
SET o:Procedure
RETURN count(o) as proceduresLabeled;

// Label Body Structure concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(body structure)'
SET o:BodyStructure
RETURN count(o) as bodyStructuresLabeled;

// Label Substance concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(substance)'
SET o:Substance
RETURN count(o) as substancesLabeled;

// Label Pharmaceutical/Biologic Product concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(pharmaceutical / biologic product)'
   OR o.fullySpecifiedName ENDS WITH '(product)'
SET o:Product
RETURN count(o) as productsLabeled;

// Label Organism concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(organism)'
SET o:Organism
RETURN count(o) as organismsLabeled;

// Label Physical Object concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(physical object)'
SET o:PhysicalObject
RETURN count(o) as physicalObjectsLabeled;

// Label Observable Entity concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(observable entity)'
SET o:ObservableEntity
RETURN count(o) as observableEntitiesLabeled;

// Label Qualifier Value concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(qualifier value)'
SET o:QualifierValue
RETURN count(o) as qualifierValuesLabeled;

// Label Situation concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(situation)'
SET o:Situation
RETURN count(o) as situationsLabeled;

// Label Staging/Scale concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(staging scale)'
   OR o.fullySpecifiedName ENDS WITH '(assessment scale)'
SET o:StagingScale
RETURN count(o) as stagingScalesLabeled;

// Label Specimen concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(specimen)'
SET o:Specimen
RETURN count(o) as specimensLabeled;

// Label Environment concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(environment)'
   OR o.fullySpecifiedName ENDS WITH '(environment / location)'
SET o:Environment
RETURN count(o) as environmentsLabeled;

// Label Event concepts
MATCH (o:ObjectConcept)
WHERE o.fullySpecifiedName ENDS WITH '(event)'
SET o:Event
RETURN count(o) as eventsLabeled;
