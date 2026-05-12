//
//  KFCommentBaseViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/9/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol KFCommentBaseViewControllerDelegate <NSObject>
- (void)didSaveComment;
- (void)dismissCommentPopover;
- (void)dismissSaveCommentPopover;
@end

@interface KFCommentBaseViewController : UIViewController

@property (strong, nonatomic) NSString *navTitle;
@property (weak, nonatomic) id<KFCommentBaseViewControllerDelegate> delegate;

@property NSInteger recordIndex;
@property NSInteger currentMoveIndex;

- (void)updateComment:(NSString *)comment;

@end
