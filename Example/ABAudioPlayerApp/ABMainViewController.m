//
//  ABMainViewController.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/11/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABMainViewController.h"
#import "ABAudioPlayer.h"
#import "ABAudioMetadata.h"
#import "NSString+TimeInterval.h"
#import "ABIOSAudioPath.h"

@interface ABMainViewController ()

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ABMainViewController

#pragma mark - main routine

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        player = [[ABAudioPlayer alloc] init];
        player.delegate = self;
        __weak ABMainViewController *weakSelf = self;
        self.timer = [NSTimer scheduledTimerWithTimeInterval:1.f target:weakSelf
                                                    selector:@selector(updatePlayedTime:)
                                                    userInfo:nil repeats:YES];
    }
    return self;
}

- (void)dealloc
{
    [self.timer invalidate];
}

#pragma mark - actions

- (IBAction)playButtonPressed:(id)sender
{
    if (!player.source)
    {
        NSString *path = kIOSAudioPath;//[[NSBundle mainBundle] pathForResource:kIOSAudioPath ofType:nil];
        NSLog(@"Audio file bundle path:\n%@", path);
        [player playerPlaySource:kIOSAudioPath];
    }
    else
    {
        [player playerStart];
    }
}

- (IBAction)pauseButtonPressed:(id)sender
{
    [player playerPause];
}

- (IBAction)stopButtonPressed:(id)sender
{
    [player playerStop];
}

- (IBAction)volumeValueChanged:(id)sender
{
    UISlider *slider = sender;
    player.volume = slider.value;
}

- (IBAction)panValueChanged:(id)sender
{
    UISlider *slider = sender;
    player.pan = slider.value;
}

#pragma mark - audio player delegate implementation

- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didChangeStatus:(ABAudioPlayerStatus)status
{
    [self.activity stopAnimating];
    switch (status)
    {
        case ABAudioPlayerStatusBuffering:
            [self.activity startAnimating];
            break;

        case ABAudioPlayerStatusError:
        case ABAudioPlayerStatusStopped:
            self.timeField.text = nil;
            self.metadataText.text = nil;
            self.artworkImage.image = nil;
            break;

        default:
            break;
    }
}

- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didFail:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"Player failed with error:\n%@",
                                                   error.localizedDescription];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:nil message:message delegate:nil
                                          cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
}

- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didReceiveMetadata:(ABAudioMetadata *)metadata
{
    self.metadataText.text = [NSString stringWithFormat:@"%@\n%@\n(%@ / %@ - %@)\nGenre: %@\n"
                                                        "(%@)", metadata.title, metadata.artist,
                                                        metadata.track, metadata.album,
                                                        metadata.year, metadata.genre,
                                                        metadata.comments];
    self.artworkImage.image = metadata.artwork;
}

#pragma mark - private

- (void)updatePlayedTime:(id)sender
{
    NSString *time = [NSString stringWithTimeInterval:player.time];
    NSString *duration = [NSString stringWithTimeInterval:player.duration];
    self.timeField.text = [NSString stringWithFormat:@"%@ / %@", time, duration];
}

@end
