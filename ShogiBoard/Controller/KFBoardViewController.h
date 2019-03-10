//
//  KFBoardViewController.h
//  ShogiBoard
//
//  Created by Maeda Kazuya on 2013/12/01.
//  Copyright (c) 2013年 Kifoo, Inc. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>
#import <UIKit/UIKit.h>
#import "GAITrackedViewController.h"

@class KFCommentViewController;
@class KFLoadRecordViewController;
@class KFMatchTableViewController;
@class KFMoveTableViewController;
@class KFPiece;
@class KFRecord;
@class KFRecordTableViewController;
@class KFSaveCommentViewController;
@class KFSaveRecordViewController;
@class KFSearchRecordViewController;
@class KFSettingViewController;
@class KFTitleTableViewController;
@class KFSquareButton;
@class GADBannerView;
@class NADView;

#define PIECE_WIDTH_NORMAL      32
#define PIECE_HEIGHT_NORMAL     35
#define PIECE_WIDTH_WIDE        70
#define PIECE_HEIGHT_WIDE       80

// Komaochi index
enum {
    kKomaochiIndexHirate,
    kKomaochiIndexKyoochi,
    kKomaochiIndexKakuochi,
    kKomaochiIndexHishaochi,
    kKomaochiIndexHikyoochi,
    kKomaochiIndexNimaiochi,
    kKomaochiIndexYonmaiochi,
    kKomaochiIndexRokumaiochi,
    kKomaochiIndexHachimaiochi
};

// Alert tag
enum {
    kMenuAlertTag = 0,
    kPromotionAlertTag,
    kRecordAlertTag,
    kSNSAlertTag,
    kOtherAlertTag,
    kLoadOptionAlertTag,
    kManageRecordAlertTag,
    kSearchOptionAlertTag,
    kGetRecordOptionAlertTag,
    kKomaochiAlertTag
};

// Menu index number of play mode
enum {
    kPlayMenuIndexCancel = 0,
    kPlayMenuIndexInitBoard,
    kPlayMenuIndexManageRecord,
    kPlayMenuIndexOpenSetting,
    kPlayMenuIndexCloseBoard
};

// Menu index number of read mode
enum {
    kReadMenuIndexCancel = 0,
    kReadMenuIndexInitBoard,
    kReadMenuIndexManageRecord,
    kReadMenuIndexOpenSetting
};

// Menu index number of managing record
enum {
    kManageRecordMenuIndexCancel = 0,
    kManageRecordMenuIndexReadRecord,
    kManageRecordMenuIndexSaveRecord,
    kManageRecordMenuIndexShareRecord,
    kManageRecordMenuIndexGetRecord,
    kManageRecordMenuIndexShareImage,
    kManageRecordMenuIndexEditBoard,
};

// Menu index number of load option
enum {
    kLoadMenuIndexCancel = 0,
    kLoadMenuIndexSearchRecord,
    kLoadMenuIndexMatchList,
    kLoadMenuIndexTitleList
};

// Menu index number of selecting searching way
enum {
    kSearchRecordMenuIndexCancel = 0,
    kSearchRecordMenuIndexCondition,
    kSearchRecordMenuIndexPosition,
    kSearchRecordMenuIndexPrevious
};

// Menu index number of getting record option
enum {
    kGetRecordMenuIndexCancel = 0,
    kGetRecordMenuIndexClipBoard,
    kGetRecordMenuIndexUrl
};

//SystemSoundID dropSound;

@interface KFBoardViewController : GAITrackedViewController <UIPopoverControllerDelegate, UIAlertViewDelegate>

@property (strong, nonatomic) KFSquareButton *selectedSquare;
@property (strong, nonatomic) KFSquareButton *targetSquare;
@property (strong, nonatomic) KFSquareButton *previousSquare;
@property (strong, nonatomic) KFPiece *selectedPiece;
@property (strong, nonatomic) KFRecord *currentRecord;

@property (strong, nonatomic) NSMutableDictionary *squareDic;
@property (strong, nonatomic) NSMutableDictionary *thisSideCapturedPieces;
@property (strong, nonatomic) NSMutableDictionary *counterSideCapturedPieces;
@property (strong, nonatomic) NSMutableDictionary *thisSideCapturedPieceButtons;
@property (strong, nonatomic) NSMutableDictionary *counterSideCapturedPieceButtons;
@property (strong, nonatomic) NSMutableArray *moveArray;

