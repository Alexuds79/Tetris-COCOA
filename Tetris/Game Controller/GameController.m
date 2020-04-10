//
//  GameController.m
//  Tetris
//
//  Created by Alejandro Mateos on 04/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file GameController.m
 * @Author Alejandro Mateos
 * @date 04/12/2019
 * @brief Clase controladora de la lógica de la aplicación. Controlling class of the application logic.
 */

#import "GameController.h"
#import "ETPanelWindowController.h"

@implementation GameController
@synthesize player, topPoints, currentPoints;



/**
 * @brief Método de inicialización de la clase Controlador.
 *
 * Se instancian objetos del modelo del tablero y del modelo de datos de figuras, así como del panel de preferencias. Se proporciona valor inicial a la velocidad de juego y puntuación. Finalmente, se registran los observadores para notificaciones procedentes del panel secundario (cambio de velocidad, de tipo de figura y color de figura), así como un un observador para detectar que se ha alcanzado el estado de Game Over.
 *
 * @return Parámetro de tipo id, que representa a la propia clase.
 */
- (id)init{
    self = [super init];
    
    if(self){
        m = [TetrisModel sharedModel];
        figure = [TetrisFigure sharedFigure];
        panel = [[ETPanelWindowController alloc] init];
        
        playButton = [[NSMenuItem alloc] init];
        stopButton = [[NSMenuItem alloc] init];
        resumeButton = [[NSMenuItem alloc] init];
        panelButton = [[NSMenuItem alloc] init];
        currentPoints = topPoints = pointsForMove = pointsForLine = pointsForBlock = 0;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(gameOver:) name:@"GameOver" object:nil];
    }
    
    return self;
}



/**
 * @brief Método que implementa un patrón Singleton para devolver siempre la misma instancia del controlador.
 *
 * @return Objeto de tipo id, que representa la instancia de la clase controlador que se de devuelve.
 */
+ (id)sharedController{
    static GameController *c = nil;
    
    if(!c){
        c = [[[self class] alloc] init];
    }
    
    return c;
}


/**
 * @brief Método útil para establecer el diseño inicial de la ventana principal.
 *
 * Únicamente se hace uso de este procedimiento para poner en estado inicial la visualización de los botones del menú.
 */
- (void)awakeFromNib{
    [playButton setHidden:NO];
    [stopButton setHidden:YES];
    [resumeButton setHidden:YES];
}



/**
 * @brief Método que registra la acción correspondiente al botón de Play.
 *
 * Una vez pulsado el botón, éste se oculta y se muestra, como es lógico, el botón que detiene el juego actual. Se lanza una notificación que indica a la vista que el juego ha comenzado.
 *
 * @param sender Parámetro que identifica al objeto que es propietario de la acción.
 */
- (IBAction)playGame:(id)sender{
    [playButton setHidden:YES];
    [stopButton setHidden:NO];
    [resumeButton setHidden:YES];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayGame" object:self userInfo:nil];
}



/**
 * @brief Método que registra la acción correspondiente al botón de Stop.
 *
 * Una vez pulsado el botón, éste se oculta y se muestran, como es lógico, los botones que permiten reiniciar el juego desde el principio, o bien, reanudarlo en el estado en el que se dejó. Se lanza una notificación que indica a la vista que el juego se ha detenido.
 *
 * @param sender Parámetro que identifica al objeto que es propietario de la acción.
 */
- (IBAction)stopGame:(id)sender{
    [playButton setHidden:NO];
    [stopButton setHidden:YES];
    [resumeButton setHidden:NO];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"StopGame" object:self userInfo:nil];
}



/**
 * @brief Método que registra la acción correspondiente al botón de Reanudación.
 *
 * Una vez pulsado el botón, éste se oculta y se muestra, como es lógico, el botón que permite parar nuevamente la partida en curso. Se lanza una notificación que indica a la vista que el juego se ha reanudado.
 *
 * @param sender Parámetro que identifica al objeto que es propietario de la acción.
 */
