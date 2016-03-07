//
//  KFTitleTableViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 11/15/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class GADBannerView;
@class KFRecord;

@protocol KFTitleTableViewControllerDelegate <NSObject>
- (void)didFinishLoadRecord:(KFRecord *)record;
- (void)dismissTitleTablePopover;
@end

@interface KFTitleTableViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSArray *titleList;
@property (strong, nonatomic) NSDictionary *titleUrlDic;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) UIPopoverController *titleDetailPopoverController;
@property (weak, nonatomic) id<KFTitleTableViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBannerView;

- (IBAction)backButtonTapped:(id)sender;

@end
