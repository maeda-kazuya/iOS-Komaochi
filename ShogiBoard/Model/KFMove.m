//
//  KFMove.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2014/01/12.
//  Copyright (c) 2014年 Kifoo, Inc. All rights reserved.
//

#import "KFMove.h"
#import "KFPiece.h"
#import "KFSquareButton.h"

@implementation KFMove

# pragma mark - Public methods
- (NSString *)getMoveTextWithMarked:(BOOL)marked {
    NSMutableString *moveText = [NSMutableString string];
    
    NSString *orderMark = marked ? [self getOrderMark] : nil;
    NSString *xStr = [self getXStr:self.currentSquare.x];
    NSString *yStr = [self getYStr:self.currentSquare.y];
    NSString *pieceName = [self getMovedPieceName];
    NSString *drop = [self getDropText];
    
    [moveText appendString:(orderMark ? orderMark : @"")];
    [moveText appendString:(xStr ? xStr : @"")];
    [moveText appendString:(yStr ? yStr : @"")];
    [moveText appendString:(pieceName ? pieceName : @"")];
    [moveText appendString:(drop ? drop : @"")];
    
    if (!self.didDrop) {
        NSString *promotion = [self getPromotionText];
        [moveText appendString:(promotion ? promotion : @"")];
    }
    
    return moveText;
}

- (NSString *)getMoveTextForShogiDB {
    NSMutableString *moveText = [NSMutableString string];
    
    NSString *xStr = [self getXStr:self.currentSquare.x];
    NSString *yStr = [self getYStr:self.currentSquare.y];
    NSString *pieceName = [self getMovedPieceNameForShogiDB];
    NSString *drop = [self getDropText];
    
    [moveText appendString:(xStr ? xStr : @"")];
    [moveText appendString:(yStr ? yStr : @"")];
    [moveText appendString:(pieceName ? pieceName : @"")];
    [moveText appendString:(drop ? drop : @"")];
    
    if (!self.didDrop) {
        NSString *promotion = [self getPromotionText];
        [moveText appendString:(promotion ? promotion : @"")];
    }
    
    return moveText;
}


- (NSString *)getMoveTextWithIndex:(NSInteger)index {
    return [NSString stringWithFormat:@"%ld手目 %@", index, [self getMoveTextWithMarked:YES]];
}

- (NSString *)getPreviousPosition {
    if (self.didDrop) {
        return @"";
    } else {
        return [NSString stringWithFormat:@"(%d%d)", self.previousSquare.x, self.previousSquare.y];
    }
}

- (NSString *)getMovedPieceName {
    NSString *pieceName = nil;
    
    switch (self.movedPieceId.intValue) {
        case 0:
            pieceName = @"玉";
            break;
        case 1:
            pieceName = @"金";
            break;
        case 2:
            pieceName = @"銀";
            break;
        case 3:
            pieceName = @"桂";
            break;
        case 4:
            pieceName = @"香";
            break;
        case 5:
            pieceName = @"角";
            break;
        case 6:
            pieceName = @"飛";
            break;
        case 7:
            pieceName = @"歩";
            break;
        case 8:
            pieceName = @"成銀";
            break;
        case 9:
            pieceName = @"成桂";
            break;
        case 10:
            pieceName = @"成香";
            break;
        case 11:
            pieceName = @"馬";
            break;
        case 12:
            pieceName = @"龍";
            break;
        case 13:
            pieceName = @"と";
            break;
        default:
            break;
    }
    
    return pieceName;
}

// 将棋DBの局面検索が玉でなく王でないと引っかからなかったりするため臨時で定義。
// やはりサーバ側も自分で実装する必要ありそう
- (NSString *)getMovedPieceNameForShogiDB {
    NSString *pieceName = nil;
    
    switch (self.movedPieceId.intValue) {
        case 0:
            pieceName = @"王";
            break;
        case 1:
            pieceName = @"金";
            break;
        case 2:
            pieceName = @"銀";
            break;
        case 3:
            pieceName = @"桂";
            break;
        case 4:
            pieceName = @"香";
            break;
        case 5:
            pieceName = @"角";
            break;
        case 6:
            pieceName = @"飛";
            break;
        case 7:
            pieceName = @"歩";
            break;
        case 8:
            pieceName = @"成銀";
            break;
        case 9:
            pieceName = @"成桂";
            break;
        case 10:
            pieceName = @"成香";
            break;
        case 11:
            pieceName = @"馬";
            break;
        case 12:
            pieceName = @"龍";
            break;
        case 13:
            pieceName = @"と";
            break;
        default:
            break;
    }
    
    return pieceName;
}

- (NSString *)getMovedPieceId {
    if ([self.movedPieceName isEqualToString:@"玉"] || [self.movedPieceName isEqualToString:@"王"]) {
        return @"0";
    } else if ([self.movedPieceName isEqualToString:@"金"]) {
        return @"1";
    } else if ([self.movedPieceName isEqualToString:@"銀"]) {
        return @"2";
    } else if ([self.movedPieceName isEqualToString:@"桂"]) {
        return @"3";
    } else if ([self.movedPieceName isEqualToString:@"香"]) {
        return @"4";
    } else if ([self.movedPieceName isEqualToString:@"角"]) {
        return @"5";
    } else if ([self.movedPieceName isEqualToString:@"飛"]) {
        return @"6";
    } else if ([self.movedPieceName isEqualToString:@"歩"]) {
        return @"7";
    } else if ([self.movedPieceName isEqualToString:@"成銀"]) {
        return @"8";
    } else if ([self.movedPieceName isEqualToString:@"成桂"]) {
        return @"9";
    } else if ([self.movedPieceName isEqualToString:@"成香"]) {
        return @"10";
    } else if ([self.movedPieceName isEqualToString:@"馬"]) {
        return @"11";
    } else if ([self.movedPieceName isEqualToString:@"龍"] || [self.movedPieceName isEqualToString:@"竜"]) {
        return @"12";
    } else if ([self.movedPieceName isEqualToString:@"と"]) {
        return @"13";
    } else {
        return nil;
    }
}

