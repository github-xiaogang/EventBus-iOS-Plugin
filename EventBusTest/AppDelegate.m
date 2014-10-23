//
//  AppDelegate.m
//  EventBusTest
//
//  Created by 张小刚 on 14-3-14.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "AppDelegate.h"
#import "EventWindowController.h"
#import "XToDoModel.h"


#pragma mark -----------------   EventBusTest 是一个普通cocoa程序，测试使用，省得每次都要重启Xcode   ----------------

@interface AppDelegate ()
{
    EventWindowController * _eventWindowController;
}

@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    // Insert code here to initialize your application
    _eventWindowController = [[EventWindowController alloc] initWithWindowNibName:@"EventWindowController"];
    // set your project path here (full path)
    NSString *projectPath = @"/Users/zhang/github/EventBus-iOS-Plugin";
    NSAssert(projectPath, @"please set projectPath");
    [_eventWindowController setProjectPath:projectPath];
    [_eventWindowController.window makeKeyAndOrderFront:nil];
}

@end



















