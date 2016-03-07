//
//  KFRecord.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2014/01/26.
//  Copyright (c) 2014年 Kifoo, Inc. All rights reserved.
//

#import "KFRecord.h"
#import "KFMove.h"
#import "KFSquareButton.h"
#import "KFPiece.h"
#import "GAI.h"
#import "GAIDictionaryBuilder.h"

@implementation KFRecord

- (id)init {
    self = [super init];

    if (self) {
        self.title = [NSString string];
        self.recordCSV = [NSMutableString string];
        self.moveArray = [NSArray array];
        self.commentDic = [NSDictionary dictionary];
        self.isCSV = YES;
    }

    return self;
}

# pragma mark - Public method
+ (KFRecord *)retrieveRecordAtIndex:(NSInteger)index {
    KFRecord *record = [[KFRecord alloc] init];
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recordArray = [NSMutableArray arrayWithArray:[userDefault arrayForKey:@"RecordArray"]];

    NSDictionary *recordDic = [recordArray objectAtIndex:index];
    
    record.index = index;
    record.title = [recordDic objectForKey:@"title"];
    record.recordCSV = [recordDic objectForKey:@"body"];
    record.commentDic = [self createCommentDicFromRecordDic:recordDic];
    record.isCSV = YES;
    
    return record;
}

+ (KFRecord *)buildRecordFromText:(NSString *)recordText {
    KFRecord *record = [[KFRecord alloc] init];

    //TODO:Implement
    //TODO:commentも付ける。boardVCでコメントを追加・編集するときローカル保存されたcsvを使ってるのでそのあたりもどうにかする。
    //webから読み込んだ場合もとりあえずcsvも作る？

    record.recordText = recordText;
    record.isCSV = NO;
    
    return record;
}

- (void)saveRecord {
    [self createRecordCSV];
    [self saveRecordInLocal];
    
    // Track for Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"RecordManagement"
                                                          action:@"saveRecordInLocalCompleted"
                                                           label:@"saveRecord"
                                                           value:nil] build]];
}

- (NSString *)getRecordText {
    NSMutableString *recordText = [NSMutableString string];
    int count = 1;
    
    for (KFMove *move in self.moveArray) {
        [recordText appendString:[NSString stringWithFormat:@"%d %@%@\n", count, [move getMoveTextWithMarked:NO], [move getPreviousPosition]]];
        count++;
    }
    NSLog(@"Record str:%@", recordText);

    return [NSString stringWithString:recordText];
}

- (void)updateRecord:(NSInteger)index {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recordArray = [NSMutableArray arrayWithArray:[userDefault arrayForKey:@"RecordArray"]];
    
    NSString *recordTitle = [[recordArray objectAtIndex:index] objectForKey:@"title"];
    
    [recordArray removeObjectAtIndex:index];

    [self createRecordCSV];
    
    NSMutableDictionary *recordDic = [NSMutableDictionary dictionary];
    
    [recordDic setObject:recordTitle forKey:@"title"];
    [recordDic setObject:self.recordCSV forKey:@"body"];
    [recordArray insertObject:recordDic atIndex:index];
    
    [userDefault setObject:recordArray forKey:@"RecordArray"];
}

- (void)addComment:(NSDictionary *)commentDic index:(NSInteger)index {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableArray *recordArray = [NSMutableArray arrayWithArray:[userDefault arrayForKey:@"RecordArray"]];
    NSMutableDictionary *recordDic = [NSMutableDictionary dictionary];
    
    // Copy the title and body
    NSString *recordTitle = [[recordArray objectAtIndex:index] objectForKey:@"title"];
    NSString *recordString = [[recordArray objectAtIndex:index] objectForKey:@"body"];

    NSString *oldRecordComment = [[recordArray objectAtIndex:index] objectForKey:@"comment"];
    NSMutableString *recordComment;

    // Copy comment
    if ([oldRecordComment length] > 0) {
        recordComment = [NSMutableString stringWithString:oldRecordComment];
    } else {
        recordComment = [NSMutableString string];
    }

    // Create comment string (CSV)
    for (NSString *key in [commentDic allKeys]) {
        NSString *comment = [commentDic objectForKey:key];        
        [recordComment appendString:[NSString stringWithFormat:@"%@,%@\n", key, comment]];
    }
    
    // Remove the element
    [recordArray removeObjectAtIndex:index];

    // Set record information
    [recordDic setObject:recordTitle forKey:@"title"];
    [recordDic setObject:recordString forKey:@"body"];
    [recordDic setObject:recordComment forKey:@"comment"];
    
    NSLog(@"###[KFRecord] recordDic:%@", recordDic);
    
    // Insert record
    [recordArray insertObject:recordDic atIndex:index];

    // Update userDefault
    [userDefault setObject:recordArray forKey:@"RecordArray"];
}

# pragma mark - Private method
- (void)createRecordCSV {
    self.recordCSV = [NSMutableString string];
    
    for (KFMove *move in self.moveArray) {
        NSString *previousX = [NSString stringWithFormat:@"%d", move.previousSquare.x];
        NSString *previousY = [NSString stringWithFormat:@"%d", move.previousSquare.y];
        NSString *currentX = [NSString stringWithFormat:@"%d", move.currentSquare.x];
        NSString *currentY = [NSString stringWithFormat:@"%d", move.currentSquare.y];
        NSString *side = [NSString stringWithFormat:@"%ld", move.movedPiece.side];
        NSString *pieceId = [move.movedPiece getPieceId];
        NSString *pieceName = [move.movedPiece getPieceName];
        NSString *didDrop = move.didDrop ? @"1" : @"0";
        NSString *didPromote = move.didPromote ? @"1" : @"0";

        [self.recordCSV appendString:[NSString stringWithFormat:@"%@,%@,%@,%@,%@,%@,%@,%@,%@\n", previousX, previousY, currentX, currentY, side, pieceId, pieceName, didDrop, didPromote]];
    }

    NSLog(@"### [FINISH] recordString : %@", self.recordCSV);
}

- (void)saveRecordInLocal {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSMutableDictionary *recordDic = [NSMutableDictionary dictionary];
    NSMutableArray *recordArray = [NSMutableArray arrayWithArray:[userDefault arrayForKey:@"RecordArray"]];
    
    if (!recordArray) {
        recordArray = [NSMutableArray array];
    }
    
    [recordDic setObject:self.title forKey:@"title"];
    
    [recordDic setObject:self.recordCSV forKey:@"body"];
    [recordArray addObject:recordDic];
    
    [userDefault setObject:recordArray forKey:@"RecordArray"];

//    NSLog(@"#### RecordArray : %@", recordArray);
}

+ (NSDictionary *)createCommentDicFromRecordDic:(NSDictionary *)recordDic {
    NSMutableDictionary *commentDic = [NSMutableDictionary dictionary];
    
    NSString *commentStr = [recordDic objectForKey:@"comment"];
    NSArray *lines = [commentStr componentsSeparatedByString:@"\n"];
    
    for (NSString *line in lines) {
        if (![line length] > 0) {
            break;
        }
        
        NSArray *items = [line componentsSeparatedByString:@","];
        NSString *indexKey = items[0];
        NSString *comment = items[1];
        
        [commentDic setObject:comment forKey:indexKey];
    }
    
    //    record.commentDic = [NSDictionary dictionaryWithDictionary:commentDic];
    return commentDic;
}

@end
