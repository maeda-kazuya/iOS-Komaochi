//
//  KFAppDelegate.h
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/01.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KFTitleViewController;
@class KFBoardViewController;
@class KFForkTableViewController;

@interface KFAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) KFTitleViewController *titleViewController;
@property (strong, nonatomic) KFBoardViewController *boardViewController;
@property (strong, nonatomic) KFBoardViewController *wideBoardViewController;
@property (strong, nonatomic) KFForkTableViewController *forkTableViewController;

@end
