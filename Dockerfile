# Sử dụng hình ảnh OpenJDK chính thức làm hình ảnh nền tảng
FROM openjdk:11-jre-slim

# Thiết lập các biến môi trường cho Spark và Scala
ENV SPARK_VERSION=3.5.1
ENV HADOOP_VERSION=3.2
ENV SCALA_VERSION=2.13.6
ENV SPARK_HOME=/opt/spark
ENV SCALA_HOME=/usr/share/scala
ENV PATH=$SPARK_HOME/bin:$SCALA_HOME/bin:$PATH

# Sao chép file Spark vào thư mục /opt và giải nén
COPY spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION}.tgz /tmp/spark.tgz
RUN tar xvzf /tmp/spark.tgz -C /opt/ && \
    mv /opt/spark-${SPARK_VERSION}-bin-hadoop${HADOOP_VERSION} $SPARK_HOME && \
    rm /tmp/spark.tgz

# Cài đặt các phụ thuộc
RUN apt-get update && \
    apt-get install -y curl python3 python3-pip sqlite3 procps wget && \
    apt-get clean

# Cài đặt Scala
RUN wget -qO- https://downloads.lightbend.com/scala/${SCALA_VERSION}/scala-${SCALA_VERSION}.tgz | tar xz -C /usr/share/ && \
    ln -s /usr/share/scala-${SCALA_VERSION} $SCALA_HOME

# Cài đặt JPype và JayDeBeApi
RUN pip3 install JPype1 JayDeBeApi pyspark

# Sao chép driver SQLite JDBC
COPY sqlite-jdbc-3.34.0.jar $SPARK_HOME/jars/sqlite-jdbc-3.34.0.jar

# Sao chép các script khởi tạo và Spark SQL
COPY setup_db.py /opt/setup_db.py
COPY run_crud.py /opt/run_crud.py

# Mở các cổng cho Spark UI và JDBC
EXPOSE 4040 7077 8080 18080

# Đặt entrypoint để giữ cho container chạy
ENTRYPOINT ["tail", "-f", "/dev/null"]
