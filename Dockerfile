FROM ubuntu:14.04

ENV DEBIAN_FRONTEND "noninteractive"
ENV DEBCONF_NONINTERACTIVE_SEEN "true"

RUN apt-get -y update && \
    apt-get install -y --force-yes software-properties-common python-software-properties && \
    apt-add-repository -y ppa:webupd8team/java && \
    apt-get -y update && \
    /bin/echo debconf shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections && \ 
    DEBIAN_FRONTEND=noninteractive apt-get -y install oracle-java7-installer oracle-java7-set-default && \
    apt-get -y install curl

RUN curl -s http://d3kbcqa49mib13.cloudfront.net/spark-1.5.2-bin-hadoop2.6.tgz | tar -xz -C /usr/local/
RUN cd /usr/local && ln -s spark-1.5.2-bin-hadoop2.6 spark

RUN echo "deb http://repos.mesosphere.io/ubuntu/ trusty main" > /etc/apt/sources.list.d/mesosphere.list && \
  apt-key adv --keyserver keyserver.ubuntu.com --recv E56151BF && \
  apt-get -y update && \
  apt-get -y install mesos && \
  apt-get clean && rm -rf /var/lib/apt/lists/*

RUN printf "\n192.168.33.10 node1" >> /etc/hosts &&\
  echo "zk://192.168.33.10:2181/mesos" > /etc/mesos/zk

ENV SPARK_HOME /usr/local/spark
ENV SPARK_WORKER_OPTS="-Dspark.driver.port=7001 \
                       -Dspark.fileserver.port=7002 \
                       -Dspark.broadcast.port=7003 \
                       -Dspark.replClassServer.port=7004 \ 
                       -Dspark.blockManager.port=7005 \
                       -Dspark.executor.port=7006 \
                       -Dspark.ui.port=4040 \
                       -Dspark.broadcast.factory=org.apache.spark.broadcast.HttpBroadcastFactory"
ENV SPARK_WORKER_PORT 8888
ENV SPARK_WORKER_WEBUI_PORT 8081

EXPOSE 8080 7077 8888 8081 4040 7001 7002 7003 7004 7005 7006 
CMD ["./usr/local/spark-1.5.2-bin-hadoop2.6/sbin/start-mesos-dispatcher.sh", "-m mesos://192.168.33.10:5050"]
