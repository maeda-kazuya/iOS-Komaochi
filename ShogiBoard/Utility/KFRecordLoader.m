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
                                   // 竜王戦
                                   } else if (self.matchId == MATCH_ID_RYUOU) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_RYUOU_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*\\>棋譜\\<.*" body:line index:0];
                                           if ([moveText length] > 0) {
//                                              // NSLog(@"moveText = %@", moveText);
                                               count++;
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
//                                              // NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.matchListUrl, path];
                                               
//                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"第%d局", count];
                                       } else if (self.matchDetailId == MATCH_DETAIL_ID_RYUOU_TERM26) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*第\\d局棋譜.*" body:line index:0];
                                           if ([moveText length] > 0) {
//                                              // NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                           }
                                           
                                           match.matchTitle = [self matchedStringbyPattern:@".*(第\\d局)棋譜.*" body:line index:1];
                                       }  else if (self.matchDetailId == MATCH_DETAIL_ID_RYUOU_TERM25) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*第\\d局詳細情報.*" body:line index:0];
                                           if ([moveText length] > 0) {
//                                              // NSLog(@"moveText = %@", moveText);
                                               count++;
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                              // NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               
                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"第%d局", count];
                                       }
                                   // 棋聖戦
                                   } else if (self.matchId == MATCH_ID_KISEI) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_KISEI_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*\"棋譜を見る\".*" body:line index:0];
                                           if ([moveText length] > 0) {
                                              // NSLog(@"moveText = %@", moveText);
                                               count++;
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(http.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                              // NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@", path];
                                               
                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                           
                                           match.matchTitle = @"棋聖戦最新局";
                                       } else if (self.matchDetailId == MATCH_DETAIL_ID_KISEI_OTHER) {
                                           NSString *termStr = [self matchedStringbyPattern:@"第\\d+期（\\d+年）" body:line index:0];
                                           if ([termStr length] > 0) {
//                                              // NSLog(@"##### term:%@", termStr);
                                               term = [NSString stringWithString:termStr];
                                           }
                                           
                                           NSString *gameNameStr = [self matchedStringbyPattern:@".*game_name.*" body:line index:0];
                                           if ([gameNameStr length] > 0) {
                                               gameName = [self matchedStringbyPattern:@"game_name\">(.*)</span" body:line index:1];
                                               
                                               if ([gameName length] > 0) {
//                                                  // NSLog(@"##### gameName:%@", gameName);
                                                   
                                                   KFMatch *match = [matchList lastObject];
                                                   match.matchTitle = [NSString stringWithFormat:@"%@ %@", term, gameName];
                                               }
                                           }
                                           
                                           NSString *moveText = [self matchedStringbyPattern:@".*\"棋譜を見る\".*" body:line index:0];
                                           if ([moveText length] > 0) {
                                              // NSLog(@"moveText = %@", moveText);
                                               count++;
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                              // NSLog(@"path = %@", path);
                                               
                                               if ([[self matchedStringbyPattern:@"\\.\\./kifu" body:line index:0] length] > 0) {
                                                   path = [path stringByReplacingOccurrencesOfString:@"../" withString:@"/"];
                                                   path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                                   match.recordUrl = [NSString stringWithFormat:@"%@%@", KISEI_SITE_URL, path];
                                               } else {
                                                   //web上のkifファイルがうまく読み込めないので飛ばす?
                                                   //TODO:あとでどうにかする
                                                   break;
                                               }
                                               
                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       }
                                   // 棋王戦
                                   } else if (self.matchId == MATCH_ID_KIOU) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_KIOU_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*\"kifu/.*" body:line index:0];
                                           if ([moveText length] > 0) {
//                                              NSLog(@" # [棋王戦] moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *title = [self matchedStringbyPattern:@"\"blank\">(.*)</a>" body:line index:1];
                                           
                                           if ([title length] > 0) {
                                               if (count == 0) {
                                                   count++;
//                                                   match.matchTitle = @"棋王戦最新局";
                                                   // 棋王戦の場合、最新局の棋譜が被ってるので飛ばす
                                                   continue;
                                               } else {
                                                   match.matchTitle = title;
                                               }
                                           } else {
                                               continue;
                                           }

                                           NSString *path = [self matchedStringbyPattern:@"(kifu/(.*?)html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
//                                               NSLog(@" # [棋王戦] recordUrl = %@", match.recordUrl);
                                           }
                                       } else {
                                           NSString *moveText = [self matchedStringbyPattern:@".*\"\\.\\./kifu/.*" body:line index:0];
                                           if ([moveText length] > 0) {
                                              // NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *title = [self matchedStringbyPattern:@"blank\">(.*?)</a>" body:line index:1];
                                           
                                           if ([title length] > 0) {
                                              // NSLog(@"title:%@", title);
                                               match.matchTitle = title;
                                           }
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*?html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                              // NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                           
                                       }
                                   // 王位戦
                                   } else if (self.matchId == MATCH_ID_OUI) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_OUI_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*\"棋譜を見る\".*" body:line index:0];
                                           if ([moveText length] > 0) {
                                              // NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = @"王位戦最新局";

                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                              // NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       } else if (self.matchDetailId == MATCH_DETAIL_ID_OUI_OTHER) {
                                           NSString *gameNameStr = [self matchedStringbyPattern:@"<h3>(.*?)</h3>" body:line index:1];
                                           if ([gameNameStr length] > 0) {
                                               gameName = [NSString stringWithString:gameNameStr];
                                           }
                                           
                                           NSString *moveText = [self matchedStringbyPattern:@".*\"棋譜を見る\".*" body:line index:0];
                                           if ([moveText length] > 0) {
                                              // NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/\\d+/oui.*?html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                              // NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           } else {
                                               continue;
                                           }
                                           
                                           if ([gameName length] > 0) {
                                              // NSLog(@"title:%@", gameName);
                                               match.matchTitle = gameName;
                                           } else {
                                               count++;
                                               match.matchTitle = [NSString stringWithFormat:@"第%d局", count];
                                           }
                                       }
                                   // 王座戦
                                   } else if (self.matchId == MATCH_ID_OUZA) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_OUZA_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*>棋譜を見る<.*" body:line index:0];
                                           if ([moveText length] > 0) {
                                              // NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = @"王座戦最新局";

                                           NSString *path = [self matchedStringbyPattern:@"(kifu/\\d+/ouza.*?html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                              // NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           } else {
                                               continue;
                                           }
                                       } else if (self.matchDetailId == MATCH_DETAIL_ID_OUZA_OTHER) {
                                           NSString *gameNameStr = [self matchedStringbyPattern:@"([^>]+?)<br />" body:line index:1];
                                           if ([gameNameStr length] > 0) {
                                               gameName = [NSString stringWithString:gameNameStr];
                                           }
                                           
                                           NSString *moveText = [self matchedStringbyPattern:@".*\"棋譜を見る\".*" body:line index:0];
                                           if ([moveText length] > 0) {
                                              // NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }

                                           NSString *path = [self matchedStringbyPattern:@"(kifu/\\d+/ouza.*?html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                              // NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                              // NSLog(@"recordUrl = %@", match.recordUrl);
                                           } else {
                                               continue;
                                           }
                                           
                                           if ([gameName length] > 0) {
                                              // NSLog(@"title:%@", gameName);
                                               match.matchTitle = gameName;
                                           } else {
                                               count++;
                                               match.matchTitle = [NSString stringWithFormat:@"第%d局", count];
                                           }
                                       }
                                   // 新人王戦
                                   } else if (self.matchId == MATCH_ID_SHINJIN) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_SHINJIN_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*>棋譜<.*" body:line index:0];
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText : %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"%d局目", ++count];

                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       } else {
                                           NSString *moveText = [self matchedStringbyPattern:@".*>棋譜<.*" body:line index:0];

                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"%d局目", ++count];
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*?html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                           
                                       }
                                   // 達人戦
                                   } else if (self.matchId == MATCH_ID_TATSUJIN) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_TATSUJIN_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*href=\"kifu.*" body:line index:0];
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText : %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"達人戦 棋譜その%d", ++count];
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       } else {
                                           NSString *gameNameStr = [self matchedStringbyPattern:@"</span>(.*?)</p>" body:line index:1];
                                           if ([gameNameStr length] > 0) {
                                               gameName = [NSString stringWithString:gameNameStr];
                                           }
                                           
                                           
                                           NSString *moveText = [self matchedStringbyPattern:@".*>棋譜を見る<.*" body:line index:0];
                                           
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"%d局目", ++count];
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*?html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                           
                                           if ([gameName length] > 0) {
                                               // NSLog(@"title:%@", gameName);
                                               match.matchTitle = gameName;
                                           } else {
                                               match.matchTitle = [NSString stringWithFormat:@"棋譜その%d", ++count];
                                           }
                                       }
                                   // 加古川清流戦
                                   } else if (self.matchId == MATCH_ID_KAKOGAWA) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_KAKOGAWA_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*href=\"kifu.*" body:line index:0];
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText : %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"加古川清流戦 棋譜その%d", ++count];
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       }
                                   // 女流名人戦
                                   } else if (self.matchId == MATCH_ID_JORYU_MEIJIN) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_JORYU_MEIJIN_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*href=\"kifu.*" body:line index:0];
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText : %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"女流名人戦 棋譜その%d", ++count];
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       } else {
                                           NSString *gameNameStr = [self matchedStringbyPattern:@"\"result\">(.*?)</td>" body:line index:1];
                                           if ([gameNameStr length] > 0) {
                                               gameName = [NSString stringWithString:gameNameStr];
                                           }
                                           
                                           NSString *moveText = [self matchedStringbyPattern:@".*棋譜を見る<.*" body:line index:0];
                                           
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           NSString *path = [self matchedStringbyPattern:@".*\"kifu\"><a href=\"(\\d\\d/.*?html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@kifu/%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                               
                                               if ([gameName length] > 0) {
                                                   match.matchTitle = gameName;
                                               } else {
                                                   match.matchTitle = [NSString stringWithFormat:@"棋譜その%d", ++count];
                                               }
                                           } else {
                                               continue;
                                           }
                                       }
                                    // 女流王位
                                   } else if (self.matchId == MATCH_ID_JORYU_OUI) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_JORYU_OUI_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*href=\"kifu.*" body:line index:0];
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText : %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"女流王位戦 その%d", ++count];
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       } else {
                                           NSString *gameNameStr = [self matchedStringbyPattern:@"<h3>(.*?)</h3>" body:line index:1];
                                           if ([gameNameStr length] > 0) {
                                               gameName = [NSString stringWithString:gameNameStr];
                                           }
                                           
                                           NSString *moveText = [self matchedStringbyPattern:@".*\"棋譜を見る\".*" body:line index:0];
                                           
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           

                                           NSString *path = [self matchedStringbyPattern:@"(kifu/24.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"%d局目", ++count];
                                           
                                           if ([gameName length] > 0) {
                                               // NSLog(@"title:%@", gameName);
                                               match.matchTitle = gameName;
                                           } else {
                                               match.matchTitle = [NSString stringWithFormat:@"棋譜その%d", ++count];
                                           }
                                           
                                       }
                                       //女流王座
                                   } else if (self.matchId == MATCH_ID_JORYU_OUZA) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_JORYU_OUZA_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*href=\"kifu.*" body:line index:0];
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText : %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"女流王座戦 その%d", ++count];
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       } else {
                                           NSString *gameNameStr = [self matchedStringbyPattern:@"<h2 class=\"heading\">(.*?)</h2>" body:line index:1];
                                           if ([gameNameStr length] > 0) {
                                               gameName = [NSString stringWithString:gameNameStr];
                                           }
                                           
                                           NSString *moveText = [self matchedStringbyPattern:@".*<a href=\"kifu/.*" body:line index:0];
                                           
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"%d局目", ++count];
                                           
                                           if ([gameName length] > 0) {
                                               // NSLog(@"title:%@", gameName);
//                                               match.matchTitle = gameName;
                                               match.matchTitle = [NSString stringWithFormat:@"%@ %d", gameName, ++count];
                                           } else {
                                               match.matchTitle = [NSString stringWithFormat:@"棋譜その%d", ++count];
                                           }
                                           
                                       }
                                       // 朝日杯
                                   } else if (self.matchId == MATCH_ID_ASAHI) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_ASAHI_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*href=\"kifu.*" body:line index:0];
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText : %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"朝日杯 その%d", ++count];
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       } else {
                                           NSString *gameNameStr = [self matchedStringbyPattern:@"<h2 class=\"heading\">(.*?)</h2>" body:line index:1];
                                           if ([gameNameStr length] > 0) {
                                               gameName = [NSString stringWithString:gameNameStr];
                                           }
                                           
                                           NSString *moveText = [self matchedStringbyPattern:@".*<a href=\"kifu/.*" body:line index:0];
                                           
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(kifu/.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@%@", self.siteUrl, path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"%d局目", ++count];
                                           
                                           if ([gameName length] > 0) {
                                               // NSLog(@"title:%@", gameName);
                                               //                                               match.matchTitle = gameName;
                                               match.matchTitle = [NSString stringWithFormat:@"%@ %d", gameName, ++count];
                                           } else {
                                               match.matchTitle = [NSString stringWithFormat:@"棋譜その%d", ++count];
                                           }
                                           
                                       }
                                       //大和証券杯
                                   } else if (self.matchId == MATCH_ID_DAIWA) {
                                       if (self.matchDetailId == MATCH_DETAIL_ID_DAIWA_TOP) {
                                           NSString *moveText = [self matchedStringbyPattern:@".*alt=\"棋譜を見る\".*" body:line index:0];
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText : %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"大和証券杯 その%d", ++count];
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(http://.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@", path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           }
                                       } else {
                                           NSString *gameNameStr = [self matchedStringbyPattern:@"target=\"_blank\">(.*?)</a>" body:line index:1];
                                           if ([gameNameStr length] > 0) {
                                               gameName = [NSString stringWithString:gameNameStr];
                                           }
                                           
                                           NSString *moveText = [self matchedStringbyPattern:@".*<a href=\"http://live.shogi.or.jp.*" body:line index:0];
                                           
                                           if ([moveText length] > 0) {
                                               NSLog(@"moveText = %@", moveText);
                                           } else {
                                               continue;
                                           }
                                           
                                           
                                           NSString *path = [self matchedStringbyPattern:@"(http://.*html)" body:line index:1];
                                           
                                           if ([path length] > 0) {
                                               NSLog(@"path = %@", path);
                                               
                                               path = [path stringByReplacingOccurrencesOfString:@"html" withString:@"kif"];
                                               match.recordUrl = [NSString stringWithFormat:@"%@", path];
                                               NSLog(@"recordUrl = %@", match.recordUrl);
                                           } else {
                                               continue;
                                           }
                                           
                                           match.matchTitle = [NSString stringWithFormat:@"%d局目", ++count];
                                           
                                           if ([gameName length] > 0) {
                                               match.matchTitle =  gameName;
                                           } else {
                                               match.matchTitle = [NSString stringWithFormat:@"棋譜その%d", ++count];
                                           }
                                           
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
