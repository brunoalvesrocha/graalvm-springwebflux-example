#!/usr/bin/env bash
 
echo "[-->] Detect artifactId from pom.xml"
ARTIFACT=$(mvn -q \
-Dexec.executable=echo \
-Dexec.args='${project.artifactId}' \
--non-recursive \
exec:exec);
echo "artifactId is '$ARTIFACT'"
 
echo "[-->] Detect artifact version from pom.xml"
VERSION=$(mvn -q \
  -Dexec.executable=echo \
  -Dexec.args='${project.version}' \
  --non-recursive \
  exec:exec);
echo "artifact version is $VERSION"
 
echo "[-->] Detect Spring Boot Main class ('start-class') from pom.xml"
MAINCLASS=$(mvn -q \
-Dexec.executable=echo \
-Dexec.args='${start-class}' \
--non-recursive \
exec:exec);
echo "Spring Boot Main class ('start-class') is 'MAINCLASS'"

echo "[-->] Cleaning target directory & creating new one"
rm -rf target
mkdir -p target/native-image
 
echo "[-->] Build Spring Boot App with mvn package"
mvn -DskipTests package

echo "[-->] Expanding the Spring Boot fat jar"
JAR="$ARTIFACT-$VERSION.jar"
cd target/native-image
jar -xvf ../$JAR >/dev/null 2>&1
cp -R META-INF BOOT-INF/classes
 
echo "[-->] Set the classpath to the contents of the fat jar (where the libs contain the Spring Graal AutomaticFeature)"
LIBPATH=`find BOOT-INF/lib | tr '\n' ':'`
CP=BOOT-INF/classes:$LIBPATH

time native-image \
  --initialize-at-run-time=io.netty.channel.epoll.EpollEventLoop \
  --initialize-at-run-time=io.netty.channel.unix.Errors \
  --initialize-at-run-time=io.netty.channel.unix.IovArray \
  --initialize-at-run-time=io.netty.channel.unix.Socket \
   --initialize-at-run-time=io.netty.util.internal.logging.Log4JLogger \
   --initialize-at-run-time=io.netty.handler.ssl.JettyNpnSslEngine \
   --initialize-at-run-time=io.netty.handler.ssl.ReferenceCountedOpenSslEngine \
  --no-server \
  --no-fallback \
  -H:DeadlockWatchdogInterval=10 \
  -H:+DeadlockWatchdogExitOnTimeout \
  -H:+TraceClassInitialization \
  -H:Name=$ARTIFACT \
  -H:+ReportExceptionStackTraces \
  -Dspring.graal.remove-unused-autoconfig=true \
  -Dspring.graal.remove-yaml-support=true \
  -cp $CP $MAINCLASS;