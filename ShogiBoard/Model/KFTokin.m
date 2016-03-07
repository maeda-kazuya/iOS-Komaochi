//
//  KFTokin.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/29.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFTokin.h"
#import "KFFu.h"

@implementation KFTokin

- (id)initWithSide:(NSInteger)side {
    self = [super initWithSide:side];
    
    if (self) {
        self.isPromoted = YES;
    }
    
    return self;
}

- (NSString *)getPieceName {
    return @"To";
}

- (NSString *)getPieceNameJp {
    return @"と";
}

- (NSString *)getImageName {
    if (self.side == THIS_SIDE) {
        return @"s_to.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_to.png";
    } else {
        return nil;
    }
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return @"s_to.png";
    } else if (side == COUNTER_SIDE) {
        return @"g_to.png";
    } else {
        return nil;
    }
}

- (KFPiece *)getOriginalPiece {
    KFFu *originalPiece = [[KFFu alloc] initWithSide:self.side];
    
    return originalPiece;
}

- (NSString *)getPieceId {
    return PIECE_ID_TO;
}

- (NSString *)getOriginalPieceId {
    return PIECE_ID_FU;
}

@end
