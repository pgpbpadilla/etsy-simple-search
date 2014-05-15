//
//  ESListing.h
//  EtsySearch
//
//  Created by Pablo Padilla on 5/18/14.
//  Copyright (c) 2014 pgpbpadilla. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ESSearchResult : NSObject

@property (nonatomic, retain) NSArray* listings;
@property (nonatomic) NSDictionary* pagination;
@property (nonatomic) NSDictionary* params;
@property (nonatomic) NSInteger count;

@end
