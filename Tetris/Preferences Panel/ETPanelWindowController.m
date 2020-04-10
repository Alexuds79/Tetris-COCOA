//
//  ETPanelWindowController.m
//  Tetris
//
//  Created by Alejandro Mateos on 06/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file ETPanelWindowController.m
 * @Author Alejandro Mateos
 * @date 06/12/2019
 * @brief Clase controladora del panel de configuración y estado del juego. Controlling class of the configuration and game status panel.
 */

#import "ETPanelWindowController.h"

@implementation ETPanelWindowController
@synthesize statusTable, speedSlider;


/**
 * @brief Método de inicialización de la clase que representa el panel de preferencias.
 *
 * Se instancia la tabla de estado de juego, se recibe la instancia compartida de la figura actual y se obtiene el vector de figuras generadas. Se registran observadores para las notificaciones de actualización de tabla, comienzo y final de juego.
 *
 * @return Objeto de tipo id, que representa a la propia clase.
 */
- (id)init{
    if(![super initWithWindowNibName:@"PreferencesPanel"]){
        return nil;
    }
    
    statusTable = [[NSTableView alloc] init];
    
    generatedFigures = [c getGeneratedFigures];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"UpdateTable" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"PlayGame" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(receiveNotification:) name:@"GameOver" object:nil];
    
    return self;
}



/**
 * @brief Método de inicialización de la vista previo a la inicialización del controlador de la misma. En nuestro caso, no se hace nada aquí.
 */
- (void)windowDidLoad {
    [super windowDidLoad];
    
    // Implement this method to handle any initialization after your window controller's window has been loaded from its nib file.
}



/**
 * @brief Método de captura de las notificaciones observadas.
 *
 * Si la notificación es de actualización de tabla: Se llama al método que lleva a efecto la actualización.
 * Si la notificación es de comienzo de juego: Se limpia el vector de figuras y la tabla se redibuja vacía.
 * Si la notificación es de final de juego: El slider de velocidad del panel se coloca a valor inicial.
 *
 * @param aNotification Objeto que contiene toda la información necesaria para gestionar la notificación.
 */
- (void)receiveNotification:(NSNotification*)aNotification{
    if([[aNotification name] isEqualToString:@"UpdateTable"]){
        [self updateTable];
    }
    
    if([[aNotification name] isEqualToString:@"PlayGame"]){
        [generatedFigures removeAllObjects];
        [statusTable reloadData];
    }
    
    if([[aNotification name] isEqualToString:@"GameOver"]){
        [self setSliderValue:[speedSlider minValue]];
    }
}



/**
 * @brief Método para la actualización de la información ofrecida en la tabla del panel.
 *
 * Se obtiene el vector de figuras y se refresca la tabla. Posteriormente, se hace lo propio llamando a actualizar con la última fila para cambiar el color de la misma al de la figura actual. Finalmente, se posiciona el scroll en  la parte inferior.
 */
- (void)updateTable{
    c = [GameController sharedController];
    generatedFigures = [c getGeneratedFigures];
    [statusTable reloadData];
    
    int index = (int)[generatedFigures indexOfObject:[generatedFigures lastObject]];
    [statusTable reloadDataForRowIndexes:[NSIndexSet indexSetWithIndex:index]
                           columnIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, [statusTable numberOfColumns])]];
    
    
    [statusTable scrollRowToVisible:[generatedFigures indexOfObject:[generatedFigures lastObject]]];
}



/**
 * @brief Método del protocolo del delegado de la tabla.
 *
 * En función del nombre de la columna se muestra la información correspondiente y posteriormente se realizan gestiones para visualizar correctamente el color de fondo de cada celda.
 *
 * @param tableView Parámetro que identifica la tabla del panel.
 * @param tableColumn Columna que se actualiza llamando al presente método.
 * @param row Fila que se actualiza llamando al presente método.
 *
 * @return La celda que se actualiza con el nuevo formato y contenido.
 */
