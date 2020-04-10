//
//  BoardView.m
//  Tetris
//
//  Created by Alejandro Mateos on 03/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file BoardView.m
 * @Author Alejandro Mateos
 * @date 03/12/2019
 * @brief Clase controladora de la ventana principal. Controlling class of the main window.
 */

#import "BoardView.h"

@implementation BoardView



/**
 * @brief Método inicializador de la vista principal.
 *
 * En primer lugar, se instancia una referencia del controlador principal y se inicializan un conjunto de variables booleanas.
 * Lo siguiente es registrar los observadores del centro de notificaciones respecto de las notificaciones de: inicio de juego, pausa y reanudación.
 * Se concluye instanciando un temporizador que efectuará una animación de las etiquetas iniciales en un período de 0.7 segundos.
 *
 * @param coder Parámetro de código de inicialización.
 * @return Parámetro de tipo id, que es la referencia de la propia clase (self).
 */
- (id)initWithCoder:(NSCoder *)coder{
    self = [super initWithCoder:coder];
    
    if(self){
        c = [GameController sharedController];
        gameStarted = gameOverState = false;
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"PlayGame" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"StopGame" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"ResumeGame" object:nil];
        
        timerLabels = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(animateLabel:) userInfo:nil repeats:YES];
    }
    
    return self;
}



/**
 * @brief Método de captura de notificaciones.
 *
 * Se propone la captura de tres tipos de notificaciones: de inicio de juego, pausa y reanudación
 * Si la notificación es de inicio de juego: se reanuda la reproducción de la música desde el inicio. Se instancia el temporizador de animación de las figuras. Se crea una nueva figura y se llama a la inicialización del tablero lógico. Finalmente, se indica que el juego ha comenzado mediante variable booleana.
 * Si la notificación es de pausa de juego: se detiene el temporizador.
 * Si la notificación es de reanudación de juego: se reestablece el temporizador para la animación de las figuras.
 *
 * @param aNotification Parámetro de tipo notificación que contiene la información necesaria para su gestión cuando es capturada.
 */
- (void)receiveNotification:(NSNotification*)aNotification{
    if([[aNotification name] isEqualToString:@"PlayGame"]){
        [[c player] stop];
        [c playMusicWithName:@"TetrisMusic" extension:@"m4a"];
        
        timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(startAnimation:) userInfo:nil repeats:YES];
        [c createNewFigure];
        [c initLogicBoard];
        gameStarted = true;
    }
    
    if([[aNotification name] isEqualToString:@"StopGame"]){
        [timer invalidate];
    }
    
    if([[aNotification name] isEqualToString:@"ResumeGame"]){
        timer = [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(startAnimation:) userInfo:nil repeats:YES];
    }
}



/**
 * @brief Método para el selector del temporizador de animación de las figuras.
 *
 * Se realiza una llamada al método que produce el movimiento descendente de la figura y se solicita el redibujado de la propia vista.
 *
 * @param sender Representa el objeto que invoca el selector.
 */
- (void)startAnimation:(id)sender{
    [c moveDown];
    [self setNeedsDisplay:YES];
}



/**
 * @brief Método para el selector del temporizador de animación de las etiquetas de inicio de juego o estado de Game Over.
 *
 * En cualquiera de los casos, se establece una animación de intermitencia para la etiqueta en cuestión por medio de llamadas a conveniencia efectuadas sobre el atributo hidden de la etiqueta.
 *
 * @param sender Representa el objeto que invoca el selector.
 */
- (void)animateLabel: (id)sender{
    if(gameOverState){
        if([gameOverLabel isHidden]) [gameOverLabel setHidden:false];
        else [gameOverLabel setHidden:true];
    }
    
    else{
        if([pressPlayLabel isHidden]) [pressPlayLabel setHidden:false];
        else [pressPlayLabel setHidden:true];
    }
}



