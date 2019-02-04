# Package description
GROUP_ID ?= com.egt
ARTIFACT_ID ?= proto-lib
VERSION ?= 0.0.1

# Nexus configuration
SERVER_URL ?= http://nexus:8081/
# for old versions:
# /nexus/content/repositories/releases
# /nexus/content/repositories/snapshots
RELEASE_ENDPOINT ?= /repository/maven-releases
SNAPSHOT_ENDPOINT ?= /repository/maven-snapshots

# Maven settings
SETTINGS := ./settings.xml


.PHONY: all build-java build-go deploy-java

all: build-java build-go deploy-java

build-java:
	sed -i "s/GROUP_ID/${GROUP_ID}/" pom.xml
	sed -i "s/ARTIFACT_ID/${ARTIFACT_ID}/" pom.xml
	sed -i "s/VERSION/${VERSION}/" pom.xml
	./mvnw -DprotoSourceRoot=./proto/ clean package
	mkdir -p ./proto/build/java
	cp ./target/*.jar ./proto/build/java/

build-go:
	mkdir -p ./proto/build/go
	protoc-gen-go --go_out=paths=source_relative,plugins=grpc:./proto/build/go/ `find . -type f -name "*.proto"|xargs`

deploy-java:
	./mvnw -DserverUrl=${SERVER_URL} -DreleaseEndpoint=${RELEASE_ENDPOINT} -DsnapshotEndpoint=${SNAPSHOT_ENDPOINT} --settings ${SETTINGS} deploy
