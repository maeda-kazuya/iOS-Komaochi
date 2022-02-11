//
//  KFForkTableViewController.m
//  YaguraJoseki
//
//  Created by Maeda Kazuya on 4/29/15.
//  Copyright (c) 2015 Kifoo, Inc. All rights reserved.
//

#import "KFForkTableViewController.h"
#import "KFBoardViewController.h"
#import "KFRecord.h"
#import "KFRecordTableViewCell.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@import NendAd;

@interface KFForkTableViewController () <NADViewDelegate>
@end

@implementation KFForkTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!self.forkList) {
        // 初期状態
        self.navigationItem.title = @"駒落ち定跡";
        self.forkList = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"fork" ofType:@"plist"]];
        [self.tableView reloadData];
    } else {
        self.navigationItem.title = self.navigationTitle;
    }
    
    // Set Nend Ad view
    [self.nendBannerView setNendID:NEND_AD_ID spotID:NEND_SPOT_ID];
    [self.nendBannerView setDelegate:self];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.nendBannerView.hidden = YES;
    } else {
        // Show nend for iPhone
        [self.nendBannerView load];
    }

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
    
    // Google Analytics
    self.screenName = @"KFForkTableViewController";
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.forkList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    NSString *caption = [[self.forkList objectAtIndex:indexPath.row] objectForKey:@"Caption"];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = caption;
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    cell.textLabel.numberOfLines = 0;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *childForkList = [[self.forkList objectAtIndex:indexPath.row] objectForKey:@"Fork"];
    
    if (childForkList) {
        // Show fork list
        UIStoryboard *forkStoryboard = [UIStoryboard storyboardWithName:@"Fork" bundle:nil];
        KFForkTableViewController *nextForkTableViewController = [forkStoryboard instantiateViewControllerWithIdentifier:@"forkTableViewController"];
        nextForkTableViewController.navigationTitle = [[self.forkList objectAtIndex:indexPath.row] objectForKey:@"Caption"];
        nextForkTableViewController.forkList = childForkList;
        
        [self.navigationController pushViewController:nextForkTableViewController animated:YES];
    } else {
        // Show Shogi board
        KFBoardViewController *boardViewController;
        NSString *recordText = [[self.forkList objectAtIndex:indexPath.row] objectForKey:@"Record"];
        NSNumber *initialIndex = [[self.forkList objectAtIndex:indexPath.row] objectForKey:@"Index"];
        NSNumber *komaochiIndex = [[self.forkList objectAtIndex:indexPath.row] objectForKey:@"Handi"];
        KFRecord *record = [[KFRecord alloc] init];
        
        // Update Komaochi setting
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        [userDefault setObject:[NSString stringWithFormat:@"%ld", komaochiIndex.integerValue] forKey:@"komaochiIndex"];
        [userDefault synchronize];

        record.title = [[self.forkList objectAtIndex:indexPath.row] objectForKey:@"Caption"];
        record.recordText = recordText;
        record.isCSV = NO;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            boardViewController = [[KFBoardViewController alloc] initWithNibName:@"KFBoardViewController" bundle:nil];
        } else{
            boardViewController = [[KFBoardViewController alloc] initWithNibName:@"KFWideBoardViewController" bundle:nil];
        }

        // Show board in full screen
        boardViewController.modalPresentationStyle = UIModalPresentationFullScreen;

        [self presentViewController:boardViewController animated:YES completion:nil];
        
        [boardViewController readRecord:record];
        [boardViewController transferToMoveIndex:initialIndex.integerValue];
    }
}

# pragma mark - Nend

-(void)nadViewDidFinishLoad:(NADView *)adView {
    NSLog(@"delegate nadViewDidFinishLoad:");
}

-(void)nadViewDidReceiveAd:(NADView *)adView {
    NSLog(@"delegate nadViewDidReceiveAd:");
}

-(void)nadViewDidFailToReceiveAd:(NADView *)adView {
    NSLog(@"delegate nadViewDidFailToLoad:%@", adView.error);
    NSLog(@"Error code:%ld", adView.error.code);
    
    self.nendBannerView.hidden = YES;
}

@end
