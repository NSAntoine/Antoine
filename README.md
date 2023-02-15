# Antoine
## *The iOS Console.app*
An OSLog UI for iOS & iPadOS devices, Antoine allows you to view System Logs in real time, with the ability to filter logs by process, message, type, etc, as well additional stream options.

If you have used Console.app on macOS before, think of this as the iOS equivalent.

### Features
- Stream Logs
- Relatively nice UI
- Filter by a variety of ways, such as message, process, category, subsystem, and pid.
- View variety of information relating to a log, such as when it was made, it's type, etc
- Keep app streaming in the background (needs always-on location authorization)

## What can this be installed on?
Any iOS 13+ device that is jailbroken or uses TrollStore, basically any device where you can get arbitrary entitlements

## How does it work?
Antoine works by using a private System framework, LoggingSupport.framework, a framework containing C functions & structs to stream System log messages, Antoine does the following:
- Create a ``os_activity_stream_block_t`` closure that handles incoming messages, the closure provides 2 arguments (an `os_activity_stream_entry_t` entry, and an error code number as an `int`), the closure calls a delegate method to tell the user of the class that a new message was recieved
- Create a `os_activity_stream_event_block_t` closure that handles when new major events (not messages) occur in the stream (such as when the stream starts, stops, fails, etc), this closure calls a delete method that is used to update the application UI
- Create the activity stream with `os_activity_stream_for_pid`, the the `os_activity_stream_for_pid` takes in 3 arguments: the pid of the process, since we want logs of all processes, we pass in `-1`, the second argument is a set of stream flags to pass in, see `os_activity_stream_flag_t` in `ActivityStream.h`, the third argument is the `os_activity_stream_block_t` we created earlier
- Call `os_activity_stream_set_event_handler` on the activity stream & the block handler, to be notified of when new events occur
- Call `os_activity_stream_resume` to start the activity stream.

After we set up the activity stream to start, we update the UI, a view controller containing a UICollectionView.

Whenever we want to pause the activity stream, we call `os_activity_stream_cancel` on the activity stream.

## To Do / Current issues 
- Background Mode currently works by pinging location, should migrate this to instead play a quiet Audio sound
- Stream View Controller should be made to look prettier

## Credits
- [Serena](https://twitter.com/CoreSerena): Developer, creator of app
- [saagarjha](https://federated.saagarjha.com/users/saagar): Help with using os_log_* functions
- [Flower](https://twitter.com/flowerible): Icon designer
# Antoine
