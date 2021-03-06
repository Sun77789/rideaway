//
//  AddFriendViewController.h
//  HackThePlanet
//
//  Created by Malika Aubakirova on 8/15/15.
//  Copyright (c) 2015 MLH_Team. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "kiss_fft.h"

@interface AddFriendViewController : UIViewController
@property (strong, nonatomic) IBOutlet UITextField *phoneNumber;
@property (strong, nonatomic) MKRoute *routeDetails;

@property (strong, nonatomic) NSString *src;
@property (strong, nonatomic) NSString *dst;
//com.htp.rideaway

@end
