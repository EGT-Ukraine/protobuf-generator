FROM nexus.egt-ua.loc/go-team/protoc as golang-protoc-builder

#ENV PROTOBUF_VERSION 3.6.1
#ENV GRPC_VERSION 1.7.2
#
#RUN apk update && apk add git curl build-base autoconf automake libtool
#
## protoc
##RUN curl -L -o /tmp/protobuf.tar.gz https://github.com/google/protobuf/releases/download/v${PROTOBUF_VERSION}/protobuf-cpp-${PROTOBUF_VERSION}.tar.gz
##WORKDIR /tmp/
##RUN tar -zxvf protobuf.tar.gz
##WORKDIR /tmp/protobuf-${PROTOBUF_VERSION}
##RUN mkdir /export
##RUN ./autogen.sh && \
##    ./configure --prefix=/export && \
##    make -j 5 && \
##    make install
#
## Install protoc-gen-go
#RUN mkdir -p /grpc && cd /grpc && \
#        git clone -b v${GRPC_VERSION} https://github.com/grpc/grpc . && \
#        git submodule update --init
#RUN ls -lia /grpc/third_party/protobuf
#
## Install gRPC
#RUN cd /grpc && \
#    make && \
#    make -j 5 install && \
#    ldconfig
#
## Install gRPC plugins
#RUN cd /grpc && \
#    make clean && \
#    make plugins
#
#RUN go get -u -v github.com/golang/protobuf/protoc-gen-go
#
#RUN cp /go/bin/protoc-gen-go /export/bin/
#RUN cp -r /usr/lib/libstdc* /export/lib/
#RUN cp -r /usr/lib/libgcc_s* /export/lib/

#RUN apk add mlocate && updatedb && locate timestamp.proto
RUN apt-get install mlocate && updatedb && locate libprotobuf.so.14

## Main container
FROM alpine:3.9

# Nexus settings
ENV SERVER_URL http://172.17.0.2:8081
ENV RELEASE_ENDPOINT /repository/maven-releases
ENV SNAPSHOT_ENDPOINT /repository/maven-snapshots
ENV USERNAME admin
ENV PASSWORD admin123

# Package settings
ENV GROUP_ID com.egt
ENV ARTIFACT_ID some-lib
ENV VERSION 0.0.1

# Java ENV
ENV JAVA_VERSION_MAJOR 8
ENV JAVA_VERSION_MINOR 201
ENV JAVA_VERSION_BUILD 09
ENV JAVA_URL_ELEMENT 42970487e3af4f5aa5bca3f542482c60
ENV JAVA_PACKAGE jdk

RUN apk update && apk add make tar gzip curl ca-certificates build-base autoconf automake libtool
RUN curl -Ls https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk > /tmp/glibc-2.28-r0.apk && \
    apk add --allow-untrusted /tmp/glibc-2.28-r0.apk
RUN mkdir -p /opt && \
    curl -jkLH "Cookie: oraclelicense=accept-securebackup-cookie" -o java.tar.gz \
    http://download.oracle.com/otn-pub/java/jdk/${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-b${JAVA_VERSION_BUILD}/${JAVA_URL_ELEMENT}/${JAVA_PACKAGE}-${JAVA_VERSION_MAJOR}u${JAVA_VERSION_MINOR}-linux-x64.tar.gz && \
    tar -C /opt -xzvf java.tar.gz && rm -f java.tar.gz && \
    rm -rf /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/*src.zip \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/lib/missioncontrol \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/lib/visualvm \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/lib/*javafx* \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/plugin.jar \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/ext/jfxrt.jar \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/bin/javaws \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/javaws.jar \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/desktop \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/plugin \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/deploy* \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/*javafx* \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/*jfx* \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/amd64/libdecora_sse.so \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/amd64/libprism_*.so \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/amd64/libfxplugins.so \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/amd64/libglass.so \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/amd64/libgstreamer-lite.so \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/amd64/libjavafx*.so \
    /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}/jre/lib/amd64/libjfx*.so && \
    apk del curl tar gzip && \
    rm -rf /var/cache/apk/*

ENV JAVA_HOME /opt/jdk1.${JAVA_VERSION_MAJOR}.0_${JAVA_VERSION_MINOR}
ENV PATH ${PATH}:${JAVA_HOME}/bin

## protobuf-go-gen
#COPY --from=golang-protoc-builder /export/bin/protoc-gen-go /usr/bin/
#COPY --from=golang-protoc-builder /export/bin/protoc /usr/bin/
#COPY --from=golang-protoc-builder /export/lib/libstdc* /usr/lib/
#COPY --from=golang-protoc-builder /export/lib/libgcc_s** /usr/lib/
#COPY --from=golang-protoc-builder /export/lib/libprotoc.so.17 /lib/
#COPY --from=golang-protoc-builder /export/lib/libprotoc.so.17.0.0 /lib/
#COPY --from=golang-protoc-builder /export/lib/libprotobuf.so.17 /lib/
#COPY --from=golang-protoc-builder /export/include /
#COPY --from=golang-protoc-builder /go/src/github.com/golang/protobuf /go/src/github.com/golang/
COPY --from=golang-protoc-builder /usr/local/bin/protoc /usr/local/bin/protoc
COPY --from=golang-protoc-builder /usr/local/lib/libprotobuf.so /usr/lib/
COPY --from=golang-protoc-builder /usr/local/lib/libprotobuf.so.14 /usr/lib/
COPY --from=golang-protoc-builder /usr/local/lib/libprotobuf.so.14.0.0 /usr/lib/

## general
WORKDIR /app

COPY .mvn .mvn
COPY proto proto
COPY mvnw Makefile settings.xml pom.xml ./

#RUN ./mvnw -B -V -Dstyle.color=always -DgroupId=com.egt -DartifactId=protobuf-generator -Dversion=0.0.1 dependency:go-offline

CMD make