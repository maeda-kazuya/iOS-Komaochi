//
//  KFSearchRecordViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 12/7/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFSearchRecordViewController.h"
#import "KFMatchConditionViewController.h"
#import "KFMatchTableViewController.h"
#import "KFPlayerConditionViewController.h"
#import "KFStrategyConditionViewController.h"
#import "KFTermCondition.h"
#import "KFTermConditionViewController.h"
#import "KFRecordLoader.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import "NADView.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

static const NSInteger kSearchConditionNum = 4;

@interface KFSearchRecordViewController () <KFPlayerConditionViewControllerDelegate,
                                            KFMatchConditionViewControllerDelegate,
                                            KFStrategyConditionViewControllerDelegate,
                                            KFMatchTableViewControllerDelegate,
                                            KFTermConditionViewControllerDelegate,
                                            NADViewDelegate>
@end

@implementation KFSearchRecordViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.playerConditionViewController = [[KFPlayerConditionViewController alloc] init];
    self.playerConditionViewController.delegate = self;

    self.matchConditionViewController = [[KFMatchConditionViewController alloc] init];
    self.matchConditionViewController.delegate = self;
    
    self.strategyConditionViewController = [[KFStrategyConditionViewController alloc] init];
    self.strategyConditionViewController.delegate = self;
    
    self.termConditionViewController = [[KFTermConditionViewController alloc] init];
    self.termConditionViewController.delegate = self;
    
    [self restoreSearchConditions];
    
    // Load AdMob
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    
    self.adMobBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.adMobBannerView.rootViewController = self;

    GADRequest *adMobRequest = [GADRequest request];

    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.adMobBannerView loadRequest:adMobRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // Google Analytics
    self.screenName = @"KFSearchRecordViewController";
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return kSearchConditionNum;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    switch (indexPath.row) {
        case kMatchNameConditionIndex:
            cell.textLabel.text = [NSString stringWithFormat:@"棋戦：%@", (self.matchName ? self.matchName : @"")];
            break;
        case kPlayerNameConditionIndex:
            cell.textLabel.text = [NSString stringWithFormat:@"対局者：%@", (self.firstPlayerName ? self.firstPlayerName : @"")];
            break;
            /*
        case 1:
            cell.textLabel.text = [NSString stringWithFormat:@"後手：%@", self.secondPlayerName ? self.secondPlayerName : @""];
            break;
             */
        case kStrategyNameConditionIndex:
            cell.textLabel.text = [NSString stringWithFormat:@"戦型：%@", (self.strategyName ? self.strategyName : @"")];
            break;
        case kTermConditionIndex:
            cell.textLabel.text = [NSString stringWithFormat:@"期間：%@", (self.termCondition ? [self.termCondition description] : @"")];
            break;
    }

    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (indexPath.row == kMatchNameConditionIndex) {
            [self presentViewController:self.matchConditionViewController animated:YES completion:NULL];
        } else if (indexPath.row == kPlayerNameConditionIndex) {
            self.playerConditionViewController.playerIndex = kFirstPlayerIndex;
            [self presentViewController:self.playerConditionViewController animated:YES completion:NULL];
        } else if (indexPath.row == kStrategyNameConditionIndex) {
            [self presentViewController:self.strategyConditionViewController animated:YES completion:NULL];
        } else if (indexPath.row == kTermConditionIndex) {
            [self presentViewController:self.termConditionViewController animated:YES completion:NULL];
        }
    } else {
        if (indexPath.row == kMatchNameConditionIndex) {
            self.matchConditionPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.matchConditionViewController];
            self.matchConditionViewController.preferredContentSize = CGSizeMake(320, 800);

            [self.matchConditionPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                                  inView:self.view
                                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                animated:YES];
        } else if (indexPath.row == kPlayerNameConditionIndex) {
            self.playerConditionViewController.playerIndex = kFirstPlayerIndex;
            self.playerConditionPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.playerConditionViewController];
            
            [self.playerConditionPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                                   inView:self.view
                                                 permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                 animated:YES];
        } else if (indexPath.row == kStrategyNameConditionIndex) {
            self.strategyConditionPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.strategyConditionViewController];
            self.strategyConditionViewController.preferredContentSize = CGSizeMake(320, 800);

            [self.strategyConditionPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                                     inView:self.view
                                                   permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                   animated:YES];
        } else if (indexPath.row == kTermConditionIndex) {
            self.termConditionPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.termConditionViewController];
            self.termConditionViewController.preferredContentSize = CGSizeMake(320, 800);
            
            [self.termConditionPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                                 inView:self.view
                                               permittedArrowDirections:UIPopoverArrowDirectionAny
                                                               animated:YES];
        }
    }
}

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (IBAction)clearButtonTapped:(id)sender {
    self.firstPlayerName = @"";
    self.secondPlayerName = @"";
    self.matchName = @"";
    self.strategyName = @"";
    self.termCondition = nil;
    
    [self.tableView reloadData];
}

