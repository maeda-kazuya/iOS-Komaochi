//
//  KFLoadRecordViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 10/25/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class GADBannerView;
@class NADIconLoader;
@class NADIconView;
@class NADView;
@class KFRecord;
@class KFRecordLoader;

@protocol KFLoadRecordViewControllerDelegate <NSObject>
- (void)didFinishLoadRecord:(KFRecord *)record;
@end

@interface KFLoadRecordViewController : GAITrackedViewController

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet NADView *nendAdView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobBottomBannerView;

@property (weak, nonatomic) id<KFLoadRecordViewControllerDelegate> delegate;
@property (strong, nonatomic) KFRecordLoader *recordLoader;
@property (strong, nonatomic) NADIconLoader *iconLoader;


- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)loadButtonTapped:(id)sender;

@end