/**
 * @brief Método central de la vista, donde tiene lugar todo el proceso de dibujado.
 *
 * Se comienza por definir aquéllo que es conveniente ejecutar siempre que se invoque el redibujado de la vista, como es la actualización de las etiquetas de puntuaciones y el dibujado de la imagen de fondo.
 * Acciones a realizar en caso de Game Over: detenemos la música de fondo y reproducimos un sonido especial indicando fin de partida. Iniciamos el temporizador que anima la etiqueta de Game Over. Lanzamos una notificación que informa a las clases observadoras del nuevo estado de juego. Detenemos el temporizador de animación descendente de las figuras. Establecemos una serie de variables booleanas y ponemos los botonces del menú a conveniencia. Finalmente, reinicamos el tablero lógico y salimos.
 * Acciones a realizar en caso de Juego Iniciado: colocamos el nuevo fondo sobre el actual. Retiramos las etiquetas animadas del fondo. Indicamos que no estamos en estado de Game Over mediante variable booleana. Ordenamos el dibujado del tablero a partir de la información del modelo, y a continuación, hacemos lo propio para dibujar la figura actual. Comprobamos si la figura ha alcanzado su límite de movimiento y, en caso afirmativo, bloqueamos su posición en el tablero lógico del modelo. Una vez bloqueada se comprueba si la fila está completa -en cuyo caso se eliminará-,y después, se añade una nueva figura.
 *
 * @param dirtyRect Rectángulo que representa el lienzo de la vista.
 */
- (void)drawRect:(NSRect)dirtyRect {
    [super drawRect:dirtyRect];
    
    [currentRecordLabel setIntValue:[c currentPoints]];
    [topRecordLabel setIntValue:[c topPoints]];
    
    //Add a background image
    NSRect frame = [self frame];
    NSImage *image = [NSImage imageNamed:@"backgroundBlack"];
    [image setSize:frame.size];
    backgroundColor = [NSColor colorWithPatternImage:image];
    [backgroundColor setFill];
    NSRectFill(dirtyRect);
    
    //Game over status
    if([c checkGameOver]){
        [[NSNotificationCenter defaultCenter] postNotificationName:@"GameOver" object:self userInfo:nil];
        
        [[c player] stop];
        [c playMusicWithName:@"GameOver" extension:@"wav"];
        
        timerLabels = [NSTimer scheduledTimerWithTimeInterval:0.7 target:self selector:@selector(animateLabel:) userInfo:nil repeats:YES];
        [timer invalidate];
        
        gameStarted = false;
        gameOverState = true;
        
        [gameOverLabel setHidden:false];
        [pressPlayLabel setHidden:true];
        
        [c initLogicBoard];
        return;
    }
    
    //Play game status
    if(gameStarted){
        //Add a background image
        NSImage *image = [NSImage imageNamed:@"backgroundGame"];
        [image setSize:frame.size];
        
        backgroundColor = [NSColor colorWithPatternImage:image];
        [backgroundColor setFill];
        NSRectFill(dirtyRect);
        
        [timerLabels invalidate];
        [gameOverLabel setHidden:true];
        [pressPlayLabel setHidden:true];
        
        gameOverState = false;
         
        [self drawLogicBoard];
        [self drawTetrominoeWithType:[c getFigureType] row:[c getFigureRow] column:[c getFigureColumn] color:[c getFigureColor] rotation:[c getFigureRotation]];
        
        if([c getFigureRow] < [c getFigureRowDimension] || [c checkDownFigures] == false){
            [c blockFigureInLogicBoardAtRow:[c getCellValueWithRow:0 column:0] column:[c getCellValueWithRow:0 column:1] withType:[c getFigureType] withColor:[c getColorIndex]];
            [c blockFigureInLogicBoardAtRow:[c getCellValueWithRow:1 column:0] column:[c getCellValueWithRow:1 column:1] withType:[c getFigureType] withColor:[c getColorIndex]];
            [c blockFigureInLogicBoardAtRow:[c getCellValueWithRow:2 column:0] column:[c getCellValueWithRow:2 column:1] withType:[c getFigureType] withColor:[c getColorIndex]];
            [c blockFigureInLogicBoardAtRow:[c getCellValueWithRow:3 column:0] column:[c getCellValueWithRow:3 column:1] withType:[c getFigureType] withColor:[c getColorIndex]];
            
            [c checkRowCompletion];
            
            [c createNewFigure];
        }
    }
}