- (IBAction)resumeGame:(id)sender{
    [playButton setHidden:YES];
    [stopButton setHidden:NO];
    [resumeButton setHidden:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"ResumeGame" object:self userInfo:nil];
}


- (void)setSpeed: (int)s{
    [m setSpeedInitialValue:s];
    [m setSpeed:[m speedInitialValue]];
    
}



/**
 * @brief Método de captura de la notificación de final de juego
 *
 * Se reestablecen los parámetros iniciales de cara a empezar una nueva partida.
 *
 * @param aNotification Parámetro de tipo notificación que contiene toda la información necesaria para gestionar el aviso.
 */
-(void)gameOver: (NSNotification*)aNotification{
    if([[aNotification name] isEqualToString:@"GameOver"]){
        [playButton setHidden:NO];
        [stopButton setHidden:YES];
        [resumeButton setHidden:YES];
        
        [m setSpeedInitialValue:1];
        [m setSpeed:[m speedInitialValue]];
        
        currentPoints = pointsForMove = pointsForLine = pointsForBlock = 0;
    }
}



/**
 * @brief Método que establece un nuevo color para la figura activa, tras la llamada desde las funciones del panel de preferencias.
 *
 * Además de asignar color a la figura activa, se actualiza el vector de figuras asociado a la tabla del panel.
 *
 * @param color Nuevo color que se asigna a la figura.
 * @param index Índice del color seleccionado.
 * @param colorName Nombre del color seleccionado.
 */
- (void)setColor: (NSColor*)color withIndex:(int)index withName:(NSString*)colorName{
    [figure setCurrentColor:color];
    [figure setColorIndex:index];
    
    [figure updateLastFigureOfGeneratedFiguresWithRow:[figure currentRow]
                                               column:[figure currentColumn]
                                             rotation:[figure currentRotation]
                                                color:colorName
                                                 type:[figure figureName]];
}



/**
 * @brief Método que establece un nuevo tipo (forma) para la figura activa, tras la llamada efectuada desde el panel de preferencias.
 *
 * Se recoge el tipo y en función de éste se establecen también las nuevas dimensiones de la figura y se le cambia el nombre. Estos valores se actualizan en el vector de figuras asociado a la tabla del panel de preferencias.
 *
 * @param type Valor de tipo entero que indica el tipo recibido.
 */
- (void)setType: (int)type{
    NSString *name;
    
    switch(type){
        case 0: name = @"O Tetrominoe"; [figure setRowDimension:2]; [figure setColumnDimension:2]; break; //O_Block
        case 1: name = @"I Tetrominoe"; [figure setRowDimension:1]; [figure setColumnDimension:4]; break; //I_Block
        case 2: name = @"L Tetrominoe"; [figure setRowDimension:2]; [figure setColumnDimension:3]; break; //L_Block
        case 3: name = @"J Tetrominoe"; [figure setRowDimension:2]; [figure setColumnDimension:3]; break; //J_Block
        case 4: name = @"Z Tetrominoe"; [figure setRowDimension:2]; [figure setColumnDimension:3]; break; //Z_Block
        case 5: name = @"S Tetrominoe"; [figure setRowDimension:2]; [figure setColumnDimension:3]; break; //S_Block
        case 6: name = @"T Tetrominoe"; [figure setRowDimension:2]; [figure setColumnDimension:3]; break; //T_Block
    }
    
    [figure setFigureType:type];
    
    [figure updateLastFigureOfGeneratedFiguresWithRow:[figure currentRow]
                                               column:[figure currentColumn]
                                             rotation:[figure currentRotation]
                                                color:[figure colorStr]
                                                 type:name];
}



/**
 * @brief Método de gestión de cierre de la ventana
 *
 * Se construye y lanza un panel de advertencia con los mensajes y botones correspondientes. En caso de aceptación por parte del usuario, la aplicación se termina completamente.
 *
 * @param sender Parámetro que identifica al objeto responsable del método.
 * @return Variable de tipo booleano que registra la respuesta del usuario.
 */
