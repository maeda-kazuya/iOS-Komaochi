//
//  KFRecordTableViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2014/01/26.
//  Copyright (c) 2014年 Kifoo, Inc. All rights reserved.
//

#import "KFRecordTableViewController.h"
#import "KFRecord.h"
#import "KFRecordTableViewCell.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@import NendAd;

@interface KFRecordTableViewController () <NADViewDelegate>

@end

@implementation KFRecordTableViewController

static NSString * const KFRecordTableViewCellIdentifier = @"KFRecordTableViewCell";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UINib *nib = [UINib nibWithNibName:KFRecordTableViewCellIdentifier bundle:nil];
    [self.recordTableView registerNib:nib forCellReuseIdentifier:@"Cell"];
    
    // Set Nend Ad view
    /*
    [self.nendAdView setNendID:NEND_AD_ID spotID:NEND_SPOT_ID];
    [self.nendAdView setDelegate:self];
    [self.nendAdView load];
     */

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

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.userDefault = [NSUserDefaults standardUserDefaults];

    // (DEBUG) 一括削除する場合
    /*
    [userDefault removeObjectForKey:@"RecordArray"];
    [userDefault synchronize];
     */

    self.recordArray = [NSMutableArray arrayWithArray:[self.userDefault arrayForKey:@"RecordArray"]];
    self.recordCount = [self.recordArray count];

    [self.recordTableView reloadData];
    
    // Google Analytics
    self.screenName = @"KFRecordTableViewController";
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recordCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    KFRecordTableViewCell *cell = (KFRecordTableViewCell *)[self tableView:self.recordTableView cellForRowAtIndexPath:indexPath];
    NSString *text = cell.titleLabel.text;

    CGSize size = CGSizeMake(cell.titleLabel.frame.size.width, 1000);
    CGSize textSize = [text sizeWithFont:cell.titleLabel.font
                       constrainedToSize:size
                           lineBreakMode:NSLineBreakByTruncatingTail];

    return MAX(textSize.height + 20, 44);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    KFRecordTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) {
        cell = [[KFRecordTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    cell.titleLabel.text = [[self.recordArray objectAtIndex:indexPath.row] objectForKey:@"title"];
    
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [self.recordArray removeObjectAtIndex:indexPath.row];
        self.recordCount = [self.recordArray count];
        
        // Update UserDefaults
        [self.userDefault setObject:self.recordArray forKey:@"RecordArray"];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadRecord:)]) {
        KFRecord *record = [KFRecord retrieveRecordAtIndex:indexPath.row];
        [self.delegate didFinishLoadRecord:record];
    }

    // Track for Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"RecordManagement"
                                                          action:@"didSelectLocalRecordRow"
                                                           label:@"readRecord"
                                                           value:nil] build]];
}

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
