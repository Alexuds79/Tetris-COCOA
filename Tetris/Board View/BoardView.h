//
//  BoardView.h
//  Tetris
//
//  Created by Alejandro Mateos on 03/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file BoardView.h
 * @Author Alejandro Mateos
 * @date 03/12/2019
 * @brief Fichero de cabecera para el controlador de la vista principal. Header file for the main view controller.
 */

#import <Cocoa/Cocoa.h>
#import "GameController.h"
#import "constants.h"

NS_ASSUME_NONNULL_BEGIN

@interface BoardView : NSView{
    GameController *c;
    
    NSColor *backgroundColor;
    NSTimer *timer, *timerLabels;
    BOOL gameStarted, gameOverState;
    
    IBOutlet NSTextField *gameOverLabel;
    IBOutlet NSTextField *pressPlayLabel;
    IBOutlet NSTextField *currentRecordLabel;
    IBOutlet NSTextField *topRecordLabel;
}

- (void)startAnimation:(id)sender;
- (void)animateLabel:(id)sender;

- (NSRect)getRectAtRow:(NSInteger)row column:(NSInteger)column;
- (void)drawSimpleRectAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor *)color;

- (void)drawTetrominoeWithType:(NSInteger)type row:(NSInteger)row column:(NSInteger)column color:(NSColor *)color rotation:(NSInteger)rotation;
- (void)draw_OTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color;
- (void)draw_ITetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation;
- (void)draw_LTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation;
- (void)draw_JTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation;
- (void)draw_ZTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation;
- (void)draw_STetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation;
- (void)draw_TTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation;

- (void)drawLogicBoard;

@end

NS_ASSUME_NONNULL_END