- (BOOL)windowShouldClose:(NSWindow *)sender{
    NSAlert *alert = [[NSAlert alloc] init];
    
    [alert addButtonWithTitle:@"Yes, leave me out"];
    [alert addButtonWithTitle:@"No, I wanna continue playing"];
    [alert setMessageText:@"Are you sure you want to close the window?"];
    [alert setInformativeText:@"If you close the window the game will end without saving changes..."];
    [alert setAlertStyle:NSAlertStyleWarning];
    
    long result = [alert runModal];
    
    if(result == NSAlertFirstButtonReturn){
        [NSApp terminate:self];
        return YES;
    }
    else return NO;
}




/**
 * @brief Método de acceso al tipo de figura activa.
 */
- (int)getFigureType{return [figure figureType];}

/**
 @brief Método de acceso a la fila ocupada por la figura activa.
 */
- (int)getFigureRow{return [figure currentRow];}

/**
 * @brief Método de acceso a la columna ocupada por la figura activa.
 */
- (int)getFigureColumn{return [figure currentColumn];}

/**
 * @brief Método de acceso al color de la figura activa.
 */
- (NSColor *)getFigureColor{return [figure currentColor];}

/**
 * @brief Método de acceso a la rotación de la figura activa.
 */
- (int)getFigureRotation{return [figure currentRotation];}

/**
 * @brief Métdodo de acceso al número de filas ocupadas por la figura activa.
 */
- (int)getFigureRowDimension{return [figure rowDimension];}

/**
 * @brief Método de acceso al índice de color propio de la figura activa.
 */
- (int)getColorIndex{return [figure colorIndex];}

/**
 * @brief Método de acceso al color de la figura activa, a partir de un índice especificado.
 */
- (NSColor *)getColorWithColorIndex:(int)index{return [figure getColorWithColorIndex:index];}


/**
 * @brief Método de establecimiento del tipo de la figura activa.
 */
- (void)setFigureType:(int)type{[figure setFigureType:type];}

/**
 * @brief Método de establecimiento de la fila ocupada por la figura activa.
 */
- (void)setFigureRow:(int)row{[figure setCurrentRow:row];}

/**
 * @brief Método de establecimiento de la columna ocupada por la figura activa.
 */
- (void)setFigureColumn:(int)column{[figure setCurrentColumn:column];}

/**
 * @brief Método de establecimiento del color para la figura activa.
 */
- (void)setFigureColor:(NSColor*)color{[figure setCurrentColor:color];}

/**
 * @brief Método de establecimiento de la rotación de la figura activa.
 */
- (void)setFigureRotation:(int)rotation{[figure setCurrentRotation:rotation];}




/**
 * @brief Método de llamada a la creación de una nueva figura aleatoria.
 */
- (void)createNewFigure{
    [figure generateRandomFigure];
}



/**
 * @brief Método para el movimiento descendente de la figura activa.
 *
 * Se comprueba si el movimiento es posible (no se ha alcanzado el final de tablero y no existe figura debajo) y en caso afirmativo se desciende la figura un número de filas marcado por la velocidad actual. Se actualiza el vector de figuras asociado a la tabla del panel. Finalmente, se asignan puntos y se lanza una notificación de actualización de la tabla del panel para visualizar los cambios en tiempo real.
 */
- (void)moveDown{
    int row = [figure currentRow];
    
    if(row - [figure rowDimension] >= 0 && [self checkDownFigures]){
        row -= [m speed];
        if([m speed]>1) [m setSpeed:[m speedInitialValue]];
        
        [figure setCurrentRow:row];
        [figure updateLastFigureOfGeneratedFiguresWithRow:row
                                                   column:[figure currentColumn]
                                                 rotation:[figure currentRotation]
                                                    color:[figure colorStr]
                                                     type:[figure figureName]];
    }
    
    pointsForMove++;
    [self givePoints];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTable" object:self];
}



/**
 * @brief Método para el movimiento a izquierda de la figura activa.
 *
 * Se comprueba que el movimiento en cuestión sea posible (estamos dentro de los límites del tablero y no existen figuras a la izquierda bloqueando el camino) y en caso afirmativo, se disminuye el valor de columna actual en una unidad. Se actualiza el vector de figuras asociado a la tabla del panel, se asignan puntos y se lanza una notificación de actualización de la tabla del panel.
 */
