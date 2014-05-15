//
//  ESItemDetailViewController.m
//  EtsySearch
//
//  Created by Pablo Padilla on 5/18/14.
//  Copyright (c) 2014 pgpbpadilla. All rights reserved.
//

#import "ESItemDetailViewController.h"
#import "ESListing.h"
#import <QuartzCore/QuartzCore.h>

@interface ESItemDetailViewController ()

@end

@implementation ESItemDetailViewController

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
    self.navigationController.navigationBar.tintColor= [UIColor whiteColor];

    _titleLabel.text = (_listing.details)[@"title"];
    
    _priceLabel.text = [NSString stringWithFormat:@" $%@  ", (_listing.details)[@"price"] ];
    [_priceLabel sizeToFit];
    _priceLabel.layer.cornerRadius = 4;
    
    _descriptionTextView.text = (_listing.details)[@"description"];
    _imageView.image = _listing.image;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