@property (strong, nonatomic) KFSaveRecordViewController *saveRecordViewController;
@property (strong, nonatomic) KFRecordTableViewController *recordTableViewController;
@property (strong, nonatomic) KFMatchTableViewController *latestMatchTableViewController;
@property (strong, nonatomic) KFMatchTableViewController *positionMatchTableViewController;
@property (strong, nonatomic) KFMatchTableViewController *previousMatchTableViewController;
@property (strong, nonatomic) KFTitleTableViewController *TitleTableViewController;
@property (strong, nonatomic) KFLoadRecordViewController *loadRecordViewController;
@property (strong, nonatomic) KFSaveCommentViewController *saveCommentViewController;
@property (strong, nonatomic) KFCommentViewController *commentViewController;
@property (strong, nonatomic) KFSettingViewController *settingViewController;
@property (strong, nonatomic) KFSearchRecordViewController *searchRecordViewController;
@property (strong, nonatomic) KFMoveTableViewController *moveTableViewController;
@property (strong, nonatomic) UIPopoverController *recordTablePopoverController;
@property (strong, nonatomic) UIPopoverController *latestMatchTablePopoverController;
@property (strong, nonatomic) UIPopoverController *positionMatchTablePopoverController;
@property (strong, nonatomic) UIPopoverController *previousMatchTablePopoverController;
@property (strong, nonatomic) UIPopoverController *TitleTablePopoverController;
@property (strong, nonatomic) UIPopoverController *loadRecordPopoverController;
@property (strong, nonatomic) UIPopoverController *saveCommentPopoverController;
@property (strong, nonatomic) UIPopoverController *saveRecordPopoverController;
@property (strong, nonatomic) UIPopoverController *searchRecordPopoverController;
@property (strong, nonatomic) UIPopoverController *settingPopoverController;
@property (strong, nonatomic) UIPopoverController *commentPopoverController;
@property (strong, nonatomic) UIPopoverController *moveTablePopoverController;

@property NSInteger mode;
@property NSInteger currentMoveIndex;
@property NSInteger currentSide;
@property NSInteger komaochiIndex;

@property BOOL isLocatedPieceSelected;
@property BOOL isCapturedPieceSelected;
@property BOOL isMotionFree;
@property BOOL isSoundAvailable;
@property BOOL shouldClearSelectedPiece;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIToolbar *recordToolBar;
@property (weak, nonatomic) IBOutlet UINavigationItem *boardNavigationItem;

@property (weak, nonatomic) IBOutlet UIView *boardView;
@property (weak, nonatomic) IBOutlet UIView *thisSideStandView;
@property (weak, nonatomic) IBOutlet UIView *counterSideStandView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *recordTitleButtonItem;
@property (weak, nonatomic) IBOutlet UIButton *sideRewindButton;
@property (weak, nonatomic) IBOutlet UIButton *sideForwardButton;
@property (weak, nonatomic) IBOutlet UIButton *commentButton;
@property (weak, nonatomic) IBOutlet UILabel *thisSidePlayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *counterSidePlayerLabel;
@property (weak, nonatomic) IBOutlet UILabel *matchTitleLabel;

@property (weak, nonatomic) IBOutlet GADBannerView *admobTopBannerView;
@property (weak, nonatomic) IBOutlet GADBannerView *admobBottomBannerView;

- (void)readRecord:(KFRecord *)record;
- (void)transferToMoveIndex:(NSInteger)targetMoveIndex;

- (IBAction)waitButtonTapped:(id)sender;
- (IBAction)menuButtonTapped:(id)sender;
- (IBAction)topRewindButtonTapped:(id)sender;
- (IBAction)topForwardButtonTapped:(id)sender;
- (IBAction)rewindButtonTapped:(id)sender;
- (IBAction)forwardButtonTapped:(id)sender;
- (IBAction)recordTitleButtonTapped:(id)sender;
- (IBAction)recordMenuButtonTapped:(id)sender;
- (IBAction)showComment:(id)sender;
- (IBAction)closeButtonTapped:(id)sender;

