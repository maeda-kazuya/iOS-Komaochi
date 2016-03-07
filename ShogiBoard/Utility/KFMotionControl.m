//
//  KFMotionControl.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 10/11/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFMotionControl.h"
#import "KFPiece.h"
#import "KFSquareButton.h"

//TODO:打ち歩詰め、行き場のない駒のチェック
@implementation KFMotionControl

+ (BOOL)isCorrectMotionOfPiece:(KFPiece *)piece
                    fromSquare:(KFSquareButton *)fromSquare
                      toSquare:(KFSquareButton *)toSquare {
    BOOL isCorrectMotion = NO;
    NSString *pieceId = [piece getPieceId];
    NSInteger side = piece.side;
    int fromX = fromSquare.x;
    int fromY = fromSquare.y;
    int toX = toSquare.x;
    int toY = toSquare.y;
    
    if ([pieceId isEqualToString:PIECE_ID_FU]) {
        if (side == THIS_SIDE) {
            if (fromX == toX && fromY - toY == 1) {
                isCorrectMotion = YES;
            }
        } else {
            if (fromX == toX && toY - fromY == 1) {
                isCorrectMotion = YES;
            }
        }
    } else if ([pieceId isEqualToString:PIECE_ID_KYO]) {
        if (side == THIS_SIDE) {
            if (fromX == toX && fromY - toY > 0) {
                isCorrectMotion = YES;
            }
        } else {
            if (fromX == toX && toY - fromY > 0) {
                isCorrectMotion = YES;
            }
        }

    } else if ([pieceId isEqualToString:PIECE_ID_KEI]) {
        if (side == THIS_SIDE) {
            if (fabs(fromX - toX) == 1 && fromY - toY == 2) {

                isCorrectMotion = YES;
            }
        } else {
            if (fabs(fromX - toX) == 1 && toY - fromY == 2) {
                isCorrectMotion = YES;
            }
        }

    } else if ([pieceId isEqualToString:PIECE_ID_GIN]) {
        if (side == THIS_SIDE) {
            if ((fabs(fromX - toX) < 2 && fromY - toY == 1) || (fabs(fromX - toX) == 1 && toY - fromY == 1)) {
                isCorrectMotion = YES;
            }
        } else {
            if ((fabs(fromX - toX) < 2 && toY - fromY == 1) || (fabs(fromX - toX) == 1 && fromY - toY == 1)) {
                isCorrectMotion = YES;
            }
        }

    } else if ([pieceId isEqualToString:PIECE_ID_KIN] ||
               [pieceId isEqualToString:PIECE_ID_TO] ||
               [pieceId isEqualToString:PIECE_ID_NARIKYO] ||
               [pieceId isEqualToString:PIECE_ID_NARIKEI] ||
               [pieceId isEqualToString:PIECE_ID_NARIGIN]) {
        if (side == THIS_SIDE) {
            if ((fabs(fromX - toX) < 2 && fromY - toY == 1) || (fabs(fromX - toX) == 1 && toY == fromY) || (toX == fromX && toY - fromY == 1)) {
                isCorrectMotion = YES;
            }
        } else {
            if ((fabs(fromX - toX) < 2 && toY - fromY == 1) || (fabs(fromX - toX) == 1 && toY == fromY) || (toX == fromX && fromY - toY == 1)) {
                isCorrectMotion = YES;
            }
        }

    } else if ([pieceId isEqualToString:PIECE_ID_GYOKU]) {
        // 斜め及び真っ直ぐの前後の動き　又は　横の動き
        if ((fabs(fromX - toX) < 2 && fabs(fromY - toY) == 1) || (fabs(fromX - toX) == 1 && toY == fromY)) {
            isCorrectMotion = YES;
        }
    } else if ([pieceId isEqualToString:PIECE_ID_HISHA]) {
        if (fromX == toX || fromY == toY) {
            isCorrectMotion = YES;
        }
    } else if ([pieceId isEqualToString:PIECE_ID_RYU]) {
        if (fromX == toX || fromY == toY || (fabs(fromX - toX) < 2 && fabs(fromY - toY) == 1)) {
            isCorrectMotion = YES;
        }
    } else if ([pieceId isEqualToString:PIECE_ID_KAKU]) {
        if (fabs(fromX - toX) == fabs(fromY - toY)) {
            isCorrectMotion = YES;
        }
    } else if ([pieceId isEqualToString:PIECE_ID_UMA]) {
        if (fabs(fromX - toX) == fabs(fromY - toY) || (fabs(fromX - toX) == 1 && fromY == toY) || (fabs(fromY - toY) == 1 && fromX == toX)) {
            isCorrectMotion = YES;
        }
    }

    return isCorrectMotion;
}

