# Spark running into Spark Standalone cluster in Docker

Apache Spark is an open-source, distributed processing system used for big data workloads.

In this demo, a Spark container uses a Spark Standalone cluster as a resource management and job scheduling technology to perform distributed data processing.

This Docker image contains Spark binaries prebuilt and uploaded in Docker Hub.

## Build Spark image
```shell
$ wget https://archive.apache.org/dist/spark/spark-2.3.2/spark-2.3.2-bin-hadoop2.7.tgz
$ docker image build -t mkenjis/ubspkcluster_img
$ docker login   # provide user and password
$ docker image push mkenjis/ubspkcluster_img
```

## Shell Scripts Inside 

> run_spark.sh

Sets up the environment for Spark client by executing the following steps :
- sets environment variables for JAVA and SPARK
- starts the SSH service for passwordless SSH files on start-up

> create_conf_files.sh

Creates the following Hadoop files on $SPARK_HOME/conf directory :
- spark-env.sh

## Start Swarm cluster

1. start swarm mode in node1
```shell
$ docker swarm init --advertise-addr <IP node1>
$ docker swarm join-token worker  # issue a token to add a node as worker to swarm
```

2. add 3 more workers in swarm cluster (node2, node3, node4)
```shell
$ docker swarm join --token <token> <IP node1>:2377
```

3. label each node to anchor each container in swarm cluster
```shell
docker node update --label-add hostlabel=hdpmst node1
docker node update --label-add hostlabel=hdp1 node2
docker node update --label-add hostlabel=hdp2 node3
docker node update --label-add hostlabel=hdp3 node4
```

4. create an external "overlay" network in swarm to link the 2 stacks (hdp and spk)
```shell
docker network create --driver overlay mynet
```

5. start a spark standalone cluster
```shell
$ docker stack deploy -c docker-compose.yml spk
$ docker service ls
ID             NAME           MODE         REPLICAS   IMAGE                             PORTS
t3s7ud9u21hr   spk_spk_mst    replicated   1/1        mkenjis/ubspkcluster_img:latest   
mi3w7xvf9vyt   spk_spk1   replicated   1/1        mkenjis/ubspkcluster_img:latest   
xlg5ww9q0v6j   spk_spk2   replicated   1/1        mkenjis/ubspkcluster_img:latest   
ni5xrb60u71i   spk_spk3   replicated   1/1        mkenjis/ubspkcluster_img:latest
```

6. in spark master node, start spark-shell in spark cluster mode
```shell
$ docker container exec -it <spk_mst ID> bash
$
$ spark-shell --master spark://<spk_hostname>:7077
2021-12-13 15:09:50 WARN  NativeCodeLoader:62 - Unable to load native-hadoop library for your platform... using builtin-java classes where applicable
Setting default log level to "WARN".
To adjust logging level use sc.setLogLevel(newLevel). For SparkR, use setLogLevel(newLevel).
Spark context Web UI available at http://464730a41833:4040
Spark context available as 'sc' (master = spark://464730a41833:7077, app id = app-20211213150958-0000).
Spark session available as 'spark'.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /___/ .__/\_,_/_/ /_/\_\   version 2.3.2
      /_/
         
Using Scala version 2.11.8 (Java HotSpot(TM) 64-Bit Server VM, Java 1.8.0_181)
Type in expressions to have them evaluated.
Type :help for more information.

scala> 
```
