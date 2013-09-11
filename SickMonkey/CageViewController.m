//
//  ViewController.m
//  SickMonkey
//
//  Created by Ivelin Ivanov on 9/10/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import "CageViewController.h"
#import "Monkey.h"

@interface CageViewController () {
    NSInteger cageSize;
    NSMutableArray *allMonkeys;
    Monkey *selectedMonkey;
    NSUInteger days;
}

@property (weak, nonatomic) IBOutlet UIView *cageView;
@property (weak, nonatomic) IBOutlet UIStepper *dayStepper;
@property (weak, nonatomic) IBOutlet UILabel *daysLabel;
@property (weak, nonatomic) IBOutlet UILabel *gridLabel;
@property (weak, nonatomic) IBOutlet UIStepper *gridStepper;

- (IBAction)startSimulationButtonPressed:(id)sender;
- (IBAction)resetSimulation:(id)sender;
- (IBAction)dayStepperChanged:(id)sender;
- (IBAction)gridStepperChanged:(id)sender;

@end

@implementation CageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    days = 1;
    cageSize = 5;
	
    [self buildCage];
}

#pragma mark - Monkey Handling Methods

- (void)selectIllMonkey:(UIGestureRecognizer *)recognizer {
    UIImageView *monkeyView = (UIImageView *)recognizer.view;
    
    if (selectedMonkey != nil) {
        selectedMonkey.monkeyView.layer.borderColor = [UIColor lightGrayColor].CGColor;
    }
    
    monkeyView.layer.borderColor = [UIColor redColor].CGColor;
    
    for (NSInteger i = 0; i < cageSize; i++) {
        for (NSInteger j = 0; j < cageSize; j++) {
            Monkey *monkey = allMonkeys[i][j];
            
            if ([monkey.monkeyView isEqual:monkeyView]) {
                selectedMonkey = monkey;
            }
        }
    }
    
    NSLog(@"%@", selectedMonkey);
}

#pragma mark - Cage View Building methods

- (void)getCageSize {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Select size of cage!"
                                                    message:@"The cage dimensions are N x N. Default value is 5."
                                                   delegate:self
                                          cancelButtonTitle:@"Select"
                                          otherButtonTitles:@"Default", nil];
    
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    [[alert textFieldAtIndex:0] setKeyboardType:UIKeyboardTypeNumberPad];
    
    [alert show];
}

- (void)buildCage {
    allMonkeys = [[NSMutableArray alloc] initWithCapacity:cageSize];
    
    CGFloat monkeySize = self.cageView.bounds.size.width / cageSize;
    
    CGFloat xOrigin = 0.0f;
    CGFloat yOrigin = 0.0f;
    
    NSUInteger monkeyCounter = 0;
    
    for (NSInteger i = 0; i < cageSize; i++) {
        
        NSMutableArray *rowOfMonkeys = [[NSMutableArray alloc] initWithCapacity:cageSize];
        
        for (NSInteger j = 0; j < cageSize; j++) {
            
            UIImageView *monkeyView = [[UIImageView alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, monkeySize, monkeySize)];
            monkeyView.image = [UIImage imageNamed:@"monkey.jpg"];
            monkeyView.contentMode = UIViewContentModeScaleAspectFit;
            
            monkeyView.layer.borderWidth = 2;
            monkeyView.layer.borderColor = [UIColor lightGrayColor].CGColor;
            
            UITapGestureRecognizer *tapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                            action:@selector(selectIllMonkey:)];
            tapRecognizer.numberOfTapsRequired = 1;
            tapRecognizer.numberOfTouchesRequired = 1;
            
            monkeyView.userInteractionEnabled = YES;
            
            monkeyView.tag = monkeyCounter;
            
            [monkeyView addGestureRecognizer:tapRecognizer];
            
            [self.cageView addSubview:monkeyView];
            
            Monkey *monkey = [[Monkey alloc] init];
            monkey.monkeyView = monkeyView;
            monkey.number = monkeyCounter;
            
            monkeyCounter ++;
            
            [rowOfMonkeys addObject:monkey];
            
            xOrigin += monkeySize;
        }
        
        [allMonkeys addObject:rowOfMonkeys];
        
        xOrigin = 0.0f;
        yOrigin += monkeySize;
    }
    
    NSLog(@"%@", allMonkeys);
    
    [self getMonkeyNeighbours];
}

