//
//  KFSaveRecordViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2014/01/25.
//  Copyright (c) 2014年 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GADBannerView;

@protocol KFSaveRecordViewControllerDelegate <NSObject>
- (void)dismissSaveRecordPopover;
@end

@interface KFSaveRecordViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobBannerView;
@property (weak, nonatomic) id<KFSaveRecordViewControllerDelegate> delegate;

@property (strong, nonatomic) NSMutableArray *moveArray;
@property (strong, nonatomic) NSString *recordTitle;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)saveButtonTapped:(id)sender;

@end
