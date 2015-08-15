//
//  PageContentViewController.h
//  HackThePlanet
//
//  Created by Malika Aubakirova on 8/15/15.
//  Copyright (c) 2015 MLH_Team. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PageContentViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *backImg;
@property NSUInteger pageIndex;
@property NSString *titleText;
@property NSString *imageFile;
- (IBAction)startUsing:(id)sender;
@property (strong, nonatomic) IBOutlet UIButton *startButton;

@end
