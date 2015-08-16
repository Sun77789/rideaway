//
//  SparkTransaction.m
//  SparkCoreLib
//
//  Created by Jon Hoffman on 7/23/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

#import "SparkTransaction.h"

@implementation SparkTransaction

@synthesize baseUrl, accessToken, deviceId;
@synthesize transactionType = _subclassTransactionType;

-(instancetype)init {
    self = [super init];
    if (self) {
        self.baseUrl = @"https://api.spark.io/v1/devices";
        self.accessToken = @"";
        self.deviceId = @"";
        _subclassTransactionType = UNKNOWN;
    }
    return self;
}

-(instancetype)initWithAccessToken:(NSString *)token andDeviceId:(NSString *)devId {
    self = [self init];
    if (self) {
        self.accessToken = token;
        self.deviceId = devId;
    }
    return self;
}

@end
