//
//  KFSettingViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 10/11/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class NADView;
@class GADBannerView;

@protocol KFSettingViewControllerDelegate <NSObject>
- (void)updateSetting;
- (void)turnBoardView:(BOOL)shouldTurn;
- (void)dismissSettingPopover;
@end

@interface KFSettingViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet NADView *nendAdView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *largeAdmobBannerView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *motionSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *soundSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *turnSwitch;
@property (weak, nonatomic) IBOutlet UIPickerView *komaochiPickerView;
//@property NSInteger komaochiIndex;

@property (weak, nonatomic) id<KFSettingViewControllerDelegate> delegate;

- (IBAction)closeButtonTapped:(id)sender;
- (IBAction)motionControlChanged:(id)sender;
- (IBAction)soundSwitchChanged:(id)sender;
- (IBAction)turnSwitchChanged:(id)sender;

@end
