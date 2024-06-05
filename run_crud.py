import logging
import sqlite3
from pyspark.sql import SparkSession
from pyspark.sql.functions import col
import time

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

def create_spark_session():
    spark = SparkSession.builder \
        .appName("SparkSQL CRUD Operations") \
        .config("spark.jars", "/opt/sqlite-jdbc-3.34.0.jar") \
        .getOrCreate()
    return spark

def connect_to_db():
    try:
        conn = sqlite3.connect('/opt/spark/examples/src/main/resources/people.db')
        logger.info("Database connection successful.")
        return conn
    except Exception as e:
        logger.error(f"Database connection failed: {e}")
        return None

def create_temp_view(spark, jdbc_url, jdbc_table):
    try:
        df = spark.read \
            .format("jdbc") \
            .option("url", jdbc_url) \
            .option("dbtable", jdbc_table) \
            .option("driver", "org.sqlite.JDBC") \
            .load()
        df.createOrReplaceTempView("people")
        logger.info("Temporary view created.")
    except Exception as e:
        logger.error(f"Creating temporary view failed: {e}")

def read_data(spark, n=5):
    try:
        df = spark.sql(f"SELECT * FROM people ORDER BY id DESC LIMIT {n}")
        df.show()
    except Exception as e:
        logger.error(f"Reading data failed: {e}")

def insert_data(conn):
    try:
        cursor = conn.cursor()
        cursor.executemany("INSERT INTO people (name, age, country) VALUES (?, ?, ?)", [('Rashford', 30, 'England' ), ('Sancho', 25, 'England' )])
        conn.commit()
        logger.info("Data insertion successful.")
        
        # Read bottom of the table after insert
        read_data(spark)
    except Exception as e:
        logger.error(f"Data insertion failed: {e}")

def update_data(conn):
    try:
        cursor = conn.cursor()
        cursor.execute("UPDATE people SET age = 40 WHERE id = 1000001")
        conn.commit()
        logger.info("Data update successful.")
        
        # Read bottom of the table after update
        read_data(spark)
    except Exception as e:
        logger.error(f"Data update failed: {e}")

def delete_data(conn):
    try:
        cursor = conn.cursor()
        cursor.execute("DELETE FROM people WHERE id >= 1000001")
        conn.commit()
        logger.info("Data deletion successful.")
        
        # Read bottom of the table after delete
        read_data(spark)
    except Exception as e:
        logger.error(f"Data deletion failed: {e}")

def performance_test(conn):
    try:
        cursor = conn.cursor()
        
        # Measure time to count all records
        start_time = time.time()
        cursor.execute("SELECT COUNT(*) FROM people")
        count_all = cursor.fetchone()[0]
        count_all_time = time.time() - start_time
        logger.info(f"Count all records: {count_all}")
        logger.info(f"Time to count all records: {count_all_time} seconds")

        # Measure time to count records with age > 50
        start_time = time.time()
        cursor.execute("SELECT COUNT(*) FROM people WHERE age > 50")
        count_age_gt_50 = cursor.fetchone()[0]
        count_age_gt_50_time = time.time() - start_time
        logger.info(f"Count records with age > 50: {count_age_gt_50}")
        logger.info(f"Time to count records with age > 50: {count_age_gt_50_time} seconds")
        
    except Exception as e:
        logger.error(f"Performance test failed: {e}")
        raise  # Optionally re-raise the exception after logging

if __name__ == "__main__":
    spark = create_spark_session()
    conn = connect_to_db()

    if conn:
        jdbc_url = "jdbc:sqlite:/opt/spark/examples/src/main/resources/people.db"
        jdbc_table = "people"

        create_temp_view(spark, jdbc_url, jdbc_table)

        logger.info("Reading data...")
        read_data(spark)

        logger.info("Inserting new data...")
        insert_data(conn)

        logger.info("Updating data...")
        update_data(conn)

        logger.info("Deleting data...")
        delete_data(conn)

        logger.info("Performance test with large dataset...")
        performance_test(conn)

        conn.close()
        spark.stop()
