//
//  KFSaveCommentViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/1/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFCommentBaseViewController.h"

@class GADBannerView;

@interface KFSaveCommentViewController : KFCommentBaseViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *commentNaviItem;
@property (weak, nonatomic) IBOutlet UITextView *commentView;

@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;

- (IBAction)cancel:(id)sender;
- (IBAction)saveComment:(id)sender;

@end