- (void)moveLeft{
    int column = [figure currentColumn];
    
    if(column > 0 && [self checkLeftFigures]){
        column -= 1;
        
        [figure setCurrentColumn:column];
        [figure updateLastFigureOfGeneratedFiguresWithRow:[figure currentRow]
                                                   column:column
                                                 rotation:[figure currentRotation]
                                                    color:[figure colorStr]
                                                     type:[figure figureName]];
    }
    
    pointsForMove++;
    [self givePoints];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTable" object:self];
}



/**
 * @brief Método para el movimiento a derecha de la figura activa.
 *
 * Se comprueba que el movimiento en cuestión sea posible (estamos dentro de los límites del tablero y no existen figuras a la derecha bloqueando el camino) y en caso afirmativo, se aumenta el valor de columna actual en una unidad. Se actualiza el vector de figuras asociado a la tabla del panel, se asignan puntos y se lanza una notificación de actualización de la tabla del panel.
 */
- (void)moveRight{
    int column = [figure currentColumn];
    
    if(column + [figure columnDimension] < COLUMNS && [self checkRightFigures]){
        column += 1;
        
        [figure setCurrentColumn:column];
        [figure updateLastFigureOfGeneratedFiguresWithRow:[figure currentRow]
                                                   column:column
                                                 rotation:[figure currentRotation]
                                                    color:[figure colorStr]
                                                     type:[figure figureName]];
    }
    
    pointsForMove++;
    [self givePoints];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTable" object:self];
}



/**
 * @brief Método de gestión de la rotación de la figura activa.
 *
 * Se diferencian casos en función del número de rotaciones que son posibles para cada tipo de figura. En cada caso, se comprueba si la rotación no provoca colisión con otra figura del entorno. En caso de ser posible la rotación, se modifica el atributo de rotación de la figura según el caso y se actualizan las dimensiones ocupadas por la figura en su nueva rotación. Finalmente, se actualiza el vector de figuras asociado a la tabla del panel, se conceden puntos y se lanza una notificación para el redibujado de la tabla del panel.
 */