/**
 * @brief Método de necesaria implementación para hacer posible la captura de las teclas que pulse el usuario.
 * @return Parámetro de tipo booleano que retorna verdadero, indicando que se admite dicha captura.
 */
- (BOOL)acceptsFirstResponder{
    return YES;
}



/**
 * @brief Método de captura de teclas, necesario para gestionar la respuesta del usuario a lo visualizado en pantalla.
 *
 * Se obtiene el código asociado a la tecla pulsada y en caso de tratarse de una tecla de flecha, se efectúa la llamada correspondiente:
 * - Flecha arriba: rotación
 * - Flecha abajo: movimiento hacia abajo
 * - Flecha izquierda: movimiento a izquierda
 * - Flecha derecha: movimiento a derecha
 * Finalmente, se fuerza el redibujado de la vista.
 *
 * @param event Evento que contiene la información necesaria sobre la tecla pulsada por el jugador.
 */
- (void)keyDown:(NSEvent *)event{
    if(gameStarted){
        NSString* const character = [event charactersIgnoringModifiers];
        unichar const code = [character characterAtIndex:0];

        switch (code){
            case NSUpArrowFunctionKey: [c rotate]; break;
            case NSDownArrowFunctionKey: [c moveDown]; break;
            case NSLeftArrowFunctionKey: [c moveLeft]; break;
            case NSRightArrowFunctionKey: [c moveRight]; break;
        }

        [self setNeedsDisplay:YES];
    }
}



/**
 * @brief Método que devuelve un objeto de tipo rectángulo a partir de un valor de fila y columna.
 *
 * Se toman las dimensiones de la ventana y a partir de ellas se calculan las dimensiones de una celda particular, dividiendo el alto y ancho de la vista por el número de filas y columnas designadas, respectivamente. Obtenidas las dimensiones de la celda, se devuelve un rectángulo de esas mismas dimensiones, desplazado una distancia equivalente a la celda definida por el valor de fila y columna que se reciben como parámetros.
 *
 * @param row Valor de fila de la celda en cuestión.
 * @param column Valor de columna de la celda en cuestión.
 *
 * @return Rectángulo en la fila y columna especificada.
 */
- (NSRect)getRectAtRow:(NSInteger)row column:(NSInteger)column{
    NSRect frame = [self frame];
    
    //Setting the dimensions of a cell
    float cellHeight = frame.size.height / ROWS;
    float cellWidth = frame.size.width / COLUMNS;
    
    //Setting the position of the rectangle
    float r = row * cellHeight;
    float c = column * cellWidth;
    NSRect rect = NSMakeRect(c, r, cellWidth, cellHeight);
    
    NSAlignmentOptions alignOpts = NSAlignMinXNearest | NSAlignMinYNearest | NSAlignMaxXNearest | NSAlignMaxYNearest;
    
    return [self backingAlignedRect:rect options:alignOpts];
}



/**
 * @brief Método que proporciona relleno y trazo a un rectángulo obtenido a partir de su fila y columna
 *
 * Se obtiene el rectángulo a partir de la fila y columna especificadas. Se le asigna el color especificado y un trazo estándar de color negro.
 *
 * @param row Valor de fila del rectángulo en cuestión.
 * @param column Valor de columna del rectángulo en cuestión.
 * @param color Color para el rectángulo en cuestión.
 */
- (void)drawSimpleRectAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor *)color{
    //Drawing a simple square
    NSRect r = [self getRectAtRow:row column:column];
    
    [color set];
    [NSBezierPath fillRect:r];
    
    //Stroke for the square
    NSColor *strokeColor = [NSColor blackColor];
    [strokeColor set];
    [NSBezierPath strokeRect:r];
}



/**
 * @brief Método de dibujado del estado actual del tablero lógico sobre la vista principal.
 *
 * Se realiza un recorrido de la matriz que representa el estado del tablero y se obtiene el valor de cada celda para calcular en cada caso el tipo de figura que la ocupa y el color de la misma. Una vez obtenidos estos valores, se llama a la función que realiza el dibujado de la celda simple, obteniendo al final un dibujado completo de nuestro tablero.
 */