@property (weak, nonatomic) IBOutlet KFSquareButton *square11;
@property (weak, nonatomic) IBOutlet KFSquareButton *square12;
@property (weak, nonatomic) IBOutlet KFSquareButton *square13;
@property (weak, nonatomic) IBOutlet KFSquareButton *square14;
@property (weak, nonatomic) IBOutlet KFSquareButton *square15;
@property (weak, nonatomic) IBOutlet KFSquareButton *square16;
@property (weak, nonatomic) IBOutlet KFSquareButton *square17;
@property (weak, nonatomic) IBOutlet KFSquareButton *square18;
@property (weak, nonatomic) IBOutlet KFSquareButton *square19;
@property (weak, nonatomic) IBOutlet KFSquareButton *square21;
@property (weak, nonatomic) IBOutlet KFSquareButton *square22;
@property (weak, nonatomic) IBOutlet KFSquareButton *square23;
@property (weak, nonatomic) IBOutlet KFSquareButton *square24;
@property (weak, nonatomic) IBOutlet KFSquareButton *square25;
@property (weak, nonatomic) IBOutlet KFSquareButton *square26;
@property (weak, nonatomic) IBOutlet KFSquareButton *square27;
@property (weak, nonatomic) IBOutlet KFSquareButton *square28;
@property (weak, nonatomic) IBOutlet KFSquareButton *square29;
@property (weak, nonatomic) IBOutlet KFSquareButton *square31;
@property (weak, nonatomic) IBOutlet KFSquareButton *square32;
@property (weak, nonatomic) IBOutlet KFSquareButton *square33;
@property (weak, nonatomic) IBOutlet KFSquareButton *square34;
@property (weak, nonatomic) IBOutlet KFSquareButton *square35;
@property (weak, nonatomic) IBOutlet KFSquareButton *square36;
@property (weak, nonatomic) IBOutlet KFSquareButton *square37;
@property (weak, nonatomic) IBOutlet KFSquareButton *square38;
@property (weak, nonatomic) IBOutlet KFSquareButton *square39;
@property (weak, nonatomic) IBOutlet KFSquareButton *square41;
@property (weak, nonatomic) IBOutlet KFSquareButton *square42;
@property (weak, nonatomic) IBOutlet KFSquareButton *square43;
@property (weak, nonatomic) IBOutlet KFSquareButton *square44;
@property (weak, nonatomic) IBOutlet KFSquareButton *square45;
@property (weak, nonatomic) IBOutlet KFSquareButton *square46;
@property (weak, nonatomic) IBOutlet KFSquareButton *square47;
@property (weak, nonatomic) IBOutlet KFSquareButton *square48;
@property (weak, nonatomic) IBOutlet KFSquareButton *square49;
@property (weak, nonatomic) IBOutlet KFSquareButton *square51;
@property (weak, nonatomic) IBOutlet KFSquareButton *square52;
@property (weak, nonatomic) IBOutlet KFSquareButton *square53;
@property (weak, nonatomic) IBOutlet KFSquareButton *square54;
@property (weak, nonatomic) IBOutlet KFSquareButton *square55;
@property (weak, nonatomic) IBOutlet KFSquareButton *square56;
@property (weak, nonatomic) IBOutlet KFSquareButton *square57;
@property (weak, nonatomic) IBOutlet KFSquareButton *square58;
@property (weak, nonatomic) IBOutlet KFSquareButton *square59;
@property (weak, nonatomic) IBOutlet KFSquareButton *square61;
@property (weak, nonatomic) IBOutlet KFSquareButton *square62;
@property (weak, nonatomic) IBOutlet KFSquareButton *square63;
@property (weak, nonatomic) IBOutlet KFSquareButton *square64;
@property (weak, nonatomic) IBOutlet KFSquareButton *square65;
@property (weak, nonatomic) IBOutlet KFSquareButton *square66;
@property (weak, nonatomic) IBOutlet KFSquareButton *square67;
@property (weak, nonatomic) IBOutlet KFSquareButton *square68;
@property (weak, nonatomic) IBOutlet KFSquareButton *square69;
@property (weak, nonatomic) IBOutlet KFSquareButton *square71;
@property (weak, nonatomic) IBOutlet KFSquareButton *square72;
@property (weak, nonatomic) IBOutlet KFSquareButton *square73;
@property (weak, nonatomic) IBOutlet KFSquareButton *square74;
@property (weak, nonatomic) IBOutlet KFSquareButton *square75;
@property (weak, nonatomic) IBOutlet KFSquareButton *square76;
@property (weak, nonatomic) IBOutlet KFSquareButton *square77;
@property (weak, nonatomic) IBOutlet KFSquareButton *square78;
@property (weak, nonatomic) IBOutlet KFSquareButton *square79;
@property (weak, nonatomic) IBOutlet KFSquareButton *square81;
@property (weak, nonatomic) IBOutlet KFSquareButton *square82;
@property (weak, nonatomic) IBOutlet KFSquareButton *square83;
@property (weak, nonatomic) IBOutlet KFSquareButton *square84;
@property (weak, nonatomic) IBOutlet KFSquareButton *square85;
@property (weak, nonatomic) IBOutlet KFSquareButton *square86;
@property (weak, nonatomic) IBOutlet KFSquareButton *square87;
@property (weak, nonatomic) IBOutlet KFSquareButton *square88;
@property (weak, nonatomic) IBOutlet KFSquareButton *square89;
@property (weak, nonatomic) IBOutlet KFSquareButton *square91;
@property (weak, nonatomic) IBOutlet KFSquareButton *square92;
@property (weak, nonatomic) IBOutlet KFSquareButton *square93;
@property (weak, nonatomic) IBOutlet KFSquareButton *square94;
@property (weak, nonatomic) IBOutlet KFSquareButton *square95;
@property (weak, nonatomic) IBOutlet KFSquareButton *square96;
@property (weak, nonatomic) IBOutlet KFSquareButton *square97;
@property (weak, nonatomic) IBOutlet KFSquareButton *square98;
@property (weak, nonatomic) IBOutlet KFSquareButton *square99;

