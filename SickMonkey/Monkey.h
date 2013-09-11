//
//  Monkey.h
//  SickMonkey
//
//  Created by Ivelin Ivanov on 9/11/13.
//  Copyright (c) 2013 MentorMate. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Monkey : NSObject

@property (strong, nonatomic) UIImageView *monkeyView;
@property (copy, nonatomic) NSMutableArray *neighbours;
@property (assign, nonatomic) NSUInteger number;

@end
