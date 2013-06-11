//
//  CardView.h
//  MemoryGame
//
//  Created by Brian Lewis on 5/9/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MatchDelegate.h"

@interface CardView : UIView

@property (strong, nonatomic) id<MatchDelegate> matchDelegate;
@property (strong, nonatomic) UIImageView *cardImageView; //common amongst all cards
@property (strong, nonatomic) UIImageView *itemImageView; //the hidden image that only one other card matches
@property BOOL matched;

@end