+ (BOOL)doesPieceExistBetweenFrom:(KFSquareButton *)fromSquare
                               to:(KFSquareButton *)toSquare
                        squareDic:(NSDictionary *)squareDic
                    selectedPiece:(KFPiece *)piece {
    BOOL doesPieceExist = NO;
    NSString *pieceId = [piece getPieceId];

    int fromX = fromSquare.x;
    int fromY = fromSquare.y;
    int toX = toSquare.x;
    int toY = toSquare.y;
    
    if ([pieceId isEqualToString:PIECE_ID_HISHA] || [pieceId isEqualToString:PIECE_ID_RYU] || [pieceId isEqualToString:PIECE_ID_KYO]) {
        int start = 0;
        int end = 0;
        
        if (fromX == toX) { // 縦方向の移動
            if (fromY > toY) { // 下から上へ
                start = toY + 1;
                end = fromY - 1;
            } else {           // 上から下へ
                start = fromY + 1;
                end = toY - 1;
            }
            
            for (int i = start; i <= end; i++) {
                KFSquareButton *square = [squareDic objectForKey:[NSString stringWithFormat:@"%d%d", fromX, i]];
                if (square.locatedPiece) {
                    doesPieceExist = YES;
                }
            }
        } else if (fromY == toY) { // 横方向の移動
            if (fromX > toX) { // 左から右へ
                start = toX + 1;
                end = fromX - 1;
            } else {           // 右から左へ
                start = fromX + 1;
                end = toX - 1;
            }

            for (int i = start; i <= end; i++) {
                KFSquareButton *square = [squareDic objectForKey:[NSString stringWithFormat:@"%d%d", i, fromY]];
                if (square.locatedPiece) {
                    doesPieceExist = YES;
                }
            }
        }
    }
    
    if ([pieceId isEqualToString:PIECE_ID_KAKU] || [pieceId isEqualToString:PIECE_ID_UMA]) {
        int startX = 0;
        int startY = 0;
        int end = 0;
        int i, j;

        KFSquareButton *square;
        
        if (toX - fromX > 0 && toY - fromY > 0) { // 右上から左下へ
            startX = fromX + 1;
            startY = fromY + 1;
            end = toX - 1;
            
            for (i = startX, j = startY; i <= end; i++, j++) {
                square = [squareDic objectForKey:[NSString stringWithFormat:@"%d%d", i, j]];
                if (square.locatedPiece) {
                    doesPieceExist = YES;
                }
            }
        } else if (toX - fromX > 0 && toY - fromY < 0) { // 右下から左上へ
            startX = fromX + 1;
            startY = fromY - 1;
            end = toX - 1;
            
            for (i = startX, j = startY; i <= end; i++, j--) {
                square = [squareDic objectForKey:[NSString stringWithFormat:@"%d%d", i, j]];
                if (square.locatedPiece) {
                    doesPieceExist = YES;
                }
            }
            
        } else if (toX - fromX < 0 && toY - fromY > 0) { // 左上から右下へ
            startX = fromX - 1;
            startY = fromY + 1;
            end = toX + 1;
            
            for (i = startX, j = startY; i >= end; i--, j++) {
                square = [squareDic objectForKey:[NSString stringWithFormat:@"%d%d", i, j]];
                if (square.locatedPiece) {
                    doesPieceExist = YES;
                }
            }
        } else if (toX - fromX < 0 && toY - fromY < 0) { // 左下から右上へ
            startX = fromX - 1;
            startY = fromY - 1;
            end = toX + 1;
            
            for (i = startX, j = startY; i >= end; i--, j--) {
                square = [squareDic objectForKey:[NSString stringWithFormat:@"%d%d", i, j]];
                if (square.locatedPiece) {
                    doesPieceExist = YES;
                }
            }
        }
    }

    return doesPieceExist;
}

+ (BOOL)isNifuForSide:(NSInteger)side row:(NSInteger)row squareDic:(NSDictionary *)squareDic {
    BOOL isNifu = NO;
    KFSquareButton *square;
    
    for (int i = 0; i < 9; i++) {
        square = [squareDic objectForKey:[NSString stringWithFormat:@"%ld%d", row, i]];
        
        if (square.locatedPiece.side == side && [[square.locatedPiece getPieceId] isEqualToString:PIECE_ID_FU]) {
            isNifu = YES;
        }
    }
    
    return isNifu;
}

@end
