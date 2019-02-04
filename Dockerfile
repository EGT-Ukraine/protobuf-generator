FROM golang:1.11-alpine as protoc-builder

ENV PROTOBUF_VERSION 3.6.1
ENV GRPC_VERSION 1.18.0
ENV OUTDIR "/export"

RUN apk --update --no-cache add build-base curl automake autoconf libtool git zlib-dev git

RUN mkdir -p /protobuf && \
        curl -L https://github.com/google/protobuf/archive/v${PROTOBUF_VERSION}.tar.gz | tar xvz --strip-components=1 -C /protobuf

RUN git clone --depth 1 --recursive -b v${GRPC_VERSION} https://github.com/grpc/grpc.git /grpc && \
        rm -rf grpc/third_party/protobuf && \
        ln -s /protobuf /grpc/third_party/protobuf

RUN cd /protobuf && \
        autoreconf -f -i -Wall,no-obsolete && \
        ./configure --prefix=/usr --enable-static=no && \
        make -j5 && make install
RUN cd /grpc && \
        make -j5 plugins

RUN cd /protobuf && \
        make install DESTDIR=${OUTDIR}
RUN cd /grpc && \
        make install-plugins prefix=${OUTDIR}/usr

RUN go get -u -v -ldflags '-w -s' \
        github.com/golang/protobuf/protoc-gen-go \
        && install -c ${GOPATH}/bin/protoc-gen* ${OUTDIR}/usr/bin/


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

RUN apk update && apk add make tar gzip curl ca-certificates bash build-base autoconf automake libtool git
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
COPY --from=protoc-builder /export/usr/bin/protoc /usr/bin/protoc
COPY --from=protoc-builder /export/usr/bin/protoc-gen-go /usr/bin/protoc-gen-go
COPY --from=protoc-builder /export/usr/include/google /usr/include/google
COPY --from=protoc-builder /export/usr/lib/libproto* /usr/lib/

## general
WORKDIR /app

COPY .mvn .mvn
COPY proto proto
COPY mvnw Makefile settings.xml pom.xml ./

RUN ./mvnw -B -V -Dstyle.color=always -DgroupId=com.egt -DartifactId=protobuf-generator -Dversion=0.0.1 dependency:go-offline

CMD make