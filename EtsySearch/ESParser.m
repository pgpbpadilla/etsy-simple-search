//
//  ESParser.m
//  EtsySearch
//
//  Created by Pablo Padilla on 5/18/14.
//  Copyright (c) 2014 pgpbpadilla. All rights reserved.
//

#import "ESParser.h"
#import "ESSearchResult.h"
#import "ESListing.h"

@implementation ESParser

+searchResultFrom:(NSDictionary*)searchResponse{
    ESSearchResult* listing = [[ESSearchResult alloc] init];
    
    listing.pagination = (searchResponse)[@"pagination"];
    
    NSMutableArray* listings = [NSMutableArray array];
    for (NSDictionary* listingDetail in (searchResponse)[@"results"]) {
        ESListing* listing = [[ESListing alloc] init];
        listing.details = listingDetail;
        [listings addObject:listing];
    }
    listing.listings = listings;
    listing.count = [(searchResponse)[@"count"] intValue];
    listing.params = (searchResponse)[@"params"];
    
    return listing;
}

@end
