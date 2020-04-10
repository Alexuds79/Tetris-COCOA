//
//  TetrisModel.m
//  Tetris
//
//  Created by Alejandro Mateos on 04/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file TetrisModel.m
 * @Author Alejandro Mateos
 * @date 04/12/2019
 * @brief Clase que representa el modelo de datos del tablero lógico de la aplicación. Class that represents the data model of the application's logical board.
 */

#import "TetrisModel.h"

@implementation TetrisModel
@synthesize speedInitialValue, speed;

/**
 * @brief Método de inicialización de la clase.
 *
 * Se da valor inicial (vacío) a las celdas del tablero lógico.
 *
 * @return Objeto de tipo id, que representa a la propia clase.
 */
- (id)init{
    self = [super init];
    
    if(self){
        [self initLogicBoard];
        
        speed = 1;
        speedInitialValue = speed;
    }
    
    return self;
}



/**
 * @brief Método de implementación de un patrón SIngleton para devolver siempre la misma instancia del modelo del tablero.
 *
 * @return Objeto de tipo id que representa la instancia del tablero.
 */
+ (id)sharedModel{
    static TetrisModel *m = nil;
    
    if(!m){
        m = [[[self class] alloc] init];
    }
    
    return m;
}


/**
 * @brief Método de inicialización del tablero lógico de la aplicación.
 *
 * Se proporciona valor vacío a todas las celdas de este tablero.
 */
- (void)initLogicBoard{
    for(int i=0; i<ROWS; i++){
        for(int j=0; j<COLUMNS; j++){
            logicBoard[i][j] = EMPTY_TYPE;
        }
    }
}



/**
 * @brief Método para bloquear una celda dentro del tablero lógico.
 *
 * Definimos 'bloquear' por establecer en este tablero un valor para la celda distinto del valor vacío. Una celda cuando se bloquea tendrá un valor que indentifica el tipo y color de la figura que la bloquea. Las decenas de este valor representarán, en este caso, el tipo; y las unidades, el color.
 *
 * @param row Fila que se desea bloquear.
 * @param column Columna que se desea bloquear.
 * @param type Tipo de la figura responsable del bloqueo.
 * @param colorIndex Índice de color de la figura responsable del bloqueo.
 */
- (void)blockFigureInLogicBoardAtRow:(int)row column:(int)column withType:(int)type withColor:(int)colorIndex{
    logicBoard[row][column] = type*10 + colorIndex;
}



/**
 * @brief Método de acceso a una celda del tablero lógico.
 *
 * @param row Fila de la celda a la que se accede.
 * @param column Columna de la celda a la que se accede.
 */
- (int) getLogicBoardPositionWithRow:(int)row column:(int)column{
    return logicBoard[row][column];
}



/**
 * @brief Método de establecimiento de un valor fijo para un celda del tablero lógico, útil sobre todo para reestablecer el valor vacío.
 *
 * @param row Fila a modificar del tablero lógico.
 * @param column Columna a modificar del tablero lógico.
 * @param value Valor a establecer en la celda.
 */
- (void)setLogicBoardPositionWithRow:(int)row column:(int)column value:(int)value{
    logicBoard[row][column] = value;
}

@end
