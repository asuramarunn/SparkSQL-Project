# Use the official OpenJDK image as the base image
FROM openjdk:11-jre-slim

# Set environment variables for Spark
ENV SPARK_VERSION=3.5.1
ENV HADOOP_VERSION=3
ENV SCALA_VERSION=2.13

# Install dependencies
RUN apt-get update && \
    apt-get install -y curl python3 python3-pip sqlite3 procps && \
    apt-get clean

# Install JPype and JayDeBeApi
RUN pip3 install JPype1 JayDeBeApi pyspark

# Copy Spark files
COPY spark-3.5.1-bin-hadoop3-scala2.13 /opt/spark

# Set environment variables for Spark
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Copy SQLite JDBC driver
COPY sqlite-jdbc-3.34.0.jar /opt/sqlite-jdbc-3.34.0.jar

# Copy initialization and Spark SQL scripts
COPY setup_db.py /opt/setup_db.py
COPY run_crud.py /opt/run_crud.py

# Expose ports for Spark UI and JDBC
EXPOSE 4040 7077 8080 18080

# Set the entrypoint to keep the container running
ENTRYPOINT ["tail", "-f", "/dev/null"]
