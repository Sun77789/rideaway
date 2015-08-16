//
//  SparkTransactionPost.h
//  SparkCoreLib
//
//  Created by Jon Hoffman on 7/23/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

#import "SparkTransaction.h"

@interface SparkTransactionPost : SparkTransaction

@property (strong, nonatomic) NSString *parameters;
@property (strong, nonatomic) NSString *functionName;

-(instancetype)init;
-(instancetype)initWithAccessToken:(NSString *)token andDeviceId:(NSString *)devId;
-(instancetype)initWithAccessToken:(NSString *)token deviceId:(NSString *)devId functionName:(NSString *)function andParameters:(NSString *)params;

@end
