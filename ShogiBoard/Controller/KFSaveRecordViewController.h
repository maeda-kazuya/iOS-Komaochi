//
//  KFSaveRecordViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2014/01/25.
//  Copyright (c) 2014年 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class GADBannerView;
@class NADIconLoader;
@class NADIconView;
@class NADView;

@protocol KFSaveRecordViewControllerDelegate <NSObject>
- (void)dismissSaveRecordPopover;
@end

@interface KFSaveRecordViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet NADView *nendAdView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobBannerView;
@property (weak, nonatomic) id<KFSaveRecordViewControllerDelegate> delegate;

@property (strong, nonatomic) NADIconLoader *iconLoader;
@property (strong, nonatomic) NSMutableArray *moveArray;
@property (strong, nonatomic) NSString *recordTitle;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@end
