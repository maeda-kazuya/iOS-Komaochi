//
//  KFBoardViewController.m
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2013/12/01.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import "KFBoardViewController.h"
#import "KFCapturedPieceButton.h"
#import "KFCommentViewController.h"
#import "KFMatchTableViewController.h"
#import "KFLoadRecordViewController.h"
#import "KFMove.h"
#import "KFMoveTableViewController.h"
#import "KFMotionControl.h"
#import "KFPiece.h"
#import "KFRecord.h"
#import "KFRecordTableViewController.h"
#import "KFSaveCommentViewController.h"
#import "KFSaveRecordViewController.h"
#import "KFSearchRecordViewController.h"
#import "KFSettingViewController.h"
#import "KFSquareButton.h"
#import "KFFu.h"
#import "KFKyosha.h"
#import "KFKeima.h"
#import "KFGin.h"
#import "KFKin.h"
#import "KFGyoku.h"
#import "KFHisha.h"
#import "KFKaku.h"
#import "GAI.h"
#import "GAITracker.h"
#import "GAIDictionaryBuilder.h"
#import <Social/Social.h>
#import <QuartzCore/QuartzCore.h>
#import <GoogleMobileAds/GoogleMobileAds.h>

@import NendAd;

@interface KFBoardViewController () <KFRecordTableViewControllerDelegate,
                                     KFMatchTableViewControllerDelegate,
                                     KFSaveRecordViewControllerDelegate,
                                     KFLoadRecordViewControllerDelegate,
                                     NADViewDelegate,
                                     KFCommentBaseViewControllerDelegate,
                                     KFSettingViewControllerDelegate,
                                     KFMoveTableViewControllerDelegate,
                                     KFSearchRecordViewControllerDelegate>
@end

@implementation KFBoardViewController

SystemSoundID dropSound;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.currentRecord = [[KFRecord alloc] init];
    
    // Record ViewController
    self.saveRecordViewController = [[KFSaveRecordViewController alloc] init];
    self.saveRecordViewController.delegate = self;
    self.recordTableViewController = [[KFRecordTableViewController alloc] init];
    self.recordTableViewController.delegate = self;
    self.loadRecordViewController = [[KFLoadRecordViewController alloc] init];
    self.loadRecordViewController.delegate = self;
    
    // Comment ViewController
    self.saveCommentViewController = [[KFSaveCommentViewController alloc] init];
    self.saveCommentViewController.delegate = self;
    
    // Setting ViewController
    self.settingViewController = [[KFSettingViewController alloc] init];
    self.settingViewController.delegate = self;
    
    // Setting ViewController
    self.searchRecordViewController = [[KFSearchRecordViewController alloc] init];
    self.searchRecordViewController.delegate = self;

    // Comment ViewController
    self.commentViewController = [[KFCommentViewController alloc] init];
    self.commentViewController.delegate = self;
    
    [self initializeBoard];
    [self setCoordinate];
    [self setSquareDic];
    [self setSwipeGestures];
    
    // Set sound
    [self configureSound];
    

    // set AdMob unit (publisher) id
    self.admobTopBannerView.adUnitID = ADMOB_TOP_UNIT_ID;
    self.admobTopBannerView.rootViewController = self;
    
    self.admobBottomBannerView.adUnitID = ADMOB_BOTTOM_UNIT_ID;
    self.admobBottomBannerView.rootViewController = self;
    
    // Load AdMob
    GADRequest *adMobRequest = [GADRequest request];

    //TODO:Activate
//    [self.admobTopBannerView loadRequest:adMobRequest];
    [self.admobBottomBannerView loadRequest:adMobRequest];

    //TODO:Load first move
    KFRecord *record = [[KFRecord alloc] init];
    
    NSDictionary *dic = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"move" ofType:@"plist"]];
    
    record.recordText = [dic objectForKey:@"phase3"];
    record.isCSV = NO;
    
//    NSLog(@"# First move : %@", record.recordText);
    
//    [self readRecord:record];
    
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.mode == PLAY_MODE) {
        self.navigationBar.hidden = NO;
        self.recordToolBar.hidden = YES;
    } else if (self.mode == READ_MODE) {
        self.navigationBar.hidden = YES;
        self.recordToolBar.hidden = NO;
    }

    // Google Analytics
    self.screenName = @"KFBoardViewController";
}

# pragma mark - Private method
// マス目を選択
- (void)selectSquare:(id)sender {
    // 棋譜閲覧モードの時は何もしない
    if (self.mode == READ_MODE) {
        return;
    }
    
    if (self.isLocatedPieceSelected || self.isCapturedPieceSelected) { // 移動先のマスを選択した場合
        self.shouldClearSelectedPiece = YES;
        self.targetSquare = sender;
        
        if (self.isLocatedPieceSelected) { //盤上の駒を動かす場合
            //同じ駒を再度選択した場合は選択状態をキャンセルする
            if (self.selectedPiece == self.targetSquare.locatedPiece && self.selectedSquare.x == self.targetSquare.x && self.selectedSquare.y == self.targetSquare.y) {
                self.isLocatedPieceSelected = NO;
                
                [self.selectedSquare setBackgroundColor:[UIColor clearColor]];
                self.selectedPiece = nil;
                self.selectedSquare = nil;
                
                return;
            }
            
            // Check the motion of piece
            if (!self.isMotionFree) {
                // The piece of same side cannot be captured
                if (self.targetSquare.locatedPiece && self.targetSquare.locatedPiece.side == self.selectedPiece.side) {
                    return;
                }
                
                // Check the motion of piece
                if (![KFMotionControl isCorrectMotionOfPiece:self.selectedPiece
                                                  fromSquare:self.selectedSquare
                                                    toSquare:self.targetSquare]) {
                    return;
                }
                
                // Check if any piece exists between selected and target square
                if ([KFMotionControl doesPieceExistBetweenFrom:self.selectedSquare
                                                            to:self.targetSquare
                                                     squareDic:self.squareDic
                                                 selectedPiece:self.selectedPiece]) {
                    return;
                }
            }

            // 成り駒判定
            if (!self.selectedPiece.isPromoted && self.selectedPiece.canPromote) {
                if (self.selectedPiece.side == THIS_SIDE) {
                    if (self.targetSquare.y < 4 || self.selectedSquare.y < 4) {
                        [self showPromotionAlert];
                        return;
                    }
                } else {
                    if (self.targetSquare.y > 6 || self.selectedSquare.y > 6) {
                        [self showPromotionAlert];
                        return;
                    }
                }
            }
            
            if (self.targetSquare.locatedPiece) { //移動先に駒がある場合
                // 駒を取る
                [self capture:self.targetSquare.locatedPiece by:self.selectedPiece.side];
            }
  
            self.isLocatedPieceSelected = NO;
        } else if (self.isCapturedPieceSelected) { //持ち駒を盤上に打つ場合
            if (self.targetSquare.locatedPiece) { //移動先に駒がある場合
                // 何もしない
                return;
            }

            if (!self.isMotionFree && [[self.selectedPiece getPieceId] isEqualToString:PIECE_ID_FU]) {
                // 二歩の判定
                if ([KFMotionControl isNifuForSide:self.selectedPiece.side
                                               row:self.targetSquare.x
                                         squareDic:self.squareDic]) {
                    return;
                }
            }
            
            if (self.selectedPiece.side == THIS_SIDE) {
                [self subtractCapturedPiece:self.selectedPiece
                                     button:(KFCapturedPieceButton *)self.selectedSquare
                                       side:THIS_SIDE];
            } else {
                [self subtractCapturedPiece:self.selectedPiece
                                     button:(KFCapturedPieceButton *)self.selectedSquare
                                       side:COUNTER_SIDE];
            }
            
            self.isCapturedPieceSelected = NO;
        }
        
        // 指し手を保存
        [self saveMoveWithPromotion:NO];
        
        // 盤面を更新
        [self updateSquareViewWithPromotion:NO];
      
        NSLog(@"移動処理終了");
    } else { // 移動元の駒を選択した場合
        KFSquareButton *selectedSquare = sender;
        
        // 空白のマスを選択した場合は何もしない
        if (!selectedSquare.locatedPiece) {
            return;
        }
        
        // Do nothing if it is incorrect turn
        if (!self.isMotionFree && self.currentSide != selectedSquare.locatedPiece.side) {
            return;
        }
        
        // オブジェクトを渡すよりcopyした方が良いかも？
        self.selectedSquare = selectedSquare;
        self.selectedPiece = selectedSquare.locatedPiece;
        
        NSLog(@"Square selected : %@ : %@", self.selectedSquare, self.selectedPiece);
        
        // Change the color of selected square
        [self.selectedSquare setBackgroundColor:[UIColor colorWithRed:0.647 green:0.165 blue:0.165 alpha:0.6]]; // brown
        
        // 駒が選択された状態にする
        self.isLocatedPieceSelected = YES;
    }
}

// 持ち駒を選択
- (void)selectCapturedPiece:(id)sender {
    // 棋譜閲覧モードの時または盤上の駒が選択されている場合は何もしない
    if (self.mode == READ_MODE || self.isLocatedPieceSelected) {
        return;
    }
    
    KFCapturedPieceButton *selectedSquare = sender;
    
    // 同じ持ち駒をタップした場合はキャンセル
    if (selectedSquare.locatedPiece == self.selectedPiece) {
        self.isCapturedPieceSelected = NO;
        
        [self.selectedSquare setBackgroundColor:[UIColor clearColor]];
        self.selectedPiece = nil;
        self.selectedSquare = nil;
        
        return;
    }
    
    // タップされたボタンに持ち駒がない場合は何もしない
    if (selectedSquare.locatedPiece == nil) {
        return;
    }
    
    // Set selected square
    self.selectedSquare = selectedSquare;
    self.selectedPiece = selectedSquare.locatedPiece;
    
    // Do nothing if it is incorrect turn
    if (!self.isMotionFree && self.currentSide != self.selectedPiece.side) {
        return;
    }
    
    // 選択されたマスの背景色を変える
    [self.selectedSquare setBackgroundColor:[UIColor grayColor]];
    
    self.isCapturedPieceSelected = YES;
    NSLog(@"持ち駒選択完了");
}

// 盤面を更新
- (void)updateSquareViewWithPromotion:(BOOL)didPromote {
    // Switch current side
    [self switchSide];

    // 移動先のマスの駒の表示, objectを更新する
    if (didPromote) { // 駒を成る場合
        [self.targetSquare setImage:[UIImage imageNamed:[self.selectedPiece getPromotedImageName]] forState:UIControlStateNormal];
        self.targetSquare.locatedPiece = [self.selectedPiece getPromotedPiece];
    } else { // 駒を成らない場合
        [self.targetSquare setImage:[UIImage imageNamed:[self.selectedPiece getImageName]] forState:UIControlStateNormal];
        self.targetSquare.locatedPiece = self.selectedPiece;
    }

    // 移動元のマス目の背景色を消す
    [self.selectedSquare setBackgroundColor:[UIColor clearColor]];
    
    if (self.shouldClearSelectedPiece) {
        // 移動元のマス目の駒のObject、画像を消す
        self.selectedSquare.locatedPiece = nil;
        [self.selectedSquare setImage:nil forState:UIControlStateNormal];
    }
    
    // 選択された駒、マスを初期化
    self.selectedSquare = nil;
    self.selectedPiece = nil;
    
    // Update previousSquare and change the background color
    [self.previousSquare setBackgroundColor:[UIColor clearColor]];
    self.previousSquare = self.targetSquare;
    [self.previousSquare setBackgroundColor:[UIColor colorWithRed:0.647 green:0.165 blue:0.165 alpha:0.2]]; // light brown
    
    // Sound
    if (self.isSoundAvailable) {
        AudioServicesPlaySystemSound(dropSound);
    }
}

// 指し手を保存
- (void)saveMoveWithPromotion:(BOOL)didPromote {
    KFMove *move = [[KFMove alloc] init];
    
    move.previousSquare = self.selectedSquare;
    move.previousSquare.locatedPiece = self.selectedSquare.locatedPiece;
    
    if ([move.previousSquare isKindOfClass:[KFCapturedPieceButton class]]) {
        move.didDrop = YES; // 駒を打った場合
    } else {
        move.didDrop = NO; // 駒を動かした場合
    }
    
    move.currentSquare = self.targetSquare;
    move.side = self.selectedPiece.side;
    move.didPromote = didPromote;
    move.movedPieceId = [self.selectedPiece getPieceId];
    move.movedPiece = [self.selectedPiece copy];
    move.capturedPiece = [self.targetSquare.locatedPiece copy];

    if (move.capturedPiece) {
        if (move.side == THIS_SIDE) {
            move.capturedPieceButton = [self.thisSideCapturedPieceButtons objectForKey:[move.capturedPiece getOriginalPieceId]];
        } else {
            move.capturedPieceButton = [self.counterSideCapturedPieceButtons objectForKey:[move.capturedPiece getOriginalPieceId]];
        }
    }

    [self.moveArray addObject:move];
    self.currentMoveIndex++;
    
    // Update title
    self.boardNavigationItem.title = [move getMoveTextWithIndex:self.currentMoveIndex + 1];
}

- (NSInteger)getOppositeSide:(NSInteger)side {
    if (side == THIS_SIDE) {
        return COUNTER_SIDE;
    } else {
        return THIS_SIDE;
    }
}

// 持ち駒を追加
- (void)addCapturedPiece:(KFPiece *)piece side:(NSInteger)side {
    NSInteger capturedPieceCount;

    if (side == THIS_SIDE) {
        capturedPieceCount = [[self.thisSideCapturedPieces objectForKey:[piece getOriginalPieceId]] integerValue];
    } else {
        capturedPieceCount = [[self.counterSideCapturedPieces objectForKey:[piece getOriginalPieceId]] integerValue];
    }
    
    if (capturedPieceCount > 0) {
        capturedPieceCount++;
    } else {
        capturedPieceCount = 1;
    }
    
    if (side == THIS_SIDE) {
        [self.thisSideCapturedPieces setObject:[NSString stringWithFormat:@"%ld", (long)capturedPieceCount] forKey:[piece getOriginalPieceId]];
    } else {
        [self.counterSideCapturedPieces setObject:[NSString stringWithFormat:@"%ld", (long)capturedPieceCount] forKey:[piece getOriginalPieceId]];
    }
}

