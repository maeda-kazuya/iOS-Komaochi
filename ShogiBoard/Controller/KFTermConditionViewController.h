//
//  KFTermConditionViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/3/15.
//  Copyright (c) 2015 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class GADBannerView;
@class KFTermCondition;

@protocol KFTermConditionViewControllerDelegate <NSObject>
- (void)didSelectTerm:(KFTermCondition *)termCondition;
@end

@interface KFTermConditionViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UIDatePicker *startDatePicker;
@property (weak, nonatomic) IBOutlet UIDatePicker *endDatePicker;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobBottomBannerView;

@property (weak, nonatomic) id<KFTermConditionViewControllerDelegate> delegate;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)submitButtonTapped:(id)sender;

@end
