//
//  SparkCoreConnector.m
//  SparkCoreLib
//
//  Created by Jon Hoffman on 7/21/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

#import "SparkCoreConnector.h"
#import "SparkTransactionGet.h"
#import "SparkTransactionPost.h"

@implementation SparkCoreConnector


+(void)connectToSparkAPIWithTransaction:(SparkTransaction *)transaction andHandler:(connectClosure)handler {
    if (transaction.transactionType == GET) {
        [self getConnectionWithTransaction:(SparkTransactionGet *)transaction  andHandler:handler];
    } else if (transaction.transactionType == POST) {
        [self postConnectionWithTransaction:(SparkTransactionPost *)transaction andHandler:handler];
    } else {
        NSString *description = NSLocalizedString(@"Unknown transaction type", @"");
        NSDictionary *errorDictionary = @{NSLocalizedDescriptionKey : description};
        NSError *error = [[NSError alloc] initWithDomain:@"SparkCoreConnectorErrorDomain" code:-1 userInfo:errorDictionary];
        handler(nil,nil,error);
    }
}

+(void)getConnectionWithTransaction:(SparkTransactionGet *)transaction andHandler:(connectClosure)handler {
    if (transaction.transactionType == GET) {
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *queue = [NSOperationQueue currentQueue];
        
        NSString *mUrl = [NSString stringWithFormat:@"%@/%@/%@?access_token=%@",transaction.baseUrl,transaction.deviceId, transaction.property, transaction.accessToken];
        
        NSURL *url = [NSURL URLWithString:mUrl];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:queue];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        request.HTTPMethod = @"GET";
        
        NSURLSessionDataTask *uploadTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
            if (error == nil) {
                
                NSDictionary *retData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                handler(response,retData,error);
            } else {
                handler(response,nil,error);
            }
        }];
        
        
        [uploadTask resume];
    }
}

+(void)postConnectionWithTransaction:(SparkTransactionPost *)transaction andHandler:(connectClosure)handler {
    if (transaction.transactionType == POST) {
        NSString *mUrl = [NSString stringWithFormat:@"%@/%@/%@",transaction.baseUrl,transaction.deviceId, transaction.functionName];
        
        NSURLSessionConfiguration *sessionConfiguration = [NSURLSessionConfiguration defaultSessionConfiguration];
        NSOperationQueue *queue = [NSOperationQueue currentQueue];
        NSURL *url = [NSURL URLWithString:mUrl];
        NSURLSession *urlSession = [NSURLSession sessionWithConfiguration:sessionConfiguration delegate:nil delegateQueue:queue];
        
        NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:url];
        
        NSString *params = [NSString stringWithFormat:@"access_token=%@&params=%@",transaction.accessToken,transaction.parameters];
        
        request.HTTPMethod = @"POST";
        [request setHTTPBody:[params dataUsingEncoding:NSUTF8StringEncoding]];
        
        NSURLSessionDataTask *uploadTask = [urlSession dataTaskWithRequest:request completionHandler:^(NSData *data,NSURLResponse *response,NSError *error) {
            if (error == nil) {
                
                NSDictionary *retData = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
                handler(response,retData,error);
            } else {
                handler(response,nil,error);
            }
        }];
        
        
        [uploadTask resume];
    }
}



@end