- (void)rotate{
    int rotation = [figure currentRotation];
    int figType = [figure figureType];
    
    switch(figType){
        
        //Without rotation (O)
        case (O_TYPE):
            rotation=0;
        break;
        
        //2 positions (I,S,Z)
        case(I_TYPE):
            if(rotation == 0){
                if([m getLogicBoardPositionWithRow:[figure currentRow] - 1  column:[figure currentColumn]] != EMPTY_TYPE) break;
                if([m getLogicBoardPositionWithRow:[figure currentRow] - 2  column:[figure currentColumn]] != EMPTY_TYPE) break;
                if([m getLogicBoardPositionWithRow:[figure currentRow] - 3  column:[figure currentColumn]] != EMPTY_TYPE) break;
                
                [figure setRowDimension:4];
                [figure setColumnDimension:1];
                
                if([self canRotate]) rotation = 90;
                else{
                    [figure setRowDimension:1];
                    [figure setColumnDimension:4];
                }
            }
            else if(rotation == 90){
                if([m getLogicBoardPositionWithRow:[figure currentRow] column:[figure currentColumn] + 1] != EMPTY_TYPE) break;
                if([m getLogicBoardPositionWithRow:[figure currentRow] column:[figure currentColumn] + 2] != EMPTY_TYPE) break;
                if([m getLogicBoardPositionWithRow:[figure currentRow] column:[figure currentColumn] + 3] != EMPTY_TYPE) break;
                
                [figure setRowDimension:1];
                [figure setColumnDimension:4];
                
                if([self canRotate]) rotation = 0;
                else{
                    [figure setRowDimension:4];
                    [figure setColumnDimension:1];
                }
            }
        break;
            
        case(S_TYPE):
        case(Z_TYPE):
            if(rotation == 0){
                [figure setRowDimension:3];
                [figure setColumnDimension:2];
                
                if([self canRotate]) rotation = 90;
                else{
                    [figure setRowDimension:2];
                    [figure setColumnDimension:3];
                }
            }
            else if(rotation == 90){
                if([figure figureType] == S_TYPE && [m getLogicBoardPositionWithRow:[figure currentRow]+0  column:[figure currentColumn] + 2] != EMPTY_TYPE) break;
                if([figure figureType] == Z_TYPE && [m getLogicBoardPositionWithRow:[figure currentRow]+1  column:[figure currentColumn] + 2] != EMPTY_TYPE) break;
                
                [figure setRowDimension:2];
                [figure setColumnDimension:3];
                
                if([self canRotate]) rotation = 0;
                else{
                    [figure setRowDimension:3];
                    [figure setColumnDimension:2];
                }
            }
        break;
        
        //4 positions (L,J,T)
        default:
            if(rotation == 0){
                [figure setRowDimension:3];
                [figure setColumnDimension:2];
                
                if([self canRotate]) rotation = 90;
                else{
                    [figure setRowDimension:2];
                    [figure setColumnDimension:3];
                }
            }
            else if(rotation == 90){
                if([m getLogicBoardPositionWithRow:[figure currentRow]+0  column:[figure currentColumn] + 2] != EMPTY_TYPE) break;
                
                [figure setRowDimension:2];
                [figure setColumnDimension:3];
                
                if([self canRotate]) rotation = 180;
                else{
                    [figure setRowDimension:3];
                    [figure setColumnDimension:2];
                }
            }
            else if(rotation == 180){
                [figure setRowDimension:3];
                [figure setColumnDimension:2];
                
                if([self canRotate]) rotation = 270;
                else{
                    [figure setRowDimension:2];
                    [figure setColumnDimension:3];
                }
            }
            else if(rotation == 270){
                if([m getLogicBoardPositionWithRow:[figure currentRow]+0  column:[figure currentColumn] + 2] != EMPTY_TYPE) break;
                
                [figure setRowDimension:2];
                [figure setColumnDimension:3];
                
                if([self canRotate]) rotation = 0;
                else{
                    [figure setRowDimension:3];
                    [figure setColumnDimension:2];
                }
            }
    }
    
    [figure setCurrentRotation:rotation];
    [figure updateLastFigureOfGeneratedFiguresWithRow:[figure currentRow]
                                               column:[figure currentColumn]
                                             rotation:rotation
                                                color:[figure colorStr]
                                                 type:[figure figureName]];
    
    pointsForMove++;
    [self givePoints];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateTable" object:self];
}



/**
 * @brief Método de comprobación de rotación, con respecto a los límites del tablero.
 *
 * @return Valor de tipo booleano que devuelve falso si la rotación provoca colisión, y verdadero en caso contrario.
 */
- (BOOL)canRotate{
    if([figure currentColumn] + [figure columnDimension] > COLUMNS) return false; //right boundary
    if([figure currentRow] - [figure rowDimension] < -1) return false; //floor boundary
    
    return true;
}



/**
 * @brief Método de comprobación de movimiento descendente.
 *
 * Si la velocidad es 1, se comprueba únicamente que la celda inferior a cada una de las celdas ocupadas por la figura no esté ocupada, y en caso de que cualquiera lo esté, la rotación no se concede.
 * Para valores de velocidad superiores a 1, donde la figura avanza múltiples filas en cada movimiento, se comprueba el número máximo de filas que puede avanzar la figura hasta que tenga lugar una colisión, o bien hasta alcanzar el valor de velocidad designado, y se avanza en consecuencia.
 *
 * @return Valor booleano que devuelve falso para rechazar la rotación, o verdadero si ésta es posible.
 */
