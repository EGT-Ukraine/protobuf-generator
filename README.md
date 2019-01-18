protobuf-generator
---
[![build](https://img.shields.io/docker/automated/egtukraine/protobuf-generator.svg)](https://hub.docker.com/r/egtukraine/protobuf-generator) [![pulls](https://img.shields.io/docker/pulls/egtukraine/protobuf-generator.svg)](https://hub.docker.com/r/egtukraine/protobuf-generator)

Application([image](https://hub.docker.com/r/egtukraine/protobuf-generator)) for packing proto files into Java library and distributing to Nexus repository.


### Build
```
docker build -t protobuf-generator .
```

### Run
```
docker run --rm \
    -v /some/path/to/proto:/app/proto \
    -e SERVER_URL=http://nexus:8081 \
    -e USERNAME=admin \
    -e PASSWORD=admin123 \
    -e GROUP_ID=com.egt \
    -e ARTIFACT_ID=some-lib \
    -e VERSION=0.0.2 \
    egtukraine/protobuf-generator
```

To play with this you could run the [Nexus Docker Image](https://hub.docker.com/r/sonatype/nexus/) and start it locally.

Makefile has two options:  
  - `build` - will just build the lib by *.proto and store it by the mounted path `/some/path/to/proto/build/java/`
  - `deploy` - store a built lib to the Nexus Repository
  
To use the options you should just add `make build` or `make deploy` in the end of the command line:
```
docker run --rm \
    ...
    egtukraine/protobuf-generator make build
```

or

```
docker run --rm \
    ...
    egtukraine/protobuf-generator make deploy
```
