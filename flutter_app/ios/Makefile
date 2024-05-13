PWD=$(shell pwd)
EXOTEL_SDK_VERSION := 1.0.3
GIT_URL := https://github.com/exotel/exotel-voip-sdk-ios/releases/download/$(EXOTEL_SDK_VERSION)/ExotelVoice.-$(EXOTEL_SDK_VERSION).xcframework.zip
EXOTEL_SDK_FILE := exotel-voice-$(EXOTEL_SDK_VERSION)-release.aar

clean : 
	rm -rf ExotelVoice.xcframework
deps: clean
	curl -L $(GIT_URL) -o ExotelVoice.xcframework.zip
	unzip -o ExotelVoice.xcframework.zip
	rm -rf *.zip
	rm -rf __MACOSX

