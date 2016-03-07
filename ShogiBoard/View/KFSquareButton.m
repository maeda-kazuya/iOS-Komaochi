//
//  KFSquareButton.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2013/12/21.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFSquareButton.h"

@implementation KFSquareButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (id)copy {
    KFSquareButton *button = [[KFSquareButton alloc] init];
    
    button.locatedPiece = self.locatedPiece;
    
    return button;
}

- (void)setCoordinateX:(int)x Y:(int)y {
    self.x = x;
    self.y = y;
}

@end
