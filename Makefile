build-all: build-swift build-linux

build-swift:
	swift build -c release

build-linux:
	docker run \
		--rm \
		-v "$(PWD):$(PWD)" \
		-w "$(PWD)" \
		swift:5.5 \
		bash -c 'make build-swift'

format:
	swift format --in-place --recursive .


.PHONY: build-swift build-linux format
