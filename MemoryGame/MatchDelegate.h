//
//  MatchDelegate.h
//  MemoryGame
//
//  Created by Brian Lewis on 5/9/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CardView;

@protocol MatchDelegate <NSObject>

-(void)didSelectCard:(CardView *)cardView;

@end
