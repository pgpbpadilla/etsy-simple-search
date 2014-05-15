//
//  ItemView.h
//  EtsySearch
//
//  Created by Pablo Padilla on 5/18/14.
//  Copyright (c) 2014 pgpbpadilla. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ESItemView : UICollectionViewCell

@property (nonatomic,weak) IBOutlet UIImageView* imageView;
@property (nonatomic,weak) IBOutlet UILabel* titleLabel;
@property (nonatomic,weak) IBOutlet UILabel* priceLabel;

@end
