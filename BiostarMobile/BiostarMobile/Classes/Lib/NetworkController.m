
/*
 * Copyright 2015 Suprema(biostar2@suprema.co.kr)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#import "NetworkController.h"


const BOOL needToEncript = NO;

static NetworkController *sharedInstance = nil;


@implementation NetworkController

@synthesize serverURL;
@synthesize URLsession;

+ (NetworkController*)sharedInstance
{
    if (nil == sharedInstance)
    {
        @synchronized(self)
        {
            if (nil == sharedInstance)
            {
                sharedInstance = [[NetworkController alloc] init];
            }
        }
    }
    
    return sharedInstance;
}

+ (void)resetSharedInstance
{
    sharedInstance = nil;
}

- (id)init
{
    if (self = [super init])
    {
        networks = [[NSMutableArray alloc] init];
        
        NSURLSessionConfiguration *configure = [NSURLSessionConfiguration defaultSessionConfiguration];
        [configure setTimeoutIntervalForRequest:60];
        [configure setURLCache:nil];
        
        URLsession = [NSURLSession sessionWithConfiguration:configure delegate:nil delegateQueue:[NSOperationQueue mainQueue]];
        
    }
    
    return self;
}


- (NSData*)convertToNSDate:(NSString*)body
{
    NSData *bodyData = nil;
    bodyData = [[NSData alloc] initWithData:[body dataUsingEncoding:NSUTF8StringEncoding]];
    return bodyData;
}


- (void)cancelAllRequests
{
    [URLsession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
        
        for (NSURLSessionTask *_task in dataTasks)
        {
            
            if (_task.state !=  NSURLSessionTaskStateCanceling || _task.state !=  NSURLSessionTaskStateCompleted) {
                [_task cancel];
            }
        }
    }];
    
}
@end
