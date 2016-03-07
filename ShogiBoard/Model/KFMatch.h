//
//  KFMatch.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 11/1/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@class KFRecord;

@interface KFMatch : NSObject

@property (strong, nonatomic) NSString *wholeTitle;
@property (strong, nonatomic) NSString *playerTitle;
@property (strong, nonatomic) NSString *matchTitle;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *recordUrl;
@property (strong, nonatomic) KFRecord *record;

@end
