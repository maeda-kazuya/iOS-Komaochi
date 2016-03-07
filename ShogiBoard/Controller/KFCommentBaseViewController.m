//
//  KFCommentBaseViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/9/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFCommentBaseViewController.h"
#import "KFRecord.h"

@interface KFCommentBaseViewController ()

@end

@implementation KFCommentBaseViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)updateComment:(NSString *)comment {
    // Update record with comment
    KFRecord *record = [[KFRecord alloc] init];
    
    // Set comment at index+1 (comment[1] : move[0])
    NSDictionary *commentDic = [NSDictionary dictionaryWithObject:comment forKey:[NSString stringWithFormat:@"%ld", self.currentMoveIndex + 1]];
    
    [record addComment:commentDic index:self.recordIndex];
    
    if ([self.delegate respondsToSelector:@selector(didSaveComment)]) {
        [self.delegate didSaveComment];
    }
}

@end
