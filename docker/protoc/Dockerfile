FROM golang:1.11-alpine

ENV PROTOBUF_VERSION 3.6.1
ENV GRPC_VERSION 1.22.0
ENV PROTOC_GO_VERSION 1.2.0
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

RUN go get -u -d -v -ldflags '-w -s' \
        github.com/golang/protobuf/protoc-gen-go && \
        cd $GOPATH/src/github.com/golang/protobuf/protoc-gen-go && \
        git checkout tags/v${PROTOC_GO_VERSION} -b v${PROTOC_GO_VERSION} && \
        go install && \
        install -c ${GOPATH}/bin/protoc-gen* ${OUTDIR}/usr/bin/

RUN go get github.com/gogo/protobuf/protoc-gen-gogofaster
