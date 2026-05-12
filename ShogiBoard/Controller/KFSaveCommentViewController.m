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
#import <GoogleMobileAds/GoogleMobileAds.h>

//@import NendAd;

@interface KFSaveCommentViewController ()
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.commentNaviItem.title = self.navTitle;

    self.commentView.text = @"";
    [self.commentView becomeFirstResponder];
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
}

@end
