//
//  KFNarikyo.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/29.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFNarikyo.h"
#import "KFKyosha.h"

@implementation KFNarikyo

- (id)initWithSide:(NSInteger)side {
    self = [super initWithSide:side];
    
    if (self) {
        self.isPromoted = YES;
    }
    
    return self;
}

- (NSString *)getPieceName {
    return @"Narikyo";
}

- (NSString *)getPieceNameJp {
    return @"成香";
}

- (NSString *)getImageName {
    if (self.side == THIS_SIDE) {
        return @"s_narikyo.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_narikyo.png";
    } else {
        return nil;
    }
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return @"s_narikyo.png";
    } else if (side == COUNTER_SIDE) {
        return @"g_narikyo.png";
    } else {
        return nil;
    }
}

- (KFPiece *)getOriginalPiece {
    KFKyosha *originalPiece = [[KFKyosha alloc] initWithSide:self.side];
    
    return originalPiece;
}

- (NSString *)getPieceId {
    return PIECE_ID_NARIKYO;
}

- (NSString *)getOriginalPieceId {
    return PIECE_ID_KYO;
}

@end
