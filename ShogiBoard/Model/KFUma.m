//
//  KFUma.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/29.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFUma.h"
#import "KFKaku.h"

@implementation KFUma

- (id)initWithSide:(NSInteger)side {
    self = [super initWithSide:side];
    
    if (self) {
        self.isPromoted = YES;
    }
    
    return self;
}

- (NSString *)getPieceName {
    return @"Uma";
}

- (NSString *)getPieceNameJp {
    return @"馬";
}

- (NSString *)getImageName {
    if (self.side == THIS_SIDE) {
        return @"s_uma.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_uma.png";
    } else {
        return nil;
    }
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return @"s_uma.png";
    } else if (side == COUNTER_SIDE) {
        return @"g_uma.png";
    } else {
        return nil;
    }
}

- (KFPiece *)getOriginalPiece {
    KFKaku *originalPiece = [[KFKaku alloc] initWithSide:self.side];
    
    return originalPiece;
}

- (NSString *)getPieceId {
    return PIECE_ID_UMA;
}

- (NSString *)getOriginalPieceId {
    return PIECE_ID_KAKU;
}

@end
