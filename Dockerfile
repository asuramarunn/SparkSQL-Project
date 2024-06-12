# Sử dụng hình ảnh OpenJDK chính thức làm hình ảnh nền tảng
FROM openjdk:11-jre-slim

# Thiết lập các biến môi trường cho Spark
ENV SPARK_VERSION=3.2.0
ENV HADOOP_VERSION=3.2

# Cài đặt các phụ thuộc
RUN apt-get update && \
    apt-get install -y curl python3 python3-pip sqlite3 procps wget && \
    apt-get clean

# Tải Spark từ URL cụ thể và giải nén
RUN set -eux; \
    wget -O /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz https://archive.apache.org/dist/spark/spark-${SPARK_VERSION}/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz && \
    tar xvzf /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz -C /opt/ && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} /opt/spark && \
    rm /tmp/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz

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
