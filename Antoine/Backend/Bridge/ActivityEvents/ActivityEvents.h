//
//  ActivityEvents.h
//  Antoine
//
//  Created by Serena on 01/12/2022
//
	

#ifndef ActivityEvents_h
#define ActivityEvents_h

// TODO: - Maaaaybe incorporate OSActivityStream and OSActivityStreamDelegate??

#include "OSActivityEvent.h"
#include "OSActivityLogMessageEvent.h"
#include "OSActivityStreamDelegate.h"
#include "OSActivityStream.h"

@interface UIKeyboardImpl : NSObject
+ (UIKeyboardImpl *)sharedInstance;
+ (UIKeyboardImpl *)activeInstance;

- (void)showKeyboardIfNeeded;
@end

#endif /* ActivityEvents_h */
