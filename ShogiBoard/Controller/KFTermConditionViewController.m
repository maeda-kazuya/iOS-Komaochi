//
//  KFTermConditionViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/3/15.
//  Copyright (c) 2015 Kifoo, Inc. All rights reserved.
//

#import "KFTermConditionViewController.h"
#import "KFTermCondition.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface KFTermConditionViewController ()
@end

@implementation KFTermConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Set start data picker for 1 year ago
    self.startDatePicker.date = [NSDate dateWithTimeIntervalSinceNow:-60 * 60 * 24 * 365];

    // Load AdMob
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    
    self.admobBottomBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.admobBottomBannerView.rootViewController = self;
    
    GADRequest *adMobRequest = [GADRequest request];
    
    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.admobBottomBannerView loadRequest:adMobRequest];
}

- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)submitButtonTapped:(id)sender {
    KFTermCondition *termCondition = [[KFTermCondition alloc] init];
    termCondition.startDate = self.startDatePicker.date;
    termCondition.endDate = self.endDatePicker.date;
    
    if ([self.delegate respondsToSelector:@selector(didSelectTerm:)]) {
        [self.delegate didSelectTerm:termCondition];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
