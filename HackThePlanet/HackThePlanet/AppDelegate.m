//
//  AppDelegate.m
//  HackThePlanet
//
//  Created by Malika Aubakirova on 8/14/15.
//  Copyright (c) 2015 MLH_Team. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import "LoginViewController.h"
#import "ViewController.h"

#import <string.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    // Initialize Parse.
    [Parse setApplicationId:@"0GgSojokFNkQJi5HWFANFAlyqU9ZWe87UgZglQUH"
                  clientKey:@"Eem0mGbiWXnuFYrkdbFGmYgtvLXUkIXMoI75nzXM"];
    // Check if user is cached and linked to Facebook, if so, bypass login
    
    [PFUser enableAutomaticUser];
    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        // this will output second and have a username and object id.
        PFUser *user = [PFUser currentUser];
        user[@"name"] = @"Malika Aubakirova";
        user[@"email"] = @"test@rideaway.com";
        user[@"shared"] = @"0";
        [user saveInBackground];
    }];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    
    NSString *temp2 = [[url.relativeString componentsSeparatedByString:@"://"][1]
                       stringByReplacingOccurrencesOfString:@"%E2%80%93" withString:@" "];
    NSString *temp = [temp2 stringByReplacingOccurrencesOfString:@"%E2%80%8E" withString:@" "];
    
    NSLog(@"PATHS: %@", temp);
    
    NSArray *listItems = [temp componentsSeparatedByString:@"?"];
    
    NSString *src = [listItems[0] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    NSString *dst = [listItems[01] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
        
        PFUser *user = [PFUser currentUser];
        user[@"url"] = @"true";
        user[@"src"] = src;
        user[@"dst"] = dst;
        [user saveInBackground];
    
    ViewController *viewController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"mainView"]; //or the homeController
    UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:viewController];
    self.window.rootViewController=navController;
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