- (void)drawLogicBoard{
    int cellValue;
    int figType, figColorIndex;
    
    for (int i=0; i<ROWS; i++){
        for (int j=0; j<COLUMNS; j++){
            cellValue = [c getLogicBoardPositionWithRow:i column:j];
            
            if(cellValue != EMPTY_TYPE){
                figType = cellValue / 10;
                figColorIndex = cellValue % 10;
                
                NSColor *color = [c getColorWithColorIndex:figColorIndex];
                [self drawSimpleRectAtRow:i column:j withColor:color];
            }
        }
    }
}



/**
 * @brief Método que sirve de abstracción para el dibujado de una figura simple sobre la vista.
 *
 * @param type Define el tipo de figura que se va a dibujar.
 * @param row Valor de fila sobre la que se dibuja la figura.
 * @param column Valor de columna sobre la que se dibuja la figura.
 * @param color Define el color que se quiere asignar a la figura que está por dibujar.
 * @param rotation Define el valor de rotación de la figura que está por dibujar.
 */
- (void)drawTetrominoeWithType:(NSInteger)type row:(NSInteger)row column:(NSInteger)column color:(NSColor *)color rotation:(NSInteger)rotation{
    switch(type){
        case O_TYPE: [self draw_OTetrominoeAtRow:row column:column withColor:color]; break;
        case I_TYPE: [self draw_ITetrominoeAtRow:row column:column withColor:color rotation:rotation]; break;
        case L_TYPE: [self draw_LTetrominoeAtRow:row column:column withColor:color rotation:rotation]; break;
        case J_TYPE: [self draw_JTetrominoeAtRow:row column:column withColor:color rotation:rotation]; break;
        case Z_TYPE: [self draw_ZTetrominoeAtRow:row column:column withColor:color rotation:rotation]; break;
        case S_TYPE: [self draw_STetrominoeAtRow:row column:column withColor:color rotation:rotation]; break;
        case T_TYPE: [self draw_TTetrominoeAtRow:row column:column withColor:color rotation:rotation]; break;
    }
}



/**
 * @brief Método de dibujado de una figura de Clase O.
 *
 * Se llama  la función de dibujado de una celda simple para cada una de las cuatro celdas que componen la figura.
 * Posteriormente, se llena una matriz con los valores de fila y columna de cada una de las celdas que componen la figura actual, lo que nos servirá para conocer en todo momento qué fila y columna ocupan cada una de los cuatro rectángulos que forman parte de la figura activa.
 *
 * @param row Valor de fila a partir del cual se dibuja la figura en cuestión.
 * @param column Valor de columna a partir del cual se dibuja la figura en cuestión.
 * @param color Color para el dibujado de la figura.
 */
