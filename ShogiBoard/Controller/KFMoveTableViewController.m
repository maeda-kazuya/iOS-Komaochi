//
//  KFMoveTableViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2/11/15.
//  Copyright (c) 2015 Kifoo, Inc. All rights reserved.
//

#import "KFMoveTableViewController.h"
#import "KFMove.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface KFMoveTableViewController ()
@end

@implementation KFMoveTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    // set AdMob unit (publisher) id
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    self.admobBottomBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.admobBottomBannerView.rootViewController = self;
    
    // Load AdMob
    GADRequest *adMobRequest = [GADRequest request];

    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.admobBottomBannerView loadRequest:adMobRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.currentMoveIndex inSection:0];
    if (indexPath && indexPath.row < [self.moveArray count]) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
    }
    
    // Google Analytics
    self.screenName = @"KFMoveTableViewController";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.moveArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    KFMove *move = [self.moveArray objectAtIndex:indexPath.row];
    cell.textLabel.text = [move getMoveTextWithIndex:indexPath.row + 1];
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(transferToMoveIndex:)]) {
        [self.delegate transferToMoveIndex:indexPath.row];
    }
    
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    // Track by Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"MoveManagement"
                                                          action:@"didSelectMoveRow"
                                                           label:@"selectMove"
                                                           value:nil] build]];
}

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
