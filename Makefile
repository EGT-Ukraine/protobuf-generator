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

# proto path prefix for generating code
PATH_PREFIX ?= build

# Maven settings
SETTINGS := ./settings.xml

# golang specific
GO_COMPILE_DIR_ORDER ?=


.PHONY: all clean build-java build-go build-python deploy-java


all: clean build-java build-go build-python deploy-java

replaceProjectVar:
	sed -i "s/GROUP_ID/${GROUP_ID}/" pom.xml
	sed -i "s/ARTIFACT_ID/${ARTIFACT_ID}/" pom.xml
	sed -i "s/VERSION/${VERSION}/" pom.xml

clean:
	./mvnw clean

build-java: replaceProjectVar
	./mvnw -DprotoSourceRoot=./proto/ package
	mkdir -p ./proto/${PATH_PREFIX}/java
	cp ./target/*.jar ./proto/${PATH_PREFIX}/java/

build-go:
	mkdir -p ./proto/${PATH_PREFIX}/go/
    ifeq (${GO_COMPILE_DIR_ORDER},)
		cd ./proto; protoc --go_out=paths=source_relative,plugins=grpc:./${PATH_PREFIX}/go/ `find . -type f -name "*.proto"|xargs`
    else
	for PROTO_DIR in ${GO_COMPILE_DIR_ORDER};do \
		cd ./proto && protoc --go_out=paths=source_relative,plugins=grpc:./${PATH_PREFIX}/go/ `find $${PROTO_DIR} -type f -name "*.proto"|xargs` && cd ../; \
	done
    endif

build-python: replaceProjectVar
	./mvnw -DprotoSourceRoot=./proto/ -DpythonOutputDirectory=./proto/${PATH_PREFIX}/python protobuf:compile-python

deploy-java:
	./mvnw -DserverUrl=${SERVER_URL} -DreleaseEndpoint=${RELEASE_ENDPOINT} -DsnapshotEndpoint=${SNAPSHOT_ENDPOINT} --settings ${SETTINGS} deploy