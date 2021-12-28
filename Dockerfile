FROM golang:1.14.1 as go-builder

WORKDIR /go/src
COPY . github.com/ProjectSigma/kubekite
WORKDIR /go/src/github.com/ProjectSigma/kubekite/cmd/kubekite

# Build and strip our binary
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -a -installsuffix cgo -o kubekite .

FROM ubuntu
ARG JOB_TEMPLATE=job-templates/job.yaml

ENV GOSU_VERSION 1.10

RUN apt-get update && \
    apt-get -y upgrade && \
    apt-get -y dist-upgrade && \
    apt-get install -y curl gnupg && \
    dpkgArch="$(dpkg --print-architecture | awk -F- '{ print $NF }')" && \
    curl -L -o /gosu "https://github.com/tianon/gosu/releases/download/1.10/gosu-${dpkgArch}" && \
    curl -L -o /gosu.asc "https://github.com/tianon/gosu/releases/download/1.10/gosu-${dpkgArch}.asc" && \
    export GNUPGHOME="$(mktemp -d)" && \
    echo "disable-ipv6" > "$GNUPGHOME/dirmngr.conf" && \
    gpg --keyserver keyserver.ubuntu.com --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 && \
    gpg --batch --verify /gosu.asc /gosu && \
    rm -r /gosu.asc && \
    chmod +x /gosu && \
    /gosu nobody true

# Copy the binary over from the builder image
COPY --from=go-builder /go/src/github.com/ProjectSigma/kubekite/cmd/kubekite/kubekite /
RUN chmod +x /kubekite

COPY ${JOB_TEMPLATE} /job.yaml

CMD ["/kubekite"]
