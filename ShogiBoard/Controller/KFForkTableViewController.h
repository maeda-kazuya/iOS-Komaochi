//
//  KFForkTableViewController.h
//  YaguraJoseki
//
//  Created by Maeda Kazuya on 4/29/15.
//  Copyright (c) 2015 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class GADBannerView;
@class NADView;

@interface KFForkTableViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *navigationTitle;
@property (strong, nonatomic) NSArray *forkList;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NADView *nendBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobBottomBannerView;

@end
