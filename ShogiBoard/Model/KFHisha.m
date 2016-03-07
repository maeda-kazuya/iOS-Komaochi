//
//  KFHisha.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/22.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFHisha.h"
#import "KFRyu.h"

@implementation KFHisha

- (id)initWithSide:(NSInteger)side {
    self = [super initWithSide:side];
    
    if (self) {
        self.canPromote = YES;
    }
    
    return self;
}

- (NSString *)getPieceName {
    return @"Hisha";
}

- (NSString *)getPieceNameJp {
    return @"飛";
}

- (NSString *)getImageName {
    if (self.side == THIS_SIDE) {
        return @"s_hisha.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_hisha.png";
    } else {
        return nil;
    }
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return @"s_hisha.png";
    } else if (side == COUNTER_SIDE) {
        return @"g_hisha.png";
    } else {
        return nil;
    }
}

- (NSString *)getPromotedImageName {
    if (self.side == THIS_SIDE) {
        return @"s_ryu.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_ryu.png";
    } else {
        return nil;
    }
}

- (KFPiece *)getPromotedPiece {
    KFRyu *promotedPiece = [[KFRyu alloc] initWithSide:self.side];
    
    return promotedPiece;
}

- (NSString *)getPieceId {
    return PIECE_ID_HISHA;
}

- (NSString *)getOriginalPieceId {
    return PIECE_ID_HISHA;
}

@end
