SDK_VERSION:=

deps:
	make deps -C android

generate-sdk:deps
	mkdir flutter-sdk
	cp -r android ./flutter-sdk
	cp -r ios ./flutter-sdk
	mkdir flutter-sdk/lib
	cp -r lib/Service ./flutter-sdk/lib/
	cp -r lib/ExotelSDKClient.dart ./flutter-sdk/lib/
	tar -czvf flutter-sdk.tar.gz flutter-sdk
	rm -rf flutter-sdk
