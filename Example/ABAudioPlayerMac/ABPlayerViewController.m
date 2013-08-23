//
//  ABPlayerViewController.m
//  ABAudioPlayerApp
//
//  Created by Alexey Belkevich on 7/12/13.
//  Copyright (c) 2013 okolodev. All rights reserved.
//

#import "ABPlayerViewController.h"
#import "ABAudioPlayer.h"
#import "ABAudioMetadata.h"
#import "ABMacAudioPath.h"
#import "NSString+TimeInterval.h"

@interface ABPlayerViewController ()

@property (nonatomic, weak) NSTimer *timer;

@end

@implementation ABPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self)
    {
        player = [[ABAudioPlayer alloc] init];
        player.delegate = self;
        __weak ABPlayerViewController *weakSelf = self;
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
    !player.source ? [player playerPlaySource:kMacAudioPath] : [player playerStart];
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
    NSSlider *slider = sender;
    player.volume = slider.floatValue;
}

- (IBAction)panValueChanged:(id)sender
{
    NSSlider *slider = sender;
    player.pan = slider.floatValue;
}

#pragma mark - audio player delegate implementation

- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didChangeStatus:(ABAudioPlayerStatus)status
{
    [self.activity stopAnimation:self];
    switch (status)
    {
        case ABAudioPlayerStatusBuffering:
            [self.activity startAnimation:self];
            break;

        case ABAudioPlayerStatusError:
        case ABAudioPlayerStatusStopped:
            self.timeField.stringValue = @"";
            self.metadataText.string = @"";
            break;

        default:
            break;
    }
}

- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didFail:(NSError *)error
{
    NSString *message = [NSString stringWithFormat:@"Player failed with error:\n%@",
                                                   error.localizedDescription];
    NSAlert *alert = [NSAlert alertWithMessageText:message defaultButton:nil alternateButton:nil
                                       otherButton:nil informativeTextWithFormat:@""];
    [alert runModal];
    
}

- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didReceiveMetadata:(ABAudioMetadata *)metadata
{
    self.metadataText.string = [NSString stringWithFormat:@"%@\n%@\n(%@ / %@ - %@)\nGenre: %@\n"
                                                        "(%@)", metadata.title, metadata.artist,
                                                        metadata.track, metadata.album,
                                                        metadata.year, metadata.genre,
                                                        metadata.comments];
}

#pragma mark - private

- (void)updatePlayedTime:(id)sender
{
    NSString *time = [NSString stringWithTimeInterval:player.time];
    NSString *duration = [NSString stringWithTimeInterval:player.duration];
    self.timeField.stringValue = [NSString stringWithFormat:@"%@ / %@", time, duration];
}

@end
