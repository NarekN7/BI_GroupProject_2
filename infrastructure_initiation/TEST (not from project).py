
import configparser

config = configparser.ConfigParser()
config.read('sql_server_config.cfg')

server = config['SQL_SERVER']['SERVER']
database = config['SQL_SERVER']['DATABASE']
username = config['SQL_SERVER']['USERNAME']
password = config['SQL_SERVER']['PASSWORD']

print("Server:", server)
print("Database:", database)
print("Username:", username)
print("Password:", password)



