//
//  SparkCoreConnector.h
//  SparkCoreLib
//
//  Created by Jon Hoffman on 7/21/14.
//  Copyright (c) 2014 Jon Hoffman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SparkTransaction.h"

@interface SparkCoreConnector : NSObject

typedef void (^connectClosure)(NSURLResponse *response, NSDictionary *responseDictionary, NSError *error);


+(void)connectToSparkAPIWithTransaction:(SparkTransaction *)transaction andHandler:(connectClosure)handler ;


@end