- (BOOL)checkDownFigures{
    
    if([m speedInitialValue] > 1){
        int maxRowsToJump = 0;
        BOOL canJump = true;
        
        for(int i=0; i<=[m speedInitialValue]; i++){
            if(canJump == true) maxRowsToJump = i;
            canJump = true;
            
            if(i!=0){
                if ([m getLogicBoardPositionWithRow:positions[0][0] - i column:positions[0][1]] != EMPTY_TYPE) {canJump = false; break;}
                if ([m getLogicBoardPositionWithRow:positions[1][0] - i column:positions[1][1]] != EMPTY_TYPE) {canJump = false; break;}
                if ([m getLogicBoardPositionWithRow:positions[2][0] - i column:positions[2][1]] != EMPTY_TYPE) {canJump = false; break;}
                if ([m getLogicBoardPositionWithRow:positions[3][0] - i column:positions[3][1]] != EMPTY_TYPE) {canJump = false; break;}
            }
        }
        
        [m setSpeed:maxRowsToJump-1];
        
        if([m speed] == 0) return false;
        if([figure currentRow] - [m speed] < 0) [m setSpeed:1];
        return true;
    }
    
    else{
        if ([m getLogicBoardPositionWithRow:positions[0][0] - 1 column:positions[0][1]] != EMPTY_TYPE) return false;
        if ([m getLogicBoardPositionWithRow:positions[1][0] - 1 column:positions[1][1]] != EMPTY_TYPE) return false;
        if ([m getLogicBoardPositionWithRow:positions[2][0] - 1 column:positions[2][1]] != EMPTY_TYPE) return false;
        if ([m getLogicBoardPositionWithRow:positions[3][0] - 1 column:positions[3][1]] != EMPTY_TYPE) return false;
        
        return true;
    }
    
}



/**
 * @brief Método de detección de colisiones respecto de las figuras situadas a la derecha.
 *
 * Se comprueba si cualquiera de las celdas situadas a la derecha de cada uno de los rectángulos que forman la figura activa está ocupada, y en caso afirmativo, el movimiento no se concede.
 *
 * @return Valor booleano que devuelve falso para rechazar el movimiento, o verdadero para concederlo.
 */
- (BOOL)checkRightFigures{
    if ([m getLogicBoardPositionWithRow:positions[0][0] column:positions[0][1] + 1] != EMPTY_TYPE) return false;
    if ([m getLogicBoardPositionWithRow:positions[1][0] column:positions[1][1] + 1] != EMPTY_TYPE) return false;
    if ([m getLogicBoardPositionWithRow:positions[2][0] column:positions[2][1] + 1] != EMPTY_TYPE) return false;
    if ([m getLogicBoardPositionWithRow:positions[3][0] column:positions[3][1] + 1] != EMPTY_TYPE) return false;
    
    return true;
}



/**
 * @brief Método de detección de colisiones respecto de las figuras situadas a la izquierda.
 *
 * Se comprueba si cualquiera de las celdas situadas a la izquierda de cada uno de los rectángulos que forman la figura activa está ocupada, y en caso afirmativo, el movimiento no se concede.
 *
 * @return Valor booleano que devuelve falso para rechazar el movimiento, o verdadero para concederlo.
 */
- (BOOL)checkLeftFigures{
    if ([m getLogicBoardPositionWithRow:positions[0][0] column:positions[0][1] - 1] != EMPTY_TYPE) return false;
    if ([m getLogicBoardPositionWithRow:positions[1][0] column:positions[1][1] - 1] != EMPTY_TYPE) return false;
    if ([m getLogicBoardPositionWithRow:positions[2][0] column:positions[2][1] - 1] != EMPTY_TYPE) return false;
    if ([m getLogicBoardPositionWithRow:positions[3][0] column:positions[3][1] - 1] != EMPTY_TYPE) return false;
    
    return true;
}



/**
 * @brief Método de comprobación de filas completadas
 *
 * Se recorren todas las columnas del tablero en el espacio ocupado por la figura que se acaba de colocar, y en caso de que toda una fila esté completa (se indica mediante flag), se llama a su eliminación, se conceden puntos y se reproduce un sonido.
 */
