//
//  KFPiece.h
//  Kifoo
//
//  Created by Maeda Kazuya on 2013/12/21.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFPiece : NSObject<NSCopying>

@property NSInteger side;
@property BOOL canPromote;
@property BOOL isPromoted;

- (id)initWithSide:(NSInteger)side;

- (NSString *)getPieceId;         // Return the pieceId with its promoting status. (e.g.)"Ryu" returns the pieceId of "Ryu"
- (NSString *)getOriginalPieceId; // Return the original pieceId regardless of promoting status. (e.g.)"Ryu" returns the pieceId of "Hisha"
- (NSString *)getPieceName;
- (NSString *)getPieceNameJp;
- (NSString *)getImageName;
- (NSString *)getImageNameWithSide:(NSInteger)side;
- (NSString *)getPromotedImageName;
- (KFPiece *)getPromotedPiece;
- (KFPiece *)getOriginalPiece;

@end