- (IBAction)square11tapped:(id)sender;
- (IBAction)square12tapped:(id)sender;
- (IBAction)square13tapped:(id)sender;
- (IBAction)square14tapped:(id)sender;
- (IBAction)square15tapped:(id)sender;
- (IBAction)square16tapped:(id)sender;
- (IBAction)square17tapped:(id)sender;
- (IBAction)square18tapped:(id)sender;
- (IBAction)square19tapped:(id)sender;
- (IBAction)square21tapped:(id)sender;
- (IBAction)square22tapped:(id)sender;
- (IBAction)square23tapped:(id)sender;
- (IBAction)square24tapped:(id)sender;
- (IBAction)square25tapped:(id)sender;
- (IBAction)square26tapped:(id)sender;
- (IBAction)square27tapped:(id)sender;
- (IBAction)square28tapped:(id)sender;
- (IBAction)square29tapped:(id)sender;
- (IBAction)square31tapped:(id)sender;
- (IBAction)square32tapped:(id)sender;
- (IBAction)square33tapped:(id)sender;
- (IBAction)square34tapped:(id)sender;
- (IBAction)square35tapped:(id)sender;
- (IBAction)square36tapped:(id)sender;
- (IBAction)square37tapped:(id)sender;
- (IBAction)square38tapped:(id)sender;
- (IBAction)square39tapped:(id)sender;
- (IBAction)square41tapped:(id)sender;
- (IBAction)square42tapped:(id)sender;
- (IBAction)square43tapped:(id)sender;
- (IBAction)square44tapped:(id)sender;
- (IBAction)square45tapped:(id)sender;
- (IBAction)square46tapped:(id)sender;
- (IBAction)square47tapped:(id)sender;
- (IBAction)square48tapped:(id)sender;
- (IBAction)square49tapped:(id)sender;
- (IBAction)square51tapped:(id)sender;
- (IBAction)square52tapped:(id)sender;
- (IBAction)square53tapped:(id)sender;
- (IBAction)square54tapped:(id)sender;
- (IBAction)square55tapped:(id)sender;
- (IBAction)square56tapped:(id)sender;
- (IBAction)square57tapped:(id)sender;
- (IBAction)square58tapped:(id)sender;
- (IBAction)square59tapped:(id)sender;
- (IBAction)square61tapped:(id)sender;
- (IBAction)square62tapped:(id)sender;
- (IBAction)square63tapped:(id)sender;
- (IBAction)square64tapped:(id)sender;
- (IBAction)square65tapped:(id)sender;
- (IBAction)square66tapped:(id)sender;
- (IBAction)square67tapped:(id)sender;
- (IBAction)square68tapped:(id)sender;
- (IBAction)square69tapped:(id)sender;
- (IBAction)square71tapped:(id)sender;
- (IBAction)square72tapped:(id)sender;
- (IBAction)square73tapped:(id)sender;
- (IBAction)square74tapped:(id)sender;
- (IBAction)square75tapped:(id)sender;
- (IBAction)square76tapped:(id)sender;
- (IBAction)square77tapped:(id)sender;
- (IBAction)square78tapped:(id)sender;
- (IBAction)square79tapped:(id)sender;
- (IBAction)square81tapped:(id)sender;
- (IBAction)square82tapped:(id)sender;
- (IBAction)square83tapped:(id)sender;
- (IBAction)square84tapped:(id)sender;
- (IBAction)square85tapped:(id)sender;
- (IBAction)square86tapped:(id)sender;
- (IBAction)square87tapped:(id)sender;
- (IBAction)square88tapped:(id)sender;
- (IBAction)square89tapped:(id)sender;
- (IBAction)square91tapped:(id)sender;
- (IBAction)square92tapped:(id)sender;
- (IBAction)square93tapped:(id)sender;
- (IBAction)square94tapped:(id)sender;
- (IBAction)square95tapped:(id)sender;
- (IBAction)square96tapped:(id)sender;
- (IBAction)square97tapped:(id)sender;
- (IBAction)square98tapped:(id)sender;
- (IBAction)square99tapped:(id)sender;

@end
