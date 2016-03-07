//
//  KFTitleDetailTableViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 11/16/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class KFMatchTableViewController;
@class KFRecord;
@class GADBannerView;

@protocol KFTitleDetailTableViewControllerDelegate <NSObject>
- (void)didFinishLoadRecord:(KFRecord *)record;
- (void)dismissTitleDetailTablePopover;
@end

@interface KFTitleDetailTableViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic) NSInteger titleId;
@property (strong, nonatomic) NSString *titleUrl;
@property (strong, nonatomic) NSArray *titleDetailList;
@property (strong, nonatomic) KFMatchTableViewController *matchTableViewController;
@property (strong, nonatomic) UIPopoverController *matchTablePopoverController;
@property (strong, nonatomic) UIPopoverController *titleWebPopoverController;
@property (weak, nonatomic) id<KFTitleDetailTableViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBannerView;

- (IBAction)backButtonTapped:(id)sender;
- (id)initWithTitleId:(NSInteger)titleId
                  url:(NSString *)titleUrl;

@end
