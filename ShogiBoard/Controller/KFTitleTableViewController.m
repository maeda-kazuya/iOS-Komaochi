//
//  KFTitleTableViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 11/15/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFTitleTableViewController.h"
#import "KFTitleDetailTableViewController.h"
#import "KFTitleWebViewController.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

static const NSInteger kTitleMatchIdFirstNumber = 101;

@interface KFTitleTableViewController () <KFTitleDetailTableViewControllerDelegate>
@end

@implementation KFTitleTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.titleList = [NSArray arrayWithObjects:
                      RYUOU_TITLE_NAME,
                      KISEI_TITLE_NAME,
                      KIOU_TITLE_NAME,
                      OUI_TITLE_NAME,
                      OUZA_TITLE_NAME,
                      SHINJIN_TITLE_NAME,
                      TATSUJIN_TITLE_NAME,
                      KAKOGAWA_TITLE_NAME,
                      JORYU_MEIJIN_TITLE_NAME,
                      JORYU_OUI_TITLE_NAME,
                      RICOH_TITLE_NAME,
                      ASAHI_TITLE_NAME,
                      DAIWA_TITLE_NAME, nil];
    
    self.titleUrlDic = [NSDictionary dictionaryWithObjectsAndKeys:
                        RYUOU_KIFU_URL, RYUOU_TITLE_NAME,
                        KISEI_KIFU_URL, KISEI_TITLE_NAME,
                        KIOU_KIFU_URL, KIOU_TITLE_NAME,
                        OUI_KIFU_URL, OUI_TITLE_NAME,
                        OUZA_KIFU_URL, OUZA_TITLE_NAME,
                        SHINJIN_KIFU_URL, SHINJIN_TITLE_NAME,
                        TATSUJIN_KIFU_URL, TATSUJIN_TITLE_NAME,
                        KAKOGAWA_KIFU_URL, KAKOGAWA_TITLE_NAME,
                        JORYU_MEIJIN_KIFU_URL, JORYU_MEIJIN_TITLE_NAME,
                        JORYU_OUI_KIFU_URL, JORYU_OUI_TITLE_NAME,
                        RICOH_KIFU_URL, RICOH_TITLE_NAME,
                        ASAHI_KIFU_URL, ASAHI_TITLE_NAME,
                        DAIWA_KIFU_URL, DAIWA_TITLE_NAME, nil];

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
    self.screenName = @"KFTitleTableViewController";
}

#pragma mark - Table view data source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.titleList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
    }
    
    cell.textLabel.text = [self.titleList objectAtIndex:indexPath.row];

    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    KFTitleDetailTableViewController *detailTableViewController;
    
    NSString *titleName = [self.titleList objectAtIndex:indexPath.row];
    NSString *url = [self.titleUrlDic objectForKey:titleName];

    NSLog(@"# titleName : %@", titleName);
    NSLog(@"# url : %@", url);

    detailTableViewController = [[KFTitleDetailTableViewController alloc] initWithTitleId:indexPath.row + kTitleMatchIdFirstNumber url:url];
    detailTableViewController.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:detailTableViewController animated:YES completion:NULL];
    } else {
        self.titleDetailPopoverController = [[UIPopoverController alloc] initWithContentViewController:detailTableViewController];

        detailTableViewController.preferredContentSize = CGSizeMake(320, 900);
        self.titleDetailPopoverController = [[UIPopoverController alloc] initWithContentViewController:detailTableViewController];
        
        [self.titleDetailPopoverController presentPopoverFromRect:self.view.frame
                                                           inView:self.view
                                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                         animated:YES];
    }
}

- (IBAction)backButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

# pragma mark - KFTitleDetailTableViewControllerDelegate
- (void)didFinishLoadRecord:(KFRecord *)record {
    if ([self.delegate respondsToSelector:@selector(didFinishLoadRecord:)]) {
        [self.delegate didFinishLoadRecord:record];
    }
}

- (void)dismissTitleDetailTablePopover {
    [self.titleDetailPopoverController dismissPopoverAnimated:YES];
}

@end
