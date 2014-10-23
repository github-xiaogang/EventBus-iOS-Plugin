//
//  PublisherCell.m
//  EventBusPlugin
//
//  Created by 张小刚 on 14-3-14.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

NSString * const PublisherCellId = @"PulisherCellId";

#import "PublisherCell.h"
#import "EventAction.h"

@interface PublisherCell ()
{
}
@property (weak) IBOutlet NSTextField *eventNamLabel;
@property (weak) IBOutlet NSTextField *fileNameLabel;
@property (weak) IBOutlet NSView *backgroudView;

@end


@implementation PublisherCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    [_backgroudView setWantsLayer:YES]; //动画
    _backgroudView.layer.backgroundColor = [[NSColor lightGrayColor] CGColor];
    [_backgroudView setAlphaValue:0.0f];
}

+ (CGFloat)heightForData: (id)data
{
    return 54.0f;
}

+ (PublisherCell *)newInstance
{
    NSArray * topObjects = nil;
    if(![[NSBundle bundleForClass:[self class]] loadNibNamed:@"PublisherCell" owner:nil topLevelObjects:&topObjects]){
        NSLog(@"load cell error");
    }
    PublisherCell * cell = nil;
    for (id object in topObjects) {
        if([object isKindOfClass:[PublisherCell class]]){
            cell = object;
            break;
        }
    }
    return cell;
}

- (void)setData:(id)data
{
    EventAction * action = data;
    self.eventNamLabel.stringValue = action.eventName;
    self.fileNameLabel.stringValue = [NSString stringWithFormat:@"%@ %ld",[action.filePath lastPathComponent],action.lineNo];
}

- (void)mouseDown:(NSEvent *)theEvent
{
    if((theEvent.modifierFlags & NSControlKeyMask) == NSControlKeyMask){
        // single click with ctrl
        if(_delegate && [_delegate respondsToSelector:@selector(seeSourceRequestForCell:)]){
            [_delegate seeSourceRequestForCell:self];
        }
    }else{
        // single click
        if(_delegate && [_delegate respondsToSelector:@selector(codeCompletionRequestForCell:)]){
            [_delegate codeCompletionRequestForCell:self];
        }
    }
}

- (void)beginAnimate
{
    [_backgroudView.animator setAlphaValue: 0.7];
}
- (void)endAnimate
{
    [_backgroudView.animator setAlphaValue: 0.0];
}

@end






