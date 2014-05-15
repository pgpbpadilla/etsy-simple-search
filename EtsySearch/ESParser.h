//
//  ESParser.h
//  EtsySearch
//
//  Created by Pablo Padilla on 5/18/14.
//  Copyright (c) 2014 pgpbpadilla. All rights reserved.
//

#import <Foundation/Foundation.h>
@class ESSearchResult;

@interface ESParser : NSObject

+(ESSearchResult*)searchResultFrom:(NSDictionary*)searchResponse;
    
@end
