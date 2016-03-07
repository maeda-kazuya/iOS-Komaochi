//
//  KFMotionControl.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 10/11/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFPiece;
@class KFSquareButton;

@interface KFMotionControl : NSObject

+ (BOOL)isCorrectMotionOfPiece:(KFPiece *)piece
                    fromSquare:(KFSquareButton *)fromSquare
                      toSquare:(KFSquareButton *)toSquare;

+ (BOOL)doesPieceExistBetweenFrom:(KFSquareButton *)fromSquare
                               to:(KFSquareButton *)toSquare
                        squareDic:(NSDictionary *)squareDic
                    selectedPiece:(KFPiece *)piece;

+ (BOOL)isNifuForSide:(NSInteger)side
                  row:(NSInteger)row
            squareDic:(NSDictionary *)squareDic;

@end