- (void)getMonkeyNeighbours {
    for (NSInteger i = 0; i < cageSize; i++) {
        for (NSInteger j = 0; j < cageSize; j++) {
            NSMutableArray *neighbours = [[NSMutableArray alloc] init];

            if (j + 1 < cageSize) {
                [neighbours addObject:allMonkeys[i][j + 1]];
            }
            if (j - 1 >= 0) {
                [neighbours addObject:allMonkeys[i][j - 1]];
            }
            if (i + 1 < cageSize) {
                [neighbours addObject:allMonkeys[i + 1][j]];
            }
            if (i - 1 >= 0) {
                [neighbours addObject:allMonkeys[i - 1][j]];
            }
            if (i - 1 >= 0 && j - 1 >= 0) {
                [neighbours addObject:allMonkeys[i - 1][j - 1]];
            }
            if (i - 1 >= 0 && j + 1 < cageSize) {
                [neighbours addObject:allMonkeys[i - 1][j + 1]];
            }
            if (i + 1 < cageSize && j - 1 >= 0) {
                [neighbours addObject:allMonkeys[i + 1][j - 1]];
            }
            if (i + 1 < cageSize && j + 1 < cageSize) {
                [neighbours addObject:allMonkeys[i + 1][j + 1]];
            }
            
            NSLog(@"%@",neighbours);
            Monkey *monkey = allMonkeys[i][j];
            monkey.neighbours = neighbours;
        }
    }
}

#pragma mark - Simulation Methods

- (void)startSimulation {
    self.cageView.userInteractionEnabled = NO;
    
    NSMutableArray *illMonkeys = [[NSMutableArray alloc] init];
    NSMutableArray *contaminedMonkeys;
    NSMutableSet *deadMonkeys = [[NSMutableSet alloc] init];
    
    [illMonkeys addObject:selectedMonkey];
    
    for (NSInteger day = 0; day < days; day++) {
        
        contaminedMonkeys = [[NSMutableArray alloc] init];
        
        for (Monkey *illMonkey in illMonkeys) {
            
            for (Monkey *neighbourMonkey in illMonkey.neighbours) {
                if (![deadMonkeys containsObject:neighbourMonkey]) {
                    [contaminedMonkeys addObject:neighbourMonkey];
                }
            }
            
            [deadMonkeys addObject:illMonkey];
            
            illMonkey.monkeyView.image = [UIImage imageNamed:@"dead.png"];
        
        }
        
        illMonkeys = [contaminedMonkeys mutableCopy];
    }
}


- (IBAction)startSimulationButtonPressed:(id)sender {

    NSLog(@"Simulation started!");
    
    if (selectedMonkey == nil) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Cannot simulate!"
                                                        message:@"You have to choose ill monkey first!"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles: nil];
        [alert show];
    } else {
        [self startSimulation];
    }
}

- (void)reset {
    selectedMonkey = nil;
    self.cageView.userInteractionEnabled = YES;
    
    [[self.cageView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self buildCage];
}

- (IBAction)resetSimulation:(id)sender {
    [self reset];
}

- (IBAction)dayStepperChanged:(id)sender {
    days = (NSInteger)self.dayStepper.value;
    self.daysLabel.text = [NSString stringWithFormat:@"Days: %d", days];
}

- (IBAction)gridStepperChanged:(id)sender {
    cageSize = (NSInteger)self.gridStepper.value;
    self.gridLabel.text = [NSString stringWithFormat:@"Grid size: %d", cageSize];
    
    [self reset];
}

@end
