//
//  KFRecordTableViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2014/01/26.
//  Copyright (c) 2014年 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class KFRecord;
@class GADBannerView;

@protocol KFRecordTableViewControllerDelegate <NSObject>
- (void)didFinishLoadRecord:(KFRecord *)record;
@end

@interface KFRecordTableViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *recordTableView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBannerView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@property (weak, nonatomic) id<KFRecordTableViewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *recordArray;
@property (strong, nonatomic) NSUserDefaults *userDefault;
@property (nonatomic) NSInteger recordCount;

- (IBAction)backButtonTapped:(id)sender;

@end
