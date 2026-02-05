"""
SNOMED CT Neo4j Database Initialization Script

This script initializes a Neo4j database for SNOMED CT data using py2neo.
It sets up the necessary constraints and indexes for optimal performance.
"""

from py2neo import Graph, Node, Relationship
import logging

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class Neo4jInitializer:
    """Initialize Neo4j database with SNOMED CT schema"""
    
    def __init__(self, uri="bolt://localhost:7687", user="neo4j", password="password"):
        """
        Initialize the database connection
        
        Args:
            uri: Neo4j connection URI
            user: Database username
            password: Database password
        """
        try:
            self.graph = Graph(uri, auth=(user, password))
            logger.info("Successfully connected to Neo4j database")
        except Exception as e:
            logger.error(f"Failed to connect to Neo4j: {e}")
            raise
    
    def clear_database(self):
        """Clear all data from the database (use with caution!)"""
        logger.warning("Clearing all data from database...")
        self.graph.run("MATCH (n) DETACH DELETE n")
        logger.info("Database cleared")
    
    def create_constraints(self):
        """Create constraints for node uniqueness"""
        logger.info("Creating constraints...")
        
        constraints = [
            "CREATE CONSTRAINT patient_id IF NOT EXISTS FOR (p:Patient) REQUIRE p.id IS UNIQUE",
            "CREATE CONSTRAINT allergy_id IF NOT EXISTS FOR (a:Allergy) REQUIRE a.id IS UNIQUE",
            "CREATE CONSTRAINT condition_id IF NOT EXISTS FOR (c:Condition) REQUIRE c.id IS UNIQUE",
            "CREATE CONSTRAINT device_id IF NOT EXISTS FOR (d:Device) REQUIRE d.id IS UNIQUE",
            "CREATE CONSTRAINT concept_id IF NOT EXISTS FOR (o:ObjectConcept) REQUIRE o.conceptId IS UNIQUE",
        ]
        
        for constraint in constraints:
            try:
                self.graph.run(constraint)
                logger.info(f"Created constraint: {constraint.split()[2]}")
            except Exception as e:
                logger.warning(f"Constraint may already exist or failed: {e}")
    
    def create_indexes(self):
        """Create indexes for better query performance"""
        logger.info("Creating indexes...")
        
        indexes = [
            "CREATE INDEX patient_name IF NOT EXISTS FOR (p:Patient) ON (p.name)",
            "CREATE INDEX allergy_code IF NOT EXISTS FOR (a:Allergy) ON (a.code)",
            "CREATE INDEX condition_code IF NOT EXISTS FOR (c:Condition) ON (c.code)",
            "CREATE INDEX device_code IF NOT EXISTS FOR (d:Device) ON (d.code)",
            "CREATE INDEX concept_fsn IF NOT EXISTS FOR (o:ObjectConcept) ON (o.fullySpecifiedName)",
        ]
        
        for index in indexes:
            try:
                self.graph.run(index)
                logger.info(f"Created index: {index.split()[2]}")
            except Exception as e:
                logger.warning(f"Index may already exist or failed: {e}")
    
    def verify_connection(self):
        """Verify the database connection and version"""
        try:
            result = self.graph.run("CALL dbms.components() YIELD name, versions, edition").data()
            if result:
                logger.info(f"Neo4j version: {result[0]['versions'][0]}, edition: {result[0]['edition']}")
            return True
        except Exception as e:
            logger.error(f"Failed to verify connection: {e}")
            return False
    
    def initialize(self, clear_existing=False):
        """
        Initialize the database with schema
        
        Args:
            clear_existing: If True, clear all existing data before initialization
        """
        logger.info("Starting database initialization...")
        
        if not self.verify_connection():
            logger.error("Cannot proceed without valid database connection")
            return False
        
        if clear_existing:
            self.clear_database()
        
        self.create_constraints()
        self.create_indexes()
        
        logger.info("Database initialization completed successfully!")
        return True


def main():
    """Main execution function"""
    import argparse
    
    parser = argparse.ArgumentParser(description='Initialize Neo4j database for SNOMED CT')
    parser.add_argument('--uri', default='bolt://localhost:7687', help='Neo4j connection URI')
    parser.add_argument('--user', default='neo4j', help='Neo4j username')
    parser.add_argument('--password', default='password', help='Neo4j password')
    parser.add_argument('--clear', action='store_true', help='Clear existing data before initialization')
    
    args = parser.parse_args()
    
    initializer = Neo4jInitializer(uri=args.uri, user=args.user, password=args.password)
    success = initializer.initialize(clear_existing=args.clear)
    
    if success:
        logger.info("✓ Database is ready for SNOMED CT data import")
    else:
        logger.error("✗ Database initialization failed")
        exit(1)


if __name__ == "__main__":
    main()
