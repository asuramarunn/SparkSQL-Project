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

# Tải Spark từ các URL khả dụng
RUN set -eux; \
    wget -O /tmp/spark-3.5.1-bin-hadoop3-scala2.13.tgz https://archive.apache.org/dist/spark/spark-3.5.1/spark-3.5.1-bin-hadoop3-scala2.13.tgz && \
    tar xvzf /tmp/spark-3.5.1-bin-hadoop3-scala2.13.tgz -C /opt/ && \
    mv /opt/spark-3.5.1-bin-hadoop3-scala2.13 /opt/spark && \
    rm /tmp/spark-3.5.1-bin-hadoop3-scala2.13.tgz


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
