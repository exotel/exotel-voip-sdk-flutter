PWD=$(shell pwd)
EXOTEL_SDK_PATH := $(PWD)/exotel-voice-sdk
get_latest_version_cmd := 	curl --silent https://github.com/exotel/exotel-voip-sdk-android/releases | grep -o '\/tag\/.*' | awk -F'[<>]' '{print $$2}' | head -n 1
EXOTEL_SDK_VERSION := $(shell $(get_latest_version_cmd))
GIT_URL := https://github.com/exotel/exotel-voip-sdk-android/releases/download/$(EXOTEL_SDK_VERSION)/exotel-voice-$(EXOTEL_SDK_VERSION)-release.aar
EXOTEL_SDK_FILE := exotel-voice-$(EXOTEL_SDK_VERSION)-release.aar

clean-deps:
	rm -rf $(EXOTEL_SDK_PATH)/exotel-voice-release.aar

deps: clean-deps
	curl -L $(GIT_URL) -o $(EXOTEL_SDK_PATH)/exotel-voice-release.aar