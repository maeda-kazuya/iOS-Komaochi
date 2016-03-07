//
//  KFCommentViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/1/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFCommentBaseViewController.h"
#import <UIKit/UIKit.h>

@class GADBannerView;

@interface KFCommentViewController : KFCommentBaseViewController

@property (weak, nonatomic) IBOutlet UINavigationItem *commentNaviItem;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;
@property (weak, nonatomic) IBOutlet UITextView *commentView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobBannerView;

@property (strong, nonatomic) NSDictionary *commentDic;
@property BOOL isEditting;

- (IBAction)goBack:(id)sender;
- (IBAction)editComment:(id)sender;

@end
