//
//  KFPiece.m
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/21.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFPiece.h"

@implementation KFPiece

- (id)initWithSide:(NSInteger)side {
    self = [super init];

    if (self) {
        self.side = side;
    }

    return self;
}

- (id)copyWithZone:(NSZone *)zone {
    KFPiece *piece = [[[self class] alloc] init];
    
    if (piece) {
        piece.side = self.side;
        piece.canPromote = self.canPromote;
        piece.isPromoted = self.isPromoted;
    }
    
    return piece;
}

- (NSString *)getPieceId {
    // Override this method in sub class
    return nil;
}

- (NSString *)getOriginalPieceId {
    // Override this method in sub class
    return nil;
}

- (NSString *)getPieceName {
    // Override this method in sub class
    return nil;
}

- (NSString *)getPieceNameJp {
    // Override this method in sub class
    return nil;
}

- (NSString *)getImageName {
    // Override this method in sub class
    return nil;
}

- (NSString *)getImageNameWithSide:(NSInteger)side {
    // Override this method in sub class
    return nil;
}

- (NSString *)getPromotedImageName {
    // Override this method in sub class
    return nil;
}

- (KFPiece *)getPromotedPiece {
    // Override this method in sub class
    return nil;
}

- (KFPiece *)getOriginalPiece {
    // Override this method in sub class
    return nil;
}


@end
