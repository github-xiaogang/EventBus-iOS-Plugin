//
//  EventWindowController.m
//  PluginDemo
//
//  Created by 张小刚 on 14-3-14.
//  Copyright (c) 2014年 duohuo. All rights reserved.
//

#import "EventWindowController.h"
#import "XToDoModel.h"
#import "RegexKitLite.h"
#import "EventDeclare.h"
#import "EventAction.h"
#import "PublisherCell.h"

@interface EventWindowController ()<NSTableViewDataSource,NSTableViewDelegate,NSWindowDelegate,PublisherCellDelegate>
{
    NSArray * _list;
    NSArray * _searchedList;
    NSArray * _eventDeclareList;
    NSArray * _eventActionList;
    NSArray * _excludeFileNames;
}
@property (weak) IBOutlet NSTableView *tableview;
@property (weak) IBOutlet NSSearchField *searchTextfield;

@end

@implementation EventWindowController

- (void)windowDidLoad
{
    [super windowDidLoad];
    self.window.level=NSFloatingWindowLevel;
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
    //exclude EventBus related files
    _excludeFileNames = @[@"EventBus.h",@"EventBus.m",@"EventPublisher.h",@"EventSubscriber.h"];
}

- (void)reloadData
{
    [self loadData];
    [self cookForShow];
    [_tableview reloadData];
}

- (void)cookForShow
{
    NSMutableArray * publishList = [NSMutableArray array];
    for (EventAction * action in _eventActionList) {
        if(action.actionType == EventActionTypePublish){
            [publishList addObject:action];
        }
    }
    if(publishList.count == 0) publishList = nil;
    _list = publishList;
    _searchedList = [self sortedArray:_list];
}

#pragma mark -----------------   table view datasource & delegate   ----------------
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    return _searchedList.count;
}

- (CGFloat)tableView:(NSTableView *)tableView heightOfRow:(NSInteger)row
{
    return [PublisherCell heightForData:_searchedList[row]];
}

- (NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row
{
    PublisherCell * cell = [tableView makeViewWithIdentifier:PublisherCellId owner:self];
    if(cell == nil){
        cell = [PublisherCell newInstance];
    }
    cell.delegate = self;
    [cell setData:_searchedList[row]];
    return cell;
}

#pragma mark -----------------   cell delegate   ----------------
- (void)codeCompletionRequestForCell: (PublisherCell *)cell
{
    NSInteger row = [_tableview rowForView:cell];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.25/2];
        [cell beginAnimate];
    } completionHandler:^{
        [cell endAnimate];
        EventAction * action = _searchedList[row];
        [self insertConent:[NSString stringWithFormat:@"@\"%@\"",action.eventName]];
        [self.window close];
    }];
}

- (void)seeSourceRequestForCell: (PublisherCell *)cell
{
    NSInteger row = [_tableview rowForView:cell];
    [NSAnimationContext runAnimationGroup:^(NSAnimationContext *context) {
        [context setDuration:0.25/2];
        [cell beginAnimate];
    } completionHandler:^{
        [cell endAnimate];
        EventAction * action = _searchedList[row];
        [self openItem:action];
        [self.window close];
    }];
}

#pragma mark -----------------   Action   ----------------

- (IBAction)searchTextChanged:(id)sender {
    NSString * searchStr = _searchTextfield.stringValue;
    if(searchStr.length == 0){
        _searchedList = _list;
        _searchedList = [self sortedArray:_list];
    }else{
        NSMutableArray * searchList = [NSMutableArray array];
        for (EventAction * action in _list) {
            if([action.eventName rangeOfString:searchStr].length > 0){
                [searchList addObject:action];
            }
        }
        if(searchList.count == 0) searchList = nil;
        _searchedList = [self sortedArray:searchList];
    }
    [_tableview reloadData];
}

//reload data when become main
- (void)windowDidBecomeMain:(NSNotification *)notification
{
    [_searchTextfield becomeFirstResponder];
    [self reloadData];
}

