//
//  OSActivityEvent.h
//  Antoine
//
//  Created by Serena on 01/12/2022
//
	

#ifndef OSActivityEvent_h
#define OSActivityEvent_h
@import Foundation;

NS_ASSUME_NONNULL_BEGIN

/// Describes a basic activity event reported by LoggingSupport.
/// The implementation of this class resides in the LoggingSupport framework.
@interface OSActivityEvent : NSObject

@property (readonly, nonatomic) NSUInteger activityID;
@property (copy, nonatomic) NSString *eventMessage;
@property (readonly, nonatomic) NSUInteger eventType;
@property (readonly, nonatomic) NSUInteger machTimestamp;
@property (readonly, nonatomic) NSUInteger parentActivityID;
@property (readonly, nonatomic) BOOL persisted;
@property (readonly, copy, nonatomic) NSString *process;
@property (readonly, nonatomic) int processID;
@property (readonly, copy, nonatomic) NSString *processImagePath;
@property (readonly, copy, nonatomic) NSUUID *processImageUUID;
@property (readonly, nonatomic) NSUInteger processUniqueID;
@property (readonly, copy, nonatomic) NSString *sender;
@property (readonly, copy, nonatomic) NSString *senderImagePath;
@property (readonly, copy, nonatomic) NSUUID *senderImageUUID;
@property (readonly, nonatomic) NSUInteger threadID;
@property (readonly, nonatomic) struct timeval timeGMT;
@property (readonly, copy, nonatomic) NSDate *timestamp;
@property (readonly, copy, nonatomic) NSTimeZone *timezone;
@property (retain, nonatomic) NSString *timezoneName;
@property (readonly, nonatomic) NSUInteger traceID;
@property (readonly, nonatomic) struct timezone tz;

+(id)activityEventFromStreamEntry:(struct os_activity_stream_entry_s *)arg0 ;
-(BOOL)persisted;
-(id)description;
-(id)properties;
-(void)_addProperties:(id)arg0 ;
-(id)_initWithProperties:(id)arg0;
-(void)fillFromStreamEntry:(struct os_activity_stream_entry_s *)arg0 eventMessage:(char *)arg1 persisted:(BOOL)arg2 ;

@end

NS_ASSUME_NONNULL_END

#endif /* OSActivityEvent_h */
