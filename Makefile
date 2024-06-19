SDK_VERSION:=1.0.8

clean:
	rm -rf SDK/*
android-deps:
	make deps -C flutter_app/android

ios-deps:
	make deps -C flutter_app/ios

generate-sdk: clean android-deps ios-deps
	mkdir SDK/flutter-sdk
	cp -r flutter_app/android ./SDK/flutter-sdk
	cp -r flutter_app/ios ./SDK/flutter-sdk
	mkdir SDK/flutter-sdk/lib
	cp -r flutter_app/lib/Service ./SDK/flutter-sdk/lib/
	cp -r flutter_app/lib/exotelSDK ./SDK/flutter-sdk/lib/
	cd SDK && tar -czvf flutter-sdk-v${SDK_VERSION}.tar.gz ./flutter-sdk/
	rm -rf SDK/flutter-sdk