- (NSString *)getXStr:(int)x {
    NSString *xStr;
    
    switch (x) {
        case 1:
            xStr = @"１";
            break;
        case 2:
            xStr = @"２";
            break;
        case 3:
            xStr = @"３";
            break;
        case 4:
            xStr = @"４";
            break;
        case 5:
            xStr = @"５";
            break;
        case 6:
            xStr = @"６";
            break;
        case 7:
            xStr = @"７";
            break;
        case 8:
            xStr = @"８";
            break;
        case 9:
            xStr = @"９";
            break;
        default:
            break;
    }
    
    return xStr;
}

- (NSString *)getYStr:(int)y {
    NSString *yStr;
    
    switch (y) {
        case 1:
            yStr = @"一";
            break;
        case 2:
            yStr = @"二";
            break;
        case 3:
            yStr = @"三";
            break;
        case 4:
            yStr = @"四";
            break;
        case 5:
            yStr = @"五";
            break;
        case 6:
            yStr = @"六";
            break;
        case 7:
            yStr = @"七";
            break;
        case 8:
            yStr = @"八";
            break;
        case 9:
            yStr = @"九";
            break;
        default:
            break;
    }
    
    return yStr;
}

- (NSInteger)getXInt:(NSString *)x {
    NSInteger xInt = 0;
    
    if ([x isEqualToString:@"1"] || [x isEqualToString:@"１"]) {
        xInt = 1;
    } else if ([x isEqualToString:@"2"] || [x isEqualToString:@"２"]) {
        xInt = 2;
    } else if ([x isEqualToString:@"3"] || [x isEqualToString:@"３"]) {
        xInt = 3;
    } else if ([x isEqualToString:@"4"] || [x isEqualToString:@"４"]) {
        xInt = 4;
    } else if ([x isEqualToString:@"5"] || [x isEqualToString:@"５"]) {
        xInt = 5;
    } else if ([x isEqualToString:@"6"] || [x isEqualToString:@"６"]) {
        xInt = 6;
    } else if ([x isEqualToString:@"7"] || [x isEqualToString:@"７"]) {
        xInt = 7;
    } else if ([x isEqualToString:@"8"] || [x isEqualToString:@"８"]) {
        xInt = 8;
    } else if ([x isEqualToString:@"9"] || [x isEqualToString:@"９"]) {
        xInt = 9;
    }
    
    return xInt;
}

- (NSInteger)getYInt:(NSString *)y {
    NSInteger yInt = 0;
    
    if ([y isEqualToString:@"1"] || [y isEqualToString:@"１"] || [y isEqualToString:@"一"]) {
        yInt = 1;
    } else if ([y isEqualToString:@"2"] || [y isEqualToString:@"２"] || [y isEqualToString:@"二"]) {
        yInt = 2;
    } else if ([y isEqualToString:@"3"] || [y isEqualToString:@"３"] || [y isEqualToString:@"三"]) {
        yInt = 3;
    } else if ([y isEqualToString:@"4"] || [y isEqualToString:@"４"] || [y isEqualToString:@"四"]) {
        yInt = 4;
    } else if ([y isEqualToString:@"5"] || [y isEqualToString:@"５"] || [y isEqualToString:@"五"]) {
        yInt = 5;
    } else if ([y isEqualToString:@"6"] || [y isEqualToString:@"６"] || [y isEqualToString:@"六"]) {
        yInt = 6;
    } else if ([y isEqualToString:@"7"] || [y isEqualToString:@"７"] || [y isEqualToString:@"七"]) {
        yInt = 7;
    } else if ([y isEqualToString:@"8"] || [y isEqualToString:@"８"] || [y isEqualToString:@"八"]) {
        yInt = 8;
    } else if ([y isEqualToString:@"9"] || [y isEqualToString:@"９"] || [y isEqualToString:@"九"]) {
        yInt = 9;
    }
    
    return yInt;
}

# pragma mark - Private methods
- (NSString *)getOrderMark {
    if (self.side == THIS_SIDE) {
        return @"▲";
    } else {
        return @"△";
    }
}

- (NSString *)getPromotionText {
    KFPiece *movedPiece = self.movedPiece;

    if (self.didPromote) {
        // 成った場合
        return @"成";
    } else if ([movedPiece isPromoted]) {
        // すでに成っている場合
        return @"";
    } else {
        if (self.side == THIS_SIDE) {
            if (self.currentSquare.y < 4 || self.previousSquare.y < 4) {
                if (movedPiece.canPromote && !self.didPromote) {
                    // あえて成らなかった時
                    return @"不成";
                }
            }

            // 元々成れない時
            return @"";
        } else {
            if (self.currentSquare.y > 6 || self.previousSquare.y > 6) {
                if (movedPiece.canPromote && !self.didPromote) {
                    // あえて成らなかった時
                    return @"不成";
                }
            }
            // 元々成れない時
            return @"";
        }
    }
}

- (NSString *)getDropText {
    if (self.didDrop) {
        return @"打";
    } else {
        return @"";
    }
}

@end
