import os
import configparser
import pyodbc
import sys
from pathlib import Path
sys.path.insert(0, str(Path(os.getcwd()).resolve().parent))

BASE_DIR = os.path.dirname(os.path.abspath(__file__))

print(f"Script's BASE_DIR: {sys.path}")

def get_db_config(config_file=r"infrastructure_initiation/sql_server_config.cfg"):
    config_path = os.path.join(BASE_DIR, config_file)
    print(f"Config Path: {config_path}")

    if not os.path.exists(config_path):
        raise FileNotFoundError(f"Configuration file not found: {config_path}")

    config = configparser.ConfigParser()
    config.read(config_path)
    db_config = {
        "server": config.get("SQL_SERVER", "SERVER"),
        "database": config.get("SQL_SERVER", "DATABASE"),
        "username": config.get("SQL_SERVER", "USERNAME"),
        "password": config.get("SQL_SERVER", "PASSWORD"),
    }
    return db_config

print(get_db_config())



def read_sql_file(file_path):
    if not os.path.exists(file_path):
        raise FileNotFoundError(f"SQL file not found: {file_path}")

    with open(file_path, 'r', encoding='utf-8') as file:
        sql_script = file.read()

    return sql_script


#
# def execute_sql_script(connection, sql_script, params=None):
#
#     try:
#         with connection.cursor() as cursor:
#             if params:
#                 cursor.execute(sql_script, params)
#             else:
#                 cursor.execute(sql_script)
#             connection.commit()
#     except pyodbc.Error as e:
#         raise RuntimeError(f"An error occurred while executing the SQL script: {e}")

def execute_sql_script(connection, sql_script, params=None):
    """
    Executes an SQL script and commits the transaction.
    """
    print("Starting to execute SQL script...")  # Debugging log
    try:
        with connection.cursor() as cursor:
            if params:
                print(f"Executing with params: {params}")  # Debugging log
                cursor.execute(sql_script, params)
            else:
                print(f"Executing script: {sql_script[:100]}...")  # Limit to 100 characters
                cursor.execute(sql_script)
            connection.commit()
            print("SQL script executed successfully!")  # Debugging log
    except pyodbc.Error as e:
        print(f"SQL Execution Error: {e}")
        raise RuntimeError(f"An error occurred while executing the SQL script: {e}")



def execute_sql_file(connection, file_path, params=None):

    sql_script = read_sql_file(file_path)
    execute_sql_script(connection, sql_script, params)


def get_db_connection(config_file=r"infrastructure_initiation/sql_server_config.cfg"):

    db_config = get_db_config(config_file)
    connection_string = (
        f"Driver={{SQL Server}};"
        f"Server={db_config['server']};"
        f"Database={db_config['database']};"
        f"UID={db_config['username']};"
        f"PWD={db_config['password']};"
    )
    return pyodbc.connect(connection_string)

def extract_tables_db(cursor, *excluded_schemas):
    results = []
    for row in cursor.execute("EXEC sp_tables"):
        if row.TABLE_SCHEM not in excluded_schemas:
            results.append(row.TABLE_NAME)
    return results


def extract_table_cols(cursor, table_name):
    result = []
    for row in cursor.columns(table=table_name):
        result.append(row.column_name)
    return result


def find_primary_key(cursor, table_name, schema=None):
    primary_keys = cursor.primaryKeys(table=table_name, schema=schema)

    columns = [desc[0] for desc in cursor.description]
    results = []
    for row in primary_keys.fetchall():
        results.append(dict(zip(columns, row)))

    try:
        return results[0]
    except IndexError:
        return None
