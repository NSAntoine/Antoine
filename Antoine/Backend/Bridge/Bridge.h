//
//  Bridge.h
//  Antoine
//
//  Created by Serena on 23/11/2022
//

// The complete bridge for the ActivityStreamAPI
// including ActivityStreamAPI.h,
// some c functions, and the OSActivityEvent (sub)class(es).

#ifndef Bridge_h
#define Bridge_h

@import Darwin;

#include "ActivityStreamAPI.h"
#include "ActivityEvents/ActivityEvents.h"

os_activity_stream_t *os_activity_stream_for_pid(pid_t pid,
                                                 os_activity_stream_flag_t flags,
                                                 os_activity_stream_block_t stream_block);

void os_activity_stream_resume(os_activity_stream_t stream);
void os_activity_stream_cancel(os_activity_stream_t stream);

void os_activity_stream_set_event_handler(os_activity_stream_t stream,
                                          os_activity_stream_event_block_t block);

NSString * _Nonnull antoineGetBuildDate() {
    return @__DATE__;
}

NSString * _Nonnull antoineGetBuildTime() {
    return @__TIME__;
}

/*
 These are not required anymore, due to now using the OSActivityEvent subclasses,
 however they're going to be below, in case they're ever needed:
 (btw, os_log_copy_formatted_message for some reason would just return garbage)
 
 uint8_t os_log_get_type(os_log_message_t);
 void proc_name(int pid, char *buf, int size);
 char *os_log_copy_formatted_message(struct os_log_message_s message);
 */

#endif /* Bridge_h */
