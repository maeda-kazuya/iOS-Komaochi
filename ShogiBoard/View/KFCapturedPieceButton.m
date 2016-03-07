//
//  KFCapturedPieceButton.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/25.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFCapturedPieceButton.h"

#define COUNT_LABEL_NORMAL_X    24
#define COUNT_LABEL_NORMAL_Y    10
#define COUNT_LABEL_WIDE_X      60
#define COUNT_LABEL_WIDE_Y      50

@implementation KFCapturedPieceButton

- (id)init {
    self = [super init];
    
    if (self) {
        NSInteger labelX;
        NSInteger labelY;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            labelX = COUNT_LABEL_NORMAL_X;
            labelY = COUNT_LABEL_NORMAL_Y;
        } else {
            labelX = COUNT_LABEL_WIDE_X;
            labelY = COUNT_LABEL_WIDE_Y;
        }
        
        self.countLabel = [[UILabel alloc] initWithFrame:CGRectMake(labelX, labelY, 32, 35)];
        self.countLabel.backgroundColor = [UIColor clearColor];
        self.countLabel.textColor = [UIColor whiteColor];
        [self addSubview:self.countLabel];
    }
    
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

@end
