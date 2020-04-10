//
//  TetrisFigure.h
//  Tetris
//
//  Created by Alejandro Mateos on 05/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file TetrisFigure.h
 * @Author Alejandro Mateos
 * @date 05/12/2019
 * @brief Fichero de cabecera para el modelo de datos de figuras. Header file for the figure data model.
 */

#import <Foundation/Foundation.h>
#import <Cocoa/Cocoa.h>
#import "constants.h"

NS_ASSUME_NONNULL_BEGIN

@interface TetrisFigure : NSObject{
    int figureType, currentRow, currentColumn, currentRotation, rowDimension, columnDimension, colorIndex;
    NSString *figureName, *colorStr;
    NSColor *currentColor;
    NSArray *colorSet;
    NSMutableArray *generatedFigures;
}

@property int figureType, currentRow, currentColumn, currentRotation, rowDimension, columnDimension, colorIndex;
@property NSString *figureName, *colorStr;
@property NSColor *currentColor;
@property NSArray *colorSet;
@property NSMutableArray *generatedFigures;

- (void)generateRandomFigure;
- (NSColor *)getColorWithColorIndex:(int)index;
- (void)updateLastFigureOfGeneratedFiguresWithRow:(int)row column:(int)column rotation:(int)rotation color:(NSString*)c type:(NSString*)fn;

+(id)sharedFigure;

@end

NS_ASSUME_NONNULL_END
