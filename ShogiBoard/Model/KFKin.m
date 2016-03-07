//
//  KFKin.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/22.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFKin.h"

@implementation KFKin

- (id)initWithSide:(NSInteger)side {
    self = [super initWithSide:side];
    
    if (self) {
        self.canPromote = NO;
    }
    
    return self;
}

- (NSString *)getPieceName {
    return @"Kin";
}

- (NSString *)getPieceNameJp {
    return @"金";
}

- (NSString *)getImageName {
    if (self.side == THIS_SIDE) {
        return @"s_kin.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_kin.png";
    } else {
        return nil;
    }
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return @"s_kin.png";
    } else if (side == COUNTER_SIDE) {
        return @"g_kin.png";
    } else {
        return nil;
    }
}

- (NSString *)getPieceId {
    return PIECE_ID_KIN;
}

- (NSString *)getOriginalPieceId {
    return PIECE_ID_KIN;
}

@end
