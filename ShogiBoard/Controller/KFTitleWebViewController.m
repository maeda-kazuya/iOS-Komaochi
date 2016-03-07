//
//  KFTitleWebViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 11/15/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFTitleWebViewController.h"
#import "KFTitleDetailTableViewController.h"
#import "KFMatchTableViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface KFTitleWebViewController () <KFMatchTableViewControllerDelegate>
@end

@implementation KFTitleWebViewController

- (id)initWithMatchId:(NSInteger)matchId
        matchDetailId:(NSInteger)matchDetailId
                  url:(NSString *)matchListUrl {
    self = [super init];
    
    if (self) {
        self.matchId = matchId;
        self.matchDetailId = matchDetailId;
        self.matchListUrl = matchListUrl;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    self.matchTableViewController = [[KFMatchTableViewController alloc] initWithMatchId:self.matchId
                                                                          matchDetailId:self.matchDetailId
                                                                                    url:self.matchListUrl];
    self.matchTableViewController.siteUrl = self.siteUrl;
    self.matchTableViewController.delegate = self;
    
    // set AdMob unit (publisher) id
    self.adMobBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.adMobBannerView.rootViewController = self;
    
    // Load AdMob
    GADRequest *adMobRequest = [GADRequest request];

    [self.adMobBannerView loadRequest:adMobRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.naviItem.title = self.title;
    self.urlTextField.text = self.matchListUrl;
    
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.matchListUrl]]];
    
    self.screenName = @"KFTitleWebViewController";
}

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)showRecords:(id)sender {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.matchTableViewController animated:YES completion:NULL];
        [self.matchTableViewController loadMatchList];
    } else {
        self.matchTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.matchTableViewController];
        
        self.matchTableViewController.preferredContentSize = self.view.frame.size;
        self.matchTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.matchTableViewController];
        
        [self.matchTablePopoverController presentPopoverFromRect:self.view.frame
                                                          inView:self.view
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
        
        [self.matchTableViewController loadMatchList];
    }
    
    // Track by Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"MatchManagement"
                                                          action:@"showMatchListFromTitleWebVC"
                                                           label:@"showMatchList"
                                                           value:[NSNumber numberWithInteger:self.matchId]] build]];
}

# pragma mark - KFMatchTableViewControllerDelegate
- (void)didFinishLoadRecord:(KFRecord *)record {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadRecord:)]) {
        [self.delegate didFinishLoadRecord:record];
    }
}

- (void)dismissMatchTablePopover {
    [self.matchTablePopoverController dismissPopoverAnimated:YES];
}

@end
