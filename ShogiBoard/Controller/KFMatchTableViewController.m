//
//  KFMatchTableViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 11/1/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFMatchTableViewController.h"
#import "KFMatch.h"
#import "KFRecord.h"
#import "KFRecordLoader.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@import NendAd;

@interface KFMatchTableViewController () <KFRecordLoaderDelegate>
@property (strong, nonatomic) KFMatch *selectedMatch;
@end

@implementation KFMatchTableViewController

- (id)initWithMatchId:(NSInteger)matchId
        matchDetailId:(NSInteger)matchDetailId
                  url:(NSString *)matchListUrl {
    self = [super init];
    
    if (self) {
        self.matchId = matchId;
        self.matchDetailId = matchDetailId;
        self.matchListUrl = matchListUrl;
    }
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.isDummyWebAvailable = NO;
    
    self.recordLoader = [[KFRecordLoader alloc] init];
    self.recordLoader.delegate = self;
    self.recordLoader.matchId = self.matchId;
    self.recordLoader.matchDetailId = self.matchDetailId;
    self.recordLoader.matchListUrl = self.matchListUrl;
    self.recordLoader.siteUrl = self.siteUrl;
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl addTarget:self action:@selector(onRefresh) forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
    
    // set AdMob unit (publisher) id
    self.adMobBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.adMobBannerView.rootViewController = self;
    self.adMobBottomView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.adMobBottomView.rootViewController = self;

    // Load AdMob
    GADRequest *adMobRequest = [GADRequest request];
    
    [self.adMobBannerView loadRequest:adMobRequest];
    [self.adMobBottomView loadRequest:adMobRequest];

    // Show adMob for iPad
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone) {
        self.adMobBannerView.hidden = NO;
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    // Google Analytics
    self.screenName = @"KFMatchTableViewController";
}

- (void)onRefresh {
    if (self.isDummyWebAvailable) {
        [self.dummyWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.matchListUrl]]];
    } else {
        [self.recordLoader loadMatchList];
    }
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.matchList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    KFMatch *match = [self.matchList objectAtIndex:indexPath.row];

    if ([match.playerTitle length] > 0) {
        cell.textLabel.text = match.playerTitle;

        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ %@",
                                     match.date ? match.date : @"",
                                     match.matchTitle ? match.matchTitle : @""];
    } else {
        cell.textLabel.text = [NSString stringWithFormat:@"%@", match.matchTitle ? match.matchTitle : @""];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.textLabel.numberOfLines = 0;
    }

    // Set gray background color for the record which is checked already
    if ([self isCheckedRecord:match]) {
        cell.backgroundColor = [UIColor colorWithWhite:0.8 alpha:0.5];
    } else {
        cell.backgroundColor = [UIColor whiteColor];
    }

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KFMatch *match = [self.matchList objectAtIndex:indexPath.row];
    self.selectedMatch = match;
    self.recordLoader.recordUrl = match.recordUrl;
    
    [self.recordLoader loadRecord];

    // Save as checked record
    [self saveCheckedRecord:match];
    
    // Save the position of selected record row
    [self saveRecordRowIndex:indexPath.row];
    
    // Track by Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"MatchManagement"
                                                          action:@"didSelectMatchRecordRow"
                                                           label:@"loadMatch"
                                                           value:nil] build]];
}

# pragma mark - KFRecordLoaderDelegate
- (void)didFinishLoadMatchList:(NSArray *)matchList {
    NSLog(@"# [KFMatchTableViewController] didFinishLoadMatchList");
    
    [self.activityIndicator stopAnimating];
    
    if ([self.refreshControl isRefreshing]) {
        [self.refreshControl endRefreshing];
    }
    
    self.matchList = matchList;
    
    NSSortDescriptor *sort1 = [NSSortDescriptor sortDescriptorWithKey:@"date" ascending:NO];
    self.matchList = [self.matchList sortedArrayUsingDescriptors:@[sort1]];
    
    [self.tableView reloadData];
    
    // Scroll to the last selected row (only for "previous search")
    [self scrollToLastSelectedRow];
}

- (void)didFinishLoadRecord:(KFRecord *)record {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadRecord:)]) {
        if (self.selectedMatch.date) {
            record.date = self.selectedMatch.date;
        }
        
        [self.delegate didFinishLoadRecord:record];
    }
    
    self.selectedMatch = nil;
}

# pragma mark - UIWebViewDelegate
-(void)webViewDidFinishLoad:(UIWebView*)webView {
    NSLog(@"# webViewDidFinishLoad");
    NSString* html = [self.dummyWebView stringByEvaluatingJavaScriptFromString:@"document.getElementsByTagName('html')[0].outerHTML"];
    [self.recordLoader scanHTMLString:html];
}

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

# pragma mark - Private method
- (void)loadMatchList {
    [self.recordLoader loadMatchList];
}

- (void)loadMatchListByCondition {
    [self.recordLoader loadMatchListByCondition];
}

// URL直接読み込みだとHTMLソースが文字化けする場合があるので、webView経由でソースを取得する
- (void)loadDummyWebView {
    [self.activityIndicator startAnimating];
    
    self.isDummyWebAvailable = YES;

    self.dummyWebView = [[UIWebView alloc] init];
    self.dummyWebView.delegate = self;
    [self.dummyWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.matchListUrl]]];
    
    [self saveRequestUrl:self.matchListUrl];
}

- (void)loadSamePositionMatch {
    [self.activityIndicator startAnimating];
    
    self.isDummyWebAvailable = YES;
    
    self.dummyWebView = [[UIWebView alloc] init];
    self.dummyWebView.delegate = self;
    [self.dummyWebView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:self.matchListUrl]]];
    
    [self saveRequestUrl:self.matchListUrl];
}

- (void)saveRequestUrl:(NSString *)url {
    if (self.matchId == MATCH_ID_Search || self.matchId == MATCH_ID_POSITION) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:url forKey:@"previousSearchUrl"];
    }
}

- (void)saveCheckedRecord:(KFMatch *)match {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *checkedMatchKey = [NSString stringWithFormat:@"%@%@%@", match.date, match.matchTitle, match.playerTitle];
    
    [userDefault setObject:@"1" forKey:checkedMatchKey];
}

- (BOOL)isCheckedRecord:(KFMatch *)match {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    
    NSString *checkedMatchKey = [NSString stringWithFormat:@"%@%@%@", match.date, match.matchTitle, match.playerTitle];
    NSString *checked = [userDefault objectForKey:checkedMatchKey];

    if ([checked isEqualToString:@"1"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)saveRecordRowIndex:(NSInteger)index {
    if (self.matchId == MATCH_ID_Search || self.matchId == MATCH_ID_POSITION || self.matchId == MATCH_ID_PREVIOUS) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setInteger:index forKey:@"selectedRecordRowIndex"];
    }
}

- (void)scrollToLastSelectedRow {
    if (self.matchId != MATCH_ID_PREVIOUS) {
        return;
    }
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSInteger index = [userDefault integerForKey:@"selectedRecordRowIndex"];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
    
    if (indexPath.row && indexPath.row < [self.matchList count]) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
}

@end