// 持ち駒のボタンを配置
- (void)locateCapturedPieceButtons:(NSInteger)side {
    NSInteger pieceWidth;
    NSInteger pieceHeight;
    NSInteger offset;
    NSInteger counterOffset;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        pieceWidth = PIECE_WIDTH_NORMAL;
        pieceHeight = PIECE_HEIGHT_NORMAL;
        offset = 200;
        counterOffset = 4;
    } else {
        pieceWidth = PIECE_WIDTH_WIDE;
        pieceHeight = PIECE_HEIGHT_WIDE;
        offset = 540;
        counterOffset = 30;
    }
    
    //ボタンをひとつずつ配置に付ける
    int count = 0;
    if (side == THIS_SIDE) {
        for (KFCapturedPieceButton *button in [self.thisSideCapturedPieceButtons allValues]) {
            button.frame = CGRectMake(offset - (pieceWidth * count), 4, pieceWidth, pieceHeight);
            count++;
        }
    } else {
        for (KFCapturedPieceButton *button in [self.counterSideCapturedPieceButtons allValues]) {
            button.frame = CGRectMake(counterOffset + pieceWidth * count, 4, pieceWidth, pieceHeight);
            count++;
        }
    }
}

// 持ち駒Buttonを追加
- (void)addCapturedPiece:(KFPiece *)capturedPiece
                  button:(KFSquareButton *)capturedPieceButton
                    side:(NSInteger)side {
    UIView *standView;
    NSMutableDictionary *capturedPiecesDic;
    NSMutableDictionary * capturedPieceButtonsDic;
    NSString *pieceId = [capturedPiece getOriginalPieceId];
    
    if (side == THIS_SIDE) {
        standView = self.thisSideStandView;
        capturedPiecesDic = self.thisSideCapturedPieces;
        capturedPieceButtonsDic = self.thisSideCapturedPieceButtons;
    } else {
        standView = self.counterSideStandView;
        capturedPiecesDic = self.counterSideCapturedPieces;
        capturedPieceButtonsDic = self.counterSideCapturedPieceButtons;
    }

    // 持ち駒０のときは普通に表示、同じ駒を追加した場合は数を表示、異なる駒の場合は位置をずらして表示
    if ([capturedPiecesDic count] == 0) {
        // ボタンリストに追加
        [capturedPieceButtonsDic setObject:capturedPieceButton forKey:pieceId];
        
        [self locateCapturedPieceButtons:side];
    } else if ([capturedPiecesDic objectForKey:pieceId] != nil) {
        //ボタンのオブジェクトを取得
        KFCapturedPieceButton *existingCapturedPiecebutton = [capturedPieceButtonsDic objectForKey:pieceId];

        NSInteger capturedPieceCount = [[capturedPiecesDic objectForKey:pieceId] integerValue];
        existingCapturedPiecebutton.countLabel.text = [NSString stringWithFormat:@"%ld", ++capturedPieceCount];
    } else {
        // ボタンリストに追加
        [capturedPieceButtonsDic setObject:capturedPieceButton forKey:pieceId];
        
        [self locateCapturedPieceButtons:side];
    }
    
    [standView addSubview:capturedPieceButton];
}

// 駒を取る
- (void)capture:(KFPiece *)piece by:(NSInteger)side {
    if (piece.isPromoted) {
        piece = [piece getOriginalPiece];
    }
    
    //持ち駒用のボタンを作成
    KFCapturedPieceButton *capturedPieceButton = [[KFCapturedPieceButton alloc] init];
    [capturedPieceButton addTarget:self action:@selector(selectCapturedPiece:) forControlEvents:UIControlEventTouchDown];

    // 持ち駒ボタンに駒を登録
    capturedPieceButton.locatedPiece = [piece copy];
    
    //持ち駒の属性を持ち駒を取った駒と同じにする
    capturedPieceButton.locatedPiece.side = side;

    //持ち駒の画像を設定
    [capturedPieceButton setImage:[UIImage imageNamed:[piece getImageNameWithSide:side]] forState:UIControlStateNormal];

    [self addCapturedPiece:piece button:capturedPieceButton side:side];

    // Add to captured pieces
    [self addCapturedPiece:piece side:side];
}

// 持ち駒を駒台から減らす
- (void)subtractCapturedPiece:(KFPiece *)piece
                       button:(KFCapturedPieceButton *)button
                         side:(NSInteger)side {
    //数を１引いて１個以上残っていれば数字を表示、0になればボタンごと削除
    NSInteger capturedPieceCount;
    NSString *pieceId = [piece getOriginalPieceId];

    if (side == THIS_SIDE) {
        capturedPieceCount = [[self.thisSideCapturedPieces objectForKey:pieceId] integerValue];
    } else {
        capturedPieceCount = [[self.counterSideCapturedPieces objectForKey:pieceId] integerValue];
    }
    
    if (capturedPieceCount > 1) { //同じ種類の持ち駒が複数あった場合
        capturedPieceCount--;
        
        if (side == THIS_SIDE) {
            [self.thisSideCapturedPieces setObject:[NSString stringWithFormat:@"%ld", capturedPieceCount] forKey:pieceId];
        } else {
            [self.counterSideCapturedPieces setObject:[NSString stringWithFormat:@"%ld", capturedPieceCount] forKey:pieceId];
        }
        
        if (capturedPieceCount > 1) {
            button.countLabel.text = [NSString stringWithFormat:@"%ld", capturedPieceCount];
        } else {
            button.countLabel.text = nil;
        }
        
        self.shouldClearSelectedPiece = NO;
    } else { //同じ種類の持ち駒がなくなった場合
        NSLog(@"piece : %@", piece);
        NSLog(@"pieceID : %@", pieceId);
        
        if (side == THIS_SIDE) {
            [self.thisSideCapturedPieces removeObjectForKey:pieceId];
            
            //ボタンを消す
            [[self.thisSideCapturedPieceButtons objectForKey:pieceId] removeFromSuperview];
            [self.thisSideCapturedPieceButtons removeObjectForKey:pieceId];
        } else {
            [self.counterSideCapturedPieces removeObjectForKey:pieceId];
            
            //ボタンを消す
            [[self.counterSideCapturedPieceButtons objectForKey:pieceId] removeFromSuperview];
            [self.counterSideCapturedPieceButtons removeObjectForKey:pieceId];
        }
        
        // ボタンを再配置
        [self locateCapturedPieceButtons:piece.side];
    }
}

// 成り駒確認Alert表示
- (void)showPromotionAlert {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:@"成りますか？"
                                                   delegate:self
                                          cancelButtonTitle:@"キャンセル"
                                          otherButtonTitles:@"はい", @"いいえ", nil];
    alert.tag = kPromotionAlertTag;

    [alert show];
}

- (void)restoreMove:(NSInteger)index {
    KFMove *lastMove = [self.moveArray objectAtIndex:index];

    // Clear color of previous square
    [lastMove.currentSquare setBackgroundColor:[UIColor clearColor]];

    if (lastMove.didDrop) { // 駒を打った場合
        // 打った駒を駒台に復元する
        [self capture:lastMove.movedPiece by:lastMove.side];
        
        // 打った場所の駒を消す
        lastMove.currentSquare.locatedPiece = nil;
        [lastMove.currentSquare setImage:nil forState:UIControlStateNormal];
    } else { // 駒を動かした場合
        // 元の場所に駒を復元する
        if ([lastMove didPromote]) {
            [lastMove.previousSquare setImage:[UIImage imageNamed:[[lastMove.currentSquare.locatedPiece getOriginalPiece] getImageName]] forState:UIControlStateNormal];
            lastMove.previousSquare.locatedPiece = [lastMove.currentSquare.locatedPiece getOriginalPiece];
        } else {
            [lastMove.previousSquare setImage:[UIImage imageNamed:[lastMove.currentSquare.locatedPiece getImageName]] forState:UIControlStateNormal];
            lastMove.previousSquare.locatedPiece = lastMove.currentSquare.locatedPiece;
        }
        
        if (lastMove.capturedPiece) { // 駒を取った場合は元々そこにあった駒に戻す
            lastMove.currentSquare.locatedPiece = lastMove.capturedPiece;
            NSInteger capturedPieceSide = lastMove.capturedPiece.side;
            
            [lastMove.currentSquare setImage:[UIImage imageNamed:[lastMove.capturedPiece getImageNameWithSide:capturedPieceSide]]
                                    forState:UIControlStateNormal];
            
            // 取った駒を駒台から除去する
            [self subtractCapturedPiece:lastMove.capturedPiece
                                 button:lastMove.capturedPieceButton
                                   side:lastMove.side];
        } else { // 何もない場所に動かした場合
            lastMove.currentSquare.locatedPiece = nil;
            [lastMove.currentSquare setImage:nil forState:UIControlStateNormal];
        }
    }
    
    // Switch current side
    [self switchSide];

    // Update title
    if (index > 0) {
        KFMove *titleMove = [self.moveArray objectAtIndex:index - 1];
        
        if (self.mode == PLAY_MODE) {
            self.boardNavigationItem.title = [titleMove getMoveTextWithIndex:index];
        } else if (self.mode == READ_MODE) {
            self.recordTitleButtonItem.title = [titleMove getMoveTextWithIndex:index];
        }
    } else {
        if (self.mode == PLAY_MODE) {
            self.boardNavigationItem.title = @"対局開始";
        } else if (self.mode == READ_MODE) {
            self.recordTitleButtonItem.title = @"初期画面";
        }
    }
}

- (UIImage *)takeScreenShot {
    // 新しいコンテキストを作成
//    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect screenRect = [self.boardView bounds];

    UIGraphicsBeginImageContext(screenRect.size);

    // カレントコンテキストを取得
    CGContextRef context = UIGraphicsGetCurrentContext();

    // 黒で塗り潰す
    [[UIColor blackColor] set];
    CGContextFillRect(context, screenRect);
    
    // 対象ビューのレイヤーをカレントコンテキストに描画
//    [self.view.layer renderInContext:context];
    [self.boardView.layer renderInContext:context];
    
    // カレントコンテキストの画像を取得
    UIImage *screenImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return screenImage;
}

- (void)shareOnTwitter {
    SLComposeViewController *twitterPostVC = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
    [self shareOnSNS:twitterPostVC];
    
    // Track for Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"OtherServices"
                                                          action:@"shareImageOnTwitter"
                                                           label:@"shareImage"
                                                           value:[NSNumber numberWithInteger:self.currentMoveIndex]] build]];
}

- (void)shareOnFacebook {
    SLComposeViewController *facebookPostVC =  [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
    [self shareOnSNS:facebookPostVC];
    
    // Track for Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"OtherServices"
                                                          action:@"shareImageOnFacebook"
                                                           label:@"shareImage"
                                                           value:[NSNumber numberWithInteger:self.currentMoveIndex]] build]];
}

- (void)shareOnSNS:(SLComposeViewController *)composeViewController {
    UIImage *screenImage = [self takeScreenShot];
    NSString *text;
    if (self.currentMoveIndex >= 0) {
        text = [self createSNSText];
    }

    [composeViewController setInitialText:text];
    [composeViewController addImage:screenImage];
    
    [self presentViewController:composeViewController animated:YES completion:nil];
}

- (void)shareRecord {
    KFRecord *record = [[KFRecord alloc] init];
    record.moveArray = self.moveArray;

    NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
    [outputFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    
    NSString *recordText = [record getRecordText];
    NSArray* actItems = [NSArray arrayWithObjects:recordText, nil];
    
    UIActivityViewController *activityView = [[UIActivityViewController alloc] initWithActivityItems:actItems applicationActivities:nil];
    
    if (UI_USER_INTERFACE_IDIOM() != UIUserInterfaceIdiomPhone && [[UIDevice currentDevice].systemVersion floatValue] >= 8.0) {
        activityView.popoverPresentationController.sourceView = self.navigationBar;
    }

    if (self.mode == PLAY_MODE) {
        // Set current time as a subject
        [activityView setValue:[outputFormatter stringFromDate:[NSDate date]] forKey:@"subject"];
    } else if (self.mode == READ_MODE) {
        // Set record title as a subject
        if ([self.currentRecord.title length] > 0) {
            [activityView setValue:self.currentRecord.title forKey:@"subject"];
        } else if ([self.currentRecord.matchName length] > 0) {
            NSString *title = [NSString stringWithFormat:@"%@ (%@ 対 %@)", self.currentRecord.matchName, self.currentRecord.firstPlayer, self.currentRecord.secondPlayer];
            [activityView setValue:title forKey:@"subject"];
        }
    }
    
    [self presentViewController:activityView animated:YES completion:nil];
    
    // Track for Google Analytics
    id<GAITracker> tracker = [[GAI sharedInstance] defaultTracker];
    [tracker send:[[GAIDictionaryBuilder createEventWithCategory:@"OtherServices"
                                                          action:@"shareRecordMethodCalled"
                                                           label:@"shareRecord"
                                                           value:[NSNumber numberWithInteger:self.currentMoveIndex]] build]];
}

- (NSString *)createSNSText {
    if ([self.moveArray count] <= self.currentMoveIndex) {
        return nil;
    }

    KFMove *lastMove = [self.moveArray objectAtIndex:self.currentMoveIndex];
    NSString *text = [NSString stringWithFormat:@"%@まで", [lastMove getMoveTextWithMarked:YES]];
    
    return text;
}

- (BOOL)canRewind {
    // Cannot rewind at the first position
    if (self.currentMoveIndex < 0) {
        return NO;
    } else {
        return YES;
    }
}

- (void)toggleCommentButton {
    NSString *comment = [self.currentRecord.commentDic objectForKey:[NSString stringWithFormat:@"%ld", self.currentMoveIndex + 1]];
    if ([comment length] > 0) {
        self.commentButton.tintColor = [UIColor whiteColor];
    } else {
        self.commentButton.tintColor = [UIColor grayColor];
    }
}

- (void)setSwipeGestures {
    UISwipeGestureRecognizer* swipeLeftGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                                                          action:@selector(swipeLeft:)];
    UISwipeGestureRecognizer* swipeRightGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self
                                                                                           action:@selector(swipeRight:)];
    
    swipeLeftGesture.direction = UISwipeGestureRecognizerDirectionLeft;
    swipeRightGesture.direction = UISwipeGestureRecognizerDirectionRight;
    
    [self.view addGestureRecognizer:swipeLeftGesture];
    [self.view addGestureRecognizer:swipeRightGesture];
}

