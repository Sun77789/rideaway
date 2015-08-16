//
//  SparkTransactionGet.h
//  SparkCoreLib
//
//  Created by Jon Hoffman on 7/23/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

#import "SparkTransaction.h"

@interface SparkTransactionGet : SparkTransaction

@property (strong, nonatomic) NSString* property;

-(instancetype)init;
-(instancetype)initWithAccessToken:(NSString *)token andDeviceId:(NSString *)devId;
-(instancetype)initWithAccessToken:(NSString *)token deviceId:(NSString *)devId andProperty:(NSString *)prop;


@end
