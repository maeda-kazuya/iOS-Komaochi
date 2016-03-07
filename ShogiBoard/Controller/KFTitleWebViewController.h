//
//  KFTitleWebViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 11/15/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class KFRecord;
@class KFMatchTableViewController;
@class KFTitleDetailTableViewController;
@class GADBannerView;

@protocol KFTitleWebViewControllerDelegate <NSObject>
@optional
- (void)didFinishLoadRecord:(KFRecord *)record;
- (void)dismissTitleWebPopover;
@end

@interface KFTitleWebViewController : GAITrackedViewController

@property (nonatomic) NSInteger matchId;
@property (nonatomic) NSInteger matchDetailId;
@property (strong, nonatomic) NSString *siteUrl;
@property (strong, nonatomic) NSString *matchListUrl;
@property (strong, nonatomic) NSString *title;

@property (strong, nonatomic) KFMatchTableViewController *matchTableViewController;
@property (strong, nonatomic) UIPopoverController *matchTablePopoverController;
@property (weak, nonatomic) id<KFTitleWebViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UITextField *urlTextField;
@property (weak, nonatomic) IBOutlet UINavigationItem *naviItem;
@property (weak, nonatomic) IBOutlet UIWebView *webView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBannerView;

- (IBAction)backButtonTapped:(id)sender;
- (IBAction)showRecords:(id)sender;

- (id)initWithMatchId:(NSInteger)matchId
        matchDetailId:(NSInteger)matchDetailId
                  url:(NSString *)matchListUrl;

@end