- (void)draw_OTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color{
    [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
    [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
    [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
    [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
    
    [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                 row1:(int)row-0 col1:(int)column+1
                                 row2:(int)row-1 col2:(int)column+0
                                 row3:(int)row-1 col3:(int)column+1];
}



/**
 * @brief Método de dibujado de una figura de Clase I.
 *
 * Se llama  la función de dibujado de una celda simple para cada una de las cuatro celdas que componen la figura y en función de la rotación establecida.
 * Posteriormente, se llena una matriz con los valores de fila y columna de cada una de las celdas que componen la figura actual, lo que nos servirá para conocer en todo momento qué fila y columna ocupan cada una de los cuatro rectángulos que forman parte de la figura activa.
 *
 * @param row Valor de fila a partir del cual se dibuja la figura en cuestión.
 * @param column Valor de columna a partir del cual se dibuja la figura en cuestión.
 * @param color Color para el dibujado de la figura.
 * @param rotation Valor de rotación para la figura en cuestión.
 */
- (void)draw_ITetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation{
    switch(rotation){
        case 0:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+2 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+3 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-0 col1:(int)column+1
                                         row2:(int)row-0 col2:(int)column+2
                                         row3:(int)row-0 col3:(int)column+3];
        break;
            
        case 90:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-3 column:column+0 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-1 col1:(int)column+0
                                         row2:(int)row-2 col2:(int)column+0
                                         row3:(int)row-3 col3:(int)column+0];
        break;
    }
}



/**
 * @brief Método de dibujado de una figura de Clase L.
 *
 * Se llama  la función de dibujado de una celda simple para cada una de las cuatro celdas que componen la figura y en función de la rotación establecida.
 * Posteriormente, se llena una matriz con los valores de fila y columna de cada una de las celdas que componen la figura actual, lo que nos servirá para conocer en todo momento qué fila y columna ocupan cada una de los cuatro rectángulos que forman parte de la figura activa.
 *
 * @param row Valor de fila a partir del cual se dibuja la figura en cuestión.
 * @param column Valor de columna a partir del cual se dibuja la figura en cuestión.
 * @param color Color para el dibujado de la figura.
 * @param rotation Valor de rotación para la figura en cuestión.
 */
- (void)draw_LTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation{
    switch(rotation){
        case 0:
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+2 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+2 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-1 col0:(int)column+0
                                         row1:(int)row-1 col1:(int)column+1
                                         row2:(int)row-1 col2:(int)column+2
                                         row3:(int)row-0 col3:(int)column+2];
        break;
        
        case 90:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+1 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-1 col1:(int)column+0
                                         row2:(int)row-2 col2:(int)column+0
                                         row3:(int)row-2 col3:(int)column+1];
        break;
            
        case 180:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+2 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-0 col1:(int)column+1
                                         row2:(int)row-0 col2:(int)column+2
                                         row3:(int)row-1 col3:(int)column+0];
        break;
            
        case 270:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+1 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-0 col1:(int)column+1
                                         row2:(int)row-1 col2:(int)column+1
                                         row3:(int)row-2 col3:(int)column+1];
        break;
    }
}



/**
 * @brief Método de dibujado de una figura de Clase J.
 *
 * Se llama  la función de dibujado de una celda simple para cada una de las cuatro celdas que componen la figura y en función de la rotación establecida.
 * Posteriormente, se llena una matriz con los valores de fila y columna de cada una de las celdas que componen la figura actual, lo que nos servirá para conocer en todo momento qué fila y columna ocupan cada una de los cuatro rectángulos que forman parte de la figura activa.
 *
 * @param row Valor de fila a partir del cual se dibuja la figura en cuestión.
 * @param column Valor de columna a partir del cual se dibuja la figura en cuestión.
 * @param color Color para el dibujado de la figura.
 * @param rotation Valor de rotación para la figura en cuestión.
 */
- (void)draw_JTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation{
    switch(rotation){
        case 0:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+2 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-1 col1:(int)column+0
                                         row2:(int)row-1 col2:(int)column+1
                                         row3:(int)row-1 col3:(int)column+2];
        break;
            
        case 90:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+0 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-0 col1:(int)column+1
                                         row2:(int)row-1 col2:(int)column+0
                                         row3:(int)row-2 col3:(int)column+0];
        break;
            
        case 180:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+2 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+2 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-0 col1:(int)column+1
                                         row2:(int)row-0 col2:(int)column+2
                                         row3:(int)row-1 col3:(int)column+2];
        break;
            
        case 270:
            [self drawSimpleRectAtRow:row-2 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-2 col0:(int)column+0
                                         row1:(int)row-2 col1:(int)column+1
                                         row2:(int)row-1 col2:(int)column+1
                                         row3:(int)row-0 col3:(int)column+1];
        break;
    }
}



/**
 * @brief Método de dibujado de una figura de Clase Z.
 *
 * Se llama  la función de dibujado de una celda simple para cada una de las cuatro celdas que componen la figura y en función de la rotación establecida.
 * Posteriormente, se llena una matriz con los valores de fila y columna de cada una de las celdas que componen la figura actual, lo que nos servirá para conocer en todo momento qué fila y columna ocupan cada una de los cuatro rectángulos que forman parte de la figura activa.
 *
 * @param row Valor de fila a partir del cual se dibuja la figura en cuestión.
 * @param column Valor de columna a partir del cual se dibuja la figura en cuestión.
 * @param color Color para el dibujado de la figura.
 * @param rotation Valor de rotación para la figura en cuestión.
 */
