//
//  OSActivityStream.h
//  Antoine
//
//  Created by Serena on 09/12/2022
//
	

#ifndef OSActivityStream_h
#define OSActivityStream_h

typedef NS_OPTIONS(NSUInteger, OSActivityStreamOption) {
    OSActivityStreamOptionProcessOnly = 0x00000001,
    OSActivityStreamOptionTracePayload = 0x00000002,
    OSActivityStreamOptionLiveStream = 0x00000004,
    OSActivityStreamOptionPreciseTimestamps = 0x00000008,

    OSActivityStreamOptionTypeInfo = 0x00000100,
    OSActivityStreamOptionTypeDebug = 0x00000200,

    OSActivityStreamOptionNoPrivateData = 0x80000000,
};

typedef NS_OPTIONS(NSUInteger, OSActivityEventFilter) {
    OSActivityEventFilterActivities = 0x000001,
    OSActivityEventFilterTraceMessages = 0x000002,
    OSActivityEventFilterLogMessages = 0x000004,
    
    OSActivityEventFilterDefault =
    OSActivityEventFilterActivities |
    OSActivityEventFilterTraceMessages |
    OSActivityEventFilterLogMessages,
};

NS_ASSUME_NONNULL_BEGIN
// reverse engineered.. sigh
@interface OSActivityStream : NSObject

-(id)init;
-(void)start;
-(void)stop;
-(void)addProcessID:(pid_t)arg0;

@property (nonatomic, nullable, weak, nonatomic) id<OSActivityStreamDelegate> delegate;
@property (nonatomic, assign) OSActivityStreamOption options;
@property (nonatomic, assign) OSActivityEventFilter eventFilter;

@end

NS_ASSUME_NONNULL_END

#endif /* OSActivityStream_h */
