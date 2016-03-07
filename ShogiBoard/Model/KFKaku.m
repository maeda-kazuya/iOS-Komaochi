//
//  KFKaku.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/21.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFKaku.h"
#import "KFUma.h"

@implementation KFKaku

- (id)initWithSide:(NSInteger)side {
    self = [super initWithSide:side];
    
    if (self) {
        self.canPromote = YES;
    }
    
    return self;
}

- (NSString *)getPieceName {
    return @"Kaku";
}

- (NSString *)getPieceNameJp {
    return @"角";
}

- (NSString *)getImageName {
    if (self.side == THIS_SIDE) {
        return @"s_kaku.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_kaku.png";
    } else {
        return nil;
    }
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return @"s_kaku.png";
    } else if (side == COUNTER_SIDE) {
        return @"g_kaku.png";
    } else {
        return nil;
    }
}

- (NSString *)getPromotedImageName {
    if (self.side == THIS_SIDE) {
        return @"s_uma.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_uma.png";
    } else {
        return nil;
    }
}

- (KFPiece *)getPromotedPiece {
    KFUma *promotedPiece = [[KFUma alloc] initWithSide:self.side];
    
    return promotedPiece;
}

- (NSString *)getPieceId {
    return PIECE_ID_KAKU;
}

- (NSString *)getOriginalPieceId {
    return PIECE_ID_KAKU;
}

@end