- (void)draw_ZTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation{
    switch(rotation){
        case 0:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+2 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-0 col1:(int)column+1
                                         row2:(int)row-1 col2:(int)column+1
                                         row3:(int)row-1 col3:(int)column+2];
        break;
        
        case 90:
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+0 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+1
                                         row1:(int)row-1 col1:(int)column+1
                                         row2:(int)row-1 col2:(int)column+0
                                         row3:(int)row-2 col3:(int)column+0];
        break;
    }
}



/**
 * @brief Método de dibujado de una figura de Clase S.
 *
 * Se llama  la función de dibujado de una celda simple para cada una de las cuatro celdas que componen la figura y en función de la rotación establecida.
 * Posteriormente, se llena una matriz con los valores de fila y columna de cada una de las celdas que componen la figura actual, lo que nos servirá para conocer en todo momento qué fila y columna ocupan cada una de los cuatro rectángulos que forman parte de la figura activa.
 *
 * @param row Valor de fila a partir del cual se dibuja la figura en cuestión.
 * @param column Valor de columna a partir del cual se dibuja la figura en cuestión.
 * @param color Color para el dibujado de la figura.
 * @param rotation Valor de rotación para la figura en cuestión.
 */
- (void)draw_STetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation{
    switch(rotation){
        case 0:
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+2 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+1
                                         row1:(int)row-0 col1:(int)column+2
                                         row2:(int)row-1 col2:(int)column+1
                                         row3:(int)row-1 col3:(int)column+0];
        break;
            
        case 90:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+1 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-1 col1:(int)column+0
                                         row2:(int)row-1 col2:(int)column+1
                                         row3:(int)row-2 col3:(int)column+1];
        break;
    }
}



/**
 * @brief Método de dibujado de una figura de Clase T.
 *
 * Se llama  la función de dibujado de una celda simple para cada una de las cuatro celdas que componen la figura y en función de la rotación establecida.
 * Posteriormente, se llena una matriz con los valores de fila y columna de cada una de las celdas que componen la figura actual, lo que nos servirá para conocer en todo momento qué fila y columna ocupan cada una de los cuatro rectángulos que forman parte de la figura activa.
 *
 * @param row Valor de fila a partir del cual se dibuja la figura en cuestión.
 * @param column Valor de columna a partir del cual se dibuja la figura en cuestión.
 * @param color Color para el dibujado de la figura.
 * @param rotation Valor de rotación para la figura en cuestión.
 */
- (void)draw_TTetrominoeAtRow:(NSInteger)row column:(NSInteger)column withColor:(NSColor*)color rotation:(NSInteger)rotation{
    switch(rotation){
        case 0:
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+2 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+1
                                         row1:(int)row-1 col1:(int)column+0
                                         row2:(int)row-1 col2:(int)column+1
                                         row3:(int)row-1 col3:(int)column+2];
        break;
            
        case 90:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-1 col1:(int)column+0
                                         row2:(int)row-2 col2:(int)column+0
                                         row3:(int)row-1 col3:(int)column+1];
        break;
            
        case 180:
            [self drawSimpleRectAtRow:row-0 column:column+0 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-0 column:column+2 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+0
                                         row1:(int)row-0 col1:(int)column+1
                                         row2:(int)row-0 col2:(int)column+2
                                         row3:(int)row-1 col3:(int)column+1];
        break;
            
        case 270:
            [self drawSimpleRectAtRow:row-0 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-2 column:column+1 withColor:color];
            [self drawSimpleRectAtRow:row-1 column:column+0 withColor:color];
            
            [c fillPositionsMatrixWithRow0:(int)row-0 col0:(int)column+1
                                         row1:(int)row-1 col1:(int)column+1
                                         row2:(int)row-2 col2:(int)column+1
                                         row3:(int)row-1 col3:(int)column+0];
        break;
    }
}


@end
