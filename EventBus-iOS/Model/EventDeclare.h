//
//  EventDeclare.h
//  EventBusPlugin
//
//  Created by 张小刚 on 14-3-14.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString * const EventDeclareSyncPublisher;
extern NSString * const EventDeclareAsyncPublisher;
extern NSString * const EventDeclareSyncSubscriber;
extern NSString * const EventDeclareAsyncSubscriber;

typedef enum {
    EventDeclareTypeSyncPublisher   =   1 << 0,
    EventDeclareTypeAsyncPublisher  =   1 << 1,
    EventDeclareTypeSyncSubscriber  =   1 << 2,
    EventDeclareTypeAsyncSubscriber =   1 << 3,
}EventDeclareType;

/**
 *  收集项目中所有标记实现 <EventBus接口> 的代码，解析后得到的数据模型
 *  类与它的EventType之间的对应关系， 暂时未使用
 */
@interface EventDeclare : NSObject

@property (nonatomic, retain) NSString * className;
@property (nonatomic, assign) int lineNo;
@property (nonatomic, assign) EventDeclareType declareType;
@property (nonatomic, retain) NSString * filePath;

@end
