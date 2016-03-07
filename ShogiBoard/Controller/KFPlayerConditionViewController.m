//
//  KFPlayerConditionViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 12/14/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFPlayerConditionViewController.h"
#import "NADView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface KFPlayerConditionViewController () <NADViewDelegate>
@end

@implementation KFPlayerConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playerTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    // Set Nend Ad view
    [self.nendAdView setNendID:NEND_AD_ID spotID:NEND_SPOT_ID];
    [self.nendAdView setDelegate:self];
    [self.nendAdView load];
    
    // Load AdMob
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    
    self.adMobBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.adMobBannerView.rootViewController = self;

    GADRequest *adMobRequest = [GADRequest request];

    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.adMobBannerView loadRequest:adMobRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    [self.playerTextField becomeFirstResponder];
    self.playerTextField.text = @"";
    self.playerNavigationItem.title = @"対局者名を入力";

    /*
    switch (self.playerIndex) {
        case kFirstPlayerIndex:
            self.playerNavigationItem.title = @"先手棋士名";
            break;
        case kSecondPlayerIndex:
            self.playerNavigationItem.title = @"後手棋士名";
            break;
            
        default:
            break;
    }
     */
    
    // Google Analytics
//    self.screenName = @"KFPlayerConditionViewController";
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)submitButtonTapped:(id)sender {
    if ([self.delegate respondsToSelector:@selector(didSelectPlayerName:index:)]) {
        [self.delegate didSelectPlayerName:self.playerTextField.text index:self.playerIndex];
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
