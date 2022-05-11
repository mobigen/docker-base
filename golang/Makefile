# Copyright (c) 2021 Mobigen JBLIM. All Rights Reserved.

################################################################################
##                             PROGRAM PARAMS                                 ##
################################################################################

# program name and version info 
TARGET := cache-server
VERSION := v1.0.8
IMAGE ?= repo.iris.tools/iris/$(TARGET):$(VERSION)

################################################################################

GO ?= $(shell command -v go 2> /dev/null)
MACHINE = $(shell uname -m)
GOFLAGS ?= $(GOFLAGS:)
BUILD_TIME := $(shell date -u +%Y%m%d.%H%M%S)
BUILD_HASH := $(shell git rev-parse --short HEAD)

################################################################################

MODULE_NAME := $(shell head -1 go.mod | awk '{print $$2}')
LDFLAGS += -X '$(MODULE_NAME)/common/appdata.Name=$(TARGET)'
LDFLAGS += -X '$(MODULE_NAME)/common/appdata.Version=$(VERSION)'
LDFLAGS += -X '$(MODULE_NAME)/common/appdata.BuildHash=$(BUILD_HASH)'

################################################################################
##                             Docker PARAMS                                 ##
################################################################################

## Docker Build Versions
DOCKER_BUILD_IMAGE = golang:1.17.3-alpine3.15
DOCKER_FRONT_BUILD_IMAGE=node:16
DOCKER_BASE_IMAGE = alpine:3.15
GO_MOD_HASH=$(shell git log -p -- go.mod | head -n 1 | awk '{print $$1}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
PACKAGE_HASH=$(shell git log -p -- frontend/package.json | head -n 1 | awk '{print $$1}' | sed -r "s/\x1B\[([0-9]{1,3}(;[0-9]{1,2})?)?[mGK]//g")
CHECK_IMAGE=$(shell docker images | grep '$(TARGET)-buildbase' | grep $(GO_MOD_HASH))
CHECK_FRONT_IMAGE=$(shell docker images | grep '$(TARGET)-frontbase' | grep $(PACKAGE_HASH))

DOCKER_BUILD_BASE_IMAGE=$(TARGET)-buildbase:$(GO_MOD_HASH)
DOCKER_FRONT_BUILD_BASE_IMAGE=$(TARGET)-frontbase:$(PACKAGE_HASH)

# Binaries.
TOOLS_BIN_DIR := $(abspath bin)
GO_INSTALL = ./scripts/go_install.sh

MOCKGEN_VER := v1.6.0
MOCKGEN_BIN := mockgen
MOCKGEN := $(TOOLS_BIN_DIR)/$(MOCKGEN_BIN)-$(MOCKGEN_VER)

GOCOV_VER := latest
GOCOV_BIN := gocov
GOCOV_GEN := $(TOOLS_BIN_DIR)/$(GOCOV_BIN)

GOCOV-HTML_VER := latest
GOCOV-HTML_BIN := gocov-html
GOCOV-HTML_GEN := $(TOOLS_BIN_DIR)/$(GOCOV-HTML_BIN)

OUTDATED_VER := master
OUTDATED_BIN := go-mod-outdated
OUTDATED_GEN := $(TOOLS_BIN_DIR)/$(OUTDATED_BIN)

GOLINT_VER := master
GOLINT_BIN := golint
GOLINT_GEN := $(TOOLS_BIN_DIR)/$(GOLINT_BIN)

SWAG_BIN := swag
SWAG_VER := latest
SWAGDOC := $(TOOLS_BIN_DIR)/$(SWAG_BIN)

SONAR_SCANNER_BIN := sonar-scanner
SONAR_SCANNER_VER := 4.7.0.2747
SONAR_SCANNER := $(TOOLS_BIN_DIR)/sonar/bin/$(SONAR_SCANNER_BIN)

JUNIT_REPORT_BIN := go-junit-report
JUNIT_REPORT_VER := latest
JUNIT_REPORT := $(TOOLS_BIN_DIR)/$(JUNIT_REPORT_BIN)

export GO111MODULE=on

## Checks the code style, tests, builds and bundles.
all: check-style dist

## Runs govet and gofmt against all packages.
.PHONY: check-style
check-style: govet lint
	@echo Checking for style guide compliance

## Runs lint against all packages.
.PHONY: lint
lint: $(GOLINT_GEN)
	@echo Running lint
	$(GOLINT_GEN) -set_exit_status ./...
	@echo lint success

## Runs govet against all packages.
.PHONY: vet
govet:
	@echo Running govet
	$(GO) vet ./...
	@echo Govet success

## Builds and thats all :)
.PHONY: dist
dist:	build

.PHONY: build
build: ## Build binary
	@echo Building $(TARGET)
	GOOS=linux GOARCH=amd64 CGO_ENABLED=1 $(GO) build -ldflags "$(LDFLAGS)" -gcflags all=-trimpath=$(PWD) -asmflags all=-trimpath=$(PWD) \
	     -a -installsuffix cgo -o build/bin/$(TARGET) main.go

.PHONY: image
image: base frontend deploy
base:  ## Build the docker image 
	@if [ -z "${CHECK_IMAGE}" ]; then \
		echo "Docker Build Image"; \
		docker build \
		--build-arg DOCKER_BUILD_IMAGE=$(DOCKER_BUILD_IMAGE) \
		. -f build/Dockerfile.Build -t $(DOCKER_BUILD_BASE_IMAGE) \
		--no-cache; \
	else \
		echo "Already Exists Base Stage Image"; \
	fi 

.PHONY: frontend
frontend: ## Build Frontend image
	@if [ -z "${CHECK_FRONT_IMAGE}" ]; then \
		echo "Docker Front Build Image"; \
		docker build \
		--build-arg DOCKER_FRONT_BUILD_IMAGE=$(DOCKER_FRONT_BUILD_IMAGE) \
		. -f build/Dockerfile.Frontend -t $(DOCKER_FRONT_BUILD_BASE_IMAGE) \
		--no-cache; \
	else \
		echo "Already Exists Front Base Stage Image"; \
	fi 

deploy:  ## Build the docker image 
	@echo Building $(TARGET) Docker Image
	docker build \
	--build-arg DOCKER_BUILD_IMAGE=$(DOCKER_BUILD_BASE_IMAGE) \
	--build-arg DOCKER_FRONT_BUILD_IMAGE=$(DOCKER_FRONT_BUILD_BASE_IMAGE) \
	--build-arg DOCKER_BASE_IMAGE=$(DOCKER_BASE_IMAGE) \
	. -f build/Dockerfile -t $(IMAGE) \
	--no-cache

.PHONY: swag
swag: $(SWAGDOC)
	$(SWAGDOC) init --parseDependency --parseInternal --exclude \
		.cache,bin,build,configs,common,db,docs,gateway,internal,mocks,scripts,tools

# Generate mocks from the interfaces.
.PHONY: mocks
mocks:  $(MOCKGEN)
	go generate ./...

.PHONY: verify-mocks
verify-mocks:  $(MOCKGEN) mocks
	@if !(git diff --quiet HEAD); then \
		echo "generated files are out of date, run make mocks"; exit 1; \
	fi

.PHONY: test
test: mocks $(GOLINT_GEN) $(SONAR_SCANNER) $(JUNIT_REPORT)
	while true; do \
		$(GO) test ./... -json > report.json; \
		$(GOLINT_GEN) ./... > golint-report.out; \
		$(GO) test ./... -v -covermode=atomic -coverprofile=coverage.out 2>&1 | $(JUNIT_REPORT) -set-exit-code > report.xml; \
		$(SONAR_SCANNER) -Dsonar.projectKey=iris-cache-server \
			-Dsonar.host.url=https://sonarqube.iris.tools \
			-Dsonar.login=3122f0b32c423ecca7112b61339e1b738aafa091 \
			-Dsonar.sourceEncoding=UTF-8 \
			-Dsonar.language=go \
			-Dsonar.exclusions= \
			-Dsonar.sources=. \
			-Dsonar.tests=. \
			-Dsonar.go.coverage.reportPaths=coverage.out \
			-Dsonar.go.tests.reportPaths=report.json \
			-Dsonar.go.golint.reportPaths=golint-report.out \
			-Dsonar.test.inclusions=**/*_test.go; \
		break; \
	done

.PHONY: report
report: $(JUNIT_REPORT)
	while true; do \
  		break; \
  	done
#  		$(JUNIT_REPORT) go test -v -tags="unit integration" -covermode=atomic -coverprofile=coverage.out ./cmd/... ./common/... 2>&1 | go-junit-report -set-exit-code > report.xml

.PHONY: gocov 
gocov: $(GOCOV_GEN) ## Runs gocov
	$(GOCOV_GEN) test ./... | gocov-html > cov-out.html 

.PHONY: check-modules
check-modules: $(OUTDATED_GEN) ## Check outdated modules
	@echo Checking outdated modules
	$(GO) list -u -m -json all | $(OUTDATED_GEN) -update -direct


## Clean Cache
.PHONY: clean
clean: 
	while true; do \
		go clean -i -cache -testcache -modcache; \
		rm -rf coverage.out golint-report.out report.json report.xml; \
		break; \
	done

## --------------------------------------
## Tooling Binaries
## --------------------------------------

$(MOCKGEN): ## Build mockgen.
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/golang/mock/mockgen $(MOCKGEN_BIN) $(MOCKGEN_VER)

$(OUTDATED_GEN): ## Build go-mod-outdated.
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/psampaz/go-mod-outdated $(OUTDATED_BIN) $(OUTDATED_VER)

$(GOLINT_GEN): ## Build golint.
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) golang.org/x/lint/golint $(GOLINT_BIN) $(GOLINT_VER)

$(SWAGDOC): ## Swagger Documents
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/swaggo/swag/cmd/swag $(SWAG_BIN) $(SWAG_VER)

## gocov, gocov-html.
$(GOCOV_GEN): 
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/axw/gocov/gocov $(GOCOV_BIN) $(GOCOV_VER) && \
		  GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/matm/gocov-html $(GOCOV-HTML_BIN) $(GOCOV-HTML_VER)

$(SONAR_SCANNER):
	while true; do \
		wget -O bin/sonar-scanner.zip \
			https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.7.0.2747-linux.zip; \
		unzip bin/sonar-scanner.zip -d bin;\
		mv bin/sonar-scanner-4.7.0.2747-linux bin/sonar; \
		sed -i 's/use_embedded_jre=true/use_embedded_jre=false/g' bin/sonar/bin/sonar-scanner; \
		break; \
	done

$(JUNIT_REPORT): ## make junit report result
	GOBIN=$(TOOLS_BIN_DIR) $(GO_INSTALL) github.com/jstemmer/go-junit-report $(JUNIT_REPORT_BIN) $(JUNIT_REPORT_VER)
