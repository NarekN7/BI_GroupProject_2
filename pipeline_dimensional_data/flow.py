from logging import setup_logger
from pipeline_dimensional_data.tasks import (
    create_dimensional_tables,
    ingest_data_into_dimensions,
    ingest_data_into_fact,
    ingest_data_into_fact_error,
)
from utils import get_db_connection
import uuid


class DimensionalDataFlow:
    def __init__(self):
        """
        Initializes the DimensionalDataFlow class and generates a unique execution ID.
        Sets up a logger for the execution.
        """
        self.execution_id = self.generate_uuid()
        self.logger = setup_logger(self.execution_id)

    @staticmethod
    def generate_uuid():
        """
        Generates a unique UUID for tracking execution.
        :return: UUID string
        """
        return str(uuid.uuid4())

    def exec(self, start_date, end_date):
        """
        Executes all tasks sequentially with start and end dates.
        Logs progress and results for each step.
        :param start_date: Start date for fact and fact error ingestion.
        :param end_date: End date for fact and fact error ingestion.
        :return: Overall execution status.
        """

        try:
            self.logger.info("Starting dimensional data flow pipeline...")

            # Step 1: Create dimensional tables
            self.logger.info("Step 1: Creating dimensional tables...")
            connection = get_db_connection()
            result = create_dimensional_tables(connection)
            self.logger.info(f"Step 1 Result: {result}")
            if not result["success"]:
                self.logger.error(f"Step 1 failed: {result['error']}")
                return {"execution_id": self.execution_id, "success": False, "error": result["error"]}

            # Step 2: Ingest data into dimension tables
            self.logger.info("Step 2: Ingesting data into dimension tables...")
            result = ingest_data_into_dimensions(connection)
            self.logger.info(f"Step 2 Result: {result}")
            if not result["success"]:
                self.logger.error(f"Step 2 failed: {result['error']}")
                return {"execution_id": self.execution_id, "success": False, "error": result["error"]}

            # Step 3: Ingest data into the fact table
            self.logger.info("Step 3: Ingesting data into the fact table...")
            result = ingest_data_into_fact(connection, start_date, end_date)
            self.logger.info(f"Step 3 Result: {result}")
            if not result["success"]:
                self.logger.error(f"Step 3 failed: {result['error']}")
                return {"execution_id": self.execution_id, "success": False, "error": result["error"]}

            # Step 4: Ingest faulty rows into the fact error table
            self.logger.info("Step 4: Ingesting faulty rows into the fact error table...")
            result = ingest_data_into_fact_error(connection, start_date, end_date)
            self.logger.info(f"Step 4 Result: {result}")
            if not result["success"]:
                self.logger.error(f"Step 4 failed: {result['error']}")
                return {"execution_id": self.execution_id, "success": False, "error": result["error"]}

            connection.close()
            self.logger.info("Pipeline executed successfully.")
            return {"execution_id": self.execution_id, "success": True, "message": "Pipeline executed successfully."}

        except Exception as e:
            self.logger.error(f"Pipeline execution failed: {e}")
            return {"execution_id": self.execution_id, "success": False, "error": str(e)}
