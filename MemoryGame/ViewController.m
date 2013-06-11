//
//  ViewController.m
//  MemoryGame
//
//  Created by Brian Lewis on 5/9/13.
//  Copyright (c) 2013 Brian Lewis. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
{
    __weak IBOutlet UILabel *gameTextLabel;
    __weak IBOutlet UILabel *timerLabel;
    __weak IBOutlet UILabel *scoreLabel;
    __weak IBOutlet UILabel *highScoreLabel;
    __weak IBOutlet UIButton *pauseResumeButton;
    __weak IBOutlet UIButton *restartButton;
    
    NSMutableArray *selections;
    int matchCount;
    
    NSTimer *gameTimer;
    NSTimer *flipTimer;
    int seconds;
    BOOL paused;
    BOOL gameStarted;
    
    int score;
    int highScore;
    
    NSArray *itemImages;
    UIImage *cardImage;
    
    AVAudioPlayer *gameMusic;
    AVAudioPlayer *pauseSound;
    AVAudioPlayer *matchSound;
    AVAudioPlayer *winSound;
}

- (IBAction)restartButtonPressed:(id)sender;
- (IBAction)pauseResumeButtonPressed:(id)sender;

-(void)displayTime;
-(void)flipBack;
-(void)disableSelectionOfAllCards;
-(void)enableSelectionOfUnmatchedCards;

@end

@implementation ViewController
 

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
  
    //manually create all of the CardViews
    for (int y=0; y<4; y++) {
        for (int x=0; x<4; x++) {
            CGRect  viewRect = CGRectMake(23+70*x, 140+97*y, 63, 84);
            [self.view addSubview:[[CardView alloc] initWithFrame:viewRect]];
        }
    }
    
    //load images
    cardImage = [UIImage imageNamed:@"cardBack.png"];
    
    itemImages = [[NSArray alloc] initWithObjects:
                  [UIImage imageNamed:@"block.png"],
                  [UIImage imageNamed:@"blueFlower.png"],
                  [UIImage imageNamed:@"blueMushroom.png"],
                  [UIImage imageNamed:@"chomp.png"],
                  [UIImage imageNamed:@"coin.png"],
                  [UIImage imageNamed:@"flower.png"],
                  [UIImage imageNamed:@"goomba.png"],
                  [UIImage imageNamed:@"mushroom.png"], nil];

    
    //sounds
    NSBundle *bundle = [NSBundle mainBundle]; //allows you to access resources without knowing absolutle path 

    gameMusic = [[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"backgroundMusic" ofType:@"m4a"]] error:NULL];
    pauseSound = [[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"pause" ofType:@"wav"]] error:NULL];
    matchSound = [[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"powerup" ofType:@"wav"]] error:NULL];
    winSound = [[AVAudioPlayer alloc]initWithData:[NSData dataWithContentsOfFile:[bundle pathForResource:@"win" ofType:@"wav"]] error:NULL];
    gameMusic.delegate = self;
    
    highScore = 0;
    
    [self initialize];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.    
}

-(void)initialize //initialize is called every time a new game is about to begin, which is why it is separate from viewDidLoad
{
    matchCount = 0; //keeps track of the number of matches. When matchCount == 8 the game is over.
    score = 999;
    seconds = 0;
    
    gameTextLabel.text = @"Mario Memory Game";
    timerLabel.text = @"00:00";
    scoreLabel.text = @"Score: 999";
    [pauseResumeButton setTitle:@"Pause" forState:UIControlStateNormal];
    [restartButton setTitle:@"Restart" forState:UIControlStateNormal];
    
    paused = NO;
    gameStarted = NO;
    pauseResumeButton.userInteractionEnabled = NO; //can't pause the game until the game actually starts
    gameMusic.currentTime = 14;
    
    selections = [[NSMutableArray alloc] initWithCapacity:2]; //selections is used to track the 2 cards selected as a potential match

    NSMutableArray *tags = [[NSMutableArray alloc] init];
    int randomTag;
    int randomIndex;
    
    for (int i=0; i<16; i++) {
        [tags addObject:[NSNumber numberWithInt:i/2]]; //16 tags: [0,0,1,1,2,2...,7,7]
    }
        
    for (UIView * myView in self.view.subviews) {
        
        if ([myView isKindOfClass:[CardView class]]) { //go through all views and pick the ones that are CardViews
            
            randomIndex = arc4random() % tags.count; 
            randomTag = [tags[randomIndex] intValue]; //picking a random tag from the tag array
            [tags removeObjectAtIndex:randomIndex]; //remove it so it can't be selected for the next Card in the for loop
            myView.tag = randomTag;

            ((CardView*)myView).matchDelegate = self;
            ((CardView*)myView).matched = NO;
            myView.userInteractionEnabled = YES;
            
            //item subview
            ((CardView*)myView).itemImageView = [[UIImageView alloc] initWithImage:itemImages[myView.tag]]; //random tag used to assign hidden image
            [myView addSubview: ((CardView*)myView).itemImageView];
            
            //card subview
            ((CardView*)myView).cardImageView = [[UIImageView alloc] initWithImage:cardImage]; //every card has the same image on top
            [myView addSubview: ((CardView*)myView).cardImageView];
        }
    }
}

