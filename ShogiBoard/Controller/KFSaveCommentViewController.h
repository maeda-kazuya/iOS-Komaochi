//
//  KFSaveCommentViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/1/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "KFCommentBaseViewController.h"

@class NADView;
@class NADIconLoader;
@class NADIconView;
@class GADBannerView;

@interface KFSaveCommentViewController : KFCommentBaseViewController

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UINavigationItem *commentNaviItem;
@property (weak, nonatomic) IBOutlet UITextView *commentView;

@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet NADView *nendAdView;
@property (weak, nonatomic) IBOutlet NADIconView *nadFirstIconView;
@property (weak, nonatomic) IBOutlet NADIconView *nadSecondIconView;
@property (weak, nonatomic) IBOutlet NADIconView *nadThirdIconView;
@property (weak, nonatomic) IBOutlet NADIconView *nadFourthIconView;

@property (strong, nonatomic) NADIconLoader *iconLoader;

- (IBAction)cancel:(id)sender;
- (IBAction)saveComment:(id)sender;

@end
