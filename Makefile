# Package description
GROUP_ID ?= com.egt
ARTIFACT_ID ?= proto-lib
VERSION ?= 0.0.1

# Server configuration
SERVER_URL ?= http://nexus:8081/

# Maven settings
SETTINGS := ./settings.xml

all: build deploy

build:
	./mvnw -DgroupId=${GROUP_ID} -DartifactId=${ARTIFACT_ID} -Dversion=${VERSION} -DprotoSourceRoot=./proto/ clean package
	mkdir -p ./build/java
	cp ./target/*.jar ./build/java/

deploy:
	./mvnw -DserverUrl=${SERVER_URL} -DgroupId=${GROUP_ID} -DartifactId=${ARTIFACT_ID} -Dversion=${VERSION} --settings ${SETTINGS} deploy