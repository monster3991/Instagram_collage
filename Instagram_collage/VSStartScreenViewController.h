//
//  VSStartScreenViewController.h
//  Instagram_collage
//
//  Created by Admin on 24.07.14.
//  Copyright (c) 2014 MSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSPreviewViewController.h"

@interface VSStartScreenViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *makeCollageButton;

@property (weak, nonatomic) IBOutlet UITextField *userNameTextField;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) VSPreviewViewController *previewViewController;
@property (strong, nonatomic) NSMutableArray *topPhotos;

-(NSData *) getJSONWithImagesList:(NSString *)maxIdFromPrevious;

- (IBAction)makeImage:(id)sender;

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;

@end
