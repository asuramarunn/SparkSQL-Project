# Sử dụng hình ảnh OpenJDK chính thức làm hình ảnh nền tảng
FROM openjdk:11-jre-slim

# Thiết lập các biến môi trường cho Spark
ENV SPARK_VERSION=3.5.1
ENV HADOOP_VERSION=3
ENV SCALA_VERSION=2.13

# Cài đặt các phụ thuộc
RUN apt-get update && \
    apt-get install -y curl python3 python3-pip sqlite3 procps wget && \
    apt-get clean

# Tải và giải nén Spark từ link chính xác
RUN wget https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar -xzf spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    mv spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark && \
    rm spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

# Thiết lập các biến môi trường cho Spark
ENV SPARK_HOME=/opt/spark
ENV PATH=$SPARK_HOME/bin:$PATH

# Cài đặt JPype và JayDeBeApi
RUN pip3 install JPype1 JayDeBeApi pyspark

# Sao chép driver SQLite JDBC
COPY sqlite-jdbc-3.34.0.jar /opt/sqlite-jdbc-3.34.0.jar

# Sao chép các script khởi tạo và Spark SQL
COPY setup_db.py /opt/setup_db.py
COPY run_crud.py /opt/run_crud.py

# Mở các cổng cho Spark UI và JDBC
EXPOSE 4040 7077 8080 18080

# Đặt entrypoint để giữ cho container chạy
ENTRYPOINT ["tail", "-f", "/dev/null"]