- (void)configureSound {
    NSString *path = [[NSBundle mainBundle] pathForResource:@"komaoto1" ofType:@"wav"];
    NSURL *url = [NSURL fileURLWithPath:path];
    AudioServicesCreateSystemSoundID((CFURLRef)CFBridgingRetain(url), &dropSound);
}

- (void)switchSide {
    // ルールモードから自由モードに切り替えた際のために常にcurrent sideを更新しておく
//    if (self.currentSide == THIS_SIDE && self.selectedPiece.side == THIS_SIDE) {
    if (self.currentSide == THIS_SIDE) {
        self.currentSide = COUNTER_SIDE;
//    } else if (self.currentSide == COUNTER_SIDE && self.selectedPiece.side == COUNTER_SIDE) {
    } else if (self.currentSide == COUNTER_SIDE) {
        self.currentSide = THIS_SIDE;
    }
}

- (void)showSaveRecordViewController {
    if ([self.currentRecord.title length] > 0) {
        self.saveRecordViewController.recordTitle = self.currentRecord.title;
    } else if ([self.currentRecord.matchName length] > 0) {
        self.saveRecordViewController.recordTitle = [NSString stringWithFormat:@"%@ (%@ 対 %@)", self.currentRecord.matchName, self.currentRecord.firstPlayer, self.currentRecord.secondPlayer];
    } else {
        self.saveRecordViewController.recordTitle = nil;
    }

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.saveRecordViewController animated:YES completion:NULL];
    } else {
        self.saveRecordPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.saveRecordViewController];
        self.saveRecordPopoverController.delegate = self;
        
        [self.saveRecordPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                           inView:self.boardView
                                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                         animated:YES];
    }
}

- (void)showRecordViewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.recordTableViewController animated:YES completion:NULL];
    } else {
        self.recordTableViewController.preferredContentSize = CGSizeMake(320, 900);
        self.recordTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.recordTableViewController];
        self.recordTablePopoverController.delegate = self;
        
        [self.recordTablePopoverController presentPopoverFromRect:self.navigationBar.frame
                                                       inView:self.boardView
                                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                                     animated:YES];
    }
}

- (void)showLatestMatchTableViewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.latestMatchTableViewController animated:YES completion:NULL];
        [self.latestMatchTableViewController loadDummyWebView];
    } else {
        self.latestMatchTableViewController.preferredContentSize = CGSizeMake(320, 900);
        self.latestMatchTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.latestMatchTableViewController];
        self.latestMatchTablePopoverController.delegate = self;
        
        [self.latestMatchTablePopoverController presentPopoverFromRect:self.navigationBar.frame
                                                      inView:self.boardView
                                    permittedArrowDirections:UIPopoverArrowDirectionAny
                                                    animated:YES];

        [self.latestMatchTableViewController loadDummyWebView];
    }
}

- (void)showPositionMatchTableViewController {
    NSString *url = [self buildPositionRequestUrl];
    
    NSLog(@"# Escaped URL : %@", url);
    
    self.positionMatchTableViewController = [[KFMatchTableViewController alloc] initWithMatchId:MATCH_ID_POSITION
                                                                                  matchDetailId:MATCH_DETAIL_ID_POSITION
                                                                                            url:url];
    self.positionMatchTableViewController.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.positionMatchTableViewController animated:YES completion:NULL];
        [self.positionMatchTableViewController loadDummyWebView];
    } else {
        self.positionMatchTableViewController.preferredContentSize = CGSizeMake(320, 900);
        self.positionMatchTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.positionMatchTableViewController];
        self.positionMatchTablePopoverController.delegate = self;
        
        [self.positionMatchTablePopoverController presentPopoverFromRect:self.navigationBar.frame
                                                          inView:self.boardView
                                        permittedArrowDirections:UIPopoverArrowDirectionAny
                                                        animated:YES];
        
        [self.positionMatchTableViewController loadDummyWebView];
    }
}

- (void)showLoadRecordViewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.loadRecordViewController animated:YES completion:NULL];
    } else {
        self.loadRecordViewController.preferredContentSize = CGSizeMake(320, 568);
        self.loadRecordPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.loadRecordViewController];
        self.loadRecordPopoverController.delegate = self;
        
        [self.loadRecordPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                           inView:self.boardView
                                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                         animated:YES];
    }
}

- (void)showSettingViewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.settingViewController animated:YES completion:NULL];
    } else {
        self.settingViewController.preferredContentSize = CGSizeMake(320, 568);
        self.settingPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.settingViewController];
        self.settingPopoverController.delegate = self;

        [self.settingPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                       inView:self.boardView
                                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                                     animated:YES];
    }
}

- (void)showSaveCommentViewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.saveCommentViewController animated:YES completion:NULL];
    } else {
        self.saveCommentViewController.preferredContentSize = CGSizeMake(320, 568);
        self.saveCommentPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.saveCommentViewController];
        self.saveCommentPopoverController.delegate = self;
        
        [self.saveCommentPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                           inView:self.boardView
                                         permittedArrowDirections:UIPopoverArrowDirectionAny
                                                         animated:YES];
    }
}

- (void)showCommentViewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.commentViewController animated:NO completion:NULL];
    } else {
        //TODO:popupを透明にする?
        self.commentViewController.preferredContentSize = CGSizeMake(320, 568);
        self.commentPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.commentViewController];
        self.commentPopoverController.delegate = self;

        [self.commentPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                       inView:self.boardView
                                     permittedArrowDirections:UIPopoverArrowDirectionAny
                                                     animated:NO];
    }
}

- (void)showSearchRecordViewController {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.searchRecordViewController animated:YES completion:NULL];
    } else {
        self.searchRecordViewController.preferredContentSize = CGSizeMake(320, 800);
        self.searchRecordPopoverController = [[UIPopoverController alloc] initWithContentViewController:self.searchRecordViewController];
        self.searchRecordPopoverController.delegate = self;
        
        [self.searchRecordPopoverController presentPopoverFromRect:self.navigationBar.frame
                                                            inView:self.boardView
                                          permittedArrowDirections:UIPopoverArrowDirectionAny
                                                          animated:YES];
    }
}

- (void)showPreviousSearchResult {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    NSString *url = [userDefault stringForKey:@"previousSearchUrl"];
    
    NSLog(@"# previous search request url : %@", url);

    self.previousMatchTableViewController = [[KFMatchTableViewController alloc] initWithMatchId:MATCH_ID_PREVIOUS
                                                                                  matchDetailId:0
                                                                                            url:url];
    self.previousMatchTableViewController.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.previousMatchTableViewController animated:YES completion:NULL];
        [self.previousMatchTableViewController loadDummyWebView];
    } else {
        self.previousMatchTableViewController.preferredContentSize = CGSizeMake(320, 900);
        self.previousMatchTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.previousMatchTableViewController];
        self.previousMatchTablePopoverController.delegate = self;
        
        [self.previousMatchTablePopoverController presentPopoverFromRect:self.navigationBar.frame
                                                                  inView:self.boardView
                                                permittedArrowDirections:UIPopoverArrowDirectionAny
                                                                animated:YES];
        
        [self.previousMatchTableViewController loadDummyWebView];
    }
}

- (NSString *)buildPositionRequestUrl {
    NSMutableString *url = [NSMutableString stringWithString:@"http://wiki.optus.nu/shogi/index.php?cmd=kif&cmds=query7&mode=2"];
    [url appendString:[NSString stringWithFormat:@"&kensaku=%ld", self.currentMoveIndex + 1]];
    
    NSMutableArray *moveArray = [NSMutableArray arrayWithArray:self.moveArray];
    
    // 現在の指し手以降の手を削除する
    [moveArray removeObjectsInRange:NSMakeRange(self.currentMoveIndex + 1, [moveArray count] - self.currentMoveIndex - 1)];
    
    int count = 0;
    for (KFMove *move in moveArray) {
        NSString *moveText = [move getMoveTextForShogiDB];
        [url appendString:[NSString stringWithFormat:@"&te%d=%@", ++count, moveText]];
    }
    
    NSLog(@"# URL : %@", url);
    
    return [url stringByAddingPercentEscapesUsingEncoding:NSJapaneseEUCStringEncoding];
}

# pragma mark - action method for swipe gesture
- (void)swipeLeft:(UISwipeGestureRecognizer *)sender {
    if (self.mode == READ_MODE) {
        NSInteger count = self.currentMoveIndex + 1;
        
        for (int i = 0; i < count; i++) {
            [self rewindButtonTapped:nil];
        }
    }
}

- (void)swipeRight:(UISwipeGestureRecognizer *)sender {
    if (self.mode == READ_MODE) {
        NSInteger count = [self.moveArray count] - self.currentMoveIndex - 1;
        BOOL wasSoundAvailable = NO;

        // Disable sound temporarily
        if (self.isSoundAvailable) {
            wasSoundAvailable = YES;
            self.isSoundAvailable = NO;
        }

        for (int i = 0; i < count; i++) {
            [self forwardButtonTapped:nil];
        }
        
        // Restore sound setting
        if (wasSoundAvailable) {
            self.isSoundAvailable = YES;
        }
    }
}

