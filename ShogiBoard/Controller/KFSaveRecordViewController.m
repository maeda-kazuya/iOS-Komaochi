//
//  KFSaveRecordViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2014/01/25.
//  Copyright (c) 2014年 Kifoo, Inc. All rights reserved.
//

#import "KFSaveRecordViewController.h"
#import "KFRecord.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface KFSaveRecordViewController ()
@end

@implementation KFSaveRecordViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
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

    // Set Nend Banner view
    /*
    [self.nendAdView setNendID:NEND_AD_ID spotID:NEND_SPOT_ID];
    [self.nendAdView setDelegate:self];
    [self.nendAdView load];
     */

    // Set AdMob
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    
    self.admobBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.admobBannerView.rootViewController = self;

    GADRequest *adMobRequest = [GADRequest request];

    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.admobBannerView loadRequest:adMobRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if ([self.recordTitle length] > 0) {
        self.titleTextField.text = self.recordTitle;
    } else {
        NSDate *date = [NSDate date];
        
        NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
        [outputFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
        
        NSString *dateStr = [outputFormatter stringFromDate:date];
        
        // Show current date in text field
        self.titleTextField.text = dateStr;
    }

    // Focus on text field
    [self.titleTextField becomeFirstResponder];
    
    // Google Analytics
    self.screenName = @"KFSaveRecordViewController";
}

/*
# pragma mark - NADViewDelegate
-(void)nadViewDidFinishLoad:(NADView *)adView {
    NSLog(@"delegate nadViewDidFinishLoad:");
}

-(void)nadIconLoaderDidFailToReceiveAd:(NADIconLoader *)iconLoader
                           nadIconView:(NADIconView *)nadIconView{
    NSLog(@"delegate nadIconLoaderDidFailToReceiveAd:%@", iconLoader.error);
}
 */

# pragma mark - Action method
- (IBAction)cancelButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone && [self.delegate respondsToSelector:@selector(dismissSaveRecordPopover)]) {
        [self.delegate dismissSaveRecordPopover];
    }
}

- (IBAction)saveButtonTapped:(id)sender {
    KFRecord *record = [[KFRecord alloc] init];

    record.title = self.titleTextField.text;
    record.moveArray = self.moveArray;
    
    [record saveRecord];
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone && [self.delegate respondsToSelector:@selector(dismissSaveRecordPopover)]) {
        [self.delegate dismissSaveRecordPopover];
    }
}

@end
