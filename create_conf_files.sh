
# spark-env.sh (SPARK)
# ============
echo 'export JAVA_HOME=/usr/local/jre1.8.0_181' >$SPARK_HOME/conf/spark-env.sh
echo 'export SPARK_DAEMON_JAVA_OPTS="-Dspark.deploy.recoveryMode=FILESYSTEM -Dspark.deploy.recoveryDirectory=/root/recover"' >>$SPARK_HOME/conf/spark-env.sh
echo '' >>$SPARK_HOME/conf/spark-env.sh
echo '# Number of worker instances to run on each machine (default: 1)' >>$SPARK_HOME/conf/spark-env.sh
echo '#export SPARK_WORKER_INSTANCES=2' >>$SPARK_HOME/conf/spark-env.sh
echo '#export SPARK_WORKER_CORES=2' >>$SPARK_HOME/conf/spark-env.sh
chmod +x $SPARK_HOME/conf/spark-env.sh