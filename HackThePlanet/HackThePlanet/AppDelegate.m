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
    
    LoginViewController *controller = (LoginViewController *)self.window.rootViewController;
    //NSLog(@"PATHS: %@ %@", url.relativeString);
    
    NSString *temp2 = [[url.relativeString componentsSeparatedByString:@"://"][1]
                       stringByReplacingOccurrencesOfString:@"%E2%80%93" withString:@" "];
    NSString *temp = [temp2 stringByReplacingOccurrencesOfString:@"%E2%80%8E" withString:@" "];
    
    NSLog(@"PATHS: %@", temp);
    
    NSArray *listItems = [temp componentsSeparatedByString:@"?"];
    
    NSString *src = [listItems[0] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    NSString *dst = [listItems[01] stringByReplacingOccurrencesOfString:@"-" withString:@" "];
    
    [controller setSrc:src];
    [controller setDst:dst];
        
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

// You must free the result if result is non-NULL.
char *str_replace(char *orig, char *rep, char *with) {
    char *result; // the return string
    char *ins;    // the next insert point
    char *tmp;    // varies
    int len_rep;  // length of rep
    int len_with; // length of with
    int len_front; // distance between rep and end of last rep
    int count;    // number of replacements
    
    if (!orig)
        return NULL;
    if (!rep)
        rep = "";
    len_rep = strlen(rep);
    if (!with)
        with = "";
    len_with = strlen(with);
    
    ins = orig;
    for (count = 0; tmp = strstr(ins, rep); ++count) {
        ins = tmp + len_rep;
    }
    
    // first time through the loop, all the variable are set correctly
    // from here on,
    //    tmp points to the end of the result string
    //    ins points to the next occurrence of rep in orig
    //    orig points to the remainder of orig after "end of rep"
    tmp = result = malloc(strlen(orig) + (len_with - len_rep) * count + 1);
    
    if (!result)
        return NULL;
    
    while (count--) {
        ins = strstr(orig, rep);
        len_front = ins - orig;
        tmp = strncpy(tmp, orig, len_front) + len_front;
        tmp = strcpy(tmp, with) + len_with;
        orig += len_front + len_rep; // move to next "end of rep"
    }
    strcpy(tmp, orig);
    return result;
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