-(void)displayTime //called every second by gameTimer. Used to update the game clock
{
    seconds++;
    timerLabel.text = [NSString stringWithFormat:@"%02d:%02d",seconds/60,seconds%60];
    
    score--;
    scoreLabel.text = [NSString stringWithFormat:@"Score: %i", score];
}

-(void)didSelectCard:(CardView *)cardView
{
    if (!gameStarted) { //the game starts when the first card is flipped
        
        gameStarted = YES;
        gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
        pauseResumeButton.userInteractionEnabled = YES;
        [gameMusic play];
    }
    
    //animation to flip the card over
    [CardView transitionFromView:cardView.cardImageView toView:cardView.itemImageView duration:.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:NULL];
    
    if(selections.count == 0) //if this is the first card flipped in the pair of two
    {
        [selections addObject:cardView];
        gameTextLabel.text = @"";
    }
    else //this is the second card selected in the pair of two
    {
        [selections addObject:cardView];
        
        if ([selections[0] tag] == [selections[1] tag])
        {
            [self matched];
        }
        else{
            [self notMatched];
        }        
    }
}

-(void)matched
{
    matchCount++;
    gameTextLabel.text = @"Match!";
        
    if (matchCount == 8) { //the game is over
    
        gameTextLabel.text = @"You Win!";

        [restartButton setTitle:@"Play" forState:UIControlStateNormal];
        [gameMusic stop];
        [winSound play];
        [gameTimer invalidate];
        pauseResumeButton.userInteractionEnabled = NO;
        
        if (score > highScore) {
            highScore = score;
            highScoreLabel.text = [NSString stringWithFormat:@"High Score: %i", highScore];
        }
    }
    else {
        [matchSound play];
    }
    
    [selections[0] setMatched: YES];
    [selections[1] setMatched: YES];
    
    [selections removeAllObjects];
}

-(void)notMatched
{
    [self disableSelectionOfAllCards]; //disable all cards from being selected until the two selected cards flip back over
    
    flipTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(flipBack) userInfo:nil repeats:NO]; //cards stay visible for 1 second
    
    score -= 5;
    gameTextLabel.text = @"No Match";
}

-(void)flipBack
{
    [CardView transitionFromView:[selections[0] itemImageView] toView:[selections[0] cardImageView] duration:.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:NULL];
    [CardView transitionFromView:[selections[1] itemImageView] toView:[selections[1] cardImageView] duration:.5 options:UIViewAnimationOptionTransitionFlipFromRight completion:NULL];
    
    if (!paused) {
        [self enableSelectionOfUnmatchedCards]; //it's possible for flipBack to occur after pause has been pressed. Only enable selections if not paused
    }
    
    [selections removeAllObjects]; //game is ready to accept two new cards as potential matches. This MUST occur after the flipBack animations.
    
    gameTextLabel.text = @"";
}

-(void)disableSelectionOfAllCards
{
    for (UIView * myView in self.view.subviews) {
        if ([myView isKindOfClass:[CardView class]] && [(CardView*)myView matched] == NO) {
            myView.userInteractionEnabled = NO;         }
    }
}

-(void)enableSelectionOfUnmatchedCards
{
    for (UIView * myView in self.view.subviews) {
        if ([myView isKindOfClass:[CardView class]] && [(CardView*)myView matched] == NO) {
            myView.userInteractionEnabled = YES; //enable all cards who have not been matched yet (this is why the matched property was needed)
        }
    }
}

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    player.currentTime = 24.2;
    [player play];
}

- (IBAction)restartButtonPressed:(id)sender
{
    [flipTimer invalidate];
    [gameTimer invalidate];
    [gameMusic stop];
    [self initialize];
}

- (IBAction)pauseResumeButtonPressed:(id)sender
{
    if (!paused) {
        [gameTimer invalidate];
        [self disableSelectionOfAllCards];
        
        [pauseResumeButton setTitle:@"Resume" forState:UIControlStateNormal];
        gameTextLabel.text = @"Game Paused";
        
        [gameMusic stop];
        [pauseSound play];
    }
    else {
        gameTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(displayTime) userInfo:nil repeats:YES];
        [self enableSelectionOfUnmatchedCards];
        
        [pauseResumeButton setTitle:@"Pause" forState:UIControlStateNormal];
        gameTextLabel.text = @"";
        [gameMusic play];
    }
    
    paused = !paused;
}

@end
