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

.PHONY: all clean build-java build-go build-python deploy-java

define GO_GENERATE
	$(eval DIR = ${1})
	echo "Parse proto files in: ${DIR}"
	cd ./proto && protoc --go_out=paths=source_relative,plugins=grpc:./${PATH_PREFIX}/go/ -I. `find ./${DIR} -type f -name "*.proto"`
endef

all: clean build-java build-go build-python deploy-java

replaceProjectVar:
	sed -i "s/GROUP_ID/${GROUP_ID}/" pom.xml
	sed -i "s/ARTIFACT_ID/${ARTIFACT_ID}/" pom.xml
	sed -i "s/VERSION/${VERSION}/" pom.xml

clean:
	./mvnw clean

build-java: replaceProjectVar
	@echo "cleaning previouse Java Build"
	@rm -rf ./proto/${PATH_PREFIX}/java
	./mvnw -DprotoSourceRoot=./proto/ package
	mkdir -p ./proto/${PATH_PREFIX}/java
	cp ./target/*.jar ./proto/${PATH_PREFIX}/java/

build-go:
	@echo "cleaning previouse Go Build"
	@rm -rf ./proto/${PATH_PREFIX}/go
	@mkdir -p ./proto/${PATH_PREFIX}/go
	@$(eval SERVICES = $(shell cd ./proto && find . -type f -name '*.proto' | grep -o "\(.*\)/" | sort -u))
	@$(foreach SERVICE,${SERVICES},$(call GO_GENERATE,${SERVICE});)

build-python: replaceProjectVar
	@echo "cleaning previouse Python Build"
	@rm -rf ./proto/${PATH_PREFIX}/python
	./mvnw -DprotoSourceRoot=./proto/ -DpythonOutputDirectory=./proto/${PATH_PREFIX}/python protobuf:compile-python

deploy-java:
	./mvnw -DserverUrl=${SERVER_URL} -DreleaseEndpoint=${RELEASE_ENDPOINT} -DsnapshotEndpoint=${SNAPSHOT_ENDPOINT} --settings ${SETTINGS} deploy
