//
//  VSPhotoPickerViewController.h
//  Instagram_collage
//
//  Created by Admin on 25.07.14.
//  Copyright (c) 2014 MSU. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VSPhotoPickerViewController : UIViewController
@property (weak, nonatomic) IBOutlet UICollectionView *galleryPhotoPickerCollectionView;
@property (strong, nonatomic) NSMutableArray *arrayWithData;

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *previousMaxId;

@end
