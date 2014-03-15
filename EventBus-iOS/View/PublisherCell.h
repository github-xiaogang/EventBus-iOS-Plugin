//
//  PublisherCell.h
//  EventBusPlugin
//
//  Created by 张小刚 on 14-3-14.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import <Cocoa/Cocoa.h>

extern NSString * const PublisherCellId;
@protocol PublisherCellDelegate;

/**
 * 自定义列表单元
 */
@interface PublisherCell : NSView
@property (nonatomic, assign) id<PublisherCellDelegate> delegate;

+ (PublisherCell *)newInstance;
+ (CGFloat)heightForData: (id)data;
- (void)setData : (id)data;

- (void)beginAnimate;
- (void)endAnimate;

@end

@protocol PublisherCellDelegate <NSObject>

- (void)codeCompletionRequestForCell: (PublisherCell *)cell;
- (void)seeSourceRequestForCell: (PublisherCell *)cell;

@end
