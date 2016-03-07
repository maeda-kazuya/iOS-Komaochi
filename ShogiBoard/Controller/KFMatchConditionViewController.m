//
//  KFMatchConditionViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 12/7/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFMatchConditionViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface KFMatchConditionViewController ()
@end

@implementation KFMatchConditionViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // Set Nend Ad view
    /*
    [self.nendAdView setNendID:NEND_AD_ID spotID:NEND_SPOT_ID];
    [self.nendAdView setDelegate:self];
    [self.nendAdView load];
     */
    
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
    return kLSMeijinMatchIndex + 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case kUnspecifiedMatchIndex:
            cell.textLabel.text = @"指定なし";
            break;
        case kJuniMatchIndex:
            cell.textLabel.text = @"順位戦";
            break;
        case kMeijinMatchIndex:
            cell.textLabel.text = @"名人戦";
            break;
        case kRyuouMatchIndex:
            cell.textLabel.text = @"竜王戦";
            break;
        case kOushouMatchIndex:
            cell.textLabel.text = @"王将戦";
            break;
        case kOuiMatchIndex:
            cell.textLabel.text = @"王位戦";
            break;
        case kOuzaMatchIndex:
            cell.textLabel.text = @"王座戦";
            break;
        case kKiseiMatchIndex:
            cell.textLabel.text = @"棋聖戦";
            break;
        case kKiouMatchIndex:
            cell.textLabel.text = @"棋王戦";
            break;
            /*
        case kAsahiMatchIndex:
            cell.textLabel.text = @"朝日OP";
            break;
             */
        case kGingaMatchIndex:
            cell.textLabel.text = @"銀河戦";
            break;
        case kNHKMatchIndex:
            cell.textLabel.text = @"NHK杯";
            break;
            /*
        case kJTMatchIndex:
            cell.textLabel.text = @"ＪＴ杯";
            break;
             */
        case kShinjinMatchIndex:
            cell.textLabel.text = @"新人王戦";
            break;
        case kTatsujinMatchIndex:
            cell.textLabel.text = @"達人戦";
            break;
        case kLMeijinMatchIndex:
            cell.textLabel.text = @"女流名人位戦";
            break;
        case kLOushouMatchIndex:
            cell.textLabel.text = @"女流王将戦";
            break;
        case kLOuiMatchIndex:
            cell.textLabel.text = @"女流王位戦";
            break;
        case kKurashikiMatchIndex:
            cell.textLabel.text = @"倉敷藤花戦";
            break;
            /*
        case kAllJapanMatchIndex:
            cell.textLabel.text = @"全日本選手権";
            break;
             */
            /*
        case kLOPMatchIndex:
            cell.textLabel.text = @"レディースOP";
            break;
             */
        case kKashimaMatchIndex:
            cell.textLabel.text = @"鹿島杯";
            break;
            /*
        case kKinshoMatchIndex:
            cell.textLabel.text = @"近将杯";
            break;
             */
        case kSandanMatchIndex:
            cell.textLabel.text = @"三段リーグ";
            break;
        case kShoreiMatchIndex:
            cell.textLabel.text = @"奨励会";
            break;
            /*
        case kLIkuseiMatchIndex:
            cell.textLabel.text = @"女流育成会";
            break;
        case kOtherNewsMatchIndex:
            cell.textLabel.text = @"その他新聞棋戦";
            break;
             */
        case kOtherMatchIndex:
            cell.textLabel.text = @"その他";
            break;
        case kJudanMatchIndex:
            cell.textLabel.text = @"十段戦";
            break;
        case kKudanMatchIndex:
            cell.textLabel.text = @"九段戦";
            break;
            /*
        case kJSenshuMatchIndex:
            cell.textLabel.text = @"全日本選手権";
            break;
             */
        case kJProMatchIndex:
            cell.textLabel.text = @"全日本プロ";
            break;
        case kHayazashiMatchIndex:
            cell.textLabel.text = @"早指戦";
            break;
        case kHayazashiShineiMatchIndex:
            cell.textLabel.text = @"早指新鋭戦";
            break;
        case kKachinukiMatchIndex:
            cell.textLabel.text = @"勝抜戦";
            break;
        case kTokyoNewsMatchIndex:
            cell.textLabel.text = @"東京新聞杯";
            break;
            /*
        case kSanshaMatchIndex:
            cell.textLabel.text = @"三社杯";
            break;
        case kHayazashiOuiMatchIndex:
            cell.textLabel.text = @"早指王位戦";
            break;
        case kSankeiMatchIndex:
            cell.textLabel.text = @"産経杯";
            break;
             */
        case kMeikiMatchIndex:
            cell.textLabel.text = @"名棋戦";
            break;
        case kWakagomaMatchIndex:
            cell.textLabel.text = @"若駒戦";
            break;
            /*
        case kSaikyoMatchIndex:
            cell.textLabel.text = @"最強者決定戦";
            break;
             */
        case kKogouMatchIndex:
            cell.textLabel.text = @"古豪新鋭戦";
            break;
            /*
        case kNihonichiMatchIndex:
            cell.textLabel.text = @"日本一杯";
            break;
        case k987MatchIndex:
            cell.textLabel.text = @"九八七段戦";
            break;
        case k654MatchIndex:
            cell.textLabel.text = @"六五四段戦";
            break;
             */
        case kTenouMatchIndex:
            cell.textLabel.text = @"天王戦";
            break;
            /*
        case kRenmeiMatchIndex:
            cell.textLabel.text = @"連盟杯";
            break;
             */
        case kTozaiMatchIndex:
            cell.textLabel.text = @"東西対抗勝継戦";
            break;
        case kWakajishiMatchIndex:
            cell.textLabel.text = @"若獅子戦";
            break;
        case kMeishouMatchIndex:
            cell.textLabel.text = @"名将戦";
            break;
            /*
        case kIBMMatchIndex:
            cell.textLabel.text = @"IBM杯";
            break;
        case kGCMatchIndex:
            cell.textLabel.text = @"ＧＣ戦";
            break;
             */
        case kHeiseiMatchIndex:
            cell.textLabel.text = @"平成最強戦";
            break;
            /*
        case kRatingMatchIndex:
            cell.textLabel.text = @"レーティング戦";
            break;
             */
        case kAMeijinMatchIndex:
            cell.textLabel.text = @"アマ名人戦";
            break;
        case kARyuouMatchIndex:
            cell.textLabel.text = @"アマ竜王戦";
            break;
        case kAOushouMatchIndex:
            cell.textLabel.text = @"アマ王将戦";
            break;
        case kAAsahiMatchIndex:
            cell.textLabel.text = @"朝日アマ名人戦";
            break;
        case kAkahataMatchIndex:
            cell.textLabel.text = @"赤旗名人戦";
            break;
        case kShibuMiejinMatchIndex:
            cell.textLabel.text = @"支部対抗戦";
            break;
            /*
        case kSeniorMeijinMatchIndex:
            cell.textLabel.text = @"シニア名人戦";
            break;
        case kAllStudentMatchIndex:
            cell.textLabel.text = @"オール学生戦";
            break;
        case kSSenshuMatchIndex:
            cell.textLabel.text = @"学生選手権";
            break;
        case kSMeijinMatchIndex:
            cell.textLabel.text = @"学生名人戦";
            break;
             */
        case kSOushouMatchIndex:
            cell.textLabel.text = @"学生王将戦";
            break;
        case kSOuzaMatchIndex:
            cell.textLabel.text = @"学生王座戦";
            break;
            /*
        case kHSenshuMatchIndex:
            cell.textLabel.text = @"高校選手権";
            break;
             */
        case kHRyuouMatchIndex:
            cell.textLabel.text = @"高校竜王戦";
            break;
            /*
        case kHShinjinMatchIndex:
            cell.textLabel.text = @"高校新人戦";
            break;
        case kJSenbatsuMatchIndex:
            cell.textLabel.text = @"中学生選抜戦";
            break;
             */
        case kJMeijinMatchIndex:
            cell.textLabel.text = @"中学生名人戦";
            break;
            /*
        case kJOushouMatchIndex:
            cell.textLabel.text = @"中学生王将戦";
            break;
             */
        case kEMeijinMatchIndex:
            cell.textLabel.text = @"小学生名人戦";
            break;
        case kAJoouMatchIndex:
            cell.textLabel.text = @"アマ女王戦";
            break;
        case kLAMeijinMatchIndex:
            cell.textLabel.text = @"女流アマ名人戦";
            break;
            /*
        case kLAKansaiMeijinMatchIndex:
            cell.textLabel.text = @"関西女流アマ名人戦";
            break;
             */
        case kLSMeijinMatchIndex:
            cell.textLabel.text = @"学生女流名人戦";
            break;
            /*
        case kLHMeijinMatchIndex:
            cell.textLabel.text = @"高校女流名人戦";
            break;
        case kLHShinjinMatchIndex:
            cell.textLabel.text = @"高校女流新人戦";
            break;
        case kLJSenbatsuMatchIndex:
            cell.textLabel.text = @"中学生女子選抜戦";
            break;
             */
            
        default:
            break;
    }
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.row) {
        case kUnspecifiedMatchIndex:
            self.matchName = @"";
            break;
        case kJuniMatchIndex:
            self.matchName = @"順位戦";
            break;
        case kMeijinMatchIndex:
            self.matchName = @"名人戦";
            break;
        case kRyuouMatchIndex:
            self.matchName = @"竜王戦";
            break;
        case kOushouMatchIndex:
            self.matchName = @"王将戦";
            break;
        case kOuiMatchIndex:
            self.matchName = @"王位戦";
            break;
        case kOuzaMatchIndex:
            self.matchName = @"王座戦";
            break;
        case kKiseiMatchIndex:
            self.matchName = @"棋聖戦";
            break;
        case kKiouMatchIndex:
            self.matchName = @"棋王戦";
            break;
            /*
        case kAsahiMatchIndex:
            self.matchName = @"朝日OP";
            break;
             */
        case kGingaMatchIndex:
            self.matchName = @"銀河戦";
            break;
        case kNHKMatchIndex:
            self.matchName = @"NHK杯";
            break;
            /*
        case kJTMatchIndex:
            self.matchName = @"ＪＴ杯";
            break;
             */
        case kShinjinMatchIndex:
            self.matchName = @"新人王戦";
            break;
        case kTatsujinMatchIndex:
            self.matchName = @"達人戦";
            break;
        case kLMeijinMatchIndex:
            self.matchName = @"女流名人位戦";
            break;
        case kLOushouMatchIndex:
            self.matchName = @"女流王将戦";
            break;
        case kLOuiMatchIndex:
            self.matchName = @"女流王位戦";
            break;
        case kKurashikiMatchIndex:
            self.matchName = @"倉敷藤花戦";
            break;
            /*
        case kAllJapanMatchIndex:
            self.matchName = @"全日本選手権";
            break;
        case kLOPMatchIndex:
            self.matchName = @"レディースOP";
            break;
             */
        case kKashimaMatchIndex:
            self.matchName = @"鹿島杯";
            break;
            /*
        case kKinshoMatchIndex:
            self.matchName = @"近将杯";
            break;
             */
        case kSandanMatchIndex:
            self.matchName = @"三段リーグ";
            break;
        case kShoreiMatchIndex:
            self.matchName = @"奨励会";
            break;
            /*
        case kLIkuseiMatchIndex:
            self.matchName = @"女流育成会";
            break;
        case kOtherNewsMatchIndex:
            self.matchName = @"その他新聞棋戦";
            break;
             */
        case kOtherMatchIndex:
            self.matchName = @"その他";
            break;
        case kJudanMatchIndex:
            self.matchName = @"十段戦";
            break;
        case kKudanMatchIndex:
            self.matchName = @"九段戦";
            break;
            /*
        case kJSenshuMatchIndex:
            self.matchName = @"全日本選手権";
            break;
             */
        case kJProMatchIndex:
            self.matchName = @"全日本プロ";
            break;
        case kHayazashiMatchIndex:
            self.matchName = @"早指戦";
            break;
        case kHayazashiShineiMatchIndex:
            self.matchName = @"早指新鋭戦";
            break;
        case kKachinukiMatchIndex:
            self.matchName = @"勝抜戦";
            break;
        case kTokyoNewsMatchIndex:
            self.matchName = @"東京新聞杯";
            break;
            /*
        case kSanshaMatchIndex:
            self.matchName = @"三社杯";
            break;
        case kHayazashiOuiMatchIndex:
            self.matchName = @"早指王位戦";
            break;
        case kSankeiMatchIndex:
            self.matchName = @"産経杯";
            break;
             */
        case kMeikiMatchIndex:
            self.matchName = @"名棋戦";
            break;
        case kWakagomaMatchIndex:
            self.matchName = @"若駒戦";
            break;
        case kSaikyoMatchIndex:
            self.matchName = @"最強者決定戦";
            break;
        case kKogouMatchIndex:
            self.matchName = @"古豪新鋭戦";
            break;
            /*
        case kNihonichiMatchIndex:
            self.matchName = @"日本一杯";
            break;
        case k987MatchIndex:
            self.matchName = @"九八七段戦";
            break;
        case k654MatchIndex:
            self.matchName = @"六五四段戦";
            break;
             */
        case kTenouMatchIndex:
            self.matchName = @"天王戦";
            break;
        case kRenmeiMatchIndex:
            self.matchName = @"連盟杯";
            break;
        case kTozaiMatchIndex:
            self.matchName = @"東西対抗勝継戦";
            break;
        case kWakajishiMatchIndex:
            self.matchName = @"若獅子戦";
            break;
        case kMeishouMatchIndex:
            self.matchName = @"名将戦";
            break;
            /*
        case kIBMMatchIndex:
            self.matchName = @"IBM杯";
            break;
        case kGCMatchIndex:
            self.matchName = @"ＧＣ戦";
            break;
             */
        case kHeiseiMatchIndex:
            self.matchName = @"平成最強戦";
            break;
            /*
        case kRatingMatchIndex:
            self.matchName = @"レーティング戦";
            break;
             */
        case kAMeijinMatchIndex:
            self.matchName = @"アマ名人戦";
            break;
        case kARyuouMatchIndex:
            self.matchName = @"アマ竜王戦";
            break;
        case kAOushouMatchIndex:
            self.matchName = @"アマ王将戦";
            break;
        case kAAsahiMatchIndex:
            self.matchName = @"朝日アマ名人戦";
            break;
        case kAkahataMatchIndex:
            self.matchName = @"赤旗名人戦";
            break;
        case kShibuMiejinMatchIndex:
            self.matchName = @"支部対抗戦";
            break;
            /*
        case kSeniorMeijinMatchIndex:
            self.matchName = @"シニア名人戦";
            break;
        case kAllStudentMatchIndex:
            self.matchName = @"オール学生戦";
            break;

        case kSSenshuMatchIndex:
            self.matchName = @"学生選手権";
            break;
                          */
        case kSMeijinMatchIndex:
            self.matchName = @"学生名人戦";
            break;
        case kSOushouMatchIndex:
            self.matchName = @"学生王将戦";
            break;
        case kSOuzaMatchIndex:
            self.matchName = @"学生王座戦";
            break;
            /*
        case kHSenshuMatchIndex:
            self.matchName = @"高校選手権";
            break;
             */
        case kHRyuouMatchIndex:
            self.matchName = @"高校竜王戦";
            break;

            /*
        case kHShinjinMatchIndex:
            self.matchName = @"高校新人戦";
            break;
        case kJSenbatsuMatchIndex:
            self.matchName = @"中学生選抜戦";
            break;
             */
        case kJMeijinMatchIndex:
            self.matchName = @"中学生名人戦";
            break;
            /*
        case kJOushouMatchIndex:
            self.matchName = @"中学生王将戦";
            break;
             */
        case kEMeijinMatchIndex:
            self.matchName = @"小学生名人戦";
            break;
        case kAJoouMatchIndex:
            self.matchName = @"アマ女王戦";
            break;
        case kLAMeijinMatchIndex:
            self.matchName = @"女流アマ名人戦";
            break;
            /*
        case kLAKansaiMeijinMatchIndex:
            self.matchName = @"関西女流アマ名人戦";
            break;
             */
        case kLSMeijinMatchIndex:
            self.matchName = @"学生女流名人戦";
            break;
            /*
        case kLHMeijinMatchIndex:
            self.matchName = @"高校女流名人戦";
            break;
        case kLHShinjinMatchIndex:
            self.matchName = @"高校女流新人戦";
            break;
        case kLJSenbatsuMatchIndex:
            self.matchName = @"中学生女子選抜戦";
            break;
             */
        default:
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(didSelectMatchName:)]) {
        [self.delegate didSelectMatchName:self.matchName];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
