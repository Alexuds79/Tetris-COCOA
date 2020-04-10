//
//  TetrisFigure.m
//  Tetris
//
//  Created by Alejandro Mateos on 05/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file TetrisFigure.m
 * @Author Alejandro Mateos
 * @date 05/12/2019
 * @brief Clase que representa el modelo de datos de una figura simple a representar en el tablero. A class that represents the data model of a simple figure to be represented on the dashboard.
 */

#import "TetrisFigure.h"

@implementation TetrisFigure
@synthesize figureType, figureName, currentRow, currentColumn, currentColor, currentRotation, colorSet, rowDimension, columnDimension, colorIndex, colorStr, generatedFigures;

/**
 * @brief Método de inicialización de la clase que representa el modelo de figuras.
 *
 * Se instancia el vector de colores posibles y también un vector de figuras generadas, útil este último para la tabla del panel.
 *
 * @return Objeto de tipo id, que representa la propia clase.
 */
- (id)init{
    self = [super init];
    
    if(self){
        colorSet = [[NSArray alloc] initWithObjects:[NSColor redColor], [NSColor greenColor], [NSColor yellowColor], [NSColor blueColor], [NSColor purpleColor],
        [NSColor orangeColor], [NSColor systemPinkColor], [NSColor cyanColor], nil];
        
        generatedFigures = [[NSMutableArray alloc] init];
    }
    
    return self;
}



/**
 * @brief Método para registrar un patrón Singleton a la hora de devolver siempre una misma instancia de la figura.
 *
 * @return Objeto que representa la instancia de la figura.
 */
+ (id)sharedFigure{
    static TetrisFigure *figure = nil;
    
    if(!figure){
        figure = [[[self class] alloc] init];
    }
    
    return figure;
}



/**
 * @brief Método de creación de una figura con valores aleatorios para sus atributos y adición de la misma al vector de figuras vinculado a la tabla del panel.
 */
- (void)generateRandomFigure{
    figureType = arc4random_uniform(7);
    currentRow = ROWS; //In order not to see the figure before clicking the play button
    currentColumn = arc4random_uniform(COLUMNS - 3);
    currentRotation = 0;
    
    colorIndex = arc4random_uniform((uint32_t)colorSet.count);
    currentColor = colorSet[colorIndex];
    
    switch(figureType){
        case O_TYPE: figureName=@"O Tetrominoe"; rowDimension=2; columnDimension=2; break;
        case I_TYPE: figureName=@"I Tetrominoe"; rowDimension=1; columnDimension=4; break;
        case L_TYPE: figureName=@"L Tetrominoe"; rowDimension=2; columnDimension=3; break;
        case J_TYPE: figureName=@"J Tetrominoe"; rowDimension=2; columnDimension=3; break;
        case Z_TYPE: figureName=@"Z Tetrominoe"; rowDimension=2; columnDimension=3; break;
        case S_TYPE: figureName=@"S Tetrominoe"; rowDimension=2; columnDimension=3; break;
        case T_TYPE: figureName=@"T Tetrominoe"; rowDimension=2; columnDimension=3; break;
    }
    
    
    //Generated figures
    NSString *name, *row, *column, *color, *rotation;
    
    switch(colorIndex){
        case 0: colorStr=@"Red"; break;
        case 1: colorStr=@"Green"; break;
        case 2: colorStr=@"Yellow"; break;
        case 3: colorStr=@"Blue"; break;
        case 4: colorStr=@"Purple"; break;
        case 5: colorStr=@"Orange"; break;
        case 6: colorStr=@"Pink"; break;
        case 7: colorStr=@"Cyan"; break;
    }
    
    name = figureName;
    row = [[NSString alloc] initWithFormat:@"%d", currentRow];
    column = [[NSString alloc] initWithFormat:@"%d", currentColumn];
    color = colorStr;
    rotation = [[NSString alloc] initWithFormat:@"%d", currentRotation];
    
    NSArray *aFigure = [[NSArray alloc] initWithObjects:name, row, column, color, rotation, nil];
    [generatedFigures addObject:aFigure];
}



/**
 * @brief Método que devuelve un color del vector de colores a partir del índice especificado.
 *
 * @param index Índice al que acceder.
 *
 * @return Color obtenido a partir del índice que se recibe como parámetro.
 */
- (NSColor *)getColorWithColorIndex:(int)index{
    return [colorSet objectAtIndex:index];
}



/**
 * @brief Método de actualización del último elemento (última figura representada mediante array de atributos) del vector de figuras asociado a la tabla del panel.
 *
 * @param row Nuevo valor de fila a representar.
 * @param column Nuevo valor de columna a representar.
 * @param rotation Nuevo valor de rotación a representar.
 * @param c Nuevo valor de color a representar.
 * @param fn Nuevo valor de nombre (tipo) de la figura a representar.
 */
- (void)updateLastFigureOfGeneratedFiguresWithRow:(int)row column:(int)column rotation:(int)rotation color:(NSString*)c type:(NSString *)fn{
    NSString *name, *rowStr, *columnStr, *color, *rotationStr;
    colorStr = c;
    figureName = fn;
    
    name = figureName;
    rowStr = [[NSString alloc] initWithFormat:@"%d", row];
    columnStr = [[NSString alloc] initWithFormat:@"%d", column];
    color = colorStr;
    rotationStr = [[NSString alloc] initWithFormat:@"%d", rotation];
    
    [generatedFigures removeObject:[generatedFigures lastObject]];
    
    NSArray *aFigure = [[NSArray alloc] initWithObjects:name, rowStr, columnStr, color, rotationStr, nil];
    [generatedFigures addObject:aFigure];
}

@end
