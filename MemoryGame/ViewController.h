//
//  ViewController.h
//  MemoryGame
//
//  Created by Brian Lewis on 5/9/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import "MatchDelegate.h"
#import "CardView.h"

@interface ViewController : UIViewController <MatchDelegate, AVAudioPlayerDelegate>

-(void)initialize;
-(void)matched;
-(void)notMatched;

@end
