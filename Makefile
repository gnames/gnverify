VERSION = $(shell git describe --tags)
VER = $(shell git describe --tags --abbrev=0)
DATE = $(shell date -u '+%Y-%m-%d_%H:%M:%S%Z')
FLAG_MODULE = GO111MODULE=on
FLAGS_SHARED = $(FLAG_MODULE) CGO_ENABLED=0 GOARCH=amd64
FLAGS_LD=-ldflags "-X github.com/gnames/gnverify.Build=${DATE} \
                  -X github.com/gnames/gnverify.Version=${VERSION}"
GOCMD=go
GOINSTALL=$(GOCMD) install $(FLAGS_LD)
GOBUILD=$(GOCMD) build $(FLAGS_LD)
GOCLEAN=$(GOCMD) clean
GOGENERATE=$(GOCMD) generate
GOGET = $(GOCMD) get

all: install

test: deps install
	@echo Run tests
	$(FLAG_MODULE) go test ./...

deps:
	@echo Download go.mod dependencies
	$(GOCMD) mod download; \
	$(GOGENERATE)

tools: deps
	@echo Installing tools from tools.go
	@cat gnverify/tools.go | grep _ | awk -F'"' '{print $$2}' | xargs -tI % go install %

build:
	$(GOGENERATE)
	cd gnverify; \
	$(GOCLEAN); \
	$(FLAGS_SHARED) $(GOBUILD);

release: dockerhub
	@echo Building releases for Linux, Mac, Windows
	cd gnverify; \
	$(GOCLEAN); \
	$(FLAGS_SHARED) GOOS=linux $(GOBUILD); \
	tar zcvf /tmp/gnverify-${VER}-linux.tar.gz gnverify; \
	$(GOCLEAN); \
	$(FLAGS_SHARED) GOOS=darwin $(GOBUILD); \
	tar zcvf /tmp/gnverify-${VER}-mac.tar.gz gnverify; \
	$(GOCLEAN); \
	$(FLAGS_SHARED) GOOS=windows $(GOBUILD); \
	zip -9 /tmp/gnverify-${VER}-win-64.zip gnverify.exe; \
	$(GOCLEAN);

install:
	$(GOGENERATE)
	cd gnverify; \
	$(FLAGS_SHARED) $(GOINSTALL);

docker: build
	docker build -t gnames/gnverify:latest -t gnames/gnverify:$(VERSION) .; \
	cd gnverify; \
	$(GOCLEAN);

dockerhub: docker
	docker push gnames/gnverify; \
	docker push gnames/gnverify:$(VERSION)

