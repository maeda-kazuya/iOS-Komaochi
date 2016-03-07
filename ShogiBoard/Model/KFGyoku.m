//
//  KFGyoku.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/22.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFGyoku.h"

@implementation KFGyoku

- (id)initWithSide:(NSInteger)side {
    self = [super initWithSide:side];
    
    if (self) {
        self.canPromote = NO;
    }
    
    return self;
}

- (NSString *)getPieceName {
    return @"Gyoku";
}

- (NSString *)getPieceNameJp {
    return @"玉";
}

- (NSString *)getImageName {
    if (self.side == THIS_SIDE) {
        return @"s_gyoku.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_gyoku.png";
    } else {
        return nil;
    }
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return @"s_gyoku.png";
    } else if (side == COUNTER_SIDE) {
        return @"g_gyoku.png";
    } else {
        return nil;
    }
}

- (NSString *)getPieceId {
    return PIECE_ID_GYOKU;
}

- (NSString *)getOriginalPieceId {
    return PIECE_ID_GYOKU;
}

@end
