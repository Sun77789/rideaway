//
//  ViewController.m
//  HackThePlanet
//
//  Created by Malika Aubakirova on 8/14/15.
//  Copyright (c) 2015 MLH_Team. All rights reserved.
//

#import "ViewController.h"
#import <AddressBookUI/AddressBookUI.h>
#import "AddFriendViewController.h"
#import <Parse/Parse.h>
#import "SparkCoreConnector.h"
#import "SparkTransactionPost.h"
#import "SparkTransactionGet.h"
#import <Parse/Parse.h>

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

@interface ViewController () <CLLocationManagerDelegate,UIPopoverPresentationControllerDelegate>
@property (strong, nonatomic) CLLocationManager *locationManager;
@property NSArray *colors;
@property (strong, nonatomic) NSTimer *countDownTimer;
@property (nonatomic) int secondsCount;

@property (strong, nonatomic) NSString *dstLabel;

@end

@implementation ViewController

CLPlacemark *thePlacemark;
MKRoute *routeDetails;
int counter = 1;
bool locationsearch;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self SetUpNavBar];
    PFUser *user = [PFUser currentUser];
    
    if(!self.src && [user[@"url"] isEqualToString: @"true"]) {
        if(!self.src) {
            self.src = user[@"src"];
            self.dst = user[@"dst"];
        }
    }
    
    if(self.src && self.dst) {
        CLGeocoder *geocoder = [[CLGeocoder alloc] init];
        [geocoder geocodeAddressString:self.src completionHandler:^(NSArray *placemarks, NSError *error) {
            
            if (error) {
                NSLog(@"%@", error);
            } else {
                MKPlacemark *srcPlacement = [placemarks lastObject];
                [self addAnnotation:srcPlacement andTitle:@"Malika's start"];
                [self DrawRouteGivenDst: self.dst startAt:srcPlacement];
            }
        }];
        
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            user[@"url"] = @"false";
            [user saveInBackground];
        }];
    }
    
    self.mapView.delegate = self;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.distanceFilter = kCLDistanceFilterNone;
    self.locationManager.delegate = self;
    // Check for iOS 8. Without this guard the code will crash with "unknown selector" on iOS 7.
    if ([self.locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)]) {
        NSLog(@"Request with authorization");
        [self.locationManager requestWhenInUseAuthorization];
        //[self InitCurrLocation];
    }
    [self.locationManager startUpdatingLocation];
    
    // self.endAddress.delegate = self;
    [self.endAddress addTarget:self.endAddress
                        action:@selector(resignFirstResponder)
              forControlEvents:UIControlEventEditingDidEndOnExit];
    
    locationsearch = FALSE;
    if(!self.src) {
        [self InitCurrLocation];
    }
    [self condition];
    
    [self.navigationController setNavigationBarHidden:NO];
    
    self.luckyButton.titleLabel.font = [UIFont fontWithName:@"Hero-Light" size:17.0];
    [self SetGesture];
}

-(void) SetGesture {
    UILongPressGestureRecognizer *lpgr = [[UILongPressGestureRecognizer alloc]
                                          initWithTarget:self action:@selector(handleGesture:)];
    lpgr.minimumPressDuration = 1.5;  //user must press for 2 seconds
    [self.mapView addGestureRecognizer:lpgr];
}

- (void)handleGesture:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state != UIGestureRecognizerStateEnded)
        return;
    
    CGPoint touchPoint = [gestureRecognizer locationInView:self.mapView];
    CLLocationCoordinate2D touchMapCoordinate =
    [self.mapView convertPoint:touchPoint toCoordinateFromView:self.mapView];
    
    MKPointAnnotation *pa = [[MKPointAnnotation alloc] init];
    pa.coordinate = touchMapCoordinate;
    [self.mapView addAnnotation:pa];
    
    CLLocation *dstLoc = [[CLLocation alloc] initWithCoordinate:touchMapCoordinate altitude:0 horizontalAccuracy:0 verticalAccuracy:100 course:0 speed:0 timestamp:0];
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:dstLoc completionHandler:^(NSArray *placemarks, NSError *error) {
        if (placemarks && placemarks.count > 0) {
            CLPlacemark *placemark = [placemarks objectAtIndex:0];
            NSString *address = [NSString stringWithFormat:@"%@ %@ %@ %@", [placemark subThoroughfare] ? [placemark subThoroughfare] : @"" , [placemark thoroughfare] ? [placemark thoroughfare] : @"", [placemark locality] ? [placemark locality] : @"", [placemark administrativeArea] ? [placemark administrativeArea] : @"the location"];
            
            thePlacemark = placemark;
            [self MarkRoute];
            self.goButton.hidden = FALSE;
        }
    }];
}

