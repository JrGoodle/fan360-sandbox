//
//  NetworkRequestController.m
//  SIHomework
//
//  Created by goodle on 11/25/15.
//  Copyright © 2015 Sporting Innovations. All rights reserved.
//

#import "EventsController.h"
#import "AFNetworking/AFNetworking.h"
#import "Event.h"

@implementation EventsController

- (void)fetchEventList {
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer.acceptableContentTypes = nil;
    NSDictionary *parameters = @{@"token": @"ABmsLgpyv3oHoovLMFnqkt-HUbSkmV0hks5WWMktwA%3D%3D"};
    [manager GET:@"https://raw.githubusercontent.com/sporting-innovations/fan360-sandbox/master/service/events.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"JSON: %@", responseObject);
        for (NSDictionary *eventDict in responseObject) {
            if (nil == self.events) {
                self.events = [[NSMutableArray alloc] init];
            }
            [self.events addObject:[[Event alloc] initWithJSONObject:eventDict]];
            [self fetchImage:eventDict];
        }
        if ([self.delegate respondsToSelector:@selector(updateEvents)]) {
            [self.delegate updateEvents];
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void)fetchImage:(NSDictionary *)dict {
    NSArray *assets = dict[@"assets"];
    NSDictionary *imageInformation = assets[0];
    NSString *imageFileName = imageInformation[@"externalId"];
    NSString *imageContentType = imageInformation[@"contentType"];
    NSString *prefixToRemove = @"image/";
    NSString *imageFileType = [imageContentType copy];
    if ([imageContentType hasPrefix:prefixToRemove])
        imageFileType = [imageContentType substringFromIndex:[prefixToRemove length]];
    NSString *imageName = [NSString stringWithFormat:@"%@.%@", imageFileName, imageFileType];
    
    NSString *urlString = [NSString stringWithFormat:@"https://raw.githubusercontent.com/sporting-innovations/fan360-sandbox/master/service/images/%@", imageName];
    NSURL *url = [NSURL URLWithString:[urlString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]];
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFImageResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        for (Event* ev in self.events) {
            if ([ev.primaryName isEqualToString:dict[@"primaryName"][@"en-US"] ]) {
                ev.image = responseObject;
            }
        }
        if ([self.delegate respondsToSelector:@selector(updateEvents)]) {
            [self.delegate updateEvents];
        }
        NSLog(@"Response: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Image error: %@", error);
    }];
    [requestOperation start];
}

@end