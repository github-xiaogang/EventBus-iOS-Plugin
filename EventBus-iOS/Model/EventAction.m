//
//  EventAction.m
//  EventBusPlugin
//
//  Created by 张小刚 on 14-3-14.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "EventAction.h"

@implementation EventAction

- (NSString *)description
{
    NSMutableString * result = [NSMutableString string];
    [result appendFormat:@"%@ ---------->  %@ %ld",self.eventName,[self.filePath lastPathComponent],self.lineNo];
    return result;
}

@end
