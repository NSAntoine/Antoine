TARGET_CODESIGN = $(shell which ldid)
TARGET_DPKG = 	  $(shell which dpkg)

APP_TMP         = $(TMPDIR)/antoine-build
APP_BUNDLE_PATH 	= $(APP_TMP)/Build/Products/Release-iphoneos/Antoine.app

all:
	xcodebuild -quiet -jobs $(shell sysctl -n hw.ncpu) -project 'Antoine.xcodeproj' -scheme Antoine -configuration Release -arch arm64 -sdk iphoneos -derivedDataPath $(APP_TMP) \
		CODE_SIGNING_ALLOWED=NO DSTROOT=$(APP_TMP)/install ALWAYS_EMBED_SWIFT_STANDARD_LIBRARIES=NO
	ldid -SAntoineEntitlements.xml $(APP_BUNDLE_PATH)/Antoine
	rm -rf build
	mkdir -p build/Payload
	mv $(APP_BUNDLE_PATH) build/Payload

	# make TrollStore tipa
	@ln -sf build/Payload Payload
	zip -r9 build/AntoineTrollStore.tipa Payload
	@rm -rf Payload

	# lol
	find . -name ".DS_Store" -delete
	@cp -r layout build
	@mkdir -p build/layout/Applications
	# make deb
	@mv build/Payload/Antoine.app build/layout/Applications/Antoine.app
	dpkg-deb --build build/layout
	@mv build/layout.deb build/Antoine.deb

	@rm -rf build/Payload
	@rm -rf build/layout

	@echo TrollStore .tipa written to build/AntoineTrollStore.tipa
	@echo Jailbroken .deb written to build/Antoine.deb
