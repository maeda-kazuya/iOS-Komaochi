//
//  KFStrategyConditionViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 12/14/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class GADBannerView;

enum {
    kUnspecifiedStrategyIndex,
    kYaguraStrategyIndex,
    kYokofudoriStrategyIndex,
    kKakugawariStrategyIndex,
    kIttezonStrategyIndex,
    kShikenStrategyIndex,
    kSankenStrategyIndex,
    kNakabishaStrategyIndex,
    kMukaibishaStrategyIndex,
    kDirectMukaiStrategyIndex,
    kSodebishaStrategyIndex,
    kMigishikenStrategyIndex,
    kYodoStrategyIndex,
    kHineriStrategyIndex,
    kAifuriStrategyIndex,
    kAigakariStrategyIndex,
    kRikisenStrategyIndex,
    kBoginStrategyIndex,
    kYokofu85hiStrategyIndex,
    kIshidaryuStrategyIndex,
    kAianagumaStrategyIndex,
    kNakabishaAnagumaStrategyIndex,
    kKazagurumaStrategyIndex,
    kSujichigaiStrategyIndex,
    kGangiStrategyIndex,
    kMigigyokuStrategyIndex,
    kOtherStrategyIndex
};

@protocol KFStrategyConditionViewControllerDelegate <NSObject>
- (void)didSelectStrategy:(NSString *)strategyName;
@end

@interface KFStrategyConditionViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *strategyName;
@property (weak, nonatomic) id<KFStrategyConditionViewControllerDelegate> delegate;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBannerView;

- (IBAction)backButtonTapped:(id)sender;

@end
