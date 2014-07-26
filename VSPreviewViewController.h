//
//  VSPreviewViewController.h
//  Instagram_collage
//
//  Created by Admin on 25.07.14.
//  Copyright (c) 2014 MSU. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VSPhotoPickerViewController.h"

@interface VSPreviewViewController : UIViewController

@property (strong, nonatomic) NSMutableArray *imagesData;
@property (strong, nonatomic) NSNumber *fromWhatImageSignalCame;
@property (strong, nonatomic) VSPhotoPickerViewController *photoPicker;
@property (strong, nonatomic) NSString *userId;

@property (weak, nonatomic) IBOutlet UIImageView *previewCollageImageView;

- (IBAction)changeLeftUpImage:(id)sender;
- (IBAction)changeLeftDownImage:(id)sender;
- (IBAction)changeRightUpImageView:(id)sender;
- (IBAction)changeRightDownImageView:(id)sender;

- (IBAction)sendCollageAction:(id)sender;

@end
