//
//  KFSaveCommentViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/1/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFSaveCommentViewController.h"
#import "KFMove.h"
#import "KFRecord.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@import NendAd;

@interface KFSaveCommentViewController () <NADViewDelegate>
@end

@implementation KFSaveCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set AdMob unit (publisher) id
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    
    // Load AdMob
    GADRequest *adMobRequest = [GADRequest request];

    [self.admobTopBannerView loadRequest:adMobRequest];
    
    /*
    // Set Nend Ad view
    [self.nendAdView setNendID:NEND_AD_ID spotID:NEND_SPOT_ID];
    [self.nendAdView setDelegate:self];
    [self.nendAdView load];
    
    //TODO:Fix for showing Ad in iPad
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
        self.nadFirstIconView.hidden = YES;
        self.nadSecondIconView.hidden = YES;
        self.nadThirdIconView.hidden = YES;
        self.nadFourthIconView.hidden = YES;
    }
    */
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.commentNaviItem.title = self.navTitle;

    self.commentView.text = @"";
    [self.commentView becomeFirstResponder];
    
    // Google Analytics
    self.screenName = @"KFSaveCommentViewController";
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone && [self.delegate respondsToSelector:@selector(dismissSaveCommentPopover)]) {
        [self.delegate dismissSaveCommentPopover];
    }
}

- (IBAction)saveComment:(id)sender {
    [self updateComment:self.commentView.text];
    [self dismissViewControllerAnimated:YES completion:NULL];

    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone && [self.delegate respondsToSelector:@selector(dismissSaveCommentPopover)]) {
        [self.delegate dismissSaveCommentPopover];
    }
    
    // Track for Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"CommentManagement"
                                                          action:@"saveCommentCompleted"
                                                           label:@"saveComment"
                                                           value:nil] build]];
}

# pragma mark - NADViewDelegate
-(void)nadViewDidFinishLoad:(NADView *)adView {
    NSLog(@"delegate nadViewDidFinishLoad:");
}

@end
