import os
import configparser
import sys
from pathlib import Path
sys.path.insert(0, str(Path(__file__).resolve().parent.parent))
from utils import *


def config_test():
    config = configparser.ConfigParser()
    config_path = r"infrastructure_initiation\sql_server_config.cfg"
    config.read(config_path)

    if not os.path.exists(config_path):
        print(f"File not found: {config_path}")
    else:
        print(f"File found at: {os.path.abspath(config_path)}")
        
    for section in config.sections():
        print(f"[{section}]")
        for key, value in config.items(section):
            print(f"{key} = {value}")
        print()

    server = config['SQL_SERVER']['SERVER']
    database = config['SQL_SERVER']['DATABASE']
    username = config['SQL_SERVER']['USERNAME']
    password = config['SQL_SERVER']['PASSWORD']

    print("Server:", server)
    print("Database:", database)
    print("Username:", username)
    print("Password:", password)


if __name__ == "__main__":
    config_test()
