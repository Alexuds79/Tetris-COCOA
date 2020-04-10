//
//  TetrisModel.h
//  Tetris
//
//  Created by Alejandro Mateos on 04/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file TetrisModel.h
 * @Author Alejandro Mateos
 * @date 04/12/2019
 * @brief Fichero de cabecera para el modelo del tablero lógico. Header file for the logic board model.
 */

#import <Foundation/Foundation.h>
#import "constants.h"

NS_ASSUME_NONNULL_BEGIN

@interface TetrisModel : NSObject{
    int logicBoard[ROWS][COLUMNS];
    
    int speedInitialValue;
    int speed;
}

@property int speedInitialValue, speed;

+ (id)sharedModel;
- (int)getLogicBoardPositionWithRow:(int)row column:(int)column;
- (void)setLogicBoardPositionWithRow:(int)row column:(int)column value:(int)value;
- (void)initLogicBoard;
- (void)blockFigureInLogicBoardAtRow:(int)row column:(int)column withType:(int)type withColor:(int)colorIndex;

@end

NS_ASSUME_NONNULL_END
