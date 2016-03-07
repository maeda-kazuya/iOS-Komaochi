//
//  KFKeima.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/22.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFKeima.h"
#import "KFNarikei.h"

@implementation KFKeima

- (id)initWithSide:(NSInteger)side {
    self = [super initWithSide:side];
    
    if (self) {
        self.canPromote = YES;
    }
    
    return self;
}

- (NSString *)getPieceName {
    return @"Keima";
}

- (NSString *)getPieceNameJp {
    return @"桂";
}

- (NSString *)getImageName {
    if (self.side == THIS_SIDE) {
        return @"s_kei.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_kei.png";
    } else {
        return nil;
    }
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return @"s_kei.png";
    } else if (side == COUNTER_SIDE) {
        return @"g_kei.png";
    } else {
        return nil;
    }
}

- (NSString *)getPromotedImageName {
    if (self.side == THIS_SIDE) {
        return @"s_narikei.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_narikei.png";
    } else {
        return nil;
    }
}

- (KFPiece *)getPromotedPiece {
    KFNarikei *promotedPiece = [[KFNarikei alloc] initWithSide:self.side];
    
    return promotedPiece;
}

- (NSString *)getPieceId {
    return PIECE_ID_KEI;
}

- (NSString *)getOriginalPieceId {
    return PIECE_ID_KEI;
}

@end
