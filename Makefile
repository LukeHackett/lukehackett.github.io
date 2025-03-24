WORK_DIR := $(shell pwd)
SRC_DIR := $(WORK_DIR)
PUBLIC_DIR := $(WORK_DIR)/public
RESOURCES_DIR := $(WORK_DIR)/resources

.PHONY: clean
clean:
	rm -rf .hugo_build.lock
	rm -rf $(PUBLIC_DIR)
	rm -rf $(RESOURCES_DIR)

.PHONY: run
run: clean
	hugo server --openBrowser --gc --cleanDestinationDir --forceSyncStatic --ignoreCache --noHTTPCache

.PHONY: build
build: clean
	hugo build --gc --minify