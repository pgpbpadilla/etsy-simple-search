//
//  EtsySearch.h
//  EtsySearch
//
//  Created by Pablo Padilla on 5/18/14.
//  Copyright (c) 2014 pgpbpadilla. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
@class ESSearchResult, ESItemView, ESListing;

@interface EtsySearch : NSObject

-(void)findByKeywords:(NSString*)keywords
              success:(void (^)(ESSearchResult *))success
              failure:(void (^)(NSError *))failure;
-(void)loadNextPage:(void (^)(ESSearchResult *))success
            failure:(void (^)(NSError *))failure;
-(void)getTrendingItems:(void (^)(ESSearchResult*))success
                failure:(void (^)(NSError*))failure;
- (void)setImageFor:(ESListing *)listing inItemView:(ESItemView *)itemView;

@end
