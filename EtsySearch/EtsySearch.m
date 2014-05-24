//
//  EtsySearch.m
//  EtsySearch
//
//  Created by Pablo Padilla on 5/18/14.
//  Copyright (c) 2014 pgpbpadilla. All rights reserved.
//

#import "EtsySearch.h"
#import "ESListing.h"
#import "ESParser.h"
#import "ESItemView.h"
#import "ESSearchResult.h"

NSString* const ESBaseURL= @"https://api.etsy.com/v2/";
NSString* const ESAPIKey=@"api_key";
NSString* const ESIncludes=@"includes";
NSString* const ESLimit=@"limit";
NSString* const ESKeywords=@"keywords";
NSString* const ESPage=@"page";

NSString* const MyAPIKey= @"liwecjs0c3ssk6let4p1wqt9";

typedef enum ESResultsView {
    ESTrendingView,
    ESKeywordsSearchView
} ESResultsView;

@implementation EtsySearch{
    AFHTTPRequestOperationManager* manager;
    ESSearchResult* trending;
    __block ESSearchResult* lastResult;
    NSMutableDictionary* baseParams;
    ESResultsView currentView;
}

-(id)init{
    self = [super init];
    
    if (!self) {
        return nil;
    }

    // set initial view
    currentView = ESTrendingView;
    
    // setup the Operation Manager
    manager = [[AFHTTPRequestOperationManager alloc]
                        initWithBaseURL:[NSURL URLWithString:ESBaseURL]];
    manager.requestSerializer = [[AFJSONRequestSerializer alloc] init];
    manager.responseSerializer = [[AFJSONResponseSerializer alloc] init];
    
    baseParams = [NSMutableDictionary dictionary];
    (baseParams)[ESAPIKey]= MyAPIKey;
    (baseParams)[ESLimit]= @16;
    (baseParams)[ESIncludes]= @"MainImage";
    
    return self;
}

-(void)getResource:(NSString*)path withParams:(NSDictionary*)params
           success:(void (^)(ESSearchResult *))success
           failure:(void (^)(NSError *))failure{
    
    [baseParams addEntriesFromDictionary:params];
    [manager.operationQueue cancelAllOperations];
    [manager GET:path
      parameters:baseParams
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             ESSearchResult* result = [ESParser searchResultFrom:responseObject];
             lastResult = result;
             success(result);
         } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
             failure(error);
         }];
    
    NSLog(@"Current # of operations executing: %d",
          manager.operationQueue.operations.count);
    
}

#pragma mark - Public Methods
-(void)findByKeywords:(NSString*)keywords
              success:(void (^)(ESSearchResult *))success
              failure:(void (^)(NSError *))failure{
    
    // change the current view
    currentView = ESKeywordsSearchView;
    
    NSDictionary* params = @{ESKeywords: keywords};

    [self getResource:@"listings/active"
           withParams:params
              success:^(ESSearchResult *result) {
                  success(result);
              } failure:^(NSError *error) {
                  failure(error);
              }];
}

-(void)getTrendingItems:(void (^)(ESSearchResult *))success
                failure:(void (^)(NSError *))failure{
    
    [self getResource:@"listings/trending"
           withParams:nil
              success:^(ESSearchResult *result) {
               success(result);
           } failure:^(NSError *error) {
               failure(error);
           }];
}

- (void)setImageFor:(ESListing *)listing inItemView:(ESItemView *)itemView
{
    // async request for the image
    NSURLRequest* imageRequest = [NSURLRequest requestWithURL:
                                  [NSURL URLWithString:(listing.details)[@"MainImage"][@"url_170x135"]]];
    AFHTTPRequestOperation* imageOp = [[AFHTTPRequestOperation alloc] initWithRequest:imageRequest];
    imageOp.responseSerializer = [[AFImageResponseSerializer alloc] init];
    
    __weak UIImageView* wImageView = itemView.imageView;
    [imageOp setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, UIImage* image) {
        listing.image = image;
        
        [UIView transitionWithView:wImageView duration:1
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            wImageView.image = image;
                            [wImageView setNeedsLayout];
                        } completion:nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [imageOp start];
}

-(void)loadNextPage:(void (^)(ESSearchResult *))success
            failure:(void (^)(NSError *))failure{
    
    NSError* error;
    NSString* errorDesc;
    if (!lastResult) {
        errorDesc = @"Cannot load next page.";
        error = [NSError errorWithDomain:@"ESNextPage"
                                    code:101
                                userInfo:@{NSLocalizedDescriptionKey: errorDesc}];
        failure(error);
        return;
    }
    
    if ([NSNull null] == (lastResult.pagination)[@"next_page"]) {
        errorDesc = @"No more pages to load.";
        error = [NSError errorWithDomain:@"ESNextPage"
                                    code:101
                                userInfo:@{NSLocalizedDescriptionKey: errorDesc}];
        failure(error);
        return;
    }
    
    NSInteger nextPage = [(lastResult.pagination)[@"next_page"] intValue] + 1;
    NSInteger lastPage= [(lastResult.pagination)[@"effective_page"] intValue];
    
    if (lastPage > nextPage) {
        // don't load pages that already loaded
        return;
    }
    
    // update page parameter for the next search
    (baseParams)[ESPage] = [NSNumber numberWithInteger:nextPage];
    
    if (currentView == ESTrendingView) {
        [self getTrendingItems:^(ESSearchResult *result) {
            success(result);
        } failure:^(NSError *error) {
            failure(error);
        }];
    } else if (currentView == ESKeywordsSearchView) {
    
        [self findByKeywords:(lastResult.params)[@"keywords"]
                     success:^(ESSearchResult *result) {
                         success(result);
                     } failure:^(NSError *error) {
                         failure(error);
                     }];
    }
    
}
@end
