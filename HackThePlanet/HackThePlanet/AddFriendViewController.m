//
//  AddFriendViewController.m
//  HackThePlanet
//
//  Created by Malika Aubakirova on 8/15/15.
//  Copyright (c) 2015 MLH_Team. All rights reserved.
//

#import "AddFriendViewController.h"
#import <Parse/Parse.h>

@interface AddFriendViewController ()

@end

@implementation AddFriendViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)inviteAFriend:(id)sender {
    PFUser *user = [PFUser currentUser];
    user[@"friendPhoneNumber"] = self.phoneNumber.text;
    [user saveInBackground];
    
    NSString *name = @"Malika Aubakirova";
    NSString *temp = @"Malika is inviting you to take a ride. Please, visit Rideaway at link";
    NSString *app = [NSString stringWithFormat:@"rideaway://%@?%@",  self.src, self.dst];
    
    NSString *msg = [NSString stringWithFormat:@"%@ %@", temp, app];
    
    [PFCloud callFunctionInBackground:@"SMS"
                       withParameters:@{
                                        @"fromName": name,
                                        @"toNum": self.phoneNumber.text,
                                        @"msg": temp,
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (error) {
                                        NSLog(@"ERROR: %@",error);
                                    } else {
                                        NSLog(@"%@", result);
                                    }
                                }];
    [PFCloud callFunctionInBackground:@"MMS"
                       withParameters:@{
                                        @"fromName": name,
                                        @"toNum": self.phoneNumber.text,
                                        @"msg": app,
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (error) {
                                        NSLog(@"ERROR: %@",error);
                                    } else {
                                        NSLog(@"%@", app);
                                    }
                                }];
    
}


- (void) SendSMS:(NSString *)num away:(NSString *)miles{
    NSString *name = @"Malika Aubakirova";
        [PFCloud callFunctionInBackground:@"SMS"
                           withParameters:@{
                                            @"fromName": name,
                                            @"toNum": @"3122135143",
                                            @"miles": miles,
                                            }
                                    block:^(NSString *result, NSError *error) {
                                        if (error) {
                                            NSLog(@"ERROR: %@",error);
                                        } else {
                                            NSLog(@"%@", result);
                                        }
                                    }];
}

NSArray *generateOrderedMeetingPoints(CLLocation *myLocation, CLLocation *yourLocation, MKMapPoint destination){
    MKMapPoint myMapPoint=MKMapPointForCoordinate([myLocation coordinate]);
    MKMapPoint yourMapPoint=MKMapPointForCoordinate([myLocation coordinate]);
    
    
    MKMapPoint vec1, vec2, projection, centroid;
    vec1.x=destination.x-myMapPoint.x;
    vec1.y=destination.y-myMapPoint.y;
    
    vec2.x=yourMapPoint.x-myMapPoint.x;
    vec2.y=yourMapPoint.y-myMapPoint.y;
    
    projection.x=(vec1.x*vec2.x+vec1.y*vec2.y)*vec2.x;
    projection.y=(vec1.x*vec2.x+vec1.y*vec2.y)*vec2.y;
    
    
    centroid.x=(myMapPoint.x+yourMapPoint.x+destination.x)/3;
    centroid.y=(myMapPoint.y+yourMapPoint.y+destination.y)/3;
    
    
    MKMapRect searchArea;
    
    
    double searchStep=100;
    searchArea.origin.x=centroid.x-searchStep/2;
    searchArea.origin.y=centroid.y-searchStep/2;
    
    searchArea.size.width=searchStep;
    searchArea.size.height=searchStep;
    
    
    
    MKCoordinateRegion meetingPointSearchRegion=MKCoordinateRegionForMapRect(searchArea);
    
    MKLocalSearchRequest *requestForAMeetingPoint=[[MKLocalSearchRequest alloc]init];
    
    
    requestForAMeetingPoint.naturalLanguageQuery=@"points of interest";
    requestForAMeetingPoint.region=meetingPointSearchRegion;
    
    MKLocalSearch *findMeetingPoint=[[MKLocalSearch alloc]initWithRequest:requestForAMeetingPoint];
    
    
    NSMutableArray *responseArray;
    
    
    MKLocalSearchCompletionHandler completionHandler=^(MKLocalSearchResponse *response, NSError *error){
        
        if(error!=nil){
            return;
        } else{
            [responseArray initWithArray:response.mapItems];
            
        }
        
    };
    
    [findMeetingPoint startWithCompletionHandler:completionHandler];
    
    
    
    [responseArray sortUsingComparator:^NSComparisonResult(id a, id b){
        
        CLLocation *l1=[[(MKMapItem *)a placemark] location];
        CLLocation *l2=[[(MKMapItem *)b placemark] location];
        
        MKMapPoint p1=MKMapPointForCoordinate(l1.coordinate);
        MKMapPoint p2=MKMapPointForCoordinate(l2.coordinate);
        
        
        double dist1=sqrt(pow(p1.x-centroid.x,2)+pow(p1.y-centroid.y,2));
        double dist2=sqrt(pow(p2.x-centroid.x,2)+pow(p2.y-centroid.y,2));
        
        if(dist1<dist2){
            return NSOrderedAscending;
        } else if (dist1>dist2){
            return NSOrderedDescending;
        } else{
            
            return NSOrderedSame;
        }
        
    }];
    
    NSArray *result=[responseArray copy];
    
    
    return result;
    
}

NSString *createURLWithCompressedRouteInfo(MKRoute *route){
    int i=0;
    
    
    MKPolyline *pline=[route polyline];
    
    int numPoints=[pline pointCount];
    
    
    NSRange range=NSMakeRange(0, numPoints);
    
    
    
    CLLocationCoordinate2D *points=malloc(numPoints*sizeof(CLLocationCoordinate2D));
    
    
    [pline getCoordinates:points range:range];
    
    CLLocationCoordinate2D start=points[0];
    CLLocationCoordinate2D end=points[numPoints-1];
    
    float *byteInfo=malloc(4*sizeof(float)+1);
    
    byteInfo[0]=start.latitude;
    byteInfo[1]=start.longitude;
    byteInfo[2]=end.latitude;
    byteInfo[3]=end.longitude;
    
    
    
    NSString *appString=[NSString stringWithFormat:@"rideaway://src="];
    
    for(i=0;i<4;i++){
        NSString *numString=[NSString stringWithFormat:@"_%f",byteInfo[i]];
        appString=[appString stringByAppendingString:numString];
    }
    
    
    NSLog(@"%@", appString);
    
    
    free(byteInfo);
    
    
    return appString;
}

void getRouteFromCompressedUrl(NSURL * url) {
    NSString *string=[url parameterString];
    CLLocationCoordinate2D start, end;
    
    NSString *sourceString=[url absoluteString];
    
    
    NSArray *seperatedStrings=[sourceString componentsSeparatedByString:@"_"];
    
    for(NSString *string in seperatedStrings){
        NSLog(@"%@", string);
    }
    
    
    start.latitude=[[seperatedStrings objectAtIndex:1] floatValue];
    start.longitude=[[seperatedStrings objectAtIndex:2] floatValue];
    end.latitude=[[seperatedStrings objectAtIndex:3] floatValue];
    end.longitude=[[seperatedStrings objectAtIndex:4] floatValue];
    
    
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
