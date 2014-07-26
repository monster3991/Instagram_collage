//
//  VSPreviewViewController.m
//  Instagram_collage
//
//  Created by Admin on 25.07.14.
//  Copyright (c) 2014 MSU. All rights reserved.
//

#import "VSPreviewViewController.h"
#import "VSStartScreenViewController.h"
#import <MessageUI/MFMailComposeViewController.h>

@interface VSPreviewViewController ()

@end

@implementation VSPreviewViewController

@synthesize imagesData, userId;
@synthesize previewCollageImageView, fromWhatImageSignalCame, photoPicker;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        fromWhatImageSignalCame = [fromWhatImageSignalCame initWithInt:0];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    VSStartScreenViewController *userPage = [[self.navigationController viewControllers] objectAtIndex:(0)];
    
    imagesData = [NSMutableArray arrayWithCapacity:4];
    
    NSData *data;
    for( unsigned int i = 0; i < 4; i++){
        data = [NSData dataWithContentsOfURL:[NSURL URLWithString:[[userPage topPhotos] objectAtIndex:i]]];
        [imagesData addObject:data];
    }
    NSLog(@"viewDidLoad");
}




- (void)viewWillAppear:(BOOL)animated
{
    //каждый раз, когда показываем окно обновляем наше превью
    CGSize size = CGSizeMake(self.previewCollageImageView.bounds.size.width, self.previewCollageImageView.bounds.size.height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(size.width, size.height), YES, 0.0);
    UIRectFill(CGRectMake(10, 70, size.width, size.height));
    NSArray *arrayImages = @[[UIImage imageWithData:[imagesData objectAtIndex:0]],
                             [UIImage imageWithData:[imagesData objectAtIndex:1]],
                            [UIImage imageWithData:[imagesData objectAtIndex:2]],
                             [UIImage imageWithData:[imagesData objectAtIndex:3]]];
    //рисуем по углам
    [[arrayImages objectAtIndex:0] drawAtPoint:CGPointMake(0, 0)];
    [[arrayImages objectAtIndex:1] drawAtPoint:CGPointMake(150, 0)];
    [[arrayImages objectAtIndex:2]drawAtPoint:CGPointMake(0, 150)];
    [[arrayImages objectAtIndex:3] drawAtPoint:CGPointMake(150, 150)];
    
    //собираем воедино
    UIImage *fImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    [previewCollageImageView setImage:fImg];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)pushImagePicker:(NSNumber *) numberImage{
    fromWhatImageSignalCame = numberImage;
    
    if ( !photoPicker)
    {
        photoPicker = [ [ VSPhotoPickerViewController alloc ] init ];
    }
    
    [self.navigationController pushViewController:photoPicker animated:YES];
}

- (IBAction)changeLeftUpImage:(id)sender {
    [self pushImagePicker:[NSNumber numberWithInt:0]];
}

- (IBAction)changeLeftDownImage:(id)sender {
    [self pushImagePicker:[NSNumber numberWithInt:2]];
}

- (IBAction)changeRightUpImageView:(id)sender {
    [self pushImagePicker:[NSNumber numberWithInt:1]];
}

- (IBAction)changeRightDownImageView:(id)sender {
    [self pushImagePicker:[NSNumber numberWithInt:4]];
}


- (IBAction)sendCollageAction:(id)sender
{
    //отправка сообщения использую встроенное приложение
    if ([MFMailComposeViewController canSendMail])
    {
        MFMailComposeViewController *controller = [[MFMailComposeViewController alloc] init];
        controller.mailComposeDelegate = self;
        [controller.navigationBar setBackgroundImage:[UIImage imageNamed:@"navigation_bg_iPhone.png"] forBarMetrics:UIBarMetricsDefault];
        controller.navigationBar.tintColor = [UIColor colorWithRed:51.0/255.0 green:51.0/255.0 blue:51.0/255.0 alpha:1.0];
        [controller setSubject:@""];
        [controller setMessageBody:@" " isHTML:YES];
        [controller setToRecipients:[NSArray arrayWithObjects:@"",nil]];
        UIPasteboard *pasteboard = [UIPasteboard generalPasteboard];
        UIImage *ui = previewCollageImageView.image;
        pasteboard.image = ui;
        NSData *imageData = [NSData dataWithData:UIImagePNGRepresentation(ui)];
        [controller addAttachmentData:imageData mimeType:@"image/png" fileName:@" "];
        [self presentViewController:controller animated:YES completion:NULL];
    }
    else{
        UIAlertView *alert=[[UIAlertView alloc] initWithTitle:@"alrt" message:nil delegate:self cancelButtonTitle:@"ok" otherButtonTitles: nil] ;
        [alert show];
    }
}

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error
{
    // статусы сообщения
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Result: canceled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Result: saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Result: sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Result: failed");
            break;
        default:
            NSLog(@"Result: not sent");
            break;
    }
    [self dismissViewControllerAnimated:YES completion:nil];
}
@end
