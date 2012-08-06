//IPC Declaration
@interface CPDistributedMessagingCenter
+ (id)centerNamed:(id)arg1;
- (BOOL)sendMessageName:(id)arg1 userInfo:(id)arg2;
- (void)runServerOnCurrentThread;
- (void)registerForMessageName:(id)arg1 target:(id)arg2 selector:(SEL)arg3;
- (id)sendMessageAndReceiveReplyName:(id)arg1 userInfo:(id)arg2;
@end

@interface HNDDisplayManager
@end

@interface SpringBoard
@end

dispatch_queue_t q;

%hook SBScreenFlash
- (void)flash{
	
}
%end

%hook SBScreenShotter
- (void)saveScreenshot:(BOOL)arg1{
	dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
		CPDistributedMessagingCenter *center;
		center = [CPDistributedMessagingCenter centerNamed:@"com.icenuts.snapshotter"];
		[center sendMessageName: @"com.icenuts.snapshotter.stop" userInfo: nil];
	});
	q = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0);
	dispatch_async(q, ^{
		[NSThread sleepForTimeInterval: 1];
	    %orig;
	});
}
- (void)finishedWritingScreenshot:(id)arg1 didFinishSavingWithError:(id)arg2 context:(void *)arg3{
	CPDistributedMessagingCenter *center;
	center = [CPDistributedMessagingCenter centerNamed:@"com.icenuts.snapshotter"];
	[center sendMessageName: @"com.icenuts.snapshotter.restart" userInfo: nil];
	%orig;
}
%end


%hook HNDDisplayManager
- (id)init{
	CPDistributedMessagingCenter *
		center = [CPDistributedMessagingCenter centerNamed:@"com.icenuts.snapshotter"];
	if(![center doesServerExist]){
		[center runServerOnCurrentThread];
		[center registerForMessageName:@"com.icenuts.snapshotter.stop" target:self selector:@selector(handleAssistiveTouch:userInfo:)];
		[center registerForMessageName:@"com.icenuts.snapshotter.restart" target:self selector:@selector(handleAssistiveTouch:userInfo:)];
	}
	%orig;
}
%new(v@:@@)
- (void) handleAssistiveTouch:(NSString *)name userInfo:(NSDictionary *)userInfo{
	if([name isEqualToString: @"com.icenuts.snapshotter.stop"]){
		NSLog(@"----Big Pie To Bite------");
		[self cleanup];
	}else if([name isEqualToString: @"com.icenuts.snapshotter.restart"]){
		NSLog(@"----Big Pie To make------");
		[self restart];
	}
}
%end