# pragma mark - UIAlertViewDelegate method
- (void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    UIAlertView *nextAlertView;
    
    if (alertView.tag == kMenuAlertTag) { // 対局画面のメニュー
        switch (buttonIndex) {
            case kPlayMenuIndexCancel: // Cancel
                break;
            case kPlayMenuIndexInitBoard: // Initialize board
                // Show komaochi setting
                /*
                nextAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"キャンセル"
                                                 otherButtonTitles:
                                 @"平手",
                                 @"香落ち",
                                 @"角落ち",
                                 @"飛車落ち",
                                 @"飛車香落ち",
                                 @"二枚落ち",
                                 @"四枚落ち",
                                 @"六枚落ち",
                                 @"八枚落ち",
                                 nil];
                nextAlertView.tag = kKomaochiAlertTag;
                [nextAlertView show];
                 */

                [self initializeBoard];
                
                break;
            case kPlayMenuIndexManageRecord: // Manage record
                nextAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"キャンセル"
                                         otherButtonTitles:@"棋譜を読込",
                                                           @"棋譜を保存",
                                                           @"棋譜を出力",
                                                           @"棋譜を取得",
                                                           @"画像を共有",
                                                           nil];
                nextAlertView.tag = kManageRecordAlertTag;
                [nextAlertView show];
                
                break;
            case kPlayMenuIndexOpenSetting: // Open setting view
                [self showSettingViewController];
                
                break;
            case kPlayMenuIndexCloseBoard:
                [self dismissViewControllerAnimated:YES completion:nil];
                
                break;
        }
    } else if (alertView.tag == kPromotionAlertTag) { // 成り判定
        switch (buttonIndex) {
            case 0: //キャンセル
                break;
            case 1: //成り
                if (self.targetSquare.locatedPiece) { //移動先に駒がある場合
                    [self capture:self.targetSquare.locatedPiece by:self.selectedPiece.side];
                }

                // 指し手を保存
                [self saveMoveWithPromotion:YES];

                // 盤面を更新
                [self updateSquareViewWithPromotion:YES];
                
                self.isLocatedPieceSelected = NO;

                break;
            case 2: //成らず
                if (self.targetSquare.locatedPiece) { //移動先に駒がある場合
                    [self capture:self.targetSquare.locatedPiece by:self.selectedPiece.side];
                }
                
                // 指し手を保存
                [self saveMoveWithPromotion:NO];

                // 盤面を更新
                [self updateSquareViewWithPromotion:NO];

                self.isLocatedPieceSelected = NO;
                
                break;
        }
    } else if (alertView.tag == kRecordAlertTag) { // 棋譜再生画面のメニュー
        switch (buttonIndex) {
            case kReadMenuIndexCancel: // Cancel
                break;
            case kReadMenuIndexInitBoard: // Reset
                // Show komaochi setting
                /*
                nextAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"キャンセル"
                                                 otherButtonTitles:
                                 @"平手",
                                 @"香落ち",
                                 @"角落ち",
                                 @"飛車落ち",
                                 @"飛車香落ち",
                                 @"二枚落ち",
                                 @"四枚落ち",
                                 @"六枚落ち",
                                 @"八枚落ち",
                                 nil];
                nextAlertView.tag = kKomaochiAlertTag;
                [nextAlertView show];
                 */
                
                [self initializeBoard];

                break;
            case kReadMenuIndexManageRecord: // Manage record
                nextAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                   message:nil
                                                  delegate:self
                                         cancelButtonTitle:@"キャンセル"
                                         otherButtonTitles:@"棋譜を読込",
                                                           @"棋譜を保存",
                                                           @"棋譜を出力",
                                                           @"棋譜を取得",
                                                           @"画像を共有",
                                                           @"局面を編集",
                                                           nil];
                nextAlertView.tag = kManageRecordAlertTag;
                [nextAlertView show];
                
                break;
            case kReadMenuIndexOpenSetting: // Open setting view
                [self showSettingViewController];
                
                break;
        }
    } else if (alertView.tag == kSNSAlertTag) { // Share on SNS
        switch (buttonIndex) {
            case 0: // Cancel
                break;
            case 1: // Share on Twitter
                [self shareOnTwitter];
                
                break;
            case 2: // Share on Facebook
                [self shareOnFacebook];
                
                break;
        }
    } else if (alertView.tag == kLoadOptionAlertTag) { // Option for selecting the way for loading the record
        switch (buttonIndex) {
            case kLoadMenuIndexCancel: // Cancel
                break;
            case kLoadMenuIndexSearchRecord: // Search record
                nextAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"キャンセル"
                                                 otherButtonTitles:@"条件から検索", @"現在の局面から検索", @"前回の検索結果を表示", nil];
                nextAlertView.tag = kSearchOptionAlertTag;

                [nextAlertView show];
                
                break;
            case kLoadMenuIndexMatchList: // Load the latest record list
                [self showLatestMatchTableViewController];
                
                break;
        }
    } else if (alertView.tag == kManageRecordAlertTag) { // Option for managing record
        switch (buttonIndex) {
            case kManageRecordMenuIndexCancel:
                break;
            case kManageRecordMenuIndexReadRecord:
                [self showRecordViewController];
                
                break;
            case kManageRecordMenuIndexSaveRecord:
            {
                NSMutableArray *moveArray = [NSMutableArray arrayWithArray:self.moveArray];

                // 現在の指し手以降の手を削除する
                [moveArray removeObjectsInRange:NSMakeRange(self.currentMoveIndex + 1, [moveArray count] - self.currentMoveIndex - 1)];
                
                self.saveRecordViewController.moveArray = moveArray;
                [self showSaveRecordViewController];
            }

                break;
            case kManageRecordMenuIndexShareRecord:
                [self shareRecord];
                
                break;
            case kManageRecordMenuIndexGetRecord:
                nextAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                           message:nil
                                                          delegate:self
                                                 cancelButtonTitle:@"キャンセル"
                                                 otherButtonTitles:@"クリップボードから取得", @"URLから取得", nil];
                nextAlertView.tag = kGetRecordOptionAlertTag;
                
                [nextAlertView show];
                
                break;
            case kManageRecordMenuIndexShareImage:
                nextAlertView = [[UIAlertView alloc] initWithTitle:nil
                                                                message:nil
                                                               delegate:self
                                                      cancelButtonTitle:@"キャンセル"
                                                      otherButtonTitles:@"Twitterに投稿", @"Facebookに投稿", nil];
                nextAlertView.tag = kSNSAlertTag;
                
                [nextAlertView show];
                
                break;
            case kManageRecordMenuIndexEditBoard: // Edit record
                self.mode = PLAY_MODE;
                
                self.navigationBar.hidden = NO;
                self.recordToolBar.hidden = YES;
                
                self.sideRewindButton.hidden = YES;
                self.sideForwardButton.hidden = YES;
                
                self.commentButton.hidden = YES;
                
                // 現在の指し手以降の手を削除する
                [self.moveArray removeObjectsInRange:NSMakeRange(self.currentMoveIndex + 1, [self.moveArray count] - self.currentMoveIndex - 1)];
                
                self.boardNavigationItem.title = @"編集開始";
                
                break;
        }
    } else if (alertView.tag == kSearchOptionAlertTag) { // Option for searching record
        switch (buttonIndex) {
            case kSearchRecordMenuIndexCancel:
                break;
            case kSearchRecordMenuIndexCondition:
                [self showSearchRecordViewController];

                break;
            case kSearchRecordMenuIndexPosition:
                [self showPositionMatchTableViewController];
                
                break;
            case kSearchRecordMenuIndexPrevious:
                [self showPreviousSearchResult];
                
                break;
        }
    } else if (alertView.tag == kGetRecordOptionAlertTag) { // Option for getting record
        switch (buttonIndex) {
            case kGetRecordMenuIndexCancel:
                break;
            case kGetRecordMenuIndexClipBoard:
            {
                UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
                KFRecord *record = [[KFRecord alloc] init];

                record.recordText = [pasteboard valueForPasteboardType:@"public.text"];
                record.isCSV = NO;
                
                [self readRecord:record];
            }
                
                break;
            case kGetRecordMenuIndexUrl:
                [self showLoadRecordViewController];

                break;
        }
    } else if (alertView.tag == kKomaochiAlertTag) {
        self.komaochiIndex = buttonIndex - 1;
        
        [self initializeBoard];
    }
}

# pragma mark - KFSaveRecordViewControllerDelegate
- (void)dismissSaveRecordPopover {
    [self.saveRecordPopoverController dismissPopoverAnimated:YES];
}

- (void)readRecord:(KFRecord *)record {
    self.currentRecord = record;
    
    [self initializeBoard];

    // Create move array from record
    if (record.isCSV) {
        self.mode = READ_MODE;
        [self buildMoveArrayFromRecordCSV:record.recordCSV];
        
        self.matchTitleLabel.text = record.title;
    } else {
        self.mode = READ_MODE; // TODO:LOAD_MODEにする?
        [self buildMoveArrayFromRecordText:record.recordText];

        /*
        self.matchTitleLabel.text = [NSString stringWithFormat:@"%@\n%@\n",
                                     record.matchName ? record.matchName : @"",
                                     record.date ? record.date : @""];
         */
        self.matchTitleLabel.text = record.title;

        /*
        self.thisSidePlayerLabel.text = [NSString stringWithFormat:@"▲%@", self.currentRecord.firstPlayer];
        self.counterSidePlayerLabel.text = [NSString stringWithFormat:@"△%@", self.currentRecord.secondPlayer];
        self.thisSidePlayerLabel.hidden = NO;
        self.counterSidePlayerLabel.hidden = NO;
         */
    }
    
    // Hide Ad and show title in top
    self.admobTopBannerView.hidden = YES;
    self.matchTitleLabel.hidden = NO;

    // Hide all Ads for iPad
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.admobBottomBannerView.hidden = YES;
    }
    
    [self toggleCommentButton];
    
    // Enable side button and comment button
    self.sideRewindButton.hidden = NO;
    self.sideForwardButton.hidden = NO;
    
    self.commentButton.hidden = NO;

    // NaviBarを隠してToolbarを表示
    self.recordToolBar.hidden = NO;
}

- (void)buildMoveArrayFromRecordCSV:(NSString *)recordCSV {
    NSArray *lines = [recordCSV componentsSeparatedByString:@"\n"];
    int i = 0;
    
    for (NSString *line in lines) {
        if (![line length] > 0) {
            break;
        }
        
        NSLog(@"### [buildMoveArrayFromCSV] line(%d) : %@", ++i, line);
        NSArray *items = [line componentsSeparatedByString:@","];

        KFMove *move = [[KFMove alloc] init];
        
        NSString *previousX   = [items objectAtIndex:0];
        NSString *previousY   = [items objectAtIndex:1];
        NSString *currentX    = [items objectAtIndex:2];
        NSString *currentY    = [items objectAtIndex:3];
        NSString *side        = [items objectAtIndex:4];
        NSString *pieceId     = [items objectAtIndex:5];
        NSString *didDrop     = [items objectAtIndex:7];
        NSString *didPromote  = [items objectAtIndex:8];

        KFSquareButton *previousSquare = [self.squareDic objectForKey:[NSString stringWithFormat:@"%@%@", previousX, previousY]];
        move.previousSquare = previousSquare;
        move.previousSquare.locatedPiece = previousSquare.locatedPiece;
        
        KFSquareButton *currentSquare = [self.squareDic objectForKey:[NSString stringWithFormat:@"%@%@", currentX, currentY]];

        move.currentSquare = currentSquare;
        move.side = [side integerValue];
        move.movedPieceId = pieceId;

        if ([didDrop isEqualToString:@"1"]) {
            move.didDrop = YES; // 駒を打った場合
        } else {
            move.didDrop = NO; // 駒を動かした場合
        }
        
        if ([didPromote isEqualToString:@"1"]) {
            move.didPromote = YES;
        } else {
            move.didPromote = NO;
        }

        [self.moveArray addObject:move];
    }
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

// TODO:move this logic to outside
- (void)buildMoveArrayFromRecordText:(NSString *)recordText {
    NSArray *lines = [recordText componentsSeparatedByString:@"\n"];
    int i = 0;
    
    NSString *lastMoveX;
    NSString *lastMoveY;
    NSMutableString *commentStr = [NSMutableString string];
    NSMutableDictionary *commentDic = [NSMutableDictionary dictionary];
    
    for (NSString *line in lines) {
        if (!([line length] > 0)) {
            continue;
        }
        
//        NSString *comment;
        NSString *previousX;
        NSString *previousY;
        NSString *currentX;
        NSString *currentY;
        NSString *pieceName;
        
        NSString *didDrop = @"0";
        NSString *didPromote = @"0";
        
        NSString *commentLine = [self matchedStringbyPattern:@"\\*(.*)" body:line index:0];
        NSString *moveText = [self matchedStringbyPattern:@"[0-9]+\\s+.*(\\([1-9][1-9]\\)|打)" body:line index:0];
        
        // 棋戦
        if ([[self matchedStringbyPattern:@"棋戦：" body:line index:0] length] > 0) {
            self.currentRecord.matchName = [self matchedStringbyPattern:@"棋戦：(.*)" body:line index:1];
            [commentStr appendString:[NSString stringWithFormat:@"[%@]\n", self.currentRecord.matchName]];
        }

        // 日時
        if ([[self matchedStringbyPattern:@"開始日時：" body:line index:0] length] > 0) {
            self.currentRecord.date = [self matchedStringbyPattern:@"開始日時：(.*)" body:line index:1];
            [commentStr appendString:[NSString stringWithFormat:@"(%@)\n", self.currentRecord.date]];
        }
        
        // 先手・後手
        if ([[self matchedStringbyPattern:@"先手：" body:line index:0] length] > 0) {
            self.currentRecord.firstPlayer = [self matchedStringbyPattern:@"先手：(.*)" body:line index:1];
        }
        if ([[self matchedStringbyPattern:@"後手：" body:line index:0] length] > 0) {
            self.currentRecord.secondPlayer = [self matchedStringbyPattern:@"後手：(.*)" body:line index:1];
        }

        // Comment
        if ([commentLine length] > 0) {
            commentLine = [self matchedStringbyPattern:@"\\*(.*)" body:line index:1];
            [commentStr appendString:commentLine];
        } else {
            if ([commentStr length] > 0) {
                [commentDic setObject:commentStr forKey:[NSString stringWithFormat:@"%d", i]];
            }

            commentStr = [NSMutableString string];
        }

        if ([moveText length] > 0) { // 指し手の行にマッチ
//            NSLog(@"######## (%d手目) MATCH:%@", i + 1, moveText);
            i++;
        } else {
            continue;
        }

        if ([moveText rangeOfString:@"同"].location != NSNotFound) {
            currentX = lastMoveX;
            currentY = lastMoveY;
            
            previousX = [self matchedStringbyPattern:@"[0-9]+.*\\(([1-9])[1-9]\\)" body:moveText index:1];
            previousY = [self matchedStringbyPattern:@"[0-9]+.*\\([1-9]([1-9])\\)" body:moveText index:1];
            pieceName = [self matchedStringbyPattern:@"[0-9]+\\s+同\\s*(.*)\\(.*\\)" body:moveText index:1];
        } else {
            // Match with current X
            currentX = [self matchedStringbyPattern:@"[0-9]+\\s+(.)" body:moveText index:1];
            lastMoveX = currentX;

            // Match with current Y
            currentY = [self matchedStringbyPattern:@"[0-9]+\\s+.(.)" body:moveText index:1];
            lastMoveY = currentY;
            
            // Piece name
            if ([moveText rangeOfString:@"打"].location != NSNotFound) {
                didDrop = @"1";
                
                previousX = @"0";
                previousY = @"0";
                pieceName = [self matchedStringbyPattern:@"[0-9]+\\s+..(.*)打" body:moveText index:1];
            } else {
                previousX = [self matchedStringbyPattern:@"[0-9]+\\s+.*\\(([1-9])[1-9]\\)" body:moveText index:1];
                previousY = [self matchedStringbyPattern:@"[0-9]+\\s+.*\\([1-9]([1-9])\\)" body:moveText index:1];
                pieceName = [self matchedStringbyPattern:@"[0-9]+\\s+..(.*)\\([1-9][1-9]\\)" body:moveText index:1];
            }
        }
        
        if ([[self matchedStringbyPattern:@".*成$" body:pieceName index:0] length] > 0) {
            didPromote = @"1";
            pieceName = [self matchedStringbyPattern:@"(.*)成" body:pieceName index:1];
        }
        
        KFMove *move = [[KFMove alloc] init];
        move.movedPieceName = pieceName;
        
        NSString *movePreviousX   = previousX;
        NSString *movePreviousY   = previousY;
        NSString *moveCurrentX    = [NSString stringWithFormat:@"%ld", [move getXInt:currentX]];
        NSString *moveCurrentY    = [NSString stringWithFormat:@"%ld", [move getYInt:currentY]];
        
        // 駒落ちは上手が先に指すため、sideを逆にする
//        NSString *side            = (i % 2 == 0) ? @"1" : @"0";
        NSString *side            = (i % 2 == 0) ? @"0" : @"1";
        
        NSString *pieceId         = move.getMovedPieceId;
        
        /*
        NSLog(@"# [MOVE] currentX:%@", moveCurrentX);
        NSLog(@"# [MOVE] currentY:%@", moveCurrentY);
        NSLog(@"# [MOVE] previousX:%@", movePreviousX);
        NSLog(@"# [MOVE] previousY:%@", movePreviousY);
        NSLog(@"# [MOVE] side:%@", side);
        NSLog(@"# [MOVE] pieceId:%@", pieceId);
        NSLog(@"# [MOVE] didDrop:%@", didDrop);
        NSLog(@"# [MOVE] didPromote:%@", didPromote);
         */
       
        KFSquareButton *previousSquare = [self.squareDic objectForKey:[NSString stringWithFormat:@"%@%@", movePreviousX, movePreviousY]];
        move.previousSquare = previousSquare;
        move.previousSquare.locatedPiece = previousSquare.locatedPiece;
        
        KFSquareButton *currentSquare = [self.squareDic objectForKey:[NSString stringWithFormat:@"%@%@", moveCurrentX, moveCurrentY]];
        
        move.currentSquare = currentSquare;
        move.side = [side integerValue];
        move.movedPieceId = pieceId;
        
        if ([didDrop isEqualToString:@"1"]) {
            move.didDrop = YES; // 駒を打った場合
        } else {
            move.didDrop = NO; // 駒を動かした場合
        }
        
        if ([didPromote isEqualToString:@"1"]) {
            move.didPromote = YES;
        } else {
            move.didPromote = NO;
        }
        
        [self.moveArray addObject:move];
    }
    
    self.currentRecord.commentDic = [NSDictionary dictionaryWithDictionary:commentDic];
}

# pragma mark - KFRecordTableViewControllerDelegate, KFLoadRecordViewControllerDelegate, KFTitleTableViewControllerDelegate
- (void)didFinishLoadRecord:(KFRecord *)record {
    [self dismissViewControllerAnimated:YES completion:NULL];
    [self readRecord:record];
}

- (void)dismissTitleTablePopover {
    [self.TitleTablePopoverController dismissPopoverAnimated:YES];
}

# pragma mark - KFCommentBaseViewControllerDelegate
- (void)didSaveComment {
    self.currentRecord = [KFRecord retrieveRecordAtIndex:self.currentRecord.index];

    [self toggleCommentButton];
}

- (void)dismissCommentPopover {
    [self.commentPopoverController dismissPopoverAnimated:YES];
}

# pragma mark - KFSaveCommentViewControllerDelegate
- (void)dismissSaveCommentPopover {
    [self.saveCommentPopoverController dismissPopoverAnimated:YES];
}

# pragma mark - KFSettingViewControllerDelegate
- (void)updateSetting {
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    if ([[userDefault stringForKey:@"isMotionFree"] isEqualToString:@"1"]) {

    if ([[userDefault stringForKey:@"isMotionFree"] isEqualToString:@"YES"]) {
        self.isMotionFree = YES;
    } else {
        self.isMotionFree = NO;
    }
    
    if ([[userDefault stringForKey:@"isSoundAvailable"] isEqualToString:@"YES"]) {
        self.isSoundAvailable = YES;
    } else {
        self.isSoundAvailable = NO;
    }
}

- (void)turnBoardView:(BOOL)shouldTurn {
    if (shouldTurn) {
        self.boardView.transform = CGAffineTransformMakeRotation(M_PI/2 * 2);

        // Hide Ad temporarily, otherwise the captured pieces is hidden by Ad
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.admobBottomBannerView.hidden = YES;
        }
        
    } else {
        self.boardView.transform = CGAffineTransformIdentity;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            self.admobBottomBannerView.hidden = NO;
        }
    }
}

