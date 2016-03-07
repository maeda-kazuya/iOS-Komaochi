//
//  KFRecord.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2014/01/26.
//  Copyright (c) 2014年 Kifoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFRecord : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *matchName;
@property (strong, nonatomic) NSString *firstPlayer; // 先手
@property (strong, nonatomic) NSString *secondPlayer; // 後手
@property (strong, nonatomic) NSDictionary *commentDic;
@property (strong, nonatomic) NSArray *moveArray;
@property (strong, nonatomic) NSString *recordTitle;
@property (strong, nonatomic) NSMutableString *recordCSV;
@property (strong, nonatomic) NSString *recordText;

@property (nonatomic) NSInteger index;
@property (nonatomic) BOOL isCSV; //TODO:いずれはCSVでなくkif形式を使うようにしたい

+ (KFRecord *)retrieveRecordAtIndex:(NSInteger)index;
+ (KFRecord *)buildRecordFromText:(NSString *)recordText;
- (void)saveRecord;
- (void)updateRecord:(NSInteger)index;
- (void)addComment:(NSDictionary *)commentDic index:(NSInteger)index;
- (NSString *)getRecordText;

@end
