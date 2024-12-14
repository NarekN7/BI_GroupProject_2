import os
import sys
from pathlib import Path
BASE_DIR = os.path.dirname(os.path.abspath(__file__))

sys.path.insert(0, str(Path(os.getcwd()).resolve().parent))

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from utils import get_db_connection, execute_sql_file


print(f"Script's BASE_DIR: {BASE_DIR}")


print(get_db_connection())
def run_task(connection, sql_file, params):
    """
    Runs a single task by executing a SQL file with the given parameters.
    :param connection: Database connection object.
    :param sql_file: Path to the SQL file to execute.
    :param params: Dictionary of parameters to pass to the SQL script.
    :return: Task status dictionary.
    """
    try:
        # Construct the full path for the SQL file
        sql_file_path = os.path.join(BASE_DIR, sql_file)

        # Execute the SQL file
        execute_sql_file(connection, sql_file_path, params)

        return {"success": True, "message": f"Task for {sql_file} completed successfully."}
    except Exception as e:
        return {"success": False, "error": str(e)}



def create_dimensional_tables(connection):
    """
    Creates the tables for the dimensional database.
    :param connection: Database connection object.
    :return: Task status dictionary.
    """
    sql_file = "queries/create_dimensional_tables.sql"
    params = {}
    return run_task(connection, sql_file, params)


def ingest_data_into_fact(connection, start_date, end_date):
    """
    Ingests data into the fact table.
    :param connection: Database connection object.
    :param start_date: Start date for data ingestion.
    :param end_date: End date for data ingestion.
    :return: Task status dictionary.
    """
    sql_file = "queries/update_fact.sql"
    params = {"@StartDate": start_date, "@EndDate": end_date}
    return run_task(connection, sql_file, params)


def ingest_data_into_fact_error(connection, start_date, end_date):
    """
    Ingests faulty rows into the fact error table.
    :param connection: Database connection object.
    :param start_date: Start date for data ingestion.
    :param end_date: End date for data ingestion.
    :return: Task status dictionary.
    """
    sql_file = "queries/update_fact_error.sql"
    params = {"@StartDate": start_date, "@EndDate": end_date}
    return run_task(connection, sql_file, params)


def ingest_data_into_dimensions(connection):
    """
    Ingests data into multiple dimension tables sequentially.
    :param connection: Database connection object.
    :return: Task status dictionary.
    """
    dimension_files = [
        "queries/update_dim_categories.sql",
        "queries/update_dim_customers.sql",
        "queries/update_dim_employees.sql",
        "queries/update_dim_products.sql",
        "queries/update_dim_region.sql",
        "queries/update_dim_shippers.sql",
        "queries/update_dim_suppliers.sql",
        "queries/update_dim_territories.sql",
    ]

    for sql_file in dimension_files:
        result = run_task(connection, sql_file, params={})
        if not result["success"]:
            return result  # Stop and return error if any dimension fails

    return {"success": True, "message": "All dimension tables updated successfully."}


def pipeline_execution(start_date, end_date):
    """
    Executes the pipeline tasks in sequence.
    :param start_date: Start date for fact and fact error ingestion.
    :param end_date: End date for fact and fact error ingestion.
    :return: Overall pipeline status.
    """
    try:
        connection = get_db_connection()  # Correctly indented line

        # Step 1: Create dimensional tables
        result = create_dimensional_tables(connection)
        if not result["success"]:
            return result

        # Step 2: Ingest data into dimension tables
        result = ingest_data_into_dimensions(connection)
        if not result["success"]:
            return result

        # Step 3: Ingest data into the fact table
        result = ingest_data_into_fact(connection, start_date, end_date)
        if not result["success"]:
            return result

        # Step 4: Ingest faulty rows into the fact error table
        result = ingest_data_into_fact_error(connection, start_date, end_date)
        if not result["success"]:
            return result

        connection.close()
        return {"success": True, "message": "Pipeline executed successfully."}
    except Exception as e:
        return {"success": False, "error": str(e)}


# Example execution
if __name__ == "__main__":
    START_DATE = "2024-01-01"
    END_DATE = "2024-12-31"

    pipeline_result = pipeline_execution(START_DATE, END_DATE)
    if pipeline_result["success"]:
        print(pipeline_result["message"])
    else:
        print(f"Pipeline failed: {pipeline_result['error']}")
print(run_task())