- (void)checkRowCompletion{
    BOOL flag = true;
    
    for(int i = [figure currentRow]; i > [figure currentRow] - [figure rowDimension]; i--){
        flag = true;
        
        for(int j=0; j<COLUMNS; j++){
            if([m getLogicBoardPositionWithRow:i column:j] == EMPTY_TYPE) flag = false;
        }
        
        if(flag == true){
            pointsForLine++;
            [self givePoints];
            
            [self deleteRow:i];
            [self playSoundWithName:@"LineCompleted" extension:@"wav"];
        }
    }
}



/**
 * @brief Método de eliminación de filas completas.
 *
 * En primer lugar, se devuelven los valores del tablero lógico en esa fila a valor inicial o VALOR VACÍO, indicando que las celdas están libres de nuevo.
 * Posteriormente, todas las celdas superiores en el tablero se descienden a la fila inmediatamente inferior.
 *
 * @param row Valor de la fila a eliminar.
 */
- (void)deleteRow:(int)row{
    //Delete row
    for(int j=0; j<COLUMNS; j++){
        [m setLogicBoardPositionWithRow:row column:j value:EMPTY_TYPE];
    }
    
    //Move down upper rows
    for(int i=row; i<ROWS-1; i++){
        for (int j=0; j<COLUMNS; j++){
            [m setLogicBoardPositionWithRow:i column:j value:[m getLogicBoardPositionWithRow:i+1 column:j]];
        }
    }
}



/**
 * @brief Método de comprobación de estado de Game Over.
 *
 * De entre las maneras de comprobar el final de juego, se ha optado por comprobar si la fila inmediatamente inferior a la que ocupa la parte superior del tablero está ocupada por al menos dos figuras, y en caso afirmativo, se devuelve verdadero indicando final de juego.
 *
 * @return Valor booleano que devuelve verdadero ante final de partida, y falso en caso contrario.
 */
- (BOOL)checkGameOver{
    int counter = 0;
    for (int c=0; c<COLUMNS; c++){
        if([m getLogicBoardPositionWithRow:ROWS-2 column:c] != EMPTY_TYPE) counter++;
    }
    
    if(counter>1) return true;
    return false;
}



/**
 * @brief Método de llamada a la inicialización del tablero lógico del modelo.
 */
- (void)initLogicBoard{
    [m initLogicBoard];
}



/**
 * @brief Método de acceso al valor contenido en una de las celdas del tablero lógico del modelo.
 *
 * @param row Valor de fila para la celda.
 * @param column Valor de columna para la celda.
 *
 * @return Valor entero que devuelve el valor contenido en la celda solicitada.
 */
- (int) getLogicBoardPositionWithRow:(int)row column:(int)column{
    return [m getLogicBoardPositionWithRow:row column:column];
}



/**
 * @brief Método para llamar al establecimiento de un valor dentro de una celda del tablero lógico, lo que implica bloquear esa celda dentro del mismo. Cada figura posicionada bloqueará, como es lógico, cuatro celdas llamando una vez por cada uno de los cuatro rectángulos que la forman. Cada vez que se bloquea la celda se dan puntos al jugador.
 *
 * @param row Fila del tablero a bloquear.
 * @param column Columna del tablero a bloquear.
 * @param type Tipo de la figura que bloquea.
 * @param colorIndex Índice de color de la figura que bloquea.
 */
- (void)blockFigureInLogicBoardAtRow:(int)row column:(int)column withType:(int)type withColor:(int)colorIndex{
    pointsForBlock++;
    [self givePoints];
    
    [m blockFigureInLogicBoardAtRow:row column:column withType:type withColor:colorIndex];
}



/**
 * @brief Método de llenado de la matriz que contiene la posición de cada una de las celdas ocupadas por la figura activa.
 *
 * @param row0 Fila de la celda 0.
 * @param col0 Columna de la celda 0.
 * @param row1 Fila de la celda 1.
 * @param col1 Columna de la celda 1.
 * @param row2 Fila de la celda 2.
 * @param col2 Columna de la celda 2.
 * @param row3 Fila de la celda 3.
 * @param col3 Columna de la celda 3.
 */
