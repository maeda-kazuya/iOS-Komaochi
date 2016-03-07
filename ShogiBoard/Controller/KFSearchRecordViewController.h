//
//  KFSearchRecordViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 12/7/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class KFMatchConditionViewController;
@class KFMatchTableViewController;
@class KFPlayerConditionViewController;
@class KFStrategyConditionViewController;
@class KFTermCondition;
@class KFTermConditionViewController;
@class KFRecord;
@class KFRecordLoader;
@class GADBannerView;
@class NADView;

enum {
    kMatchNameConditionIndex = 0,
    kPlayerNameConditionIndex,
    kStrategyNameConditionIndex,
    kTermConditionIndex,
};

@protocol KFSearchRecordViewControllerDelegate <NSObject>
@optional
- (void)dismissSearchRecordPopover;
- (void)didFinishLoadRecord:(KFRecord *)record;
@end

@interface KFSearchRecordViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBannerView;

@property (strong, nonatomic) KFRecordLoader *recordLoader;
@property (strong, nonatomic) KFMatchTableViewController *matchTableViewController;
@property (strong, nonatomic) KFPlayerConditionViewController *playerConditionViewController;
@property (strong, nonatomic) KFMatchConditionViewController *matchConditionViewController;
@property (strong, nonatomic) KFStrategyConditionViewController *strategyConditionViewController;
@property (strong, nonatomic) KFTermConditionViewController *termConditionViewController;
@property (strong, nonatomic) UIPopoverController *matchTablePopoverController;
@property (strong, nonatomic) UIPopoverController *playerConditionPopoverController;
@property (strong, nonatomic) UIPopoverController *matchConditionPopoverController;
@property (strong, nonatomic) UIPopoverController *strategyConditionPopoverController;
@property (strong, nonatomic) UIPopoverController *termConditionPopoverController;
@property (strong, nonatomic) NSString *firstPlayerName;
@property (strong, nonatomic) NSString *secondPlayerName;
@property (strong, nonatomic) NSString *matchName;
@property (strong, nonatomic) NSString *strategyName;
@property (strong, nonatomic) KFTermCondition *termCondition;

@property (weak, nonatomic) id<KFSearchRecordViewControllerDelegate> delegate;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)clearButtonTapped:(id)sender;
- (IBAction)searchButtonTapped:(id)sender;

@end
