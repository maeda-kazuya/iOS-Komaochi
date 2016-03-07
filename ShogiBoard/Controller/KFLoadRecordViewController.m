//
//  KFLoadRecordViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 10/25/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFLoadRecordViewController.h"
#import "KFRecord.h"
#import "KFRecordLoader.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "NADView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface KFLoadRecordViewController () <KFRecordLoaderDelegate>
@end

@implementation KFLoadRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.titleTextField becomeFirstResponder];
    self.titleTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    // RecordLoader
    self.recordLoader = [[KFRecordLoader alloc] init];
    self.recordLoader.delegate = self;
    
    // set AdMob unit (publisher) id
    self.admobBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobBannerView.rootViewController = self;
    
    self.admobBottomBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.admobBottomBannerView.rootViewController = self;
    
    // Load AdMob
    GADRequest *adMobRequest = [GADRequest request];

    [self.admobBannerView loadRequest:adMobRequest];
    [self.admobBottomBannerView loadRequest:adMobRequest];
    
    // Set Nend Banner view
    /*
    [self.nendAdView setNendID:NEND_AD_ID spotID:NEND_SPOT_ID];
    [self.nendAdView setDelegate:self];
    [self.nendAdView load];
     */
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Focus on text field
    [self.titleTextField becomeFirstResponder];
    
    // Google Analytics
    self.screenName = @"KFLoadRecordViewController";
    
    // Track for Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"OtherServices"
                                                          action:@"loadRecordByUrlViewWillAppear"
                                                           label:@"loadRecordByUrl"
                                                           value:nil] build]];
}

/*
# pragma mark - NADViewDelegate
-(void)nadViewDidFinishLoad:(NADView *)adView {
    NSLog(@"delegate nadViewDidFinishLoad:");
}

 */

# pragma mark - Action method
- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)loadButtonTapped:(id)sender {
    self.recordLoader.recordUrl = self.titleTextField.text;
    [self.recordLoader loadRecord];
}

# pragma mark - KFRecordLoaderDelegate
- (void)didFinishLoadRecord:(KFRecord *)record {
    [self dismissViewControllerAnimated:YES completion:NULL];

    if ([self.delegate respondsToSelector:@selector(didFinishLoadRecord:)]) {
        [self.delegate didFinishLoadRecord:record];
    }

    // Track for Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"OtherServices"
                                                          action:@"loadRecordByUrlFinished"
                                                           label:@"loadRecordByUrl"
                                                           value:nil] build]];
}

@end
