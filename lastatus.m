#include <os/log.h>
#import <Foundation/Foundation.h>

int MKBGetDeviceLockState(CFDictionaryRef options);

#define kMobileKeyBagDeviceIsUnlocked 0

#ifdef DEBUG
#define LOG_DEBUG(fmt, ...) printf(fmt, __VA_ARGS__)
#else
#define LOG_DEBUG(fmt, ...) os_log_debug(la_log_handle(), fmt, __VA_ARGS__)
#endif

os_log_t la_log_handle(void) {
	static os_log_t log_handle = nil;
	static dispatch_once_t onceToken = 0;
	if (onceToken != -1) {
		dispatch_once(&onceToken, ^{
			log_handle = os_log_create("com.apple.LocalAuthentication", "lastatus");
		});
	}
	return log_handle;
}

int main(int argc, char *argv[]) {
	@autoreleasepool {
		if (argc != 2) {
			LOG_DEBUG("Init error", NULL);
			return EXIT_FAILURE;
		}

		int uid = atoi(argv[1]);
		LOG_DEBUG("Using id %d", uid);

    /* Why we use objc just because of this? */
		NSMutableDictionary *options = [NSMutableDictionary new];
		if (!options) {
			LOG_DEBUG("Options error", NULL);
			return EXIT_FAILURE;
		}
		options[@"ExtendedDeviceLockState"] = @YES;
#if TARGET_OS_OSX
		/* macOS requires a DeviceHandle for the user context. On embedded platforms this
		 * option is generally invalid, so we only set it for macOS builds. */
		options[@"DeviceHandle"] = uid ? @(uid) : @(4); /* 4: _uucp */
#endif

		int lock_state = MKBGetDeviceLockState((__bridge CFDictionaryRef)options);
		if (lock_state != kMobileKeyBagDeviceIsUnlocked) {
			/* This program historically treats lock state 7 as an "acceptable" non-failure state. */
			if (lock_state != 7) {
				LOG_DEBUG("Result: %d", lock_state);
				return EXIT_FAILURE;
			}
		}
	}

	return EXIT_SUCCESS;
}
