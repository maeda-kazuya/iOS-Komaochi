//
//  KFCommentViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/1/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFCommentViewController.h"
#import "KFMove.h"
#import "KFRecord.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface KFCommentViewController ()
@end

@implementation KFCommentViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // set AdMob unit (publisher) id
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;

    self.admobBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.admobBannerView.rootViewController = self;

    // Load AdMob
    GADRequest *adMobRequest = [GADRequest request];

    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.admobBannerView loadRequest:adMobRequest];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    self.isEditting = NO;
    self.commentView.editable = NO;
    self.editButton.title = @"編集";

    self.commentNaviItem.title = self.navTitle;
    self.commentView.text = [self.commentDic objectForKey:[NSString stringWithFormat:@"%ld", self.currentMoveIndex + 1]];
    
    // Google Analytics
    self.screenName = @"KFCommentViewController";
}

// Enable transparency of modalView for iPhone
- (UIModalPresentationStyle)modalPresentationStyle
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return UIModalPresentationOverCurrentContext;
    } else {
        return [super modalPresentationStyle];
    }
}

- (IBAction)goBack:(id)sender {
    [self dismissViewControllerAnimated:NO completion:NULL];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone && [self.delegate respondsToSelector:@selector(dismissCommentPopover)]) {
        [self.delegate dismissCommentPopover];
    }
}

- (IBAction)editComment:(id)sender {
    if (self.isEditting) {
        self.editButton.title = @"編集";
        self.isEditting = NO;
        self.commentView.editable = NO;

        [self updateComment:self.commentView.text];
        
        if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone && [self.delegate respondsToSelector:@selector(dismissCommentPopover)]) {
            [self.delegate dismissCommentPopover];
        }
        
        // Track for Google Analytics
        id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
        [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"CommentManagement"
                                                              action:@"updateCommentCompleted"
                                                               label:@"updateComment"
                                                               value:nil] build]];
    } else {
        // Edit comment
        self.editButton.title = @"保存";
        self.isEditting = YES;
        self.commentView.editable = YES;

        [self.commentView becomeFirstResponder];
    }
}

@end
