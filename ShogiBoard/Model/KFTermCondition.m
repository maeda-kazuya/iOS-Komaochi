//
//  KFTermCondition.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 3/3/15.
//  Copyright (c) 2015 Kifoo, Inc. All rights reserved.
//

#import "KFTermCondition.h"

@implementation KFTermCondition

- (NSString *)description {
    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy/MM/dd"];
    
    NSString* startDateString = [outputFormatter stringFromDate:self.startDate];
    NSString* endDateString = [outputFormatter stringFromDate:self.endDate];

    return [NSString stringWithFormat:@"%@ 〜 %@", startDateString, endDateString];
}

@end