-(void) condition {
    NSString *pin = greenLED1;
    NSString *pin1 = greenLED2;
  //  NSString *pin2 = yellowLED1;
  //  NSString *pin3 = yellowLED2;
    NSString *pin4 = redLED1;
    NSString *pin5 = redLED2;
    NSString *state = STATE_HIGH;
    NSString *param;
    
    if (locationsearch==TRUE)
    {
        // Insert here
        state = STATE_LOW; // Red lights up
        // state = STATE_HIGH // Green lights up
        param = [NSString stringWithFormat:@"%@%@:%@",pin,pin1,state];
        
    }
    
    else
    {
        state = STATE_LOW;
        param = [NSString stringWithFormat:@"%@%@:%@",pin4,pin5,state];
    }
    [self sendRequestWithParameter:param];

}

-(void)sendRequestWithParameter:(NSString *)parameter {
    SparkTransactionPost *postTransaction = [[SparkTransactionPost alloc] initWithAccessToken:ACCESS_TOKEN deviceId:DEVICE_ID functionName:FUNCTION andParameters:parameter];
    
    [SparkCoreConnector connectToSparkAPIWithTransaction:postTransaction andHandler:^(NSURLResponse *response, NSDictionary *responseDictionary, NSError *error){
        if(error == nil) {
            NSLog(@"Response: %@",responseDictionary);
        } else {
            NSLog(@"Error: %@",error);
        }
    }];
    
    NSLog(@"Continueing with app");
    
}


- (void) SetUpNavBar {
    //[[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    //UIColor *tintColor = [UIColor colorWithRed:235.0/255.0 green:69.0/255.0 blue:17.0/255.0 alpha:1];
    UIColor *tintColor = [UIColor blackColor];
    [[UINavigationBar appearance] setBarTintColor:tintColor];
    //[[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.colors = [[NSArray alloc] initWithObjects: [UIColor redColor], [UIColor blueColor], [UIColor greenColor], nil];
}

// Delegate method
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    CLLocation* loc = [locations lastObject]; // locations is guaranteed to have at least one object
    float latitude = loc.coordinate.latitude;
    float longitude = loc.coordinate.longitude;
    //NSLog(@"Latitude: %.8f",latitude);
    //NSLog(@"Longitude: %.8f",longitude);
}

- (IBAction)searchBox:(UITextField *)sender {
    self.dstLabel = sender.text;
    [self DrawRouteGivenDst:sender.text startAt:nil];
    self.goButton.hidden = FALSE;
}

- (void) DrawRouteGivenDst: (NSString *) text startAt: (MKPlacemark *) start {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:text completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"%@", error);
        } else {
            CGRect newFrame = self.mapView.frame;
            newFrame.size = CGSizeMake(23.0, 50.0);
            self.mapView.frame = newFrame;
            
            thePlacemark = [placemarks lastObject];
            float spanX = 0.00825;
            float spanY = 0.00825;
            MKCoordinateRegion region;
            region.center.latitude = thePlacemark.location.coordinate.latitude;
            region.center.longitude = thePlacemark.location.coordinate.longitude;
            region.span = MKCoordinateSpanMake(spanX, spanY);
            [self.mapView setRegion:region animated:YES];
            [self addAnnotation:thePlacemark];
        }
        if(start) {
            [self MarkRoute:start];
        } else {
            [self MarkRoute];
        }
    }];
}

- (void) InitCurrLocation {
    usleep(50000);
    float spanX = 0.01725;
    float spanY = 0.01725;
    self.location = self.locationManager.location;
    
    MKCoordinateRegion region;
    region.center.latitude = self.locationManager.location.coordinate.latitude;
    region.center.longitude = self.locationManager.location.coordinate.longitude;
    //region.center.latitude = 37.41;
    //region.center.longitude = -122.08;
    
    region.span = MKCoordinateSpanMake(spanX, spanY);
    [self.mapView setRegion:region animated:YES];
    [self reverseGeocode:self.location];
    locationsearch=TRUE;
}

