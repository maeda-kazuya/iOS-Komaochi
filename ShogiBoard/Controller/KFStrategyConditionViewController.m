//
//  KFStrategyConditionViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 12/14/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFStrategyConditionViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

static const NSInteger kNumberOfRow = 27;

@interface KFStrategyConditionViewController ()
@end

@implementation KFStrategyConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Load AdMob
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    
    self.adMobBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.adMobBannerView.rootViewController = self;

    GADRequest *adMobRequest = [GADRequest request];

    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.adMobBannerView loadRequest:adMobRequest];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kNumberOfRow;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case kUnspecifiedStrategyIndex:
            cell.textLabel.text = @"指定なし";
            break;
        case kYaguraStrategyIndex:
            cell.textLabel.text = @"矢倉";
            break;
        case kYokofudoriStrategyIndex:
            cell.textLabel.text = @"横歩取り";
            break;
        case kKakugawariStrategyIndex:
            cell.textLabel.text = @"角換わり";
            break;
        case kIttezonStrategyIndex:
            cell.textLabel.text = @"一手損角換わり";
            break;
        case kShikenStrategyIndex:
            cell.textLabel.text = @"四間飛車";
            break;
        case kSankenStrategyIndex:
            cell.textLabel.text = @"三間飛車";
            break;
        case kNakabishaStrategyIndex:
            cell.textLabel.text = @"中飛車";
            break;
        case kMukaibishaStrategyIndex:
            cell.textLabel.text = @"向かい飛車";
            break;
        case kDirectMukaiStrategyIndex:
            cell.textLabel.text = @"ダイレクト向かい飛車";
            break;
        case kIshidaryuStrategyIndex:
            cell.textLabel.text = @"石田流";
            break;
        case kAifuriStrategyIndex:
            cell.textLabel.text = @"相振り飛車";
            break;
        case kSodebishaStrategyIndex:
            cell.textLabel.text = @"袖飛車";
            break;
        case kMigishikenStrategyIndex:
            cell.textLabel.text = @"右四間飛車";
            break;
        case kNakabishaAnagumaStrategyIndex:
            cell.textLabel.text = @"中飛車居飛穴";
            break;
        case kHineriStrategyIndex:
            cell.textLabel.text = @"ひねり飛車";
            break;
        case kRikisenStrategyIndex:
            cell.textLabel.text = @"居飛車力戦";
            break;
        case kYodoStrategyIndex:
            cell.textLabel.text = @"陽動振飛車";
            break;
        case kBoginStrategyIndex:
            cell.textLabel.text = @"棒銀";
            break;
        case kYokofu85hiStrategyIndex:
            cell.textLabel.text = @"横歩取り８五飛";
            break;
        case kAianagumaStrategyIndex:
            cell.textLabel.text = @"相穴熊";
            break;
        case kAigakariStrategyIndex:
            cell.textLabel.text = @"相掛かり";
            break;
        case kSujichigaiStrategyIndex:
            cell.textLabel.text = @"筋違い角";
            break;
        case kMigigyokuStrategyIndex:
            cell.textLabel.text = @"右玉";
            break;
        case kGangiStrategyIndex:
            cell.textLabel.text = @"雁木";
            break;
        case kKazagurumaStrategyIndex:
            cell.textLabel.text = @"風車";
            break;
        case kOtherStrategyIndex:
            cell.textLabel.text = @"その他";
            break;
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case kUnspecifiedStrategyIndex:
            self.strategyName = @"";
            break;
        case kYaguraStrategyIndex:
            self.strategyName = @"矢倉";
            break;
        case kKakugawariStrategyIndex:
            self.strategyName = @"角換わり";
            break;
        case kYokofudoriStrategyIndex:
            self.strategyName = @"横歩取り";
            break;
        case kAigakariStrategyIndex:
            self.strategyName = @"相掛かり";
            break;
        case kHineriStrategyIndex:
            self.strategyName = @"ひねり飛車";
            break;
        case kRikisenStrategyIndex:
            self.strategyName = @"居飛車力戦";
            break;
        case kShikenStrategyIndex:
            self.strategyName = @"四間飛車";
//            self.strategyName = @"ダイレクト四間飛車"; // invalid
            break;
        case kSankenStrategyIndex:
            self.strategyName = @"三間飛車";
            break;
        case kNakabishaStrategyIndex:
            self.strategyName = @"中飛車";
            break;
        case kMukaibishaStrategyIndex:
            self.strategyName = @"向飛車";
//            self.strategyName = @"向かい飛車"; // not much
            break;
        case kYodoStrategyIndex:
            self.strategyName = @"陽動振飛車";
            break;
        case kAifuriStrategyIndex:
            self.strategyName = @"相振飛車";
//            self.strategyName = @"相振り飛車"; // not much
            break;
        case kOtherStrategyIndex:
            self.strategyName = @"その他";
            break;
        case kSodebishaStrategyIndex:
            self.strategyName = @"袖飛車";
            break;
        case kSujichigaiStrategyIndex:
            self.strategyName = @"筋違角";
//            self.strategyName = @"筋違い角"; // invalid
            break;
        case kGangiStrategyIndex:
            self.strategyName = @"雁木";
            break;
        case kBoginStrategyIndex:
            self.strategyName = @"棒銀";
            break;
        case kIttezonStrategyIndex:
            self.strategyName = @"一手損角換わり";
            break;
        case kYokofu85hiStrategyIndex:
            self.strategyName = @"横歩取り８五飛";
            break;
        case kIshidaryuStrategyIndex:
//            self.strategyName = @"三間飛車石田流"; // not much
            self.strategyName = @"石田流";
            break;
        case kNakabishaAnagumaStrategyIndex:
            self.strategyName = @"中飛車居飛穴";
//            self.strategyName = @"中飛車左穴熊"; // invalid
            break;
        case kDirectMukaiStrategyIndex:
            self.strategyName = @"ダイレクト向かい飛車";
            break;
        case kKazagurumaStrategyIndex:
            self.strategyName = @"風車";
            break;
        case kAianagumaStrategyIndex:
            self.strategyName = @"相穴熊";
            break;
        case kMigigyokuStrategyIndex:
            self.strategyName = @"右玉";
            break;
        case kMigishikenStrategyIndex:
            self.strategyName = @"右四間飛車";
            break;
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectStrategy:)]) {
        [self.delegate didSelectStrategy:self.strategyName];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
