VERSION = $(shell git describe --tags)
VER = $(shell git describe --tags --abbrev=0)
DATE = $(shell date -u '+%Y-%m-%d_%H:%M:%S%Z')
FLAG_MODULE = GO111MODULE=on
FLAGS_SHARED = $(FLAG_MODULE) CGO_ENABLED=0 GOARCH=amd64
FLAGS_LD=-ldflags "-X gitlab.com/gogna/gnverify.Build=${DATE} \
                  -X gitlab.com/gogna/gnverify.Version=${VERSION}"
GOCMD=go
GOINSTALL=$(GOCMD) install $(FLAGS_LD)
GOBUILD=$(GOCMD) build $(FLAGS_LD)
GOCLEAN=$(GOCMD) clean
GOGENERATE=$(GOCMD) generate
GOGET = $(GOCMD) get

all: install

test: deps install
	$(FLAG_MODULE) go test ./...

deps:
	$(GOCMD) mod download; \
	$(GOGENERATE)

build:
	$(GOGENERATE)
	cd gnverify; \
	$(GOCLEAN); \
	$(FLAGS_SHARED) $(GOBUILD);

release:
	cd gnverify; \
	$(GOCLEAN); \
	$(FLAGS_SHARED) GOOS=linux $(GOBUILD); \
	tar zcvf /tmp/gnverify-${VER}-linux.tar.gz gnverify; \
	$(GOCLEAN);

install:
	$(GOGENERATE)
	cd gnverify; \
	$(FLAGS_SHARED) $(GOINSTALL);