- (void)reverseGeocode:(CLLocation *)location {
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            self.myAddress.text = [NSString stringWithFormat:@"%@", ABCreateStringWithAddressDictionary(placemark.addressDictionary, NO)];
        }
    }];
}


- (void)addAnnotation:(CLPlacemark *)placemark {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    point.title = [placemark.addressDictionary objectForKey:@"Street"];
    point.subtitle = [placemark.addressDictionary objectForKey:@"City"];
    [self.mapView addAnnotation:point];
}

- (void)addAnnotation:(CLPlacemark *)placemark andTitle: (NSString *) caption {
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
    point.title = caption;
    [self.mapView addAnnotation:point];
    [self.mapView selectAnnotation:point animated:YES];
}

-(MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    MKPolylineRenderer  * routeLineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:routeDetails.polyline];
    routeLineRenderer.strokeColor = [self.colors objectAtIndex: counter % 3]; // [UIColor redColor];
    counter++;
    routeLineRenderer.lineWidth = 5;
    return routeLineRenderer;
}

-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    // Handle any custom annotations.
    if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView *pinView = (MKPinAnnotationView*)[self.mapView dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.canShowCallout = YES;
        } else {
            pinView.annotation = annotation;
        }
        return pinView;
    }
    return nil;
}

- (IBAction)routeButtonPressed:(UIBarButtonItem *)sender {
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:thePlacemark];
    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"RouteButtonPressed: Error %@", error.description);
        } else {
            routeDetails = response.routes.lastObject;
            
            [self.mapView addOverlay:routeDetails.polyline];
            self.destinationLabel.text = [placemark.addressDictionary objectForKey:@"Street"];
            
            self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
            self.transportLabel.text = [NSString stringWithFormat:@"%lu" , routeDetails.transportType];
            self.allSteps = @"";
            for (int i = 0; i < routeDetails.steps.count; i++) {
                MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                NSString *newStep = step.instructions;
                self.allSteps = [self.allSteps stringByAppendingString:newStep];
                self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                self.steps.text = self.allSteps;
            }
        }
    }];
}

- (IBAction)beginRouteNow:(id)sender {
    if(self.dstLabel) {
        [self InitCurrLocation];
        CLLocation *loc_a = self.location;
        CLLocation *loc_b = thePlacemark.location;
        double distance = [loc_a distanceFromLocation:loc_b];
        self.secondsCount = routeDetails.expectedTravelTime /60;
        
        self.countDownTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerRun) userInfo:nil repeats:YES];
        
        NSString *msg = @"Bryan just started his ride.";
        if(self.src) {
            [PFCloud callFunctionInBackground:@"SMS"
                               withParameters:@{
                                                @"fromName": @"Bryan",
                                                @"toNum": @"3122135143",
                                                @"msg": msg,
                                                }
                                        block:^(NSString *result, NSError *error) {
                                            if (error) {
                                                NSLog(@"ERROR: %@",error);
                                            } else {
                                                NSLog(@"%@", result);
                                            }
                                        }];
        }
    }
    self.goButton.hidden = TRUE;
    self.resetButton.hidden = FALSE;
}

- (IBAction)clearRouteAndAll:(id)sender {
    self.resetButton.hidden = TRUE;
    self.goButton.hidden = FALSE;
    [self Clear];
}

- (void) timerRun {
//    PFQuery *query = [PFQuery queryWithClassName:@"UserStats"];
//    [query whereKey:@"user" equalTo:[PFUser currentUser]];
    
    //NSLog(@"%s", );
    self.secondsCount -= 1;
    int minutes = self.secondsCount / 60;
    
    // DON"T FORGET THIS PARRT!!!!!
    CLLocation *loc_a = self.locationManager.location;
    CLLocation *loc_b = thePlacemark.location;
    
    double distance = [loc_a distanceFromLocation:loc_b];
    if(minutes == 5) {
        PFUser *user = [PFUser currentUser];
        NSString *name = user[@"name"];
        NSString *msg = @"Malika Aubakirova is inviting you to take a ride. Please, visit Rideaway.";
        //NSString *url = createURLWithCompressedRouteInfo(self.routeDetails);
        
        [PFCloud callFunctionInBackground:@"SMS"
                           withParameters:@{
                                            @"fromName": name,
                                            @"toNum": user[@"friendPhoneNumber"],
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
}

- (void) MarkRoute {
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:thePlacemark];
    [directionsRequest setSource:[MKMapItem mapItemForCurrentLocation]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"RouteButtonPressed: Error %@", error.description);
        } else {
            routeDetails = response.routes.lastObject;
            [self.mapView addOverlay:routeDetails.polyline];
            self.destinationLabel.text = [placemark.addressDictionary objectForKey:@"Street"];
            self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
            self.transportLabel.text = [NSString stringWithFormat:@"%lu" , routeDetails.transportType];
            self.allSteps = @"";
            for (int i = 0; i < routeDetails.steps.count; i++) {
                MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                NSString *newStep = step.instructions;
                self.allSteps = [self.allSteps stringByAppendingString:newStep];
                self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                self.steps.text = self.allSteps;
            }
        }
    }];
}

