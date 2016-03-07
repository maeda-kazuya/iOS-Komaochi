//
//  KFTitleViewController.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/01.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFTitleViewController.h"
#import "KFBoardViewController.h"

@interface KFTitleViewController ()

@end

@implementation KFTitleViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showBoard:(id)sender {
    KFBoardViewController *boardViewController = [[KFBoardViewController alloc] init];
    
//    [self.navigationController pushViewController:boardViewController animated:YES];
    [self presentViewController:boardViewController
                       animated:YES
                     completion:NULL];
}

- (IBAction)startMatch:(id)sender {
}

- (IBAction)showMyPage:(id)sender {
}
@end
