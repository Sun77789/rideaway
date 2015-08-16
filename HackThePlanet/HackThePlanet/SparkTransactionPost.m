//
//  SparkTransactionPost.m
//  SparkCoreLib
//
//  Created by Jon Hoffman on 7/23/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

#import "SparkTransactionPost.h"

@implementation SparkTransactionPost

-(instancetype)init {
    self = [super init];
    if (self) {
        _subclassTransactionType = POST;
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

-(instancetype)initWithAccessToken:(NSString *)token deviceId:(NSString *)devId functionName:(NSString *)function andParameters:(NSString *)params {
    self = [self initWithAccessToken:token andDeviceId:devId];
    if (self) {
        self.functionName = function;
        self.parameters = params;
    }
    return self;
}
@end
