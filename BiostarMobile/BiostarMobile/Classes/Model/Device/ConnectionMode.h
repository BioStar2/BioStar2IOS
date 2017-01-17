//
//  ConnectionMode.h
//  BiostarMobile
//
//  Created by 정의석 on 2016. 12. 5..
//  Copyright © 2016년 suprema. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ConnectionMode : NSObject

@property (nonatomic, strong) NSString *server_ip;
@property (nonatomic, strong) NSString *server_port;
@property (nonatomic, strong) NSString *type;

@end
