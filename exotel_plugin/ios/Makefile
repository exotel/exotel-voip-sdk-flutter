PWD=$(shell pwd)
get_latest_version_cmd := curl --silent https://github.com/exotel/exotel-voip-sdk-ios/releases | grep -o '\/tag\/.*' | awk -F'[<>]' '{print $$2}' | head -n 1
EXOTEL_SDK_VERSION := $(shell $(get_latest_version_cmd))
GIT_URL := https://github.com/exotel/exotel-voip-sdk-ios/releases/download/$(EXOTEL_SDK_VERSION)/ExotelVoice-$(EXOTEL_SDK_VERSION).tar.gz

clean :
	rm -rf ExotelVoice.xcframework
deps: clean
	curl -L $(GIT_URL) -o ExotelVoice.tar.gz
	tar -xzf ExotelVoice.tar.gz
	rm -rf *.tar.gz
	rm -rf __MACOSX