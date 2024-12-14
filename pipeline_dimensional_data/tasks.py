import os
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from utils import *
print(f"Script's BASE_DIR: {BASE_DIR}")


def run_task(connection, sql_file, params):
    try:
        sql_file_path = os.path.join(BASE_DIR, sql_file)
        with open(sql_file_path, 'r', encoding='utf-8') as f:
            sql_script = f.read()
        print(f"Executing SQL from {sql_file}:")
        print(sql_script[:500])

        execute_sql_file(connection, sql_file_path, params)
        return {"success": True, "message": f"Task for {sql_file} completed successfully."}
    except Exception as e:
        return {"success": False, "error": str(e)}


def create_dimensional_tables(connection):
    sql_file = "queries/create_dimensional_tables.sql"
    return run_task(connection, sql_file, params={})


def ingest_data_into_fact(connection, start_date, end_date):
    """
    Creates the tables for the dimensional database.
    :param connection: Database connection object.
    :return: Task status dictionary.
    """
    sql_file = "queries/update_fact.sql"
    params = {"@StartDate": start_date, "@EndDate": end_date}
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
        "pipeline_dimensional_data/queries/update_dim_Categories.sql",
        "pipeline_dimensional_data/queries/update_dim_Customers.sql",
        "pipeline_dimensional_data/queries/update_dim_Employees.sql",
        "pipeline_dimensional_data/queries/update_dim_Products.sql",
        "pipeline_dimensional_data/queries/update_dim_Region.sql",
        "pipeline_dimensional_data/queries/update_dim_Shippers.sql",
        "pipeline_dimensional_data/queries/update_dim_Suppliers.sql",
        "pipeline_dimensional_data/queries/update_dim_Territories.sql",
        "pipeline_dimensional_data/queries/update_fact.sql"
    ]

    for sql_file in dimension_files:
        result = run_task(connection, sql_file, params={})
        if not result["success"]:
            return result

    return {"success": True, "message": "All dimension tables updated successfully."}


def pipeline_execution(start_date, end_date):
    """
    Executes the pipeline tasks in sequence.
    :param start_date: Start date for fact and fact error ingestion.
    :param end_date: End date for fact and fact error ingestion.
    :return: Overall pipeline status.
    """
    try:
        connection = get_db_connection()

        tasks = [
            ingest_data_into_dimensions,
            lambda conn: ingest_data_into_fact(conn, start_date, end_date),
            lambda conn: ingest_data_into_fact_error(conn, start_date, end_date)
        ]

        for task in tasks:
            result = task(connection)
            if not result["success"]:
                connection.close()
                return result

        connection.close()
        return {"success": True, "message": "Pipeline executed successfully."}
    except Exception as e:
        return {"success": False, "error": str(e)}


if __name__ == "__main__":
    START_DATE = "2024-01-01"
    END_DATE = "2024-12-31"

    pipeline_result = pipeline_execution(START_DATE, END_DATE)
    if pipeline_result["success"]:
        print(pipeline_result["message"])
    else:
        print(f"Pipeline failed: {pipeline_result['error']}")