- (void)dismissSettingPopover {
    [self.settingPopoverController dismissPopoverAnimated:YES];
}

# pragma mark - KFSearchRecordViewControllerDelegate
- (void)dismissSearchRecordPopover {
    [self.searchRecordPopoverController dismissPopoverAnimated:YES];
}

# pragma mark - KFMatchTableViewControllerDelegate
- (void)dismissMatchTablePopover {
    [self.latestMatchTablePopoverController dismissPopoverAnimated:YES];
}

# pragma mark - KFMoveTableViewControllerDelegate
- (void)transferToMoveIndex:(NSInteger)targetMoveIndex {
    // Do nothing if target is same as current move
    if (self.currentMoveIndex == targetMoveIndex) {
        return;
    }
    
    BOOL wasSoundAvailable = NO;

    // Disable sound temporarily
    if (self.isSoundAvailable) {
        wasSoundAvailable = YES;
        self.isSoundAvailable = NO;
    }

    // Update board to target move
    if (self.currentMoveIndex < targetMoveIndex) {
        // Forward
        for (NSInteger i = self.currentMoveIndex; i < targetMoveIndex; i++) {
            [self forwardButtonTapped:nil];
        }
    } else if (self.currentMoveIndex > targetMoveIndex) {
        // Rewind
        for (NSInteger i = self.currentMoveIndex; i > targetMoveIndex; i--) {
            [self rewindButtonTapped:nil];
        }
    }
    
    // Restore sound setting
    if (wasSoundAvailable) {
        self.isSoundAvailable = YES;
    }
}

# pragma mark - NADViewDelegate
-(void)nadViewDidFinishLoad:(NADView *)adView {
    NSLog(@"delegate nadViewDidFinishLoad:");
}

# pragma mark - Action method
- (IBAction)waitButtonTapped:(id)sender {
    // Cancel selected status
    if (self.isLocatedPieceSelected || self.isCapturedPieceSelected) {
        [self.selectedSquare setBackgroundColor:[UIColor clearColor]];

        self.isLocatedPieceSelected = NO;
        self.isCapturedPieceSelected = NO;
        self.selectedPiece = nil;
        self.selectedSquare = nil;
    }

    if ([self canRewind]) {
        // 手を戻す
        [self restoreMove:self.currentMoveIndex];
        
        // 直前の指し手を消去
        [self.moveArray removeLastObject];
        self.currentMoveIndex--;
    }
}

- (IBAction)menuButtonTapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"キャンセル"
                                          otherButtonTitles:@"盤面を初期化",
                                                            @"棋譜管理",
                                                            @"設定",
                                                            @"将棋盤を閉じる",
                                                            nil];
    
    alert.tag = kMenuAlertTag;
    
    [alert show];
}

- (IBAction)rewindButtonTapped:(id)sender {
    if ([self canRewind]) {
        // 手を戻す
        [self restoreMove:self.currentMoveIndex];
        self.currentMoveIndex--;
        
        // Show comment if it exists
        [self toggleCommentButton];
    }
}

- (IBAction)forwardButtonTapped:(id)sender {
    // 最終手まで進んだら何もしない
    if ([self.moveArray count] == self.currentMoveIndex + 1) {
        if ([self.moveArray count] == self.currentMoveIndex + 1) {
            //TODO:実際に棋譜から「まで〜の勝ち」等の勝敗情報を読み取って表示するようにする
            // 一時的に勝敗情報を表示
            if ([self.currentRecord.matchName length] > 0) {
                if (self.currentMoveIndex % 2 == 0) {
                    self.recordTitleButtonItem.title = @"まで先手の勝ち";
                } else {
                    self.recordTitleButtonItem.title = @"まで後手の勝ち";
                }
            }
        }
        
        return;
    }
    
    self.currentMoveIndex++;

    KFMove *move = [self.moveArray objectAtIndex:self.currentMoveIndex];
    
    // Show comment if it exists
    [self toggleCommentButton];
    
    self.selectedSquare = move.previousSquare;
    self.selectedPiece = move.previousSquare.locatedPiece;
    self.targetSquare = move.currentSquare;

    self.shouldClearSelectedPiece = YES;
    
    // 動きを再現する
    if (move.didDrop) { // 駒を打つ場合
        KFCapturedPieceButton *selectedSquare;
        
        if (move.side == THIS_SIDE) {
            selectedSquare = [self.thisSideCapturedPieceButtons objectForKey:move.movedPieceId];
        } else {
            selectedSquare = [self.counterSideCapturedPieceButtons objectForKey:move.movedPieceId];
        }
        
        // 持ち駒、ボタンを登録
        self.selectedSquare = selectedSquare;
        self.selectedPiece = selectedSquare.locatedPiece;
        
        // moveに駒を保存
        move.movedPiece = [self.selectedPiece copy];
        
        // 駒台から打った駒を消す
        if (self.selectedPiece.side == THIS_SIDE) {
            [self subtractCapturedPiece:self.selectedPiece
                                 button:(KFCapturedPieceButton *)self.selectedSquare
                                   side:THIS_SIDE];
        } else {
            [self subtractCapturedPiece:self.selectedPiece
                                 button:(KFCapturedPieceButton *)self.selectedSquare
                                   side:COUNTER_SIDE];
        }
        
        [self updateSquareViewWithPromotion:NO];
    } else { // 駒を移動する場合
        // moveに駒を保存
        move.movedPiece = [self.selectedPiece copy];
        
        if (self.targetSquare.locatedPiece) { //移動先に駒がある場合
            // 駒を取る
            [self capture:self.targetSquare.locatedPiece by:self.selectedPiece.side];
            
            // moveに取った駒を保存
            move.capturedPiece = [self.targetSquare.locatedPiece copy];
            
            // moveに持ち駒ボタンを保存
            if (move.side == THIS_SIDE) {
                move.capturedPieceButton = [self.thisSideCapturedPieceButtons objectForKey:[move.capturedPiece getOriginalPieceId]];
            } else {
                move.capturedPieceButton = [self.counterSideCapturedPieceButtons objectForKey:[move.capturedPiece getOriginalPieceId]];
            }
        }
        
        // 盤面を更新
        [self updateSquareViewWithPromotion:move.didPromote];
    }
    
    // Update title
    self.recordTitleButtonItem.title = [move getMoveTextWithIndex:self.currentMoveIndex + 1];
}

- (IBAction)recordTitleButtonTapped:(id)sender {
    if (!self.moveTableViewController) {
        self.moveTableViewController = [[KFMoveTableViewController alloc] init];
        self.moveTableViewController.delegate = self;
    }

    self.moveTableViewController.moveArray = self.moveArray;
    self.moveTableViewController.currentMoveIndex = self.currentMoveIndex;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self presentViewController:self.moveTableViewController animated:YES completion:NULL];
    } else {
        self.moveTableViewController.preferredContentSize = CGSizeMake(320, 800);
        self.moveTablePopoverController = [[UIPopoverController alloc] initWithContentViewController:self.moveTableViewController];
        self.moveTablePopoverController.delegate = self;
        
        [self.moveTablePopoverController presentPopoverFromRect:self.navigationBar.frame
                                                         inView:self.boardView
                                       permittedArrowDirections:UIPopoverArrowDirectionAny
                                                       animated:YES];
    }
}

- (IBAction)recordMenuButtonTapped:(id)sender {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil
                                                    message:nil
                                                   delegate:self
                                          cancelButtonTitle:@"キャンセル"
                                          otherButtonTitles:@"盤面を初期化",
                                                            @"棋譜管理",
                                                            @"設定",
                                                            nil];
    alert.tag = kRecordAlertTag;
    
    [alert show];
}

//TODO:Track this action
- (IBAction)showComment:(id)sender {
    NSString *comment = [self.currentRecord.commentDic objectForKey:[NSString stringWithFormat:@"%ld", self.currentMoveIndex + 1]];
    NSString *moveIndexStr = [NSString stringWithFormat:@"%ld", self.currentMoveIndex + 1];
    NSString *lastMoveStr;

    if (self.currentMoveIndex >= 0) {
        lastMoveStr = [[self.moveArray objectAtIndex:self.currentMoveIndex] getMoveTextWithMarked:YES];
    }

    NSString *navTitle = [NSString stringWithFormat:@"%@手目 %@", moveIndexStr, (lastMoveStr ? lastMoveStr : @"")];
    
    if ([comment length] > 0) {
        // Show the comment
        self.commentViewController.commentDic = self.currentRecord.commentDic;
        self.commentViewController.currentMoveIndex = self.currentMoveIndex;
        self.commentViewController.recordIndex = self.currentRecord.index;
        self.commentViewController.navTitle = navTitle;
        
        [self showCommentViewController];
    } else {
        // コメント編集不可
        return;
    }
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)topRewindButtonTapped:(id)sender {
    [self swipeLeft:nil];
}

- (IBAction)topForwardButtonTapped:(id)sender {
    [self swipeRight:nil];
}

- (IBAction)square11tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square12tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square13tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square14tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square15tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square16tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square17tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square18tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square19tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square21tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square22tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square23tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square24tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square25tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square26tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square27tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square28tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square29tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square31tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square32tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square33tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square34tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square35tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square36tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square37tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square38tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square39tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square41tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square42tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square43tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square44tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square45tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square46tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square47tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square48tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square49tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square51tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square52tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square53tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square54tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square55tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square56tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square57tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square58tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square59tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square61tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square62tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square63tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square64tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square65tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square66tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square67tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square68tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square69tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square71tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square72tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square73tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square74tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square75tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square76tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square77tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square78tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square79tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square81tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square82tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square83tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square84tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square85tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square86tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square87tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square88tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square89tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square91tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square92tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square93tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square94tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square95tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square96tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square97tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square98tapped:(id)sender {
    [self selectSquare:sender];
}
- (IBAction)square99tapped:(id)sender {
    [self selectSquare:sender];
}

