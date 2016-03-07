//
//  KFMatchTableViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 11/1/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class KFRecord;
@class KFRecordLoader;
@class GADBannerView;

@protocol KFMatchTableViewControllerDelegate <NSObject>
- (void)dismissMatchTablePopover;
@optional
- (void)didFinishLoadRecord:(KFRecord *)record;
@end

@interface KFMatchTableViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate, UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBottomView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@property (nonatomic) NSInteger matchId;
@property (nonatomic) NSInteger matchDetailId;
@property (strong, nonatomic) NSString *siteUrl;
@property (strong, nonatomic) NSString *matchListUrl;
@property (strong, nonatomic) KFRecordLoader *recordLoader;
@property (strong, nonatomic) UIRefreshControl *refreshControl;
@property (strong, nonatomic) NSArray *matchList;
@property (strong, nonatomic) UIWebView *dummyWebView;
@property (nonatomic) BOOL isDummyWebAvailable;

@property (weak, nonatomic) id<KFMatchTableViewControllerDelegate> delegate;

- (IBAction)backButtonTapped:(id)sender;

- (id)initWithMatchId:(NSInteger)matchId
        matchDetailId:(NSInteger)matchDetailId
                  url:(NSString *)matchListUrl;
- (void)loadMatchList;
- (void)loadMatchListByCondition;
- (void)loadDummyWebView;
- (void)loadSamePositionMatch;

@end
