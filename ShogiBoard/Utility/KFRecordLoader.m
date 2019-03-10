//
//  KFRecordLoader.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 10/25/14.
//  Copyright (c) 2014 Kifoo, Inc. All rights reserved.
//

#import "KFRecordLoader.h"
#import "KFMatch.h"
#import "KFRecord.h"

@implementation KFRecordLoader

- (void)loadMatchList {
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.matchListUrl]
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:5.0];
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:queue
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
//                              // NSLog(@"res:%@", res);
//                              // NSLog(@"data:%@", data);
                               
                               self.matchListBody = [[NSString alloc] initWithData:data encoding:[self detectEncoding:data]];
//                               NSLog(@"responseText = %@", self.matchListBody);
                               
                               if (error) {
                                  // NSLog(@"%@", error);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                   message:@"棋戦リストを読み込めませんでした"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                   [alert show];

                                   return;
                               }
                               
                               NSMutableArray *matchList = [NSMutableArray array];
                               
                               NSArray *lines = [self.matchListBody componentsSeparatedByString:@"\n"];
                               NSString *term = @"";
                               NSString *gameName = @"";
                               
                               int count = 0;
                               
                               for (NSString *line in lines) {
                                   if (![line length] > 0) {
                                       break;
                                   }
                                   
                                   KFMatch *match = [[KFMatch alloc] init];
                                   
                                   if (self.matchId == MATCH_ID_GENERAL) {
                                       NSString *moveText = [self matchedStringbyPattern:@".*NEWDATA.*" body:line index:0];
                                       
                                       if ([moveText length] > 0) {
//                                          // NSLog(@"moveText = %@", moveText);
                                           [self updateMatch:match text:line];
                                       } else {
                                           continue;
                                       }
                                   }

                                   [matchList addObject:match];
                               }
                               
                               if ([self.delegate respondsToSelector:@selector(didFinishLoadMatchList:)]) {
                                   [self.delegate didFinishLoadMatchList:[NSArray arrayWithArray:matchList]];
                               }
                           }];
}

- (void)loadRecord {
   // NSLog(@"recordUrl:%@", self.recordUrl);
    
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.recordUrl]
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:5.0];
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:queue
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
                              // NSLog(@"####### RESPONSE:%@", res);
//                              // NSLog(@"####### DATA:%@", data);
//                              // NSLog(@"####### ERROR:%@", error);
                               
                               self.recordBody = [[NSString alloc] initWithData:data encoding:[self detectEncoding:data]];

//                              // NSLog(@"responseText = %@", self.recordBody);
                               
                               if (error) {
                                  // NSLog(@"%@", error);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                   message:@"棋譜を読み込めませんでした"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                   [alert show];

                                   return;
                               }
                               
                               KFRecord *record = [KFRecord buildRecordFromText:self.recordBody];
                               
                               if ([self.delegate respondsToSelector:@selector(didFinishLoadRecord:)]) {
                                   [self.delegate didFinishLoadRecord:record];
                               }
                           }];
}

