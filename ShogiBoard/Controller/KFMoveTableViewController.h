//
//  KFMoveTableViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2/11/15.
//  Copyright (c) 2015 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GADBannerView;

@protocol KFMoveTableViewControllerDelegate <NSObject>
- (void)transferToMoveIndex:(NSInteger)targetMoveIndex;
@end

@interface KFMoveTableViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSMutableArray *moveArray;
@property (weak, nonatomic) id<KFMoveTableViewControllerDelegate> delegate;
@property (nonatomic) NSInteger currentMoveIndex;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobBottomBannerView;

- (IBAction)backButtonTapped:(id)sender;

@end
