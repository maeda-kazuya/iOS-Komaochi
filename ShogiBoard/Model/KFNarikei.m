//
//  KFNarikei.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/29.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFNarikei.h"
#import "KFKeima.h"

@implementation KFNarikei

- (id)initWithSide:(NSInteger)side {
    self = [super initWithSide:side];
    
    if (self) {
        self.isPromoted = YES;
    }
    
    return self;
}

- (NSString *)getPieceName {
    return @"Narikei";
}

- (NSString *)getPieceNameJp {
    return @"成桂";
}

- (NSString *)getImageName {
    if (self.side == THIS_SIDE) {
        return @"s_narikei.png";
    } else if (self.side == COUNTER_SIDE) {
        return @"g_narikei.png";
    } else {
        return nil;
    }
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return @"s_narikei.png";
    } else if (side == COUNTER_SIDE) {
        return @"g_narikei.png";
    } else {
        return nil;
    }
}

- (KFPiece *)getOriginalPiece {
    KFKeima *originalPiece = [[KFKeima alloc] initWithSide:self.side];
    
    return originalPiece;
}

- (NSString *)getPieceId {
    return PIECE_ID_NARIKEI;
}

- (NSString *)getOriginalPieceId {
    return PIECE_ID_KEI;
}

@end
