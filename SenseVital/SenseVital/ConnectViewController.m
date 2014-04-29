//
//  ConnectViewController.m
//  SenseVital
//
//  Created by Pim Nijdam on 22/04/14.
//  Copyright (c) 2014 Sense Observation Systems BV. All rights reserved.
//

#import "ConnectViewController.h"
#import <MediaPlayer/MediaPlayer.h>

@interface ConnectViewController ()

@end

@implementation ConnectViewController {
    MPMoviePlayerController* moviePlayer;
    UIImageView* thumbnailView;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //NSString* pathToImageFile = [[NSBundle mainBundle] pathForResource:@"Background" ofType:@"png"];
    //UIImage* bgImage = [UIImage imageWithContentsOfFile:pathToImageFile];
    //[self.view setBackgroundColor:[UIColor colorWithPatternImage:bgImage]];
    
    //movieplayer initialization
    NSString *path = [[NSBundle mainBundle] pathForResource:@"instruction" ofType:@"mp4"];
    NSURL *videoURL = [NSURL fileURLWithPath:path];
    moviePlayer = [[MPMoviePlayerController alloc] initWithContentURL:videoURL];
    moviePlayer.controlStyle = MPMovieControlStyleEmbedded;
    moviePlayer.shouldAutoplay = NO;
    
    [moviePlayer.view setFrame: self.videoView.bounds];
    [self.videoView addSubview: moviePlayer.view];
    
    
    //Add thumbnail image
    //UIImage *thumbnail = [moviePlayer thumbnailImageAtTime:10.0
    //                                            timeOption:MPMovieTimeOptionNearestKeyFrame];
    NSString *thumbnailPath = [[NSBundle mainBundle] pathForResource:@"videothumb" ofType:@"png"];
    
    thumbnailView = [[UIImageView alloc] initWithImage:[UIImage imageWithContentsOfFile:thumbnailPath]];
    thumbnailView.userInteractionEnabled = YES;
//    thumbnailView.frame = moviePlayer.view.frame;
    [thumbnailView setFrame:self.videoView.bounds];
    [self.videoView addSubview:thumbnailView];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTap:)];
    tap.numberOfTapsRequired = 1;
    [thumbnailView addGestureRecognizer:tap];
}


- (void)handleTap:(UITapGestureRecognizer *)gesture{
    thumbnailView.hidden = YES;
    [moviePlayer play];
}

- (void) viewWillAppear:(BOOL)animated {
    [moviePlayer prepareToPlay];
}

- (void) viewWillDisappear:(BOOL)animated {
    [moviePlayer pause ];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//Only support Portrait
- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation
{
    return UIInterfaceOrientationPortrait;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
