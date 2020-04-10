//
//  GameController.h
//  Tetris
//
//  Created by Alejandro Mateos on 04/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file GameController.h
 * @Author Alejandro Mateos
 * @date 04/12/2019
 * @brief Fichero de cabecera para el controlador principal y gestor de la lógica del juego. Header file for the main controller and game logic manager.
 */

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "TetrisModel.h"
#import "TetrisFigure.h"
#import "constants.h"

NS_ASSUME_NONNULL_BEGIN

@class ETPanelWindowController;
@interface GameController : NSObject<NSWindowDelegate>{
    IBOutlet NSMenuItem *playButton, *stopButton, *resumeButton, *panelButton;
    
    TetrisModel *m;
    TetrisFigure *figure;
    int positions[4][2];
    
    ETPanelWindowController *panel;
    
    NSSound *player;
    NSSound *sound;
    
    int currentPoints, topPoints, pointsForMove, pointsForLine, pointsForBlock;
}

@property NSSound *player;
@property int topPoints, currentPoints;

//TetrisFigure
- (int)getFigureType;
- (int)getFigureRow;
- (int)getFigureColumn;
- (NSColor *)getFigureColor;
- (int)getColorIndex;
- (int)getFigureRotation;
- (int)getFigureRowDimension;
- (NSColor *)getColorWithColorIndex:(int)index;
- (NSMutableArray *)getGeneratedFigures;

- (void)setFigureType:(int)type;
- (void)setFigureRow:(int)row;
- (void)setFigureColumn:(int)column;
- (void)setFigureColor:(NSColor*)color;
- (void)setFigureRotation:(int)rotation;

//Controller
+ (id)sharedController;
- (void)createNewFigure;
- (void)moveDown;
- (void)moveLeft;
- (void)moveRight;
- (void)rotate;
- (BOOL)canRotate;
- (void)fillPositionsMatrixWithRow0:(int)row0 col0:(int)col0 row1:(int)row1 col1:(int)col1 row2:(int)row2 col2:(int)col2 row3:(int)row3 col3:(int)col3;
- (int)getCellValueWithRow:(int)row column:(int)column;
- (void)checkRowCompletion;
- (void)deleteRow:(int)row;
- (BOOL)checkGameOver;
- (void)givePoints;
- (void)setSpeed: (int)s;
- (void)setColor: (NSColor*)color withIndex:(int)index withName:(NSString*)colorName;
- (void)setType: (int)type;


//TetrisModel
- (int)getLogicBoardPositionWithRow:(int)row column:(int)column;
- (void)blockFigureInLogicBoardAtRow:(int)row column:(int)column withType:(int)type withColor:(int)colorIndex;
- (BOOL)checkDownFigures;
- (BOOL)checkRightFigures;
- (BOOL)checkLeftFigures;
- (void)initLogicBoard;

//Preferences Panel
- (IBAction)showPanel:(id)sender;

//Main actions
- (IBAction)playGame:(id)sender;
- (IBAction)stopGame:(id)sender;
- (IBAction)resumeGame:(id)sender;
- (IBAction)showHelp:(id)sender;

//Play Music
- (void)playMusicWithName:(NSString*)name extension:(NSString*)extension;
- (void)playSoundWithName:(NSString*)name extension:(NSString*)extension;

@end

NS_ASSUME_NONNULL_END
