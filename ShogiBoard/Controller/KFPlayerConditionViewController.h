//
//  KFPlayerConditionViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 12/14/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class NADView;
@class GADBannerView;

enum {
    kFirstPlayerIndex = 0,
    kSecondPlayerIndex
};

@protocol KFPlayerConditionViewControllerDelegate <NSObject>
- (void)didSelectPlayerName:(NSString *)playerName index:(NSInteger)playerIndex;
@end

@interface KFPlayerConditionViewController : GAITrackedViewController

@property (nonatomic) NSInteger playerIndex;
@property (weak, nonatomic) id<KFPlayerConditionViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UINavigationItem *playerNavigationItem;
@property (weak, nonatomic) IBOutlet UITextField *playerTextField;
@property (weak, nonatomic) IBOutlet NADView *nendAdView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBannerView;

- (IBAction)cancelButtonTapped:(id)sender;
- (IBAction)submitButtonTapped:(id)sender;

@end
