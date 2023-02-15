//
//  OSActivityStreamDelegate.h
//  Antoine
//
//  Created by Serena on 09/12/2022
//
	

#ifndef OSActivityStreamDelegate_h
#define OSActivityStreamDelegate_h
@import Foundation;

@class OSActivityStream;

NS_ASSUME_NONNULL_BEGIN

@protocol OSActivityStreamDelegate<NSObject>
@required
- (BOOL) activityStream:(OSActivityStream *)stream results:(nullable NSArray<OSActivityEvent *> *)results;

@optional
- (void) streamDidStart:(OSActivityStream *)stream;
- (void) streamDidFail:(OSActivityStream *)stream error:(NSError *)error;
- (void) streamDidStop:(OSActivityStream *)stream;

@end

NS_ASSUME_NONNULL_END

#endif /* OSActivityStreamDelegate_h */
