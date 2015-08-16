//
//  SparkTransaction.h
//  SparkCoreLib
//
//  Created by Jon Hoffman on 7/23/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, SparkTransactionType) {
    GET,
    POST,
    UNKNOWN
};

@interface SparkTransaction : NSObject {
    @protected SparkTransactionType _subclassTransactionType;
}

@property (strong, nonatomic) NSString *baseUrl;
@property (strong, nonatomic) NSString *accessToken;
@property (strong, nonatomic) NSString *deviceId;
@property (readonly) SparkTransactionType transactionType;

-(instancetype)init;
-(instancetype)initWithAccessToken:(NSString *)token andDeviceId:(NSString *)devId;

@end
