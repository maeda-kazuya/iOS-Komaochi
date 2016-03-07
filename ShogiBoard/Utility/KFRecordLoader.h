//
//  KFRecordLoader.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 10/25/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFRecord;

@protocol KFRecordLoaderDelegate <NSObject>
@optional
- (void)didFinishLoadRecord:(KFRecord *)record;
- (void)didFinishLoadMatchList:(NSArray *)matchList;
@end

@interface KFRecordLoader : NSObject

@property (nonatomic) NSInteger matchId;
@property (nonatomic) NSInteger matchDetailId;
@property (strong, nonatomic) NSString *siteUrl;
@property (strong, nonatomic) NSString *matchListUrl;
@property (strong, nonatomic) NSString *matchListBody;
@property (strong, nonatomic) NSString *recordUrl;
@property (strong, nonatomic) NSString *recordBody;
@property (weak) id<KFRecordLoaderDelegate> delegate;

- (void)loadMatchList;
- (void)loadMatchListByCondition; //TODO:remove if unnecessary
- (void)loadRecord;
- (void)scanHTMLString:(NSString *)htmlString;

@end
