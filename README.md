protobuf-generator
---
[![build](https://img.shields.io/docker/automated/egtukraine/protobuf-generator.svg)](https://hub.docker.com/r/egtukraine/protobuf-generator) [![pulls](https://img.shields.io/docker/pulls/egtukraine/protobuf-generator.svg)](https://hub.docker.com/r/egtukraine/protobuf-generator) [![Build Status](https://travis-ci.org/EGT-Ukraine/protobuf-generator.svg?branch=master)](https://travis-ci.org/EGT-Ukraine/protobuf-generator) [![Automated Release Notes by gren](https://img.shields.io/badge/%F0%9F%A4%96-release%20notes-00B2EE.svg)](https://github-tools.github.io/github-release-notes/)

Application([image](https://hub.docker.com/r/egtukraine/protobuf-generator)) for packing proto files into Golang protobuf, python protobuf or Java library. Also, Java libs could be distributed to Nexus repository with the container.


### Run
```
docker run --rm \
    -v /some/path/to/proto:/app/proto \
    -e PATH_PREFIX=build
    -e SERVER_URL=http://nexus:8081 \
    -e USERNAME=admin \
    -e PASSWORD=admin123 \
    -e GROUP_ID=com.egt \
    -e ARTIFACT_ID=some-lib \
    -e VERSION=0.0.2 \
    egtukraine/protobuf-generator
```

`PATH_PREFIX` - path in which protobuf will be generated in your proto repo.
 
  
There are two additional options to set endpoints for release & snapshots for Nexus(by default they are equal to paths for Nexus v.3):
  * RELEASE_ENDPOINT
  * SNAPSHOT_ENDPOINT

To change them to the lower version you could change it. Ex:
```
docker run --rm \
    ...
    -e RELEASE_ENDPOINT=/nexus/content/repositories/releases
    -e SNAPSHOT_ENDPOINT=/nexus/content/repositories/snapshots
    ...
    egtukraine/protobuf-generator
``` 

To play with this you could run the [Nexus Docker Image](https://hub.docker.com/r/sonatype/nexus/) and start it locally.

Makefile options:  
  - `build-java` - will just build the Java lib by *.proto and store it by the mounted path `/some/path/to/proto/build/java/`
  - `build-go` - will build the Golang's *.pb.go and store it by the mounted path `/some/path/to/proto/build/go/`
  - `build-python` - will build the Python's *.py files and store it by the mounted path `/some/path/to/proto/build/python/`
  - `deploy-java` - store a built Java library to the Nexus Repository
  - `all` - do all of above
  
To use the options you should just add `make build-java` or `make build-go` or `make deploy-java` in the end of the command line:
```
docker run --rm \
    ...
    egtukraine/protobuf-generator make build-java
```

or

```
docker run --rm \
    ...
    egtukraine/protobuf-generator make deploy-java
```