-(NSView *)tableView:(NSTableView *)tableView viewForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    
    NSString *title = [tableColumn title];
    NSString *identifier = [tableColumn identifier];
    NSTableCellView *cell = [tableView makeViewWithIdentifier:identifier owner:self];
    
    NSArray *aFigure = [generatedFigures objectAtIndex:row];
    
    if ([title isEqualToString:@"Name"]) {
        cell.textField.stringValue = [aFigure objectAtIndex:0];
    }
    
    if ([title isEqualToString:@"Row"]) {
        cell.textField.stringValue = [aFigure objectAtIndex:1];
    }
    
    if ([title isEqualToString:@"Column"]) {
        cell.textField.stringValue = [aFigure objectAtIndex:2];
    }
    
    if ([title isEqualToString:@"Color"]) {
        cell.textField.stringValue = [aFigure objectAtIndex:3];
    }
    
    if ([title isEqualToString:@"Rotation"]) {
        cell.textField.stringValue = [aFigure objectAtIndex:4];
    }
    
    if(row == [generatedFigures indexOfObject:[generatedFigures lastObject]]){
        if([c getFigureColor] == [NSColor redColor]) cell.textField.textColor = [NSColor whiteColor];
        if([c getFigureColor] == [NSColor greenColor]) cell.textField.textColor = [NSColor blackColor];
        if([c getFigureColor] == [NSColor yellowColor]) cell.textField.textColor = [NSColor blackColor];
        if([c getFigureColor] == [NSColor blueColor]) cell.textField.textColor = [NSColor whiteColor];
        if([c getFigureColor] == [NSColor purpleColor]) cell.textField.textColor = [NSColor whiteColor];
        if([c getFigureColor] == [NSColor orangeColor]) cell.textField.textColor = [NSColor whiteColor];
        if([c getFigureColor] == [NSColor systemPinkColor]) cell.textField.textColor = [NSColor whiteColor];
        if([c getFigureColor] == [NSColor cyanColor]) cell.textField.textColor = [NSColor blackColor];
        
        cell.layer.backgroundColor = [c getFigureColor].CGColor;
    }
    else{
        NSArray *features = [generatedFigures objectAtIndex:row];
        NSString *colorStr = [features objectAtIndex:3];
        NSColor *c;
        
        if([colorStr isEqualToString:@"Red"]) c = [NSColor redColor];
        if([colorStr isEqualToString:@"Green"]) c = [NSColor greenColor];
        if([colorStr isEqualToString:@"Yellow"]) c = [NSColor yellowColor];
        if([colorStr isEqualToString:@"Blue"]) c = [NSColor blueColor];
        if([colorStr isEqualToString:@"Purple"]) c = [NSColor purpleColor];
        if([colorStr isEqualToString:@"Cyan"]) c = [NSColor cyanColor];
        if([colorStr isEqualToString:@"Orange"]) c = [NSColor orangeColor];
        if([colorStr isEqualToString:@"Pink"]) c = [NSColor systemPinkColor];
        
        cell.layer.backgroundColor = c.CGColor;
        
        if(c == [NSColor redColor]) cell.textField.textColor = [NSColor whiteColor];
        if(c == [NSColor greenColor]) cell.textField.textColor = [NSColor blackColor];
        if(c == [NSColor yellowColor]) cell.textField.textColor = [NSColor blackColor];
        if(c == [NSColor blueColor]) cell.textField.textColor = [NSColor whiteColor];
        if(c == [NSColor purpleColor]) cell.textField.textColor = [NSColor whiteColor];
        if(c == [NSColor orangeColor]) cell.textField.textColor = [NSColor whiteColor];
        if(c == [NSColor systemPinkColor]) cell.textField.textColor = [NSColor whiteColor];
        if(c == [NSColor cyanColor]) cell.textField.textColor = [NSColor blackColor];
        
    }
    
    return cell;
}

//Table datasource method protocol

/**
 * @brief Método del protocolo de la fuente de datos (DataSource) de la tabla.
 *
 * @param tableView Parámetro que identifica la tabla que se actualiza.
 *
 * @return Número de filas del vector de figuras asociado a la tabla, lo que definirá el número de filas que componen la misma.
 */
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView{
    return [generatedFigures count];
}



/**
 * @brief Método asociado al slider del panel, que lanza una notificación cada vez que cambia el valor del mismo. El movimiento del slider se ha discretizado.
 *
 * @param sender Objeto que identifica al slider que lanza el método.
 */
- (IBAction)sliderChanged:(id)sender{
   
    //Set discrete values
    int sliderValue;
    sliderValue = (int)lroundf([sender floatValue]);
    [speedSlider setIntValue:sliderValue];
    
    //Set speed
    int speed = [sender intValue];
    [c setSpeed:speed];
}



/**
 * @brief Método asociado al comportamiento de los botones de cambio de color del panel.
 *
 * Se recibe el título del botón para identificar el color a asociar a la figura, y una vez detectado, se lanzan las notificaciones para establecer el nuevo color y actualizar la tabla del panel.
 *
 * @param sender Objeto que identifica al botón responsable de la acción.
 */
- (IBAction)changeColor:(nullable id)sender{
    NSColor *color;
    int colorIndex=0;
    
    if([[sender title] isEqualToString:@"Red"]){color = [NSColor redColor]; colorIndex=0; }
    if([[sender title] isEqualToString:@"Green"]){color = [NSColor greenColor]; colorIndex=1; }
    if([[sender title] isEqualToString:@"Yellow"]){color = [NSColor yellowColor]; colorIndex=2; }
    if([[sender title] isEqualToString:@"Cyan"]){color = [NSColor cyanColor]; colorIndex=7; }
    if([[sender title] isEqualToString:@"Pink"]){color = [NSColor systemPinkColor]; colorIndex=6; }
    if([[sender title] isEqualToString:@"Orange"]){ color = [NSColor orangeColor]; colorIndex=5; }
    
    [c setColor:color withIndex:colorIndex withName:[sender title]];
    [self updateTable];
}



/**
 * @brief Método vinculado al comportamiento de los botones de cambio del tipo de la figura activa.
 *
 * Se recibe el tag del sender para identificar el ordinal del botón que ha lanzado la notificación, y en función de este número se reconoce el tipo, que se envía con la notificación correspondiente. También se notifica la orden de actualizar la tabla del propio panel.
 *
 * @param sender Objeto que identifica al botón responsable de la acción.
 */
- (IBAction)changeType:(id)sender{
    int type = (int)[sender tag];

    [c setType:type];
    [self updateTable];
}



/**
 * @brief Método para establecer un valor al slider del panel.
 *
 * @param value Valor que se debe asignar al slider.
 */
- (void)setSliderValue:(int)value{
    [speedSlider setIntValue:value];
}

@end
