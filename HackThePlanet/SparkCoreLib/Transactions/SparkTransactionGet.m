//
//  SparkTransactionGet.m
//  SparkCoreLib
//
//  Created by Jon Hoffman on 7/23/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

#import "SparkTransactionGet.h"

@implementation SparkTransactionGet

-(instancetype)init {
    self = [super init];
    if (self) {
        _subclassTransactionType = GET;
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

-(instancetype)initWithAccessToken:(NSString *)token deviceId:(NSString *)devId andProperty:(NSString *)prop {
    self = [self initWithAccessToken:token andDeviceId:devId];
    if (self) {
        self.property = prop;
    }
    return self;
}

@end
