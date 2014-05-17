//
//  SSDAppDelegate.m
//  SpotifySDKDemo
//
//  Created by Edwin van Beinum on 5/16/14.
//  Copyright (c) 2014 Ed van Beinum. All rights reserved.
//

#import <Spotify/Spotify.h>
#import "SSDAppDelegate.h"

static NSString * const kClientId = @"spotify-ios-sdk-beta";
static NSString * const kCallbackURL = @"spotify-ios-sdk-beta://callback";
static NSString * const kTokenSwapURL = @"http://localhost:1234/swap";

@interface SSDAppDelegate ()

@property (nonatomic, readwrite) SPTTrackPlayer *trackPlayer;

@end

@implementation SSDAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  // Create SPTAuth instance; create login URL and open it
  SPTAuth *auth = [SPTAuth defaultInstance];
  NSURL *loginURL = [auth loginURLForClientId:kClientId
                          declaredRedirectURL:[NSURL URLWithString:kCallbackURL]
                                       scopes:@[@"login"]];
  // Opening a URL in Safari close to application launch may trigger
  // an iOS bug, so we wait a bit before doing so.
  [application performSelector:@selector(openURL:)
                    withObject:loginURL afterDelay:0.1];
  return YES;
}

// Handle auth callback
-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
  
  // Ask SPTAuth if the URL given is a Spotify authentication callback
  if ([[SPTAuth defaultInstance] canHandleURL:url withDeclaredRedirectURL:[NSURL URLWithString:kCallbackURL]]) {
    
    // Call the token swap service to get a logged in session
    [[SPTAuth defaultInstance]
     handleAuthCallbackWithTriggeredAuthURL:url
     tokenSwapServiceEndpointAtURL:[NSURL URLWithString:kTokenSwapURL]
     callback:^(NSError *error, SPTSession *session) {
       
       if (error != nil) {
         NSLog(@"*** Auth error: %@", error);
         return;
       }
       
       // Call the -playUsingSession: method to play a track
       [self playUsingSession:session];
     }];
    return YES;
  }
  
  return NO;
}

-(void)playUsingSession:(SPTSession *)session {
  
  // Create a new track player if needed
  if (self.trackPlayer == nil) {
    self.trackPlayer = [[SPTTrackPlayer alloc] initWithCompanyName:@"MusicHackDay"
                                                           appName:@"spotify-sdk-demo"];
  }
  
  [self.trackPlayer enablePlaybackWithSession:session callback:^(NSError *error) {
    
    if (error != nil) {
      NSLog(@"*** Enabling playback got error: %@", error);
      return;
    }
    
    [SPTRequest requestItemAtURI:[NSURL URLWithString:@"spotify:album:4L1HDyfdGIkACuygktO7T7"]
                     withSession:nil
                        callback:^(NSError *error, SPTAlbum *album) {
                          
                          if (error != nil) {
                            NSLog(@"*** Album lookup got error %@", error);
                            return;
                          }
                          
                          [self.trackPlayer playTrackProvider:album];
                          
                        }];
  }];
  
}
@end
