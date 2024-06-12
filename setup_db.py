import sqlite3
import random

# Initialize SQLite database and populate it with sample data
def initialize_db():
    print("Starting database initialization...")

    # Connect to SQLite database
    conn = sqlite3.connect('/opt/spark-3.5.1-bin-hadoop3/examples/src/main/resources/people.db')
    c = conn.cursor()

    # Create table
    c.execute('''CREATE TABLE people
                 (id INTEGER PRIMARY KEY, name TEXT, age INTEGER, country TEXT)''')

    # List of countries
    countries = ['Vietnam', 'American', 'Germany', 'England', 'Sweden', 'Canada', 'Thailand', 'China', 'India', 'Japan', 'France']

    # Insert sample data
    for i in range(1000000):
        name = f'Name{i}'
        age = random.randint(1, 100)
        country = random.choice(countries)
        c.execute("INSERT INTO people (name, age, country) VALUES (?, ?, ?)", (name, age, country))

    # Commit and close
    conn.commit()
    conn.close()

    print("Database initialization completed.")

if __name__ == "__main__":
    initialize_db()
