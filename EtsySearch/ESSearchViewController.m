//
//  SearchViewController.m
//  EtsySearch
//
//  Created by Pablo Padilla on 5/18/14.
//  Copyright (c) 2014 pgpbpadilla. All rights reserved.
//

#import "ESSearchViewController.h"
#import "EtsySearch.h"
#import "ESListing.h"

#import "ESSearchResult.h"
#import "ESItemView.h"
#import "ESCollectionHeader.h"
#import "ESItemDetailViewController.h"

@interface ESSearchViewController ()

@end

@implementation ESSearchViewController{
    EtsySearch* etsySearch;
    NSMutableArray* allItems;
    BOOL isTrendingView;
    UIActivityIndicatorView* activity;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    // load trending items on first load
    isTrendingView = YES;
    etsySearch = [[EtsySearch alloc] init];
    
    [etsySearch getTrendingItems:^(ESSearchResult *result) {
        [activity stopAnimating];
        allItems = [NSMutableArray arrayWithArray:result.listings];
        [_collectionView reloadData];
    } failure:^(NSError *error) {
        [activity stopAnimating];
        NSLog(@"%@", error);
    }];
    
    
    activity = [[UIActivityIndicatorView alloc] initWithFrame:
                CGRectMake(self.navigationController.navigationBar.frame.size.width - 50, 0,
                           50, 50)];
    activity.color = [UIColor whiteColor];
    [self.navigationController.navigationBar addSubview:activity];
    [activity startAnimating];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDataSource


-(NSInteger)collectionView:(UICollectionView *)collectionView
    numberOfItemsInSection:(NSInteger)section{
    return allItems.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView
                 cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    ESItemView* itemView= [collectionView dequeueReusableCellWithReuseIdentifier:@"itemView"
                                                                  forIndexPath:indexPath];
    
    if (indexPath.item == allItems.count-8) {
        
        [activity startAnimating];
        [etsySearch loadNextPage:^(ESSearchResult *result) {
            [activity stopAnimating];
            // update asynchronously in the main queue
            double delayInSeconds = 1.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW,
                                                    (int64_t)(delayInSeconds * NSEC_PER_SEC));
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [allItems addObjectsFromArray:result.listings];
                [self.collectionView reloadData];
                [self.collectionView.collectionViewLayout invalidateLayout];
            });
            
        } failure:^(NSError *error) {
            [activity stopAnimating];
            NSLog(@"Error getting the next page."
                  @"\nError: %@", error);
        }];
    }
    
    itemView.titleLabel.text = @"";
    itemView.priceLabel.text = @"";
    itemView.imageView.image = [UIImage imageNamed:@"i-sell-on-etsy"];
    
    ESListing* listing = allItems[indexPath.item];
    itemView.titleLabel.text = (listing.details)[@"title"];
    NSString* priceString = [NSString stringWithFormat:@"$ %@ USD", (listing.details)[@"price"]];
    itemView.priceLabel.text = priceString;
    
    if (!listing.image) {
        [etsySearch setImageFor:listing inItemView:itemView];
    }else {
        itemView.imageView.image = listing.image;
    }

    
    return itemView;
}

#pragma mark - UICollectionViewDelegate
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
}
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView
          viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath{
    ESCollectionHeader* header = [collectionView
                                  dequeueReusableSupplementaryViewOfKind:kind
                                  withReuseIdentifier:@"collectionHeader"
                                  forIndexPath:indexPath];
    
    if (isTrendingView) {
        header.titleLabel.text = @"Trending Items";
    }else {
        header.titleLabel.text = [NSString stringWithFormat:@"Search Results"];
    }
    
    return header;
}



#pragma mark - UISearchBarDelegate

-(void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar{
    // clear the collection view
    allItems = nil;
    _collectionView.alpha = 0.5;
    [_collectionView reloadData];
}
-(void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    isTrendingView = NO;
    [searchBar resignFirstResponder];
    NSLog(@"Keyword is: %@", searchBar.text);
    [activity startAnimating];
    [etsySearch findByKeywords:searchBar.text
                       success:^(ESSearchResult *result) {
                           [activity stopAnimating];
                           allItems = [NSMutableArray arrayWithArray:result.listings];
                           _collectionView.alpha = 1.0;
                           [_collectionView reloadData];
                       } failure:^(NSError *error) {
                           [activity stopAnimating];
                           NSLog(@"Error while searching for %@"
                                 @"%@", searchBar.text, error);
                       }];
}

#pragma mark - Show Detail
-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([segue.identifier isEqualToString:@"showDetail"]) {
        ESItemDetailViewController* target = (ESItemDetailViewController*)segue.destinationViewController;
        NSArray* selectionIndexPath = [_collectionView indexPathsForSelectedItems];
        ESListing* listing = allItems[((NSIndexPath*)selectionIndexPath[0]).item];
        target.listing = listing;
    }
    
}
@end
