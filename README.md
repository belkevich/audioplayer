ABAudioPlayer
=======

## About
ABAudioPlayer is lightweight and extensible wrapper on `AudioToolbox.framework` for iOS and OS X. **Project is still in develop** but you can use master branch. It's stable.

---

## Using
#### Player actions
###### Create player
```objective-c
ABAudioPlayer *player = [[ABAudioPlayer alloc] initWithAudioPlayerDelegate:self];
```

---

###### Open audio file and play it
```objective-c
[player playerPlaySource:pathToMyAudioFile];
```

---

###### Stop playing
```objective-c
[player playerStop];
```

---

###### Pause
```objective-c
[player playerPause];
```

---

###### Continue playback
```objective-c
[player playerPlay];
```

---

#### Track player events
Player delegate should implement required methods of `ABAudioPlayerDelegate` protocol
###### Receive player status changes
```objective-c
- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didChangeStatus:(ABAudioPlayerStatus)status
{
    switch (status)
    {
        case ABAudioPlayerStatusBuffering:
            // audio is buffering
            // show buffering activity
            break;

        case ABAudioPlayerStatusPlaying:
            // audio is playing
            // hide buffering activity
            break;

        case ABAudioPlayerStatusPaused:
            // audio is paused
            // highlight pause button
            break;

        case ABAudioPlayerStatusStopped:
            // audio is stopped
            break;

        default:
            break;
    }
}
```

---

###### Receive player error
```objective-c
- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didFail:(NSError *)error
{
    // show error
}
```

---

#### Playback tuning
###### Volume
Player volume should be between 0.0 (mute) and 1.0 (max volume)
```objective-c
player.volume = 1.f;
```

---

###### Pan
Player pan should be between -1.0 (left) and 1.0 (right). Value 0.0 is center.
```objective-c
player.pan = 0.f;
``` 

---

#### Playback time
###### Current time
```objective-c
NSTimeInterval time = player.time;
```

---

###### Duration
```objective-c
NSTimeInterval duration = player.duration;
```

---

#### Audio metadata
Player delegate should implement optional method `audioPlayer:didReceiveMetadata:` of `ABAudioPlayerDelegate` protocol
```objective-c
- (void)audioPlayer:(ABAudioPlayer *)audioPlayer didReceiveMetadata:(ABAudioMetadata *)metadata
{
    NSString *trackTitle = metadata.title;
    NSString *trackArtist = metadata.artist;
    NSString *trackAlbum = metadata.album;
    NSNumber *trackNumber = metadata.track;
    NSNumber *trackYear = metadata.year;
    NSString *trackGenre = metadata.genre;
    NSString *trackComments = metadata.comments;
    UIImage *trackArtwork = metadata.artwork;
}
```

---

#### Current audio file
```objective-c
NSString *path = player.source;
```

---
