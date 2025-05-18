import mysql.connector
from mysql.connector import Error


def create_connection():
    """Create a database connection using configuration from config.py."""
    try:
        connection = mysql.connector.connect(
            host= "localhost",
            database="main",
            user= "root",
            password="Bichthebest3805"
        )
        if connection.is_connected():
            return connection
    except Error as e:
        print(f"Error connecting to MySQL: {e}")
        return None
    return None