//close window
- (void)windowDidResignMain:(NSNotification *)notification
{
    [self.window close];
}

#pragma mark -----------------   load data   ----------------

- (void)setProjectPath:(NSString *)projectPath
{
    if(projectPath.length > 0 && ![projectPath isEqualToString:self.projectPath]){
        _list = nil;
        _searchedList = nil;
        [_tableview reloadData];
    }
    _projectPath = projectPath;
}

// load data through run find.sh
- (void)loadData
{
    if(self.projectPath.length > 0){
        [self findItemsWithPath:self.projectPath];
    }else{
        [self showOpenPanel];
    }
}

- (NSArray*)findItemsWithPath:(NSString*)projectPath{
    NSTask *task = [[NSTask alloc] init];
    [task setLaunchPath:@"/bin/bash"];
    NSString *shellPath=[[NSBundle bundleForClass:[self class]] pathForResource:@"find" ofType:@"sh"];
    [task setArguments:@[shellPath,projectPath]];
    NSPipe *pipe;
    pipe = [NSPipe pipe];
    [task setStandardOutput: pipe];
    NSFileHandle *file;
    file = [pipe fileHandleForReading];
    [task launch];
    NSData *data;
    data = [file readDataToEndOfFile];
    NSString *string = [[NSString alloc] initWithData: data encoding: NSUTF8StringEncoding];
    NSArray *results=[string componentsSeparatedByString:@"\n"];
    //    NSLog(@"result: %@",results);
    // parse event declare
    NSArray * declareList = [self parseEventDeclare:results];
    _eventDeclareList = declareList;
    //parse event action
    NSArray * actionList = [self parseEventAction:results];
    _eventActionList = actionList;
    return nil;
}

-(void)showOpenPanel{
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:NO];
    [panel setCanChooseDirectories:YES];
    [panel beginSheetModalForWindow:[self window] completionHandler: (^(NSInteger result){
        if(result == NSOKButton) {
            NSArray *fileURLs = [panel URLs];
            self.projectPath=[[fileURLs objectAtIndex:0] path];
            [self loadData];
        }
    })];
}

#pragma mark -----------------   IDE   ----------------

-(void)insertConent:(NSString*)content{
    if ([self.parentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)self.parentWindowController;
        IDEEditorArea *editorArea = [workspaceController editorArea];
        IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
        IDESourceCodeEditor *editor= [editorContext editor];
        NSTextView *textView = editor.textView;
        if (textView && textView.isEditable) {
            [textView insertText:content];
        }else{
            NSLog(@"--------     textview  is null  ------");
        }
    }
}

