//
//  KFTitleDetailTableViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 11/16/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFTitleDetailTableViewController.h"
#import "KFTitleWebViewController.h"
#import "KFMatchTableViewController.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface KFTitleDetailTableViewController () <KFMatchTableViewControllerDelegate>
@end

@implementation KFTitleDetailTableViewController

- (id)initWithTitleId:(NSInteger)titleId
                  url:(NSString *)titleUrl {
    self = [super init];
    
    if (self) {
        self.titleId = titleId;
        self.titleUrl = titleUrl;
    }

    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    // set AdMob unit (publisher) id
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    
    self.adMobBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.adMobBannerView.rootViewController = self;
    
    // Load AdMob
    GADRequest *adMobRequest = [GADRequest request];

    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.adMobBannerView loadRequest:adMobRequest];
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.titleId == MATCH_ID_KAKOGAWA ||
        self.titleId == MATCH_ID_ASAHI
        ) {
        return 1;
    } else if (self.titleId == MATCH_ID_KISEI ||
               self.titleId == MATCH_ID_OUI ||
               self.titleId == MATCH_ID_OUZA ||
               self.titleId == MATCH_ID_TATSUJIN ||
               self.titleId == MATCH_ID_JORYU_MEIJIN ||
               self.titleId == MATCH_ID_JORYU_OUZA ||
               self.titleId == MATCH_ID_DAIWA ||
               self.titleId == MATCH_ID_JORYU_OUI
               ) {
        return 2;
    } else if (self.titleId == MATCH_ID_RYUOU || self.titleId == MATCH_ID_KIOU) { //TODO:棋王戦の36期以降が形式が違うので取れてない（要調査）
        // 竜王戦の第24期以前のkifファイルがバイナリで取得できない…
        return 3;
    } else if (self.titleId == MATCH_ID_SHINJIN) {
        return 6;
    }

    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    if (self.titleId == MATCH_ID_RYUOU) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"今期";
                break;
            case 1:
                cell.textLabel.text = @"前期";
                break;
            case 2:
                cell.textLabel.text = @"前々期";
                break;
        }
    } else if (self.titleId == MATCH_ID_KIOU) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"今期";
                break;
            case 1:
                cell.textLabel.text = @"前期";
                break;
            case 2:
                cell.textLabel.text = @"前々期";
                break;
        }
    } else if (self.titleId == MATCH_ID_KISEI ||
               self.titleId == MATCH_ID_OUI ||
               self.titleId == MATCH_ID_OUZA ||
               self.titleId == MATCH_ID_JORYU_OUZA ||
               self.titleId == MATCH_ID_DAIWA ||
               self.titleId == MATCH_ID_JORYU_OUI
               ) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"最新局";
                break;
            case 1:
                cell.textLabel.text = @"過去の対局";
                break;
        }
    } else if (self.titleId == MATCH_ID_SHINJIN) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"今期";
                break;
            case 1:
                cell.textLabel.text = @"前期";
                break;
            case 2:
                cell.textLabel.text = @"前々期";
                break;
        }
    } else if (self.titleId == MATCH_ID_TATSUJIN) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"最新局";
                break;
            case 1:
                cell.textLabel.text = @"過去の棋戦";
                break;
        }
    } else if (self.titleId == MATCH_ID_KAKOGAWA) {
        cell.textLabel.text = @"直近または過去の対局";
    } else if (self.titleId == MATCH_ID_JORYU_MEIJIN) {
        switch (indexPath.row) {
            case 0:
                cell.textLabel.text = @"最新局 ";
                break;
            case 1:
                cell.textLabel.text = @"過去の棋譜";
                break;
        }
    } else if (self.titleId == MATCH_ID_ASAHI) { // 過去の棋譜形式が面倒なのでとりあえず直近のみ
        cell.textLabel.text = @"直近または過去の対局";
    }
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSInteger detailId = 0;
    NSString *matchUrl;
    NSString *siteUrl;
    
    if (self.titleId == MATCH_ID_RYUOU) {
        siteUrl = RYUOU_KIFU_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_RYUOU_TOP;
                matchUrl = RYUOU_KIFU_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_RYUOU_TERM26;
                matchUrl = RYUOU_TERM26_KIFU_URL;
                
                break;
            case 2:
                detailId = MATCH_DETAIL_ID_RYUOU_TERM25;
                matchUrl = RYUOU_TERM25_KIFU_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_KISEI) {
        siteUrl = KISEI_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_KISEI_TOP;
                matchUrl = KISEI_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_KISEI_OTHER;
                matchUrl = KISEI_KIFU_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_KIOU) {
        siteUrl = KIOU_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_KIOU_TOP;
                matchUrl = KIOU_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_KIOU_TERM38;
                matchUrl = KIOU_TERM38_KIFU_URL;
                
                break;
            case 2:
                detailId = MATCH_DETAIL_ID_KIOU_TERM37;
                matchUrl = KIOU_TERM37_KIFU_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_OUI) {
        siteUrl = OUI_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_OUI_TOP;
                matchUrl = OUI_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_OUI_OTHER;
                matchUrl = OUI_ARCHIVE_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_OUZA) {
        siteUrl = OUZA_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_OUZA_TOP;
                matchUrl = OUZA_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_OUZA_OTHER;
                matchUrl = OUZA_ARCHIVE_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_SHINJIN) {
        siteUrl = SHINJIN_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_SHINJIN_TOP;
                matchUrl = SHINJIN_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_SHINJIN_TERM44;
                matchUrl = SHINJIN_TERM44_KIFU_URL;
                
                break;
            case 2:
                detailId = MATCH_DETAIL_ID_SHINJIN_TERM43;
                matchUrl = SHINJIN_TERM43_KIFU_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_TATSUJIN) {
        siteUrl = TATSUJIN_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_TATSUJIN_TOP;
                matchUrl = TATSUJIN_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_TATSUJIN_OTHER;
                matchUrl = TATSUJIN_ARCHIVE_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_KAKOGAWA) {
        siteUrl = KAKOGAWA_SITE_URL;
        detailId = MATCH_DETAIL_ID_KAKOGAWA_TOP;
        matchUrl = KAKOGAWA_SITE_URL;
    } else if  (self.titleId == MATCH_ID_JORYU_MEIJIN) {
        siteUrl = JORYU_MEIJIN_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_JORYU_MEIJIN_TOP;
                matchUrl = JORYU_MEIJIN_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_JORYU_MEIJIN_OTHER;
                matchUrl = JORYU_MEIJIN_ARCHIVE_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_JORYU_OUI) {
        siteUrl = JORYU_OUI_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_JORYU_OUI_TOP;
                matchUrl = JORYU_OUI_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_JORYU_OUI_OTHER;
                matchUrl = JORYU_OUI_ARCHIVE_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_JORYU_OUZA) {
        siteUrl = JORYU_OUZA_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_JORYU_OUZA_TOP;
                matchUrl = JORYU_OUZA_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_JORYU_OUZA_OTHER;
                matchUrl = JORYU_OUZA_ARCHIVE_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_ASAHI) {
        siteUrl = ASAHI_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_ASAHI_TOP;
                matchUrl = ASAHI_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_ASAHI_OTHER;
                matchUrl = ASAHI_ARCHIVE_URL;
                
                break;
        }
    } else if  (self.titleId == MATCH_ID_DAIWA) {
        siteUrl = DAIWA_SITE_URL;
        
        switch (indexPath.row) {
            case 0:
                detailId = MATCH_DETAIL_ID_DAIWA_TOP;
//                matchUrl = DAIWA_KIFU_URL;
                matchUrl = DAIWA_SITE_URL;
                
                break;
            case 1:
                detailId = MATCH_DETAIL_ID_DAIWA_OTHER;
                matchUrl = DAIWA_ARCHIVE_URL;
                
                break;
        }
    }
    
    self.matchTableViewController = [[KFMatchTableViewController alloc] initWithMatchId:self.titleId
                                                                          matchDetailId:detailId
                                                                                    url:matchUrl];
    
    self.matchTableViewController.siteUrl = siteUrl;
    self.matchTableViewController.delegate = self;

    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.matchTableViewController animated:YES completion:NULL];
        [self.matchTableViewController loadMatchList];
    } else {
        self.matchTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.matchTableViewController];
        
        self.matchTableViewController.preferredContentSize = self.view.frame.size;
        self.matchTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.matchTableViewController];
        
        [self.matchTablePopoverController presentPopoverFromRect:self.view.frame
                                                          inView:self.view
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
        
        [self.matchTableViewController loadMatchList];
    }
    
    
    // Track by Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"MatchManagement"
                                                          action:@"didSelectMatchFromTitleDetailVC"
                                                           label:@"showMatch"
                                                           value:[NSNumber numberWithInteger:self.titleId]] build]];
}

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

# pragma mark - KFMatchTableViewControllerDelegate
- (void)didFinishLoadRecord:(KFRecord *)record {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadRecord:)]) {
        [self.delegate didFinishLoadRecord:record];
    }
}

- (void)dismissMatchTablePopover {
    [self.matchTablePopoverController dismissPopoverAnimated:YES];
}

@end
