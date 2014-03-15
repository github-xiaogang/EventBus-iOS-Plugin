//
//  EventBus.m
//  EventBus-iOS
//
//  Created by 张小刚 on 14-3-14.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "EventBus.h"
#import "EventWindowController.h"
#import "XToDoModel.h"
@interface EventBus()
{
    NSBundle * _bundle;
    EventWindowController * _eventWindowController;
}
@end

@implementation EventBus

static EventBus * sharedPlugin = nil;

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if (sharedPlugin == nil && [currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[self alloc] initWithBundle:plugin];
            NSLog(@"------- Plugin Demo Loaded --------------");
        });
    }
}

// 添加操作Menu

- (id)initWithBundle:(NSBundle *)plugin {
    self = [super init];
    if (self) {
        _bundle = plugin;
        //insert a menuItem to MainMenu "Window"
        NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"View"];
        if (menuItem) {
            [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
            NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"EventBus-iOS"
                                                                    action:@selector(action)
                                                             keyEquivalent:@"e"];
            [actionMenuItem setKeyEquivalentModifierMask:NSControlKeyMask];
            [actionMenuItem setTarget:self];
            [[menuItem submenu] addItem:actionMenuItem];
        }
    }
    return self;
}

 - (void)action
{
     if(_eventWindowController.window.isVisible){
         [_eventWindowController close];
     }else{
         NSString *projectPath = [[[XToDoModel currentWorkspaceDocument].workspace.representingFilePath.fileURL
                                  path]
                                 stringByDeletingLastPathComponent];
         if(_eventWindowController == nil){
             _eventWindowController = [[EventWindowController alloc] initWithWindowNibName:@"EventWindowController"];
             _eventWindowController.window.title = @"EventBus-iOS";
         }
         NSWindowController * currentWindowController = [[NSApp mainWindow] windowController];
         if(currentWindowController) [_eventWindowController setParentWindowController:currentWindowController];
         [_eventWindowController setProjectPath:projectPath];
         [_eventWindowController.window makeKeyAndOrderFront:nil];
     }
 }


@end