- (BOOL)openItem:(EventAction *)item{
    NSWindowController *currentWindowController = self.parentWindowController;
    if ([currentWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
        //Open in current Xocde
        if ([[NSApp delegate] application:NSApp openFile:item.filePath]) {
            IDESourceCodeEditor *editor=[XToDoModel currentEditor];
            if ([editor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
                NSTextView *textView=editor.textView;
                if (textView) {
                    [self highlightItem:item inTextView:textView];
                    return YES;
                }
            }
        }
    }
    //open the file
    BOOL result= [[NSWorkspace sharedWorkspace] openFile:item.filePath withApplication:@"Xcode"];
    //open the line
    if (result) {
        //pretty slow to open file with applescript
        NSString *theSource = [NSString stringWithFormat: @"do shell script \"xed --line %ld \" & quoted form of \"%@\"", item.lineNo,item.filePath];
        NSAppleScript *theScript = [[NSAppleScript alloc] initWithSource:theSource];
        [theScript performSelectorInBackground:@selector(executeAndReturnError:) withObject:nil];
        return NO;
    }
    return result;
}

- (void)highlightItem:(EventAction*)item inTextView:(NSTextView*)textView{
    NSUInteger lineNumber = item.lineNo -1;
    NSString * text = [textView string];
    NSRegularExpression *re = [NSRegularExpression regularExpressionWithPattern:@"\n" options:0 error:nil];
    NSArray *result=[re matchesInString:text options:NSMatchingReportCompletion range:NSMakeRange(0, text.length)];
    if (result.count<=lineNumber) {
        return;
    }
    NSUInteger location=0;
    NSTextCheckingResult *aim=result[lineNumber];
    location= aim.range.location;
    NSRange range=[text lineRangeForRange:NSMakeRange(location, 0)];
    [textView scrollRangeToVisible:range];
    [textView showFindIndicatorForRange:range];
}

#pragma mark -----------------   Parse Data   ----------------

// /Users/zhang/Projects/EventBusDemo//EventBusDemo/Controller/AsyncPublishViewController.m:13:
// @interface AsyncPublishViewController ()<EventAsyncPublisher,UITableViewDelegate>

- (NSArray *)parseEventDeclare : (NSArray *)results
{
    NSMutableArray * list = [NSMutableArray array];
    for (NSString * string in results) {
        BOOL shouldNext = NO;
        for (NSString * excludePath in _excludeFileNames) {
            if([string rangeOfString:excludePath] .length > 0){
                shouldNext = YES;
                break;
            }
        }
        if(shouldNext) continue;
        if([string rangeOfString:@"@interface"].length > 0){
            EventDeclare * declare = [[EventDeclare alloc] init];
            NSArray * components = [string componentsSeparatedByString:@":"];
            if(components.count == 3){
                NSString * filePath = components[0];
                declare.filePath = filePath;
                NSString * lineNo = components[1];
                declare.lineNo = [lineNo intValue];
                NSString * definition = components[2];
                // @interface AsyncPublishViewController ()<EventAsyncPublisher,UITableViewDelegate>
                NSString * className = [definition stringByReplacingOccurrencesOfRegex:@"@interface +" withString:@""];
                //AsyncPublishViewController ()<EventAsyncPublisher,UITableViewDelegate>
                className = [className stringByReplacingOccurrencesOfRegex:@" *\\(.*\\) *< *.* *>" withString:@""];
                //AsyncPublishViewController
                declare.className = className;
                declare.declareType = [self getDeclareType:definition];
            }else if(components.count == 4){
                NSString * filePath = components[0];
                declare.filePath = filePath;
                NSString * lineNo = components[1];
                declare.lineNo = [lineNo intValue];
                NSString * definition = components[2];
                // @interface AsyncPublishViewController
                NSString * className = [definition stringByReplacingOccurrencesOfRegex:@"@interface +" withString:@""];
                // AsyncPublishViewController
                className = [className stringByReplacingOccurrencesOfRegex:@" *" withString:@""];
                declare.className = className;
                declare.declareType = [self getDeclareType:components[3]];
            }
            [list addObject:declare];
        }
    }
    if(list.count == 0) list = nil;
    return list;
}

- (EventDeclareType)getDeclareType: (NSString *)defiintion
{
    EventDeclareType declareType = 0;
    if([defiintion rangeOfString:EventDeclareAsyncPublisher].length > 0){
        declareType |= EventDeclareTypeAsyncPublisher;
    }
    if([defiintion rangeOfString:EventDeclareAsyncSubscriber].length > 0){
        declareType |= EventDeclareTypeAsyncSubscriber;
    }
    if([defiintion rangeOfString:EventDeclareSyncPublisher].length > 0){
        declareType |= EventDeclareTypeSyncPublisher;
    }
    if([defiintion rangeOfString:EventDeclareSyncSubscriber].length > 0){
        declareType |= EventDeclareTypeSyncSubscriber;
    }
    return declareType;
}

// 	    "/Users/zhang/Projects/EventBusDemo//EventBusDemo/Controller/SyncSubscribeViewController.m:71:EVENT_SUBSCRIBE(self, _textfield.text)",

//     /Users/zhangxiaogang/Desktop/EventBus-iOS-master/EventBusDemo/Controller/SyncPublishViewController.m:56:EVENT_PUBLISH(self, _textfield.text)

- (NSArray *)parseEventAction: (NSArray *)results
{
    NSMutableArray * list = [NSMutableArray array];
    for (NSString * string in results) {
        BOOL shouldNext = NO;
        for (NSString * excludePath in _excludeFileNames) {
            if([string rangeOfString:excludePath] .length > 0){
                shouldNext = YES;
                break;
            }
        }
        if(shouldNext) continue;
        if([string rangeOfString:@"EVENT_PUBLISH"].length > 0 || [string rangeOfString:@"EVENT_SUBSCRIBE"].length > 0){
            EventAction * action = [[EventAction alloc] init];
            if([string rangeOfString:@"EVENT_PUBLISH"].length > 0){
                action.actionType = EventActionTypePublish;
                NSArray * components = [string componentsSeparatedByString:@":"];
                NSString * filePath = components[0];
                action.filePath = filePath;
                NSString * lineNo = components[1];
                action.lineNo = [lineNo intValue];
                NSString * actionStr = components[2];
                if([actionStr rangeOfString:@"EVENT_PUBLISH_WITHDATA"].length > 0){
                    //EVENT_PUBLISH_WITHDATA(self, @"eventName", nil);
                    actionStr = [actionStr stringByReplacingOccurrencesOfRegex:@"EVENT_PUBLISH_WITHDATA *\\([^,]+, *" withString:@""];
                    //@"eventName", nil)
                    actionStr = [actionStr stringByReplacingOccurrencesOfRegex:@" *,.+\\)" withString:@""];
                    //@"eventName" / _textfield.text
                    actionStr = [actionStr stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                    actionStr = [actionStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    //eventName / _textfield.text
                    action.eventName = actionStr;
                }else{
                    //EVENT_PUBLISH(self, _textfield.text)",
                    actionStr = [actionStr stringByReplacingOccurrencesOfRegex:@"EVENT_PUBLISH *\\(.*, *" withString:@""];
                    //@"eventName") / _textfield.text)
                    actionStr = [actionStr stringByReplacingOccurrencesOfRegex:@" *\\) *" withString:@""];
                    //@"eventName" / _textfield.text
                    actionStr = [actionStr stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                    actionStr = [actionStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                    //eventName / _textfield.text
                    action.eventName = actionStr;
                }
            }else if([string rangeOfString:@"EVENT_SUBSCRIBE"].length > 0){
                action.actionType = EventActionTypeSubscribe;
                NSArray * components = [string componentsSeparatedByString:@":"];
                NSString * filePath = components[0];
                action.filePath = filePath;
                NSString * lineNo = components[1];
                action.lineNo = [lineNo intValue];
                NSString * actionStr = components[2];
                //EVENT_SUBSCRIBE(self, _textfield.text);
                actionStr = [actionStr stringByReplacingOccurrencesOfRegex:@"EVENT_SUBSCRIBE *\\(.*, *" withString:@""];
                //@"eventName") / _textfield.text)
                actionStr = [actionStr stringByReplacingOccurrencesOfRegex:@" *\\) *" withString:@""];
                //@"eventName" / _textfield.text
                actionStr = [actionStr stringByReplacingOccurrencesOfString:@"@\"" withString:@""];
                actionStr = [actionStr stringByReplacingOccurrencesOfString:@"\"" withString:@""];
                //eventName / _textfield.text
                action.eventName = actionStr;
            }
            [list addObject:action];
        }
    }
    if(list.count == 0) list = nil;
    return list;
}


#pragma mark -----------------   Util   ----------------

- (NSArray *)sortedArray: (NSArray *)actionArray
{
    return [actionArray sortedArrayUsingComparator:^NSComparisonResult(EventAction * obj1, EventAction * obj2) {
        return [obj1.eventName compare:obj2.eventName];
    }];
}
@end






