- (NSString *)matchedStringbyPattern:(NSString *)pattern
                                body:(NSString *)body
                               index:(NSInteger)index {
    NSError* error = nil;
    NSRegularExpression* regex = [NSRegularExpression regularExpressionWithPattern:pattern
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    NSTextCheckingResult *match= [regex firstMatchInString:body
                                                   options:NSMatchingReportProgress
                                                     range:NSMakeRange(0, body.length)];
    
    return [body substringWithRange:[match rangeAtIndex:index]];
}

- (void)updateMatch:(KFMatch *)match text:(NSString*)text {
    NSString *path = [self matchedStringbyPattern:@"(index\\.php.*kid=\\d+)" body:text index:1];
    
    if ([path length] > 0) {
       // NSLog(@"path = %@", path);
        
        path = [path stringByReplacingOccurrencesOfString:@"display" withString:@"displaytxt"];
        path = [path stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
        
        match.recordUrl = [NSString stringWithFormat:@"%@%@", @"http://wiki.optus.nu/shogi/", path];
        
       // NSLog(@"recordUrl = %@", match.recordUrl);
    }
    
    NSString *wholeTitle = [self matchedStringbyPattern:@"\\<\\/a\\>(.*?)\\<" body:text index:1];
    if ([wholeTitle length] > 0) {
       // NSLog(@"title = %@", wholeTitle);
        match.wholeTitle = wholeTitle;
    }
    
    NSString *date = [self matchedStringbyPattern:@"(\\d+-\\d+-\\d+)" body:wholeTitle index:1];
    if ([date length] > 0) {
       // NSLog(@"date = %@", date);
        match.date = date;
    }
    
    NSString *playerTitle = [self matchedStringbyPattern:@"\\>(\\D+VS\\D+)\\d+" body:text index:1];
    if ([playerTitle length] > 0) {
        playerTitle = [playerTitle stringByReplacingOccurrencesOfString:@"VS" withString:@"対"];
       // NSLog(@"player = %@", playerTitle);
        match.playerTitle = playerTitle;
    }
    
    NSString *matchTitle = [self matchedStringbyPattern:@"\\d+-\\d+-\\d+\\s*(.*)" body:wholeTitle index:1];
    if ([matchTitle length] > 0) {
       // NSLog(@"match = %@", matchTitle);
        match.matchTitle = matchTitle;
    }
}

- (void)scanHTMLString:(NSString *)htmlString {
    NSMutableArray *matchList = [NSMutableArray array];
    NSArray *lines = [htmlString componentsSeparatedByString:@"\n"];

    if (self.matchId == MATCH_ID_GENERAL) {
        for (NSString *line in lines) {
            KFMatch *match = [[KFMatch alloc] init];
            
            
            NSString *moveText = [self matchedStringbyPattern:@".*NEWDATA.*" body:line index:0];
            
            if ([moveText length] > 0) {
               // NSLog(@"moveText = %@", moveText);
                [self updateMatch:match text:line];
            } else {
                continue;
            }
            
            [matchList addObject:match];
        }
    } else if (self.matchId == MATCH_ID_Search || self.matchId == MATCH_ID_POSITION || self.matchId == MATCH_ID_PREVIOUS) {
        for (NSString *line in lines) {
            NSString *matchText = [self matchedStringbyPattern:@".*TABLE.*" body:line index:0];
            if ([matchText length] > 0) {
                //               // NSLog(@"# matchText: %@", matchText);
                NSArray *matchLines = [matchText componentsSeparatedByString:@"<a href"];
                
                for (NSString *text in matchLines) {
                    KFMatch *match = [[KFMatch alloc] init];
                    NSString *path = [self matchedStringbyPattern:@"(index\\.php.*kid=\\d+)" body:text index:1];
                    
                    if ([path length] > 0) {
                       // NSLog(@"path = %@", path);
                        
                        path = [path stringByReplacingOccurrencesOfString:@"display" withString:@"displaytxt"];
                        path = [path stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
                        
                        match.recordUrl = [NSString stringWithFormat:@"%@%@", @"http://wiki.optus.nu/shogi/", path];
                        
                       // NSLog(@"recordUrl = %@", match.recordUrl);
                    } else {
                        continue;
                    }
                    
                    NSString *wholeTitle = [self matchedStringbyPattern:@"(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>" body:text index:2];
                    if ([wholeTitle length] > 0) {
                       // NSLog(@"title = %@", wholeTitle);
                        match.wholeTitle = wholeTitle;
                        match.matchTitle = wholeTitle;
                    }
                    
                    NSString *date = [self matchedStringbyPattern:@"(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>" body:text index:5];
                    if ([date length] > 0) {
                       // NSLog(@"date = %@", date);
                        match.date = date;
                    }
                    
                    NSString *firstPlayerTitle = [self matchedStringbyPattern:@"(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>" body:text index:3];
                    if ([firstPlayerTitle length] > 0) {
                       // NSLog(@"firstPlayer = %@", firstPlayerTitle);
                    }
                    
                    NSString *secondPlayerTitle = [self matchedStringbyPattern:@"(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>" body:text index:4];
                    if ([secondPlayerTitle length] > 0) {
                       // NSLog(@"secondPlayer = %@", secondPlayerTitle);
                    }
                    
                    if ([firstPlayerTitle length] > 0 && [secondPlayerTitle length] > 0) {
                        match.playerTitle = [NSString stringWithFormat:@"%@ 対 %@", firstPlayerTitle, secondPlayerTitle];
                    }
                    
                    [matchList addObject:match];
                }
            }
        }
    }
    
    if ([self.delegate respondsToSelector:@selector(didFinishLoadMatchList:)]) {
//       // NSLog(@"# [delegate didFinishLoadMatchList] will be called.");
        [self.delegate didFinishLoadMatchList:[NSArray arrayWithArray:matchList]];
    }
}

- (NSStringEncoding) detectEncoding:(NSData *)data
{
    NSStringEncoding encoding;
    NSStringEncoding encodings[] = {
        NSUTF8StringEncoding,
        NSNonLossyASCIIStringEncoding,
        NSShiftJISStringEncoding,
        NSJapaneseEUCStringEncoding,
        NSMacOSRomanStringEncoding,
        NSWindowsCP1251StringEncoding,
        NSWindowsCP1252StringEncoding,
        NSWindowsCP1253StringEncoding,
        NSWindowsCP1254StringEncoding,
        NSWindowsCP1250StringEncoding,
        NSISOLatin1StringEncoding,
        NSUnicodeStringEncoding,
        0
    };
    
    int i = 0;
    NSString *try_str;
    
    if (memchr([data bytes], 0x1b, [data length]) != NULL) {
        try_str = [[NSString alloc] initWithData:data encoding:NSISO2022JPStringEncoding];
        if (try_str != nil)
            return NSISO2022JPStringEncoding;
    }
    
    while(encodings[i] != 0){
        try_str = [[NSString alloc] initWithData:data encoding:encodings[i]];
        if (try_str != nil) {
           // NSLog(@"%d件目のencodingにhitしました", i + 1);
            
            encoding = encodings[i];
            break;
        }
        i++;
    }
    return encoding;
}

//TODO:Remove if unnecessary (dummyのWebViewからソースを取得してるので今は使ってない）
- (void)loadMatchListByCondition {
    NSURLRequest *req = [NSURLRequest requestWithURL:[NSURL URLWithString:self.matchListUrl]
                                         cachePolicy:NSURLRequestUseProtocolCachePolicy
                                     timeoutInterval:5.0];
    
    NSOperationQueue *queue = [NSOperationQueue mainQueue];
    [NSURLConnection sendAsynchronousRequest:req
                                       queue:queue
                           completionHandler:^(NSURLResponse *res, NSData *data, NSError *error) {
                               self.matchListBody = [[NSString alloc] initWithData:data encoding:[self detectEncoding:data]];
                               
                               if (error) {
                                  // NSLog(@"%@", error);
                                   UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                                                   message:@"検索結果を読み込めませんでした"
                                                                                  delegate:nil
                                                                         cancelButtonTitle:@"OK"
                                                                         otherButtonTitles:nil];
                                   
                                   [alert show];
                                   
                                   return;
                               }
                               
                               NSArray *lines = [self.matchListBody componentsSeparatedByString:@"\n"];
                               for (NSString *line in lines) {
                                   if (![line length] > 0) {
                                       break;
                                   }
                                   
                                   NSString *matchText = [self matchedStringbyPattern:@".*TABLE.*" body:line index:0];
                                   if ([matchText length] > 0) {
                                       NSArray *matchLines = [matchText componentsSeparatedByString:@"<A Href"];
                                       NSMutableArray *matchList = [NSMutableArray array];
                                       
                                       for (NSString *text in matchLines) {
                                          // NSLog(@"# line: %@", text);
                                           
                                           KFMatch *match = [[KFMatch alloc] init];
                                           NSString *path = [self matchedStringbyPattern:@"(index\\.php.*kid=\\d+)" body:text index:1];
                                           
                                           if ([path length] > 0) {
                                              // NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"display" withString:@"displaytxt"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", @"http://wiki.optus.nu/shogi/", path];
                                               
                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *wholeTitle = [self matchedStringbyPattern:@"(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>" body:text index:2];
                                           if ([wholeTitle length] > 0) {
                                              // NSLog(@"title = %@", wholeTitle);
                                               match.wholeTitle = wholeTitle;
                                               match.matchTitle = wholeTitle;
                                           }
                                           
                                           NSString *date = [self matchedStringbyPattern:@"(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>" body:text index:5];
                                           if ([date length] > 0) {
                                              // NSLog(@"date = %@", date);
                                               match.date = date;
                                           }
                                           
                                           NSString *firstPlayerTitle = [self matchedStringbyPattern:@"(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>" body:text index:3];
                                           if ([firstPlayerTitle length] > 0) {
                                              // NSLog(@"firstPlayer = %@", firstPlayerTitle);
                                           }
                                           
                                           NSString *secondPlayerTitle = [self matchedStringbyPattern:@"(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>(.*?)</Td><Td>" body:text index:4];
                                           if ([secondPlayerTitle length] > 0) {
                                              // NSLog(@"secondPlayer = %@", secondPlayerTitle);
                                           }
                                           
                                           if ([firstPlayerTitle length] > 0 && [secondPlayerTitle length] > 0) {
                                               match.playerTitle = [NSString stringWithFormat:@"%@ 対 %@", firstPlayerTitle, secondPlayerTitle];
                                           }
                                           
                                           [matchList addObject:match];
                                           
                                           if ([self.delegate respondsToSelector:@selector(didFinishLoadMatchList:)]) {
                                               [self.delegate didFinishLoadMatchList:[NSArray arrayWithArray:matchList]];
                                           }
                                       }
                                   }
                               }
                           }];
}

@end
