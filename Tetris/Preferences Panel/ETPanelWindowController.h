//
//  ETPanelWindowController.h
//  Tetris
//
//  Created by Alejandro Mateos on 06/12/2019.
//  Copyright © 2019 Alejandro Mateos. All rights reserved.
//

/**
 * @file ETPanelWindowController.h
 * @Author Alejandro Mateos
 * @date 06/12/2019
 * @brief Fichero de cabecera para el gestor del panel de preferencias. Header file for the preferences panel manager.
 */

#import <Cocoa/Cocoa.h>
#import "GameController.h"

NS_ASSUME_NONNULL_BEGIN

@class GameController;
@interface ETPanelWindowController : NSWindowController<NSWindowDelegate, NSTableViewDelegate, NSTableViewDataSource>{
    IBOutlet NSTableView *statusTable;
    NSMutableArray *generatedFigures;
    GameController *c;
    
    IBOutlet NSSlider *speedSlider;
}

@property (nonatomic, retain) NSTableView *statusTable;
@property (strong, nonatomic) IBOutlet NSSlider *speedSlider;

- (IBAction)sliderChanged:(id)sender;
- (IBAction)changeColor:(nullable id)sender;
- (IBAction)changeType:(id)sender;
- (void)setSliderValue:(int)value;
- (void)updateTable;

@end

NS_ASSUME_NONNULL_END
