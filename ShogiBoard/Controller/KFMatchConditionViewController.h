//
//  KFMatchConditionViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 12/7/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "GAITrackedViewController.h"

@class GADBannerView;

@protocol KFMatchConditionViewControllerDelegate <NSObject>
- (void)didSelectMatchName:(NSString *)matchName;
@end

@interface KFMatchConditionViewController : GAITrackedViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSString *matchName;
@property (weak, nonatomic) id<KFMatchConditionViewControllerDelegate> delegate;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *adMobBannerView;

- (IBAction)backButtonTapped:(id)sender;

enum {
    kUnspecifiedMatchIndex,
    kJuniMatchIndex,
    kMeijinMatchIndex,
    kRyuouMatchIndex,
    kOushouMatchIndex,
    kOuiMatchIndex,
    kOuzaMatchIndex,
    kKiseiMatchIndex,
    kKiouMatchIndex,
//    kAsahiMatchIndex,
    kGingaMatchIndex,
    kNHKMatchIndex,
//    kJTMatchIndex,
    kShinjinMatchIndex,
    kTatsujinMatchIndex,
    kLMeijinMatchIndex,
    kLOushouMatchIndex,
    kLOuiMatchIndex,
    kKurashikiMatchIndex,
//    kAllJapanMatchIndex,
//    kLOPMatchIndex,
    kKashimaMatchIndex,
//    kKinshoMatchIndex,
    kSandanMatchIndex,
    kShoreiMatchIndex,
//    kLIkuseiMatchIndex,
//    kOtherNewsMatchIndex,
    kOtherMatchIndex,
    kJudanMatchIndex,
    kKudanMatchIndex,
//    kJSenshuMatchIndex,
    kJProMatchIndex,
    kHayazashiMatchIndex,
    kHayazashiShineiMatchIndex,
    kKachinukiMatchIndex,
    kTokyoNewsMatchIndex,
//    kSanshaMatchIndex,
//    kHayazashiOuiMatchIndex,
//    kSankeiMatchIndex,
    kMeikiMatchIndex,
    kWakagomaMatchIndex,
    kSaikyoMatchIndex,
    kKogouMatchIndex,
//    kNihonichiMatchIndex,
//    k987MatchIndex,
//    k654MatchIndex,
    kTenouMatchIndex,
    kRenmeiMatchIndex,
    kTozaiMatchIndex,
    kWakajishiMatchIndex,
    kMeishouMatchIndex,
//    kIBMMatchIndex,
//    kGCMatchIndex,
    kHeiseiMatchIndex,
//    kRatingMatchIndex,
    kAMeijinMatchIndex,
    kARyuouMatchIndex,
    kAOushouMatchIndex,
    kAAsahiMatchIndex,
    kAkahataMatchIndex,
    kShibuMiejinMatchIndex,
//    kSeniorMeijinMatchIndex,
//    kAllStudentMatchIndex,
//    kSSenshuMatchIndex,
    kSMeijinMatchIndex,
    kSOushouMatchIndex,
    kSOuzaMatchIndex,
//    kHSenshuMatchIndex,
    kHRyuouMatchIndex,
//    kHShinjinMatchIndex,
//    kJSenbatsuMatchIndex,
    kJMeijinMatchIndex,
//    kJOushouMatchIndex,
    kEMeijinMatchIndex,
    kAJoouMatchIndex,
    kLAMeijinMatchIndex,
//    kLAKansaiMeijinMatchIndex,
    kLSMeijinMatchIndex,
//    kLHMeijinMatchIndex,
//    kLHShinjinMatchIndex,
//    kLJSenbatsuMatchIndex
};


@end