# pragma mark - Initialization
// 盤面を初期化
- (void)initializeBoard {
    NSLog(@"# Initialize!!");
    
    self.boardNavigationItem.title = @"対局開始";
    self.recordTitleButtonItem.title = @"初期画面";
    
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];

    if ([[userDefault stringForKey:@"isMotionFree"] isEqualToString:@"NO"]) {
        self.isMotionFree = NO;
    } else {
        self.isMotionFree = YES;
    }
    
    if ([[userDefault stringForKey:@"isSoundAvailable"] isEqualToString:@"NO"]) {
        self.isSoundAvailable = NO;
    } else {
        self.isSoundAvailable = YES;
    }
    
    self.komaochiIndex = [userDefault integerForKey:@"komaochiIndex"];

    // Initialize current side
    self.currentSide = THIS_SIDE;
    
    // Hide top banner
    self.admobTopBannerView.hidden = YES;
    self.admobBottomBannerView.hidden = NO;
    
    self.navigationBar.hidden = NO;
    self.recordToolBar.hidden = YES;

    self.sideRewindButton.hidden = YES;
    self.sideForwardButton.hidden = YES;
    self.commentButton.hidden = NO;
    self.thisSidePlayerLabel.hidden = YES;
    self.counterSidePlayerLabel.hidden = YES;
    self.matchTitleLabel.hidden = YES;

    self.mode = PLAY_MODE;
    self.currentMoveIndex = -1;
    
    self.isLocatedPieceSelected = NO;
    self.isCapturedPieceSelected = NO;
    
    // Clear background color of previous target square
    [self clearSquareColor];
    
    // 指し手を初期化
    self.moveArray = [NSMutableArray array];
    
    // Captured pieces (持ち駒)を初期化
    self.thisSideCapturedPieces = [NSMutableDictionary dictionary];
    self.counterSideCapturedPieces = [NSMutableDictionary dictionary];
    
    // Captured pieces button (持ち駒ボタン)を初期化
    self.thisSideCapturedPieceButtons = [NSMutableDictionary dictionary];
    self.counterSideCapturedPieceButtons = [NSMutableDictionary dictionary];
    
    // Stand (駒台)を初期化
    for (UIView *view in [self.thisSideStandView subviews]) {
        [view removeFromSuperview];
    }
    
    for (UIView *view in [self.counterSideStandView subviews]) {
        [view removeFromSuperview];
    }
    
    [self deployPieceWithKomaochiIndex:self.komaochiIndex];
    
    // Pieces of this side
    self.square19.locatedPiece = [[KFKyosha alloc] initWithSide:THIS_SIDE];
    self.square29.locatedPiece = [[KFKeima alloc] initWithSide:THIS_SIDE];
    self.square39.locatedPiece = [[KFGin alloc] initWithSide:THIS_SIDE];
    self.square49.locatedPiece = [[KFKin alloc] initWithSide:THIS_SIDE];
    self.square59.locatedPiece = [[KFGyoku alloc] initWithSide:THIS_SIDE];
    self.square69.locatedPiece = [[KFKin alloc] initWithSide:THIS_SIDE];
    self.square79.locatedPiece = [[KFGin alloc] initWithSide:THIS_SIDE];
    self.square89.locatedPiece = [[KFKeima alloc] initWithSide:THIS_SIDE];
    self.square99.locatedPiece = [[KFKyosha alloc] initWithSide:THIS_SIDE];
    self.square28.locatedPiece = [[KFHisha alloc] initWithSide:THIS_SIDE];
    self.square88.locatedPiece = [[KFKaku alloc] initWithSide:THIS_SIDE];
    self.square17.locatedPiece = [[KFFu alloc] initWithSide:THIS_SIDE];
    self.square27.locatedPiece = [[KFFu alloc] initWithSide:THIS_SIDE];
    self.square37.locatedPiece = [[KFFu alloc] initWithSide:THIS_SIDE];
    self.square47.locatedPiece = [[KFFu alloc] initWithSide:THIS_SIDE];
    self.square57.locatedPiece = [[KFFu alloc] initWithSide:THIS_SIDE];
    self.square67.locatedPiece = [[KFFu alloc] initWithSide:THIS_SIDE];
    self.square77.locatedPiece = [[KFFu alloc] initWithSide:THIS_SIDE];
    self.square87.locatedPiece = [[KFFu alloc] initWithSide:THIS_SIDE];
    self.square97.locatedPiece = [[KFFu alloc] initWithSide:THIS_SIDE];
    
    // Images of this side
    [self.square19 setImage:[UIImage imageNamed:[self.square19.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square29 setImage:[UIImage imageNamed:[self.square29.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square39 setImage:[UIImage imageNamed:[self.square39.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square49 setImage:[UIImage imageNamed:[self.square49.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square59 setImage:[UIImage imageNamed:[self.square59.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square69 setImage:[UIImage imageNamed:[self.square69.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square79 setImage:[UIImage imageNamed:[self.square79.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square89 setImage:[UIImage imageNamed:[self.square89.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square99 setImage:[UIImage imageNamed:[self.square99.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square28 setImage:[UIImage imageNamed:[self.square28.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square88 setImage:[UIImage imageNamed:[self.square88.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square17 setImage:[UIImage imageNamed:[self.square17.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square27 setImage:[UIImage imageNamed:[self.square27.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square37 setImage:[UIImage imageNamed:[self.square37.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square47 setImage:[UIImage imageNamed:[self.square47.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square57 setImage:[UIImage imageNamed:[self.square57.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square67 setImage:[UIImage imageNamed:[self.square67.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square77 setImage:[UIImage imageNamed:[self.square77.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square87 setImage:[UIImage imageNamed:[self.square87.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square97 setImage:[UIImage imageNamed:[self.square97.locatedPiece getImageName]] forState:UIControlStateNormal];
    
    // Pieces of blank square
    self.square12.locatedPiece = nil;
    self.square32.locatedPiece = nil;
    self.square42.locatedPiece = nil;
    self.square52.locatedPiece = nil;
    self.square62.locatedPiece = nil;
    self.square72.locatedPiece = nil;
    self.square92.locatedPiece = nil;
    self.square14.locatedPiece = nil;
    self.square24.locatedPiece = nil;
    self.square34.locatedPiece = nil;
    self.square44.locatedPiece = nil;
    self.square54.locatedPiece = nil;
    self.square64.locatedPiece = nil;
    self.square74.locatedPiece = nil;
    self.square84.locatedPiece = nil;
    self.square94.locatedPiece = nil;
    self.square15.locatedPiece = nil;
    self.square25.locatedPiece = nil;
    self.square35.locatedPiece = nil;
    self.square45.locatedPiece = nil;
    self.square55.locatedPiece = nil;
    self.square65.locatedPiece = nil;
    self.square75.locatedPiece = nil;
    self.square85.locatedPiece = nil;
    self.square95.locatedPiece = nil;
    self.square16.locatedPiece = nil;
    self.square26.locatedPiece = nil;
    self.square36.locatedPiece = nil;
    self.square46.locatedPiece = nil;
    self.square56.locatedPiece = nil;
    self.square66.locatedPiece = nil;
    self.square76.locatedPiece = nil;
    self.square86.locatedPiece = nil;
    self.square96.locatedPiece = nil;
    self.square18.locatedPiece = nil;
    self.square38.locatedPiece = nil;
    self.square48.locatedPiece = nil;
    self.square58.locatedPiece = nil;
    self.square68.locatedPiece = nil;
    self.square78.locatedPiece = nil;
    self.square98.locatedPiece = nil;
    
    // Images of blank square
    [self.square12 setImage:nil forState:UIControlStateNormal];
    [self.square32 setImage:nil forState:UIControlStateNormal];
    [self.square42 setImage:nil forState:UIControlStateNormal];
    [self.square52 setImage:nil forState:UIControlStateNormal];
    [self.square62 setImage:nil forState:UIControlStateNormal];
    [self.square72 setImage:nil forState:UIControlStateNormal];
    [self.square92 setImage:nil forState:UIControlStateNormal];
    [self.square14 setImage:nil forState:UIControlStateNormal];
    [self.square24 setImage:nil forState:UIControlStateNormal];
    [self.square34 setImage:nil forState:UIControlStateNormal];
    [self.square44 setImage:nil forState:UIControlStateNormal];
    [self.square54 setImage:nil forState:UIControlStateNormal];
    [self.square64 setImage:nil forState:UIControlStateNormal];
    [self.square74 setImage:nil forState:UIControlStateNormal];
    [self.square84 setImage:nil forState:UIControlStateNormal];
    [self.square94 setImage:nil forState:UIControlStateNormal];
    [self.square15 setImage:nil forState:UIControlStateNormal];
    [self.square25 setImage:nil forState:UIControlStateNormal];
    [self.square35 setImage:nil forState:UIControlStateNormal];
    [self.square45 setImage:nil forState:UIControlStateNormal];
    [self.square55 setImage:nil forState:UIControlStateNormal];
    [self.square65 setImage:nil forState:UIControlStateNormal];
    [self.square75 setImage:nil forState:UIControlStateNormal];
    [self.square85 setImage:nil forState:UIControlStateNormal];
    [self.square95 setImage:nil forState:UIControlStateNormal];
    [self.square16 setImage:nil forState:UIControlStateNormal];
    [self.square26 setImage:nil forState:UIControlStateNormal];
    [self.square36 setImage:nil forState:UIControlStateNormal];
    [self.square46 setImage:nil forState:UIControlStateNormal];
    [self.square56 setImage:nil forState:UIControlStateNormal];
    [self.square66 setImage:nil forState:UIControlStateNormal];
    [self.square76 setImage:nil forState:UIControlStateNormal];
    [self.square86 setImage:nil forState:UIControlStateNormal];
    [self.square96 setImage:nil forState:UIControlStateNormal];
    [self.square18 setImage:nil forState:UIControlStateNormal];
    [self.square38 setImage:nil forState:UIControlStateNormal];
    [self.square48 setImage:nil forState:UIControlStateNormal];
    [self.square58 setImage:nil forState:UIControlStateNormal];
    [self.square68 setImage:nil forState:UIControlStateNormal];
    [self.square78 setImage:nil forState:UIControlStateNormal];
    [self.square98 setImage:nil forState:UIControlStateNormal];
}

- (void)deployPieceWithKomaochiIndex:(NSInteger)komaochiIndex {
    NSLog(@"komaochiIndex : %ld", komaochiIndex);
    
    self.square13.locatedPiece = [[KFFu alloc] initWithSide:COUNTER_SIDE];
    self.square23.locatedPiece = [[KFFu alloc] initWithSide:COUNTER_SIDE];
    self.square33.locatedPiece = [[KFFu alloc] initWithSide:COUNTER_SIDE];
    self.square43.locatedPiece = [[KFFu alloc] initWithSide:COUNTER_SIDE];
    self.square53.locatedPiece = [[KFFu alloc] initWithSide:COUNTER_SIDE];
    self.square63.locatedPiece = [[KFFu alloc] initWithSide:COUNTER_SIDE];
    self.square73.locatedPiece = [[KFFu alloc] initWithSide:COUNTER_SIDE];
    self.square83.locatedPiece = [[KFFu alloc] initWithSide:COUNTER_SIDE];
    self.square93.locatedPiece = [[KFFu alloc] initWithSide:COUNTER_SIDE];
    
    [self.square13 setImage:[UIImage imageNamed:[self.square13.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square23 setImage:[UIImage imageNamed:[self.square23.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square33 setImage:[UIImage imageNamed:[self.square33.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square43 setImage:[UIImage imageNamed:[self.square43.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square53 setImage:[UIImage imageNamed:[self.square53.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square63 setImage:[UIImage imageNamed:[self.square63.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square73 setImage:[UIImage imageNamed:[self.square73.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square83 setImage:[UIImage imageNamed:[self.square83.locatedPiece getImageName]] forState:UIControlStateNormal];
    [self.square93 setImage:[UIImage imageNamed:[self.square93.locatedPiece getImageName]] forState:UIControlStateNormal];
    
    switch (komaochiIndex) {
        case kKomaochiIndexHirate:
            // Pieces of counter side
            self.square11.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square21.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square31.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square41.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square51.locatedPiece = [[KFGyoku alloc] initWithSide:COUNTER_SIDE];
            self.square61.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square71.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square81.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square91.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square22.locatedPiece = [[KFKaku alloc] initWithSide:COUNTER_SIDE];
            self.square82.locatedPiece = [[KFHisha alloc] initWithSide:COUNTER_SIDE];
            
            // Images of counter side
            [self.square11 setImage:[UIImage imageNamed:[self.square11.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square21 setImage:[UIImage imageNamed:[self.square21.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square31 setImage:[UIImage imageNamed:[self.square31.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square41 setImage:[UIImage imageNamed:[self.square41.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square51 setImage:[UIImage imageNamed:[self.square51.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square61 setImage:[UIImage imageNamed:[self.square61.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square71 setImage:[UIImage imageNamed:[self.square71.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square81 setImage:[UIImage imageNamed:[self.square81.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square91 setImage:[UIImage imageNamed:[self.square91.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square22 setImage:[UIImage imageNamed:[self.square22.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square82 setImage:[UIImage imageNamed:[self.square82.locatedPiece getImageName]] forState:UIControlStateNormal];
            
            break;
        case kKomaochiIndexKyoochi:
            // Pieces of counter side
//            self.square11.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square21.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square31.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square41.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square51.locatedPiece = [[KFGyoku alloc] initWithSide:COUNTER_SIDE];
            self.square61.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square71.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square81.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square91.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square22.locatedPiece = [[KFKaku alloc] initWithSide:COUNTER_SIDE];
            self.square82.locatedPiece = [[KFHisha alloc] initWithSide:COUNTER_SIDE];
            
            // Images of counter side
//            [self.square11 setImage:[UIImage imageNamed:[self.square11.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square21 setImage:[UIImage imageNamed:[self.square21.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square31 setImage:[UIImage imageNamed:[self.square31.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square41 setImage:[UIImage imageNamed:[self.square41.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square51 setImage:[UIImage imageNamed:[self.square51.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square61 setImage:[UIImage imageNamed:[self.square61.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square71 setImage:[UIImage imageNamed:[self.square71.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square81 setImage:[UIImage imageNamed:[self.square81.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square91 setImage:[UIImage imageNamed:[self.square91.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square22 setImage:[UIImage imageNamed:[self.square22.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square82 setImage:[UIImage imageNamed:[self.square82.locatedPiece getImageName]] forState:UIControlStateNormal];
            
            // Pieces of blank square
            self.square11.locatedPiece = nil;
            
            // Images of blank square
            [self.square11 setImage:nil forState:UIControlStateNormal];
            
            break;
        case kKomaochiIndexKakuochi:
            // Pieces of counter side
            self.square11.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square21.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square31.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square41.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square51.locatedPiece = [[KFGyoku alloc] initWithSide:COUNTER_SIDE];
            self.square61.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square71.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square81.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square91.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
//            self.square22.locatedPiece = [[KFKaku alloc] initWithSide:COUNTER_SIDE];
            self.square82.locatedPiece = [[KFHisha alloc] initWithSide:COUNTER_SIDE];
            
            // Images of counter side
            [self.square11 setImage:[UIImage imageNamed:[self.square11.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square21 setImage:[UIImage imageNamed:[self.square21.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square31 setImage:[UIImage imageNamed:[self.square31.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square41 setImage:[UIImage imageNamed:[self.square41.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square51 setImage:[UIImage imageNamed:[self.square51.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square61 setImage:[UIImage imageNamed:[self.square61.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square71 setImage:[UIImage imageNamed:[self.square71.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square81 setImage:[UIImage imageNamed:[self.square81.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square91 setImage:[UIImage imageNamed:[self.square91.locatedPiece getImageName]] forState:UIControlStateNormal];
//            [self.square22 setImage:[UIImage imageNamed:[self.square22.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square82 setImage:[UIImage imageNamed:[self.square82.locatedPiece getImageName]] forState:UIControlStateNormal];
            
            // Pieces of blank square
            self.square22.locatedPiece = nil;
            
            // Images of blank square
            [self.square22 setImage:nil forState:UIControlStateNormal];
            
            break;
        case kKomaochiIndexHishaochi:
            // Pieces of counter side
            self.square11.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square21.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square31.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square41.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square51.locatedPiece = [[KFGyoku alloc] initWithSide:COUNTER_SIDE];
            self.square61.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square71.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square81.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square91.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square22.locatedPiece = [[KFKaku alloc] initWithSide:COUNTER_SIDE];
            //self.square82.locatedPiece = [[KFHisha alloc] initWithSide:COUNTER_SIDE];
            
            // Images of counter side
            [self.square11 setImage:[UIImage imageNamed:[self.square11.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square21 setImage:[UIImage imageNamed:[self.square21.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square31 setImage:[UIImage imageNamed:[self.square31.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square41 setImage:[UIImage imageNamed:[self.square41.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square51 setImage:[UIImage imageNamed:[self.square51.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square61 setImage:[UIImage imageNamed:[self.square61.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square71 setImage:[UIImage imageNamed:[self.square71.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square81 setImage:[UIImage imageNamed:[self.square81.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square91 setImage:[UIImage imageNamed:[self.square91.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square22 setImage:[UIImage imageNamed:[self.square22.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square82 setImage:[UIImage imageNamed:[self.square82.locatedPiece getImageName]] forState:UIControlStateNormal];
            
            // Pieces of blank square
            self.square82.locatedPiece = nil;
            
            // Images of blank square
            [self.square82 setImage:nil forState:UIControlStateNormal];
            
            break;
        case kKomaochiIndexHikyoochi:
            // Pieces of counter side
            //self.square11.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square21.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square31.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square41.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square51.locatedPiece = [[KFGyoku alloc] initWithSide:COUNTER_SIDE];
            self.square61.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square71.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square81.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square91.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square22.locatedPiece = [[KFKaku alloc] initWithSide:COUNTER_SIDE];
            //self.square82.locatedPiece = [[KFHisha alloc] initWithSide:COUNTER_SIDE];
            
            // Images of counter side
            //[self.square11 setImage:[UIImage imageNamed:[self.square11.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square21 setImage:[UIImage imageNamed:[self.square21.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square31 setImage:[UIImage imageNamed:[self.square31.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square41 setImage:[UIImage imageNamed:[self.square41.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square51 setImage:[UIImage imageNamed:[self.square51.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square61 setImage:[UIImage imageNamed:[self.square61.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square71 setImage:[UIImage imageNamed:[self.square71.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square81 setImage:[UIImage imageNamed:[self.square81.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square91 setImage:[UIImage imageNamed:[self.square91.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square22 setImage:[UIImage imageNamed:[self.square22.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square82 setImage:[UIImage imageNamed:[self.square82.locatedPiece getImageName]] forState:UIControlStateNormal];
            
            // Pieces of blank square
            self.square11.locatedPiece = nil;
            self.square82.locatedPiece = nil;
            
            // Images of blank square
            [self.square11 setImage:nil forState:UIControlStateNormal];
            [self.square82 setImage:nil forState:UIControlStateNormal];

            break;
        case kKomaochiIndexNimaiochi:
            // Pieces of counter side
            self.square11.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square21.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square31.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square41.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square51.locatedPiece = [[KFGyoku alloc] initWithSide:COUNTER_SIDE];
            self.square61.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square71.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square81.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square91.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            //self.square22.locatedPiece = [[KFKaku alloc] initWithSide:COUNTER_SIDE];
            //self.square82.locatedPiece = [[KFHisha alloc] initWithSide:COUNTER_SIDE];
            
            // Images of counter side
            [self.square11 setImage:[UIImage imageNamed:[self.square11.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square21 setImage:[UIImage imageNamed:[self.square21.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square31 setImage:[UIImage imageNamed:[self.square31.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square41 setImage:[UIImage imageNamed:[self.square41.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square51 setImage:[UIImage imageNamed:[self.square51.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square61 setImage:[UIImage imageNamed:[self.square61.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square71 setImage:[UIImage imageNamed:[self.square71.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square81 setImage:[UIImage imageNamed:[self.square81.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square91 setImage:[UIImage imageNamed:[self.square91.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square22 setImage:[UIImage imageNamed:[self.square22.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square82 setImage:[UIImage imageNamed:[self.square82.locatedPiece getImageName]] forState:UIControlStateNormal];
            
            // Pieces of blank square
            self.square22.locatedPiece = nil;
            self.square82.locatedPiece = nil;
            
            // Images of blank square
            [self.square22 setImage:nil forState:UIControlStateNormal];
            [self.square82 setImage:nil forState:UIControlStateNormal];
            
            break;
        case kKomaochiIndexYonmaiochi:
            // Pieces of counter side
            //self.square11.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            self.square21.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square31.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square41.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square51.locatedPiece = [[KFGyoku alloc] initWithSide:COUNTER_SIDE];
            self.square61.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square71.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square81.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            //self.square91.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            //self.square22.locatedPiece = [[KFKaku alloc] initWithSide:COUNTER_SIDE];
            //self.square82.locatedPiece = [[KFHisha alloc] initWithSide:COUNTER_SIDE];
            
            // Images of counter side
            //[self.square11 setImage:[UIImage imageNamed:[self.square11.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square21 setImage:[UIImage imageNamed:[self.square21.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square31 setImage:[UIImage imageNamed:[self.square31.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square41 setImage:[UIImage imageNamed:[self.square41.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square51 setImage:[UIImage imageNamed:[self.square51.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square61 setImage:[UIImage imageNamed:[self.square61.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square71 setImage:[UIImage imageNamed:[self.square71.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square81 setImage:[UIImage imageNamed:[self.square81.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square91 setImage:[UIImage imageNamed:[self.square91.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square22 setImage:[UIImage imageNamed:[self.square22.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square82 setImage:[UIImage imageNamed:[self.square82.locatedPiece getImageName]] forState:UIControlStateNormal];
            
            // Pieces of blank square
            self.square11.locatedPiece = nil;
            self.square91.locatedPiece = nil;
            self.square22.locatedPiece = nil;
            self.square82.locatedPiece = nil;
            
            // Images of blank square
            [self.square11 setImage:nil forState:UIControlStateNormal];
            [self.square91 setImage:nil forState:UIControlStateNormal];
            [self.square22 setImage:nil forState:UIControlStateNormal];
            [self.square82 setImage:nil forState:UIControlStateNormal];
            
            break;
        case kKomaochiIndexRokumaiochi:
            // Pieces of counter side
            //self.square11.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            //self.square21.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            self.square31.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square41.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square51.locatedPiece = [[KFGyoku alloc] initWithSide:COUNTER_SIDE];
            self.square61.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square71.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            //self.square81.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            //self.square91.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            //self.square22.locatedPiece = [[KFKaku alloc] initWithSide:COUNTER_SIDE];
            //self.square82.locatedPiece = [[KFHisha alloc] initWithSide:COUNTER_SIDE];
            
            // Images of counter side
            //[self.square11 setImage:[UIImage imageNamed:[self.square11.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square21 setImage:[UIImage imageNamed:[self.square21.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square31 setImage:[UIImage imageNamed:[self.square31.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square41 setImage:[UIImage imageNamed:[self.square41.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square51 setImage:[UIImage imageNamed:[self.square51.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square61 setImage:[UIImage imageNamed:[self.square61.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square71 setImage:[UIImage imageNamed:[self.square71.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square81 setImage:[UIImage imageNamed:[self.square81.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square91 setImage:[UIImage imageNamed:[self.square91.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square22 setImage:[UIImage imageNamed:[self.square22.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square82 setImage:[UIImage imageNamed:[self.square82.locatedPiece getImageName]] forState:UIControlStateNormal];
            
            // Pieces of blank square
            self.square11.locatedPiece = nil;
            self.square21.locatedPiece = nil;
            self.square81.locatedPiece = nil;
            self.square91.locatedPiece = nil;
            self.square22.locatedPiece = nil;
            self.square82.locatedPiece = nil;
            
            // Images of blank square
            [self.square11 setImage:nil forState:UIControlStateNormal];
            [self.square21 setImage:nil forState:UIControlStateNormal];
            [self.square81 setImage:nil forState:UIControlStateNormal];
            [self.square91 setImage:nil forState:UIControlStateNormal];
            [self.square22 setImage:nil forState:UIControlStateNormal];
            [self.square82 setImage:nil forState:UIControlStateNormal];
            
            break;
        case kKomaochiIndexHachimaiochi:
            // Pieces of counter side
            //self.square11.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            //self.square21.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            //self.square31.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            self.square41.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            self.square51.locatedPiece = [[KFGyoku alloc] initWithSide:COUNTER_SIDE];
            self.square61.locatedPiece = [[KFKin alloc] initWithSide:COUNTER_SIDE];
            //self.square71.locatedPiece = [[KFGin alloc] initWithSide:COUNTER_SIDE];
            //self.square81.locatedPiece = [[KFKeima alloc] initWithSide:COUNTER_SIDE];
            //self.square91.locatedPiece = [[KFKyosha alloc] initWithSide:COUNTER_SIDE];
            //self.square22.locatedPiece = [[KFKaku alloc] initWithSide:COUNTER_SIDE];
            //self.square82.locatedPiece = [[KFHisha alloc] initWithSide:COUNTER_SIDE];
            
            // Images of counter side
            //[self.square11 setImage:[UIImage imageNamed:[self.square11.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square21 setImage:[UIImage imageNamed:[self.square21.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square31 setImage:[UIImage imageNamed:[self.square31.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square41 setImage:[UIImage imageNamed:[self.square41.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square51 setImage:[UIImage imageNamed:[self.square51.locatedPiece getImageName]] forState:UIControlStateNormal];
            [self.square61 setImage:[UIImage imageNamed:[self.square61.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square71 setImage:[UIImage imageNamed:[self.square71.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square81 setImage:[UIImage imageNamed:[self.square81.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square91 setImage:[UIImage imageNamed:[self.square91.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square22 setImage:[UIImage imageNamed:[self.square22.locatedPiece getImageName]] forState:UIControlStateNormal];
            //[self.square82 setImage:[UIImage imageNamed:[self.square82.locatedPiece getImageName]] forState:UIControlStateNormal];
            
            // Pieces of blank square
            self.square11.locatedPiece = nil;
            self.square21.locatedPiece = nil;
            self.square31.locatedPiece = nil;
            self.square71.locatedPiece = nil;
            self.square81.locatedPiece = nil;
            self.square91.locatedPiece = nil;
            self.square22.locatedPiece = nil;
            self.square82.locatedPiece = nil;
            
            // Images of blank square
            [self.square11 setImage:nil forState:UIControlStateNormal];
            [self.square21 setImage:nil forState:UIControlStateNormal];
            [self.square31 setImage:nil forState:UIControlStateNormal];
            [self.square71 setImage:nil forState:UIControlStateNormal];
            [self.square81 setImage:nil forState:UIControlStateNormal];
            [self.square91 setImage:nil forState:UIControlStateNormal];
            [self.square22 setImage:nil forState:UIControlStateNormal];
            [self.square82 setImage:nil forState:UIControlStateNormal];
            
            break;
            
        default:
            break;
    }
    
}

- (void)setCoordinate {
    [self.square11 setCoordinateX:1 Y:1];
    [self.square21 setCoordinateX:2 Y:1];
    [self.square31 setCoordinateX:3 Y:1];
    [self.square41 setCoordinateX:4 Y:1];
    [self.square51 setCoordinateX:5 Y:1];
    [self.square61 setCoordinateX:6 Y:1];
    [self.square71 setCoordinateX:7 Y:1];
    [self.square81 setCoordinateX:8 Y:1];
    [self.square91 setCoordinateX:9 Y:1];
    [self.square12 setCoordinateX:1 Y:2];
    [self.square22 setCoordinateX:2 Y:2];
    [self.square32 setCoordinateX:3 Y:2];
    [self.square42 setCoordinateX:4 Y:2];
    [self.square52 setCoordinateX:5 Y:2];
    [self.square62 setCoordinateX:6 Y:2];
    [self.square72 setCoordinateX:7 Y:2];
    [self.square82 setCoordinateX:8 Y:2];
    [self.square92 setCoordinateX:9 Y:2];
    [self.square13 setCoordinateX:1 Y:3];
    [self.square23 setCoordinateX:2 Y:3];
    [self.square33 setCoordinateX:3 Y:3];
    [self.square43 setCoordinateX:4 Y:3];
    [self.square53 setCoordinateX:5 Y:3];
    [self.square63 setCoordinateX:6 Y:3];
    [self.square73 setCoordinateX:7 Y:3];
    [self.square83 setCoordinateX:8 Y:3];
    [self.square93 setCoordinateX:9 Y:3];
    [self.square14 setCoordinateX:1 Y:4];
    [self.square24 setCoordinateX:2 Y:4];
    [self.square34 setCoordinateX:3 Y:4];
    [self.square44 setCoordinateX:4 Y:4];
    [self.square54 setCoordinateX:5 Y:4];
    [self.square64 setCoordinateX:6 Y:4];
    [self.square74 setCoordinateX:7 Y:4];
    [self.square84 setCoordinateX:8 Y:4];
    [self.square94 setCoordinateX:9 Y:4];
    [self.square15 setCoordinateX:1 Y:5];
    [self.square25 setCoordinateX:2 Y:5];
    [self.square35 setCoordinateX:3 Y:5];
    [self.square45 setCoordinateX:4 Y:5];
    [self.square55 setCoordinateX:5 Y:5];
    [self.square65 setCoordinateX:6 Y:5];
    [self.square75 setCoordinateX:7 Y:5];
    [self.square85 setCoordinateX:8 Y:5];
    [self.square95 setCoordinateX:9 Y:5];
    [self.square16 setCoordinateX:1 Y:6];
    [self.square26 setCoordinateX:2 Y:6];
    [self.square36 setCoordinateX:3 Y:6];
    [self.square46 setCoordinateX:4 Y:6];
    [self.square56 setCoordinateX:5 Y:6];
    [self.square66 setCoordinateX:6 Y:6];
    [self.square76 setCoordinateX:7 Y:6];
    [self.square86 setCoordinateX:8 Y:6];
    [self.square96 setCoordinateX:9 Y:6];
    [self.square17 setCoordinateX:1 Y:7];
    [self.square27 setCoordinateX:2 Y:7];
    [self.square37 setCoordinateX:3 Y:7];
    [self.square47 setCoordinateX:4 Y:7];
    [self.square57 setCoordinateX:5 Y:7];
    [self.square67 setCoordinateX:6 Y:7];
    [self.square77 setCoordinateX:7 Y:7];
    [self.square87 setCoordinateX:8 Y:7];
    [self.square97 setCoordinateX:9 Y:7];
    [self.square18 setCoordinateX:1 Y:8];
    [self.square28 setCoordinateX:2 Y:8];
    [self.square38 setCoordinateX:3 Y:8];
    [self.square48 setCoordinateX:4 Y:8];
    [self.square58 setCoordinateX:5 Y:8];
    [self.square68 setCoordinateX:6 Y:8];
    [self.square78 setCoordinateX:7 Y:8];
    [self.square88 setCoordinateX:8 Y:8];
    [self.square98 setCoordinateX:9 Y:8];
    [self.square19 setCoordinateX:1 Y:9];
    [self.square29 setCoordinateX:2 Y:9];
    [self.square39 setCoordinateX:3 Y:9];
    [self.square49 setCoordinateX:4 Y:9];
    [self.square59 setCoordinateX:5 Y:9];
    [self.square69 setCoordinateX:6 Y:9];
    [self.square79 setCoordinateX:7 Y:9];
    [self.square89 setCoordinateX:8 Y:9];
    [self.square99 setCoordinateX:9 Y:9];
}

- (void)clearSquareColor {
    [self.square11 setBackgroundColor:[UIColor clearColor]];
    [self.square21 setBackgroundColor:[UIColor clearColor]];
    [self.square31 setBackgroundColor:[UIColor clearColor]];
    [self.square41 setBackgroundColor:[UIColor clearColor]];
    [self.square51 setBackgroundColor:[UIColor clearColor]];
    [self.square61 setBackgroundColor:[UIColor clearColor]];
    [self.square71 setBackgroundColor:[UIColor clearColor]];
    [self.square81 setBackgroundColor:[UIColor clearColor]];
    [self.square91 setBackgroundColor:[UIColor clearColor]];
    [self.square12 setBackgroundColor:[UIColor clearColor]];
    [self.square22 setBackgroundColor:[UIColor clearColor]];
    [self.square32 setBackgroundColor:[UIColor clearColor]];
    [self.square42 setBackgroundColor:[UIColor clearColor]];
    [self.square52 setBackgroundColor:[UIColor clearColor]];
    [self.square62 setBackgroundColor:[UIColor clearColor]];
    [self.square72 setBackgroundColor:[UIColor clearColor]];
    [self.square82 setBackgroundColor:[UIColor clearColor]];
    [self.square92 setBackgroundColor:[UIColor clearColor]];
    [self.square13 setBackgroundColor:[UIColor clearColor]];
    [self.square23 setBackgroundColor:[UIColor clearColor]];
    [self.square33 setBackgroundColor:[UIColor clearColor]];
    [self.square43 setBackgroundColor:[UIColor clearColor]];
    [self.square53 setBackgroundColor:[UIColor clearColor]];
    [self.square63 setBackgroundColor:[UIColor clearColor]];
    [self.square73 setBackgroundColor:[UIColor clearColor]];
    [self.square83 setBackgroundColor:[UIColor clearColor]];
    [self.square93 setBackgroundColor:[UIColor clearColor]];
    [self.square14 setBackgroundColor:[UIColor clearColor]];
    [self.square24 setBackgroundColor:[UIColor clearColor]];
    [self.square34 setBackgroundColor:[UIColor clearColor]];
    [self.square44 setBackgroundColor:[UIColor clearColor]];
    [self.square54 setBackgroundColor:[UIColor clearColor]];
    [self.square64 setBackgroundColor:[UIColor clearColor]];
    [self.square74 setBackgroundColor:[UIColor clearColor]];
    [self.square84 setBackgroundColor:[UIColor clearColor]];
    [self.square94 setBackgroundColor:[UIColor clearColor]];
    [self.square15 setBackgroundColor:[UIColor clearColor]];
    [self.square25 setBackgroundColor:[UIColor clearColor]];
    [self.square35 setBackgroundColor:[UIColor clearColor]];
    [self.square45 setBackgroundColor:[UIColor clearColor]];
    [self.square55 setBackgroundColor:[UIColor clearColor]];
    [self.square65 setBackgroundColor:[UIColor clearColor]];
    [self.square75 setBackgroundColor:[UIColor clearColor]];
    [self.square85 setBackgroundColor:[UIColor clearColor]];
    [self.square95 setBackgroundColor:[UIColor clearColor]];
    [self.square16 setBackgroundColor:[UIColor clearColor]];
    [self.square26 setBackgroundColor:[UIColor clearColor]];
    [self.square36 setBackgroundColor:[UIColor clearColor]];
    [self.square46 setBackgroundColor:[UIColor clearColor]];
    [self.square56 setBackgroundColor:[UIColor clearColor]];
    [self.square66 setBackgroundColor:[UIColor clearColor]];
    [self.square76 setBackgroundColor:[UIColor clearColor]];
    [self.square86 setBackgroundColor:[UIColor clearColor]];
    [self.square96 setBackgroundColor:[UIColor clearColor]];
    [self.square17 setBackgroundColor:[UIColor clearColor]];
    [self.square27 setBackgroundColor:[UIColor clearColor]];
    [self.square37 setBackgroundColor:[UIColor clearColor]];
    [self.square47 setBackgroundColor:[UIColor clearColor]];
    [self.square57 setBackgroundColor:[UIColor clearColor]];
    [self.square67 setBackgroundColor:[UIColor clearColor]];
    [self.square77 setBackgroundColor:[UIColor clearColor]];
    [self.square87 setBackgroundColor:[UIColor clearColor]];
    [self.square97 setBackgroundColor:[UIColor clearColor]];
    [self.square18 setBackgroundColor:[UIColor clearColor]];
    [self.square28 setBackgroundColor:[UIColor clearColor]];
    [self.square38 setBackgroundColor:[UIColor clearColor]];
    [self.square48 setBackgroundColor:[UIColor clearColor]];
    [self.square58 setBackgroundColor:[UIColor clearColor]];
    [self.square68 setBackgroundColor:[UIColor clearColor]];
    [self.square78 setBackgroundColor:[UIColor clearColor]];
    [self.square88 setBackgroundColor:[UIColor clearColor]];
    [self.square98 setBackgroundColor:[UIColor clearColor]];
    [self.square19 setBackgroundColor:[UIColor clearColor]];
    [self.square29 setBackgroundColor:[UIColor clearColor]];
    [self.square39 setBackgroundColor:[UIColor clearColor]];
    [self.square49 setBackgroundColor:[UIColor clearColor]];
    [self.square59 setBackgroundColor:[UIColor clearColor]];
    [self.square69 setBackgroundColor:[UIColor clearColor]];
    [self.square79 setBackgroundColor:[UIColor clearColor]];
    [self.square89 setBackgroundColor:[UIColor clearColor]];
    [self.square99 setBackgroundColor:[UIColor clearColor]];
}

- (void)setSquareDic {
    self.squareDic = [NSMutableDictionary dictionary];
    
    [self.squareDic setObject:self.square11 forKey:@"11"];
    [self.squareDic setObject:self.square21 forKey:@"21"];
    [self.squareDic setObject:self.square31 forKey:@"31"];
    [self.squareDic setObject:self.square41 forKey:@"41"];
    [self.squareDic setObject:self.square51 forKey:@"51"];
    [self.squareDic setObject:self.square61 forKey:@"61"];
    [self.squareDic setObject:self.square71 forKey:@"71"];
    [self.squareDic setObject:self.square81 forKey:@"81"];
    [self.squareDic setObject:self.square91 forKey:@"91"];
    [self.squareDic setObject:self.square12 forKey:@"12"];
    [self.squareDic setObject:self.square22 forKey:@"22"];
    [self.squareDic setObject:self.square32 forKey:@"32"];
    [self.squareDic setObject:self.square42 forKey:@"42"];
    [self.squareDic setObject:self.square52 forKey:@"52"];
    [self.squareDic setObject:self.square62 forKey:@"62"];
    [self.squareDic setObject:self.square72 forKey:@"72"];
    [self.squareDic setObject:self.square82 forKey:@"82"];
    [self.squareDic setObject:self.square92 forKey:@"92"];
    [self.squareDic setObject:self.square13 forKey:@"13"];
    [self.squareDic setObject:self.square23 forKey:@"23"];
    [self.squareDic setObject:self.square33 forKey:@"33"];
    [self.squareDic setObject:self.square43 forKey:@"43"];
    [self.squareDic setObject:self.square53 forKey:@"53"];
    [self.squareDic setObject:self.square63 forKey:@"63"];
    [self.squareDic setObject:self.square73 forKey:@"73"];
    [self.squareDic setObject:self.square83 forKey:@"83"];
    [self.squareDic setObject:self.square93 forKey:@"93"];
    [self.squareDic setObject:self.square14 forKey:@"14"];
    [self.squareDic setObject:self.square24 forKey:@"24"];
    [self.squareDic setObject:self.square34 forKey:@"34"];
    [self.squareDic setObject:self.square44 forKey:@"44"];
    [self.squareDic setObject:self.square54 forKey:@"54"];
    [self.squareDic setObject:self.square64 forKey:@"64"];
    [self.squareDic setObject:self.square74 forKey:@"74"];
    [self.squareDic setObject:self.square84 forKey:@"84"];
    [self.squareDic setObject:self.square94 forKey:@"94"];
    [self.squareDic setObject:self.square15 forKey:@"15"];
    [self.squareDic setObject:self.square25 forKey:@"25"];
    [self.squareDic setObject:self.square35 forKey:@"35"];
    [self.squareDic setObject:self.square45 forKey:@"45"];
    [self.squareDic setObject:self.square55 forKey:@"55"];
    [self.squareDic setObject:self.square65 forKey:@"65"];
    [self.squareDic setObject:self.square75 forKey:@"75"];
    [self.squareDic setObject:self.square85 forKey:@"85"];
    [self.squareDic setObject:self.square95 forKey:@"95"];
    [self.squareDic setObject:self.square16 forKey:@"16"];
    [self.squareDic setObject:self.square26 forKey:@"26"];
    [self.squareDic setObject:self.square36 forKey:@"36"];
    [self.squareDic setObject:self.square46 forKey:@"46"];
    [self.squareDic setObject:self.square56 forKey:@"56"];
    [self.squareDic setObject:self.square66 forKey:@"66"];
    [self.squareDic setObject:self.square76 forKey:@"76"];
    [self.squareDic setObject:self.square86 forKey:@"86"];
    [self.squareDic setObject:self.square96 forKey:@"96"];
    [self.squareDic setObject:self.square17 forKey:@"17"];
    [self.squareDic setObject:self.square27 forKey:@"27"];
    [self.squareDic setObject:self.square37 forKey:@"37"];
    [self.squareDic setObject:self.square47 forKey:@"47"];
    [self.squareDic setObject:self.square57 forKey:@"57"];
    [self.squareDic setObject:self.square67 forKey:@"67"];
    [self.squareDic setObject:self.square77 forKey:@"77"];
    [self.squareDic setObject:self.square87 forKey:@"87"];
    [self.squareDic setObject:self.square97 forKey:@"97"];
    [self.squareDic setObject:self.square18 forKey:@"18"];
    [self.squareDic setObject:self.square28 forKey:@"28"];
    [self.squareDic setObject:self.square38 forKey:@"38"];
    [self.squareDic setObject:self.square48 forKey:@"48"];
    [self.squareDic setObject:self.square58 forKey:@"58"];
    [self.squareDic setObject:self.square68 forKey:@"68"];
    [self.squareDic setObject:self.square78 forKey:@"78"];
    [self.squareDic setObject:self.square88 forKey:@"88"];
    [self.squareDic setObject:self.square98 forKey:@"98"];
    [self.squareDic setObject:self.square19 forKey:@"19"];
    [self.squareDic setObject:self.square29 forKey:@"29"];
    [self.squareDic setObject:self.square39 forKey:@"39"];
    [self.squareDic setObject:self.square49 forKey:@"49"];
    [self.squareDic setObject:self.square59 forKey:@"59"];
    [self.squareDic setObject:self.square69 forKey:@"69"];
    [self.squareDic setObject:self.square79 forKey:@"79"];
    [self.squareDic setObject:self.square89 forKey:@"89"];
    [self.squareDic setObject:self.square99 forKey:@"99"];
}

@end