- (void) MarkRoute: (MKPlacemark *) start {
    MKDirectionsRequest *directionsRequest = [[MKDirectionsRequest alloc] init];
    MKPlacemark *placemark = [[MKPlacemark alloc] initWithPlacemark:thePlacemark];
    [directionsRequest setSource:[[MKMapItem alloc] initWithPlacemark:start]];
    [directionsRequest setDestination:[[MKMapItem alloc] initWithPlacemark:placemark]];
    directionsRequest.transportType = MKDirectionsTransportTypeAutomobile;
    MKDirections *directions = [[MKDirections alloc] initWithRequest:directionsRequest];
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"RouteButtonPressed: Error %@", error.description);
        } else {
            routeDetails = response.routes.lastObject;
            [self.mapView addOverlay:routeDetails.polyline];
            self.destinationLabel.text = [placemark.addressDictionary objectForKey:@"Street"];
            self.distanceLabel.text = [NSString stringWithFormat:@"%0.1f Miles", routeDetails.distance/1609.344];
            self.transportLabel.text = [NSString stringWithFormat:@"%lu" , routeDetails.transportType];
            self.allSteps = @"";
            for (int i = 0; i < routeDetails.steps.count; i++) {
                MKRouteStep *step = [routeDetails.steps objectAtIndex:i];
                NSString *newStep = step.instructions;
                self.allSteps = [self.allSteps stringByAppendingString:newStep];
                self.allSteps = [self.allSteps stringByAppendingString:@"\n\n"];
                self.steps.text = self.allSteps;
            }
        }
    }];
}

