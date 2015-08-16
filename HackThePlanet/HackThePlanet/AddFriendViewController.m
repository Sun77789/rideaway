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
    NSString *msg = @"Malika Aubakirova is inviting you to take a ride. Please, visit Rideaway.";
    //NSString *url = createURLWithCompressedRouteInfo(self.routeDetails);
    
    [PFCloud callFunctionInBackground:@"SMS"
                       withParameters:@{
                                        @"fromName": name,
                                        @"toNum": self.phoneNumber.text,
                                        @"msg": msg,
                                        }
                                block:^(NSString *result, NSError *error) {
                                    if (error) {
                                        NSLog(@"ERROR: %@",error);
                                    } else {
                                        NSLog(@"%@", result);
                                    }
                                    UIPopoverController *popOver = (UIPopoverController *)self.presentedViewController;
                                    [popOver dismissPopoverAnimated:YES];
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
    MKPolyline *pline=[route polyline];
    
    int numPoints=[pline pointCount];
    
    MKMapPoint *points=[pline points];
    
    MKMapPoint start=points[0];
    MKMapPoint end=points[numPoints-1];
    
    
    kiss_fft_cfg st=kiss_fft_alloc(2*numPoints, 0, NULL, NULL);
    kiss_fft_cpx *fin=malloc(2*numPoints*sizeof(kiss_fft_cpx));
    kiss_fft_cpx *fout=malloc(2*numPoints*sizeof(kiss_fft_cpx));
    int i=0;
    for(i=0;i<numPoints;i++) {
        fin[i].r=points[i].x;
        fin[i].i=points[i].y;
    }
    
    for(i=1;i<=numPoints;i++) {
        fin[i].r=points[numPoints-i].x;
        fin[i].i=points[numPoints-i].y;
    }
    
    
    kiss_fft(st, fin, fout);
    
    
    float *byteInfo=malloc(36*sizeof(float));
    byteInfo[0]=start.x;
    byteInfo[1]=start.y;
    byteInfo[2]=end.x;
    byteInfo[3]=end.y;
    
    
    for(i=4;i<36;i++) {
        byteInfo[i]=sqrt(fout[i].r*fout[i].r+fout[i].i*fout[i].i);
    }
    
    NSString *appString=[NSString stringWithFormat:@"rideaway://"];
    NSString *routeInfo=[[NSString alloc]initWithBytes:byteInfo length:36*sizeof(float) encoding:NSUTF8StringEncoding];
    
    NSString *urlString=[appString stringByAppendingString:routeInfo];
    
    
    free(byteInfo);
    free(fin);
    free(fout);
    free(points);
    kiss_fft_free(st);
    
    return urlString;
}

MKRoute *getRouteFromCompressedUrl(NSURL * url) {
    NSString *string=[url parameterString];
    
    void *voidBytes=[string cStringUsingEncoding:NSUTF8StringEncoding];
    
    float *pfftInfo=malloc(36*sizeof(float));
    
    memcpy(pfftInfo, voidBytes, 36*sizeof(float));
    
    
    MKMapPoint start, end;
    
    start.x=pfftInfo[0];
    start.y=pfftInfo[1];
    end.x=pfftInfo[2];
    end.y=pfftInfo[3];
    
    CLLocationCoordinate2D sc=MKCoordinateForMapPoint(start);
    CLLocationCoordinate2D ec=MKCoordinateForMapPoint(end);
    
    CLLocation *startingLocation=[[CLLocation alloc] initWithLatitude:sc.latitude longitude:sc.longitude];
    CLLocation *endingLocation=[[CLLocation alloc]initWithLatitude:ec.latitude longitude:ec.longitude];
    
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    
    __block CLPlacemark *placemark1;
    __block CLPlacemark *placemark2;
    
    
    [geocoder reverseGeocodeLocation:startingLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        
        placemark1 = [placemarks lastObject];
        
    }];
    
    [geocoder reverseGeocodeLocation:endingLocation completionHandler:^(NSArray *placemarks, NSError *error) {
        if(error){
            NSLog(@"%@", [error localizedDescription]);
        }
        
        placemark2 = [placemarks lastObject];
        
    }];
    
    
    MKMapItem *startItem=[[MKMapItem alloc]initWithPlacemark:placemark1];
    MKMapItem *endItem=[[MKMapItem alloc]initWithPlacemark:placemark2];
    
    MKDirectionsRequest *request=[[MKDirectionsRequest alloc]init];
    
    [request setSource:startItem];
    [request setDepartureDate:endItem];
    
    MKDirections *directions=[[MKDirections alloc]initWithRequest:request];
    
    NSArray *routes=[NSArray alloc];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            [routes initWithArray:response.routes];
            
            
        }}];
    
    
    int tracker=0;
    int bestChoice=0;
    
    float min=0;
    
    
    for(MKRoute *route in routes){
        
        
        float error=0;
        
        
        MKPolyline *pline=[route polyline];
        
        int numPoints=[pline pointCount];
        
        MKMapPoint *points=[pline points];
        
        MKMapPoint start=points[0];
        MKMapPoint end=points[numPoints-1];
        
        
        kiss_fft_cfg st=kiss_fft_alloc(2*numPoints, 0, NULL, NULL);
        kiss_fft_cpx *fin=malloc(2*numPoints*sizeof(kiss_fft_cpx));
        kiss_fft_cpx *fout=malloc(2*numPoints*sizeof(kiss_fft_cpx));
        int i=0;
        for(i=0;i<numPoints;i++){
            
            fin[i].r=points[i].x;
            fin[i].i=points[i].y;
        }
        for(i=1;i<=numPoints;i++){
            
            fin[i].r=points[numPoints-i].x;
            fin[i].i=points[numPoints-i].y;
        }
        
        
        kiss_fft(st, fin, fout);
        
        
        float *magnitude=malloc(32*sizeof(float));
        
        for(i=0;i<32;i++){
            magnitude[i]=sqrt(fout[i].r*fout[i].r+fout[i].i*fout[i].i);
        }
        
        
        for(i=0;i<32;i++){
            
            error+=fabsf(magnitude[i]-pfftInfo[i+4]);
            
        }
        
        if(error<1.6){
            return route;
        }else{
            if(error<min){
                min=error;
                bestChoice=tracker;
                
            }
        }
        
        tracker++;
    }
    return routes[bestChoice];
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
