//
//  KFTermCondition.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/3/15.
//  Copyright (c) 2015 Kifoo, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KFTermCondition : NSObject

@property (strong, nonatomic) NSDate *startDate;
@property (strong, nonatomic) NSDate *endDate;

- (NSString *)description;

@end