- (IBAction)clearRoute:(UIBarButtonItem *)sender {
    self.destinationLabel.text = nil;
    self.distanceLabel.text = nil;
    self.transportLabel.text = nil;
    self.steps.text = nil;
    [self.mapView removeOverlay:routeDetails.polyline];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (void) Clear {
    self.destinationLabel.text = nil;
    self.distanceLabel.text = nil;
    self.transportLabel.text = nil;
    self.steps.text = nil;
    [self.mapView removeOverlay:routeDetails.polyline];
    [self.mapView removeAnnotations:self.mapView.annotations];
}

- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    
    return UIModalPresentationNone;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"popoverSegue"]) {
        AddFriendViewController *dvc = (AddFriendViewController *) segue.destinationViewController;
        [dvc setRouteDetails:routeDetails];
        NSString *src = self.myAddress.text;
        NSLog(@"My location: %@", src);
        NSString *dst = self.dstLabel;
        
        NSString *srcURLTemp1 = [[src stringByReplacingOccurrencesOfString:@"\n" withString:@" "]
                                 stringByReplacingOccurrencesOfString:[NSString stringWithFormat:@"%d",94043]
                                 withString:@""];
        
        NSString *srcURLTemp = [[srcURLTemp1 stringByReplacingOccurrencesOfString:@"CA" withString:@""]
                                stringByReplacingOccurrencesOfString:@"United States" withString:@""];
        
        NSString *srcURL = [srcURLTemp stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        
        NSString *dstURLTemp = [dst stringByReplacingOccurrencesOfString:@" " withString:@"-"];
        NSString *dstURL = [dstURLTemp stringByReplacingOccurrencesOfString:@"CA%94043%United%States" withString:@""];
        
        
        [dvc setSrc:srcURL];
        [dvc setDst:dstURL];
        
        UIPopoverPresentationController *controller = dvc.popoverPresentationController;
        if (controller) {
            controller.delegate = self;
        }
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


/* Matt's changes */
typedef struct{
    double dval;
    int index;
    
    
}indexed_double;

int compare(const void *p, const void *q){
    indexed_double a = *(const indexed_double *)p;
    indexed_double b = *(const indexed_double *)q;
    
    double x=a.dval;
    double y=b.dval;
    
    /* to avoid undefined behaviour through signed integer overflow,
     avoid: return x - y; */
    int ret;
    if (x == y)
        // ret = (m < n) ? -1 : 1;
        ret=0;
    else
        ret = (x > y) ? -1 : 1;
    
    return ret;
}





void sort_doubles(indexed_double *a,size_t n){
    int (*fptr)(const void *p,const void *q);
    fptr=&compare;
    
    qsort(a,n,sizeof(indexed_double),fptr);
}



void sortRouteCurvatures(NSMutableArray *routes){
    
    int i,j=0;
    
    
    NSUInteger numroutes=[routes count];
    
    
    double *maxCurvature=malloc(numroutes*sizeof(double));
    
    double *avgCurvature=malloc(numroutes*sizeof(double));
    
    int routeCounter=0;
    
    for(MKRoute *route in routes){
        
        MKPolyline *routePoly=[route polyline];
        
        NSUInteger numPointsInRoute=[routePoly pointCount];
        
        CLLocationCoordinate2D *mapCoordinatesInRoute=malloc(numPointsInRoute*sizeof(CLLocationCoordinate2D));//
        
        MKMapPoint *pointsInRoute=malloc(numPointsInRoute*sizeof(MKMapPoint));//
        
        NSRange ptRange=NSMakeRange(0, numPointsInRoute);
        [routePoly getCoordinates:pointsInRoute range:ptRange];
        
        for(i=0;i<numPointsInRoute;i++){
            pointsInRoute[i]=MKMapPointForCoordinate(mapCoordinatesInRoute[i]);
        }
        
        double *localCurvature=malloc(numPointsInRoute*sizeof(double));
        
        double *dispersedLocalCurvature=malloc(numPointsInRoute*sizeof(double));
        
        
        
        double max=0;
        
        
        for(i=1;i<numPointsInRoute-1;i++){
            
            double d2x=pointsInRoute[i+1].x-2*pointsInRoute[i].x+pointsInRoute[i-1].x;
            double d2y=pointsInRoute[i+1].y-2*pointsInRoute[i].y+pointsInRoute[i-1].y;
            
            localCurvature[i]=sqrt(d2x*d2x+d2y*d2y);
            for(j=0;j<5;j++){
                dispersedLocalCurvature[0]=localCurvature[j];
            }
            
            if(i<=5){
                dispersedLocalCurvature[i]=localCurvature[i+5]+dispersedLocalCurvature[i-1];
            }
            
            if(i>10){
                dispersedLocalCurvature[i]=dispersedLocalCurvature[i-1]-localCurvature[i-5]+localCurvature[i+5];
            }
            avgCurvature[routeCounter]+=localCurvature[i]/(numPointsInRoute);
            
            if(dispersedLocalCurvature[i]>max){
                max=dispersedLocalCurvature[i];
            }
            
        }
        
        
        maxCurvature[routeCounter]=max;
        
        routeCounter++;
        
        free(localCurvature);
        free(pointsInRoute);
        free(mapCoordinatesInRoute);
        
    }
    
    
    
    indexed_double *orderedRoutes=malloc(numroutes*sizeof(indexed_double));
    for(i=0;i<numroutes;i++){
        orderedRoutes[i].dval=avgCurvature[i]+maxCurvature[i];
        orderedRoutes[i].index=i;
    }
    
    sort_doubles(orderedRoutes, numroutes);
    
    
    NSMutableArray *sortedArray=[[NSMutableArray alloc]init];
    
    for(i=0;i<numroutes;i++){
        [sortedArray addObject:routes[orderedRoutes[i].index]];
    }
    
    free(maxCurvature);
    free(avgCurvature);
    free(orderedRoutes);
    
}



NSArray *feelingAdventurous(CLLocation *myLocation, int radius, int step){
    
    
    radius=M_PI*radius/4;
    
    
    MKMapPoint myPoint=MKMapPointForCoordinate([myLocation coordinate]);
    
    
    MKMapRect region1, region2, region3, region4;
    
    
    region1.origin.x=myPoint.x-radius-step;
    region1.origin.y=myPoint.y-radius-step;
    
    region2.origin.x=myPoint.x-radius;
    region2.origin.y=myPoint.y-radius-step;
    
    region3.origin.x=myPoint.x+radius;
    region3.origin.y=myPoint.y-radius-step;
    
    region4.origin.x=myPoint.x-radius;
    region4.origin.y=myPoint.y+radius;
    
    region1.size.width=step;
    region1.size.height=2*(radius+step);
    
    region2.size.width=2*radius;
    region2.size.height=step;
    
    region3.size.width=step;
    region3.size.height=2*(radius+step);
    
    region4.size.width=2*radius;
    region4.size.height=step;
    
    
    
    MKCoordinateRegion searchRegion1=MKCoordinateRegionForMapRect(region1);
    MKCoordinateRegion searchRegion2=MKCoordinateRegionForMapRect(region2);
    MKCoordinateRegion searchRegion3=MKCoordinateRegionForMapRect(region3);
    MKCoordinateRegion searchRegion4=MKCoordinateRegionForMapRect(region4);
    
    MKLocalSearchRequest *request1=[[MKLocalSearchRequest alloc]init];
    MKLocalSearchRequest *request2=[[MKLocalSearchRequest alloc]init];
    MKLocalSearchRequest *request3=[[MKLocalSearchRequest alloc]init];
    MKLocalSearchRequest *request4=[[MKLocalSearchRequest alloc]init];
    
    
    request1.naturalLanguageQuery=@"points of interest";
    request2.naturalLanguageQuery=@"points of interest";
    request3.naturalLanguageQuery=@"points of interest";
    request4.naturalLanguageQuery=@"points of interest";
    request1.region=searchRegion1;
    request2.region=searchRegion1;
    request3.region=searchRegion1;
    request4.region=searchRegion1;
    
    
    
    MKLocalSearch *search1=[[MKLocalSearch alloc]initWithRequest:request1];
    MKLocalSearch *search2=[[MKLocalSearch alloc]initWithRequest:request2];
    MKLocalSearch *search3=[[MKLocalSearch alloc]initWithRequest:request3];
    MKLocalSearch *search4=[[MKLocalSearch alloc]initWithRequest:request4];
    
    
    NSMutableArray *responseArrays;
    
    
    MKLocalSearchCompletionHandler completionHandler=^(MKLocalSearchResponse *response, NSError *error){
        
        if(error!=nil){
            return;
        }else{
            
            [responseArrays addObject:response.mapItems];
            
        }
        
    };
    
    [search1 startWithCompletionHandler:completionHandler];
    [search2 startWithCompletionHandler:completionHandler];
    [search3 startWithCompletionHandler:completionHandler];
    [search4 startWithCompletionHandler:completionHandler];
    
    
    NSMutableArray *arrayOfAllRoutes=[[NSMutableArray alloc]init];
    
    
    for(NSArray *mapItemArray in responseArrays){
        for(MKMapItem *map in mapItemArray){
            [arrayOfAllRoutes addObject:map];
        }
    }
    
    sortRouteCurvatures(arrayOfAllRoutes);
    NSArray *routes=[arrayOfAllRoutes copy];
    return routes;
    
}
- (IBAction)feelingLucky:(id)sender {
    MKLocalSearchRequest *request = [[MKLocalSearchRequest alloc] init];
    request.naturalLanguageQuery = @"Restaurants";
    request.region = self.mapView.region;
    MKLocalSearch *search = [[MKLocalSearch alloc] initWithRequest:request];
    
    [search startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        NSLog(@"Map Items: %@", response.mapItems);
       
        float spanX = 0.02725;
        float spanY = 0.02725;
        self.location = self.locationManager.location;
        MKCoordinateRegion region;
        region.center.latitude = self.locationManager.location.coordinate.latitude;
        region.center.longitude = self.locationManager.location.coordinate.longitude;
        
        region.span = MKCoordinateSpanMake(spanX, spanY);
        [self.mapView setRegion:region animated:YES];
        
        for(MKMapItem *item in response.mapItems) {
            if(item.placemark) {
                [self.mapView addAnnotation: item.placemark];
            }
        }
    }];
    
    //[self DrawRouteGivenDst:address startAt:nil];
}

@end
