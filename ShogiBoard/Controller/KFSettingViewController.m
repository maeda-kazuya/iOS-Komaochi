//
//  KFSettingViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 10/11/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFSettingViewController.h"
#import "KFBoardViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@import NendAd;

@interface KFSettingViewController () <NADViewDelegate, UIPickerViewDelegate, UIPickerViewDataSource>
@end

@implementation KFSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Load AdMob
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    
    self.largeAdmobBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.largeAdmobBannerView.rootViewController = self;

    GADRequest *adMobRequest = [GADRequest request];

    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.largeAdmobBannerView loadRequest:adMobRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *freeMotionFlag = [userDefault stringForKey:@"isMotionFree"];
    NSString *soundAvailableFlag = [userDefault stringForKey:@"isSoundAvailable"];
    NSInteger komaochiIndex = [userDefault integerForKey:@"komaochiIndex"];

    if ([freeMotionFlag isEqualToString:@"YES"]) {
        self.motionSegmentedControl.selectedSegmentIndex = 0;
    } else if ([freeMotionFlag isEqualToString:@"NO"]) {
        self.motionSegmentedControl.selectedSegmentIndex = 1;
    }
    
    if ([soundAvailableFlag isEqualToString:@"YES"]) {
        self.soundSwitch.on = YES;
    } else if ([soundAvailableFlag isEqualToString:@"NO"]) {
        self.soundSwitch.on = NO;
    }
    
    [self.komaochiPickerView selectRow:komaochiIndex inComponent:0 animated:NO];
    
    // Google Analytics
    self.screenName = @"KFSettingViewController";
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismiss];

    if ([self.delegate respondsToSelector:@selector(updateSetting)]) {
        [self.delegate updateSetting];
    }
}

- (IBAction)motionControlChanged:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if (self.motionSegmentedControl.selectedSegmentIndex == 0) {
        [userDefault setObject:@"YES" forKey:@"isMotionFree"];
    } else {
        [userDefault setObject:@"NO" forKey:@"isMotionFree"];
    }
    
    [userDefault synchronize];
}

- (IBAction)soundSwitchChanged:(id)sender {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    if (self.soundSwitch.on) {
        [userDefault setObject:@"YES" forKey:@"isSoundAvailable"];
    } else {
        [userDefault setObject:@"NO" forKey:@"isSoundAvailable"];
    }
    
    [userDefault synchronize];
}

- (IBAction)turnSwitchChanged:(id)sender {
    BOOL shouldTurn = NO;
    
    if (self.turnSwitch.on) {
        shouldTurn = YES;
    }
    
    if ([self.delegate respondsToSelector:@selector(turnBoardView:)]) {
        [self.delegate turnBoardView:shouldTurn];
    }
}

# pragma mark - UIPickerViewDelegate
- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row
       inComponent:(NSInteger)component {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    [userDefault setObject:[NSString stringWithFormat:@"%ld", row] forKey:@"komaochiIndex"];
    
    [userDefault synchronize];
}

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row
            forComponent:(NSInteger)component {
    switch (row) {
        case kKomaochiIndexHirate:
            return @"平手";
            break;
        case kKomaochiIndexKyoochi:
            return @"香落ち";
            break;
        case kKomaochiIndexKakuochi:
            return @"角落ち";
            break;
        case kKomaochiIndexHishaochi:
            return @"飛車落ち";
            break;
        case kKomaochiIndexHikyoochi:
            return @"飛車香落ち";
            break;
        case kKomaochiIndexNimaiochi:
            return @"二枚落ち";
            break;
        case kKomaochiIndexYonmaiochi:
            return @"四枚落ち";
            break;
        case kKomaochiIndexRokumaiochi:
            return @"六枚落ち";
            break;
        case kKomaochiIndexHachimaiochi:
            return @"八枚落ち";
            break;
        default:
            return @"平手";
            break;
    }
}

# pragma mark - UIPickerViewDataSource
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return 9;
}

# pragma mark - NADViewDelegate
-(void)nadViewDidFinishLoad:(NADView *)adView {
    NSLog(@"delegate nadViewDidFinishLoad:");
}

# pragma mark - Private method
- (void)dismiss {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone || [[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    } else {
        if ([self.delegate respondsToSelector:@selector(dismissSettingPopover)]) {
            [self.delegate dismissSettingPopover];
        }
    }
}

@end