- (IBAction)searchButtonTapped:(id)sender {
    if ([self isConditionBlank]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                        message:@"検索条件を指定してください"
                                                       delegate:self
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil, nil];
        [alert show];
        return;
    }

    NSString *url = [self buildRequestUrl];
    
    self.matchTableViewController = [[KFMatchTableViewController alloc] initWithMatchId:MATCH_ID_Search
                                                                          matchDetailId:0
                                                                                    url:url];
    
    self.matchTableViewController.siteUrl = url;
    self.matchTableViewController.delegate = self;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.matchTableViewController animated:YES completion:NULL];
        [self.matchTableViewController loadDummyWebView];
    } else {
        self.matchTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.matchTableViewController];
        self.matchTableViewController.preferredContentSize = self.view.frame.size;

        [self.matchTablePopoverController presentPopoverFromRect:self.view.frame
                                                          inView:self.view
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
        
        [self.matchTableViewController loadDummyWebView];
    }
    
    // Save search conditions
    [self saveSearchConditions];
    
    // Track by Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"SearchAction"
                                                          action:@"didTapSearchRecordButton"
                                                           label:@"searchRecord"
                                                           value:nil] build]];
}

# pragma mark - KFMatchConditionViewControllerDelegate
- (void)didSelectMatchName:(NSString *)matchName {
    self.matchName = matchName;
    [self.tableView reloadData];
}

# pragma mark - KFPlayerConditionViewControllerDelegate
- (void)didSelectPlayerName:(NSString *)playerName index:(NSInteger)playerIndex {
    switch (playerIndex) {
        case kFirstPlayerIndex:
            self.firstPlayerName = playerName;
            break;
        case kSecondPlayerIndex:
            self.secondPlayerName = playerName;
            break;
    }
    
    [self.tableView reloadData];
}

# pragma mark - KFStrategyConditionViewControllerDelegate
- (void)didSelectStrategy:(NSString *)strategyName {
    self.strategyName = strategyName;
    [self.tableView reloadData];
}

# pragma mark - KFTermConditionViewControllerDelegate
- (void)didSelectTerm:(KFTermCondition *)termCondition {
    self.termCondition = termCondition;
    [self.tableView reloadData];
}

# pragma mark - KFMatchTableViewControllerDelegate
- (void)didFinishLoadRecord:(KFRecord *)record {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadRecord:)]) {
        [self.delegate didFinishLoadRecord:record];
    }

    [self dismissViewControllerAnimated:YES completion:NULL];
}

# pragma mark - KFMatchTableViewControllerDelegate
- (void)dismissMatchTablePopover {
    [self.matchTablePopoverController dismissPopoverAnimated:YES];
}

# pragma mark - Private method
- (BOOL)isConditionBlank {
    if (!([self.firstPlayerName length] > 0) && !([self.secondPlayerName length] > 0) && !([self.matchName length] > 0) && !([self.strategyName length] > 0) && !self.termCondition) {
        return YES;
    } else {
        return NO;
    }
}

