//
//  LoginViewController.h
//  HackThePlanet
//
//  Created by Malika Aubakirova on 8/14/15.
//  Copyright (c) 2015 MLH_Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PageContentViewController.h"

@interface LoginViewController : UIViewController <UIPageViewControllerDataSource>

@property (strong, nonatomic) UIPageViewController *pageViewController;
@property (strong, nonatomic) NSArray *pageTitles;
@property (strong, nonatomic) NSArray *pageImages;

@property (strong, nonatomic) NSString *src;
@property (strong, nonatomic) NSString *dst;

@end
