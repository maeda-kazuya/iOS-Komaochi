//
//  KFMove.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2014/01/12.
//  Copyright (c) 2014年 Kifoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFPiece;
@class KFSquareButton;
@class KFCapturedPieceButton;

@interface KFMove : NSObject

@property (strong, nonatomic) KFSquareButton *previousSquare;
@property (strong, nonatomic) KFSquareButton *currentSquare;
@property (strong, nonatomic) KFCapturedPieceButton *capturedPieceButton;
@property (strong, nonatomic) NSString *movedPieceId;
@property (strong, nonatomic) NSString *movedPieceName;
@property (strong, nonatomic) KFPiece *movedPiece;
@property (strong, nonatomic) KFPiece *capturedPiece;

@property NSInteger side;

@property BOOL didDrop;
@property BOOL didPromote;

- (NSString *)getMoveTextForShogiDB;
- (NSString *)getMoveTextWithMarked:(BOOL)marked;
- (NSString *)getMoveTextWithIndex:(NSInteger)index;
- (NSString *)getPreviousPosition;
- (NSString *)getMovedPieceName;
- (NSString *)getMovedPieceId;
- (NSString *)getXStr:(int)x;
- (NSString *)getYStr:(int)y;
- (NSInteger)getXInt:(NSString *)x;
- (NSInteger)getYInt:(NSString *)y;

@end
