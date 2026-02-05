"""
Complete Import Script for SNOMED CT Neo4j Database

This script orchestrates the complete data import process using py2neo.
It can be used as an alternative to the bash script for cross-platform compatibility.
"""

import os
import sys
import argparse
import logging
from pathlib import Path
from py2neo import Graph

# Configure logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)


class DataImporter:
    """Import Synthea data into Neo4j"""
    
    def __init__(self, uri="bolt://localhost:7687", user="neo4j", password="password"):
        """Initialize the database connection"""
        try:
            self.graph = Graph(uri, auth=(user, password))
            logger.info("Successfully connected to Neo4j database")
        except Exception as e:
            logger.error(f"Failed to connect to Neo4j: {e}")
            raise
    
    def run_cypher_file(self, filepath, description):
        """Run a Cypher script from file"""
        try:
            logger.info(f"→ {description}")
            with open(filepath, 'r') as f:
                cypher_script = f.read()
            
            # Split by semicolon and run each statement
            statements = [s.strip() for s in cypher_script.split(';') if s.strip()]
            results = []
            
            for statement in statements:
                if statement and not statement.startswith('//'):
                    result = self.graph.run(statement).data()
                    results.extend(result)
            
            logger.info(f"  ✓ Success")
            return results
        except Exception as e:
            logger.error(f"  ✗ Failed: {e}")
            raise
    
    def import_csv_data(self, scripts_dir):
        """Import all CSV data"""
        logger.info("Step 1: Importing CSV data...")
        logger.info("----------------------------")
        
        imports = [
            ('import_patients.cypher', 'Importing patients'),
            ('import_allergies.cypher', 'Importing allergies'),
            ('import_conditions.cypher', 'Importing conditions'),
            ('import_devices.cypher', 'Importing devices'),
        ]
        
        for script, description in imports:
            script_path = scripts_dir / 'cypher' / script
            self.run_cypher_file(script_path, description)
        
        logger.info("")
    
    def create_relationships(self, scripts_dir):
        """Create relationships between nodes"""
        logger.info("Step 2: Creating relationships...")
        logger.info("--------------------------------")
        
        relationships = [
            ('create_has_relationships.cypher', 'Creating HAS relationships (Patient-Allergy)'),
            ('create_used_relationships.cypher', 'Creating USED relationships (Patient-Device)'),
            ('create_underwent_relationships.cypher', 'Creating UNDERWENT relationships (Patient-Condition)'),
        ]
        
        for script, description in relationships:
            script_path = scripts_dir / 'cypher' / script
            self.run_cypher_file(script_path, description)
        
        logger.info("")
    
    def label_concepts(self, scripts_dir):
        """Label SNOMED CT concepts by FSN suffix"""
        logger.info("Step 3: Labeling SNOMED CT concepts...")
        logger.info("--------------------------------------")
        
        try:
            script_path = scripts_dir / 'cypher' / 'label_concepts_by_fsn.cypher'
            self.run_cypher_file(script_path, 'Labeling ObjectConcept nodes by FSN suffix')
        except Exception as e:
            logger.warning(f"  ⚠ Warning: Labeling step had issues (this is OK if you don't have SNOMED CT concepts): {e}")
        
        logger.info("")
    
    def run_complete_import(self, scripts_dir):
        """Run the complete import process"""
        logger.info("=" * 48)
        logger.info("SNOMED CT Neo4j Import Script")
        logger.info("=" * 48)
        logger.info("")
        
        try:
            self.import_csv_data(scripts_dir)
            self.create_relationships(scripts_dir)
            self.label_concepts(scripts_dir)
            
            logger.info("=" * 48)
            logger.info("Import completed successfully!")
            logger.info("=" * 48)
            logger.info("")
            logger.info("Next steps:")
            logger.info("  1. Open Neo4j Browser at http://localhost:7474")
            logger.info("  2. Run example queries from the README")
            logger.info("  3. Explore your data!")
            
            return True
        except Exception as e:
            logger.error(f"Import failed: {e}")
            return False


def main():
    """Main execution function"""
    parser = argparse.ArgumentParser(description='Import Synthea data into Neo4j')
    parser.add_argument('--uri', default='bolt://localhost:7687', help='Neo4j connection URI')
    parser.add_argument('--user', default='neo4j', help='Neo4j username')
    parser.add_argument('--password', default='password', help='Neo4j password')
    parser.add_argument('--scripts-dir', help='Path to scripts directory (auto-detected if not provided)')
    
    args = parser.parse_args()
    
    # Auto-detect scripts directory
    if args.scripts_dir:
        scripts_dir = Path(args.scripts_dir)
    else:
        scripts_dir = Path(__file__).parent.parent
    
    if not scripts_dir.exists():
        logger.error(f"Scripts directory not found: {scripts_dir}")
        sys.exit(1)
    
    logger.info(f"Using scripts directory: {scripts_dir}")
    logger.info(f"Connecting to: {args.uri}")
    logger.info("")
    
    importer = DataImporter(uri=args.uri, user=args.user, password=args.password)
    success = importer.run_complete_import(scripts_dir)
    
    sys.exit(0 if success else 1)


if __name__ == "__main__":
    main()
