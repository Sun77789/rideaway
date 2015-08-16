//
//  SafetyViewController.m
//  HackThePlanet
//
//  Created by Joseph Milla on 8/15/15.
//  Copyright (c) 2015 MLH_Team. All rights reserved.
//

#import "SafetyViewController.h"
#import "SparkCoreConnector.h"
#import "SparkTransactionPost.h"
#import "SparkTransactionGet.h"

#define ACCESS_TOKEN @"2432dc921398e4a0b958b3b8a7262f5eba6a4458"
#define DEVICE_ID @"54ff6b066667515123381367"
#define FUNCTION @"led"
#define COUNT_VAR @"myvar"



#define greenLED1 @"D0"
#define greenLED2 @"D1"
#define yellowLED1 @"D2"
#define yellowLED2 @"D3"
#define redLED1 @"D4"
#define redLED2 @"D5"


#define STATE_HIGH @"HIGH"
#define STATE_LOW @"LOW"

@interface SafetyViewController ()

@end

@implementation SafetyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_led1Switch setOn:NO animated:YES];

    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
