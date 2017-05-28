
BINARY = go-php-pm
VET_REPORT = vet.report
TEST_REPORT = tests.xml
GOARCH = amd64

VERSION?=?
COMMIT=$(shell git rev-parse HEAD)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)

# Symlink into GOPATH
GITHUB_USERNAME=xocas
BUILD_DIR=${GOPATH}/src/github.com/${GITHUB_USERNAME}/${BINARY}
CURRENT_DIR=$(shell pwd)
BUILD_DIR_LINK=$(shell readlink ${BUILD_DIR})

# Setup the -ldflags option for go build here, interpolate the variable values
LDFLAGS = -ldflags "-X main.VERSION=${VERSION} -X main.COMMIT=${COMMIT} -X main.BRANCH=${BRANCH}"

# Build the project
all: clean linux darwin windows

linux: 
#	cd ${BUILD_DIR}; 
	GOOS=linux GOARCH=${GOARCH} go build ${LDFLAGS} -o builds/${BINARY}-linux-${GOARCH} . ; 
#	cd - >/dev/null

darwin:
	GOOS=darwin GOARCH=${GOARCH} go build ${LDFLAGS} -o builds/${BINARY}-darwin-${GOARCH} . ;
	
windows:
	GOOS=windows GOARCH=${GOARCH} go build ${LDFLAGS} -o builds/${BINARY}-windows-${GOARCH}.exe . ;
	
clean:
	@-rm -f ${TEST_REPORT}
	@-rm -f ${VET_REPORT}
	@-rm -f ${BINARY}-*

.PHONY: link linux darwin windows test vet fmt clean