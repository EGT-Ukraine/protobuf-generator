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


.PHONY: all build deploy

all: build deploy

build:
	./mvnw -DgroupId=${GROUP_ID} -DartifactId=${ARTIFACT_ID} -Dversion=${VERSION} -DprotoSourceRoot=./proto/ clean package
	mkdir -p ./proto/build/java
	cp ./target/*.jar ./proto/build/java/

deploy:
	./mvnw -DserverUrl=${SERVER_URL} -DreleaseEndpoint=${RELEASE_ENDPOINT} -DsnapshotEndpoint=${SNAPSHOT_ENDPOINT} -DgroupId=${GROUP_ID} -DartifactId=${ARTIFACT_ID} -Dversion=${VERSION} --settings ${SETTINGS} deploy
