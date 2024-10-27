import psycopg2

conn_params = {
    'dbname': 'usos_bot_db',  # The name of your database
    'user': 'root',      # Your PostgreSQL username
    'password': 'root',  # Your PostgreSQL password
    'host': 'localhost',     # Database host, 'localhost' for local machine
    'port': '5432'           # Default PostgreSQL port
}

# Establish the connection
try:
    connection = psycopg2.connect(**conn_params)
    cursor = connection.cursor()

    # Test the connection
    cursor.execute("SELECT version();")
    print(f"Connected! PostgreSQL version: {cursor.fetchone()}")

except Exception as e:
    print(f"An error occurred: {e}")

finally:
    # Close the connection
    if connection:
        cursor.close()
        connection.close()
        print("Database connection closed.")