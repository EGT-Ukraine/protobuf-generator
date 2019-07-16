## Main container
FROM openjdk:8-jdk-alpine

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
ENV GOGO_PROTOBUF 0

RUN apk update && apk add --no-cache make ca-certificates curl bash build-base autoconf automake libtool git
RUN curl -Ls https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.28-r0/glibc-2.28-r0.apk > /tmp/glibc-2.28-r0.apk && \
    apk add --allow-untrusted /tmp/glibc-2.28-r0.apk

## protobuf-go-gen
COPY --from=egtukraine/protoc /export/usr/bin/protoc /usr/bin/protoc
COPY --from=egtukraine/protoc /export/usr/bin/protoc-gen-go /usr/bin/protoc-gen-go
COPY --from=egtukraine/protoc /go/bin/protoc-gen-gogofaster /usr/bin/protoc-gen-gogofaster
COPY --from=egtukraine/protoc /export/usr/include/google /usr/include/google
COPY --from=egtukraine/protoc /export/usr/lib/libproto* /usr/lib/

## general
WORKDIR /app

COPY .mvn .mvn
COPY proto proto
COPY mvnw Makefile settings.xml pom.xml ./

RUN ./mvnw -B -V -Dstyle.color=always -DgroupId=com.egt -DartifactId=protobuf-generator -Dversion=0.0.1 dependency:go-offline

CMD make
