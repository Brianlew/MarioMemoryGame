//
//  CardView.m
//  MemoryGame
//
//  Created by Brian Lewis on 5/9/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "CardView.h"
#import <QuartzCore/QuartzCore.h>

@implementation CardView

@synthesize itemImageView, cardImageView, matched;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.layer.cornerRadius = 5;
        self.clipsToBounds = YES;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.userInteractionEnabled == YES) { //if a card has not been matched yet
        self.userInteractionEnabled = NO; //disable it from being selected again until it has been compared to the potential match
        [self.matchDelegate didSelectCard:self];
    }
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