- (void)fillPositionsMatrixWithRow0:(int)row0 col0:(int)col0 row1:(int)row1 col1:(int)col1 row2:(int)row2 col2:(int)col2 row3:(int)row3 col3:(int)col3{
    positions[0][0] = row0;
    positions[0][1] = col0;
    
    positions[1][0] = row1;
    positions[1][1] = col1;
    
    positions[2][0] = row2;
    positions[2][1] = col2;
    
    positions[3][0] = row3;
    positions[3][1] = col3;
}



/**
 * @brief Método de acceso a la matriz de celdas ocupadas por la figura activa.
 *
 * @param row Parámetro que indica la fila de la matriz de posiciones a la que se accede.
 * @param column Parámetro que indica la columna de la matriz de posiciones a la que se accede.
 *
 * @return Valor entero que devuelve, según el caso y la especificación de la función de llenado de esta matriz, la fila o columna ocupada por una de las celdas de la figura activa.
 */
- (int)getCellValueWithRow:(int)row column:(int)column{
    return positions[row][column];
}



/**
 * @brief Método que lanza la visualización del panel de preferencias.
 *
 * Se instancia el panel y se muestra.
 *
 * @param sender Objeto responsable de lanzar el método, en este caso, el botón de preferencias del menú principal de la vista.
 */
- (IBAction)showPanel:(id)sender{
    panel = [[ETPanelWindowController alloc] init];
    [panel showWindow:sender];
}



/**
 * @brief Método de concesión de puntos al jugador.
 *
 * El valor de puntuación se pondera en función de si el jugador ha realizado un movimiento simple, un posicionamiento, o un completado de línea. El valor de récord se establece si el actual es superior al récord que teníamos almacenado.
 */
- (void)givePoints{
    if([self checkGameOver] == false){
        currentPoints = [m speedInitialValue] * (pointsForMove + 2*pointsForBlock + 10*pointsForLine);
        
        if(currentPoints > topPoints) topPoints = currentPoints;
    }
}



/**
 * @brief Método para la reproducción de la música de fondo.
 *
 * @param name Nombre del archivo de audio.
 * @param extension Formato del archivo de audio.
 */
- (void)playMusicWithName:(NSString *)name extension:(NSString *)extension{
    player = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:extension] byReference:NO];
    [player play];
}



/**
 @brief Método para la reproducción de sonidos auxiliares.
 
 @param name Nombre del archivo de audio.
 @param extension Formato del archivo de audio.
 */
- (void)playSoundWithName:(NSString *)name extension:(NSString *)extension{
    sound = [[NSSound alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:name ofType:extension] byReference:NO];
    [sound play];
}



/**
 * @brief Método que lanza la visualización de la ventana de Ayuda.
 *
 * @param sender Objeto que identfica al responsable de lanzar el evento, en este caso, un botón situado en la vista principal de la aplicación.
 */
- (IBAction)showHelp:(id)sender{
    NSAlert *alert = [[NSAlert alloc] init];
    NSString *informativeText;
    
    informativeText = [[NSString alloc] initWithFormat:@"Press [Command+P] to PLAY the game\n"
                       "Press [Command+S] to STOP the game\n"
                       "Press [Command+R] to RESUME the game\n\n"
                       "Press [Command+,] to open the PREFERENCES window\n\n"
                       "Press [Up Arrow] to ROTATE the figure\n"
                       "Press [Down Arrow] to MOVE-DOWN the figure\n"
                       "Press [Left Arrow] to MOVE-LEFT the figure\n"
                       "Press [Right Arrow] to MOVE-RIGHT the figure"];
    
    [alert addButtonWithTitle:@"Close Help"];
    [alert setMessageText:@"WELCOME TO THE HELP WINDOW"];
    [alert setInformativeText:informativeText];
    [alert setAlertStyle:NSAlertStyleInformational];
    
    [alert runModal];
}



/**
 * @brief Método que permite acceder al vector de figuras creadas, útil para rellenar la tabla del panel.
 *
 * @return Colección de figuras generadas
 */
- (NSMutableArray *)getGeneratedFigures{
    return [figure generatedFigures];
}

@end
