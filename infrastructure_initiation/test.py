# import os
# import sys
# from pathlib import Path
# BASE_DIR = os.path.dirname(os.path.abspath(__file__))
#
# sys.path.insert(0, str(Path(os.getcwd()).resolve().parent))
#
# sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))

from utils import get_db_connection, execute_sql_file, get_db_config

print(get_db_connection())