//
//  SearchViewController.h
//  EtsySearch
//
//  Created by Pablo Padilla on 5/18/14.
//  Copyright (c) 2014 pgpbpadilla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESSearchViewController : UIViewController<UICollectionViewDataSource,
UICollectionViewDelegate, UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

@end