- (NSString *)buildRequestUrl {
//    NSString *domain = @"http://wiki.optus.nu/shogi/index.php?cmd=kif&cmds=query3&pagey=100";
    NSString *domain = @"http://wiki.optus.nu/shogi/index.php?cmd=kif&cmds=query3&pagex=0&pagey=1000&filename_check=checked";

    NSString *isKishiChecked = @"";
    NSString *isKisenChecked = @"";
    NSString *isSenkeiChecked = @"";
    NSString *isTermChecked = @"";

    NSString *firstPlayerEncoded = @"";
    NSString *kisenEncoded = @"";
    NSString *senkeiEncoded = @"";

    NSString *kisiA = @"";
    NSString *kisen = @"";
    NSString *senkei = @"";
    NSString *term = @"";
    
    if ([self.firstPlayerName length] > 0) {
        isKishiChecked = @"&kisi_check=checked";
        firstPlayerEncoded = [self.firstPlayerName stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding];
        kisiA = [NSString stringWithFormat:@"&kisi_a=%@", firstPlayerEncoded];
    }
    
    if ([self.matchName length] > 0) {
        isKisenChecked = @"&kisen_check=checked";
        kisenEncoded = [self.matchName stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding];
        kisen = [NSString stringWithFormat:@"&kisen=%@", kisenEncoded];
    }

    if ([self.strategyName length] > 0) {
        isSenkeiChecked = @"&senkei_check=checked";
        senkeiEncoded = [self.strategyName stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding];
        senkei = [NSString stringWithFormat:@"&senkei=%@", senkeiEncoded];
    }

    if (self.termCondition.startDate && self.termCondition.endDate) {
        term = [self buildTermRequestQuery];
    }

    NSString *url = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@", domain, isKishiChecked, kisiA, isSenkeiChecked, senkei, isKisenChecked, kisen, isTermChecked, term];

    NSLog(@"# URL : %@", url);
    
    return url;
}

- (void)saveSearchConditions {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    [userDefault setObject:self.matchName forKey:@"searchConditionMatchName"];
    [userDefault setObject:self.firstPlayerName forKey:@"searchConditionPlayerName"];
    [userDefault setObject:self.strategyName forKey:@"searchConditionStrategyName"];
}

- (void)restoreSearchConditions {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    self.matchName = [userDefault objectForKey:@"searchConditionMatchName"];
    self.firstPlayerName = [userDefault objectForKey:@"searchConditionPlayerName"];
    self.strategyName = [userDefault objectForKey:@"searchConditionStrategyName"];
}

- (NSString *) buildTermRequestQuery {
    NSString *term = @"";
    NSString *startYear;
    NSString *startMonth;
    NSString *startDay;
    NSString *endYear;
    NSString *endMonth;
    NSString *endDay;
    
    NSDateFormatter *yearFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *monthFormatter = [[NSDateFormatter alloc] init];
    NSDateFormatter *dayFormatter = [[NSDateFormatter alloc] init];
    
    [yearFormatter setDateFormat:@"yyyy"];
    [monthFormatter setDateFormat:@"MM"];
    [dayFormatter setDateFormat:@"dd"];
    
    startYear = [yearFormatter stringFromDate:self.termCondition.startDate];
    startMonth = [monthFormatter stringFromDate:self.termCondition.startDate];
    startDay = [dayFormatter stringFromDate:self.termCondition.startDate];
    endYear = [yearFormatter stringFromDate:self.termCondition.endDate];
    endMonth = [monthFormatter stringFromDate:self.termCondition.endDate];
    endDay = [dayFormatter stringFromDate:self.termCondition.endDate];
    
    if ([startYear length] > 0 && [startMonth length] > 0 && [startMonth length] > 0 && [endYear length] > 0 && [endMonth length] > 0 && [endDay length] > 0) {
        term = [NSString stringWithFormat:@"&dplay_check=checked&y_play1=%@&m_play1=%@&d_play1=%@&y_play2=%@&m_play2=%@&d_play2=%@", startYear, startMonth, startDay, endYear, endMonth, endDay];
    }
    
    return term;
}

@end
