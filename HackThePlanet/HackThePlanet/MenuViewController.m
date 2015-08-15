//
//  MenuViewController.m
//  HackThePlanet
//
//  Created by Malika Aubakirova on 8/15/15.
//  Copyright (c) 2015 MLH_Team. All rights reserved.
//

#import "MenuViewController.h"

@interface MenuViewController ()

@end

@implementation MenuViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.rideawayButton setImage:[UIImage imageNamed:@"ride-tap.png"]
                forState:UIControlStateSelected];
    [self.rideawayButton setImage:[UIImage imageNamed:@"ride.png"]
                forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)actionEnter:(id)sender{
    UIButton *button = (UIButton *)sender;
    button.selected = !button.selected;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
