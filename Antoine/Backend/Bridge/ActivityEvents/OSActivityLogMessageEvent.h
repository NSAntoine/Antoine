//
//  OSActivityLogMessageEvent.h
//  Antoine
//
//  Created by Serena on 01/12/2022
//
	

#ifndef OSActivityLogMessageEvent_h
#define OSActivityLogMessageEvent_h

@import Foundation;

#import "OSActivityEvent.h"

/// A subclass of OSActivityEvent,
/// with additional fields suitable for an informational log message.
@interface OSActivityLogMessageEvent : OSActivityEvent

@property (readonly, copy, nonatomic) NSString * _Nullable category;
@property (readonly, nonatomic) unsigned char messageType;
@property (readonly, nonatomic) NSUInteger senderProgramCounter;
@property (readonly, copy, nonatomic) NSString * _Nullable subsystem;

-(instancetype _Nonnull)initWithEntry:(struct os_activity_stream_entry_s * _Nonnull)arg0 ;
//-(void)_addProperties:(id)arg0 ;

@end

#endif /* OSActivityLogMessageEvent_h */
