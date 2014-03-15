//
//  EventAction.h
//  EventBusPlugin
//
//  Created by 张小刚 on 14-3-14.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
    EventActionTypePublish = 1,
    EventActionTypeSubscribe = 2,
}EventActionType;

/**
 * 收集项目中所有使用到 (EVENT_PUBLISH,EVENT_SUBSCIBE等宏) 的代码，解析后得到的数据模型
 */
@interface EventAction : NSObject

@property (nonatomic, retain) NSString * filePath;
@property (nonatomic, assign) NSUInteger lineNo;
@property (nonatomic, assign) EventActionType actionType;
@property (nonatomic, retain) NSString * eventName;

@end
