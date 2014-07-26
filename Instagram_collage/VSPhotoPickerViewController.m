//
//  VSPhotoPickerViewController.m
//  Instagram_collage
//
//  Created by Admin on 25.07.14.
//  Copyright (c) 2014 MSU. All rights reserved.
//

#import "VSPhotoPickerViewController.h"
#import "VSStartScreenViewController.h"
#import "VSPreviewViewController.h"

@interface VSPhotoPickerViewController ()

@end

@implementation VSPhotoPickerViewController
@synthesize galleryPhotoPickerCollectionView, arrayWithData, userId, previousMaxId;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        arrayWithData = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    VSStartScreenViewController *userPage = [[self.navigationController viewControllers] objectAtIndex:(0)];
    
    userId = [NSString stringWithString:userPage.userId];
    
    galleryPhotoPickerCollectionView.delegate = self;
    galleryPhotoPickerCollectionView.dataSource = self;
    galleryPhotoPickerCollectionView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    [arrayWithData removeAllObjects];
    [self.galleryPhotoPickerCollectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:@"Cell"];
}

-(NSData *) getJSONWithImagesList:(NSString *)maxIdFromPrevious
{
    //формируем запрос
    NSMutableString *stringWithURL = [NSMutableString stringWithString:@"https://api.instagram.com/v1/users/"];
    [stringWithURL appendString:userId];
    //берем 35 последних видео/изображений (максимальное колличество которое может вернуть сервер)
    [stringWithURL appendString:@"/media/recent"];
    //так как мы получаем данные порциями по 33 штук, то получаем новую порцию, где остановились получать последнюю
    if( ![maxIdFromPrevious isEqual:@""] ){
        [stringWithURL appendString:@"?max_timestamp="];
        [stringWithURL appendString:maxIdFromPrevious];
    }
    else
        [stringWithURL appendString:@"?count=33"];
    //добавляем идентификатор нашего клиента
    [stringWithURL appendString:@"&client_id=5eafaf236c394dcb9751df90580620c1"];
    
    //получаем из строки запрос
    NSURL *responseForList = [NSURL URLWithString:stringWithURL];
    //получаем и возвращаем наш JSON
    return [self getJSON:responseForList];
}

-(NSData *) getJSON:(NSURL *)url{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
    [request setURL:url];
    NSError *error = [[NSError alloc] init];
    NSHTTPURLResponse *responseCode = nil;
    NSData *responseData = [NSURLConnection sendSynchronousRequest:request returningResponse:&responseCode error:&error];
    
    if([responseCode statusCode] != 200){
        NSLog(@"Error getting %@, HTTP status code %i", url, [responseCode statusCode]);
        responseCode = nil;
        return nil;
    } else {
        responseCode = nil;
        return responseData;
    }
}

-(void) getNewPortionOfData:(BOOL)isFirst
{
    //получаем изображения частями
    VSStartScreenViewController *userPage = [[self.navigationController viewControllers] objectAtIndex:(0)];
    
    unsigned int iterator = 0;
    
    NSData *json;
    
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *jsonObject;
    
    NSArray *array;
    
    //получить JSON
    if ( isFirst)
        json = [self getJSONWithImagesList:@""];
    else
        json = [self getJSONWithImagesList:previousMaxId];
    
    jsonObject = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves error:&error];
    //массив с ссылками изображений и прочей информацией
    array = [jsonObject objectForKey:@"data"];
    
    //сбрасываем все изображения в массив, чтобы потом их отбразить
    for (iterator = 0; iterator < [array count]; iterator++) {
        if( [[[array objectAtIndex:iterator] objectForKey:@"type"] isEqualToString:@"image"] ){
            [arrayWithData addObject:[[[[array objectAtIndex:iterator] objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"]];
        }
    }
    previousMaxId = [NSString stringWithString:[[array lastObject] objectForKey:@"created_time"]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [arrayWithData removeAllObjects];
    [self getNewPortionOfData:YES];
    [galleryPhotoPickerCollectionView reloadData];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [arrayWithData removeAllObjects];
    [galleryPhotoPickerCollectionView reloadData];
}

- (NSInteger)numberOfSectionsInCollectionView: (UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    NSLog(@"amount of items = %d",[arrayWithData count]);
    return [arrayWithData count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"Cell";
    
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    if (cell == nil)
    {
        NSLog(@"create cell");
        cell = [[UICollectionViewCell alloc] init];
    }
    //отображение изображения в ячейке
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,50,50)];
    imgView.contentMode = UIViewContentModeScaleAspectFit;
    imgView.clipsToBounds = YES;
    [imgView setImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:[arrayWithData objectAtIndex:indexPath.row]]]]];
    
    [cell addSubview:imgView];
    
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    //привыделении заменять изображение
    if( indexPath.row < [arrayWithData count] ){
        NSLog(@"tap");
        VSPreviewViewController *preview = [[self.navigationController viewControllers] objectAtIndex:(1)];
        [preview.imagesData replaceObjectAtIndex:[preview.fromWhatImageSignalCame intValue] withObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[arrayWithData objectAtIndex:indexPath.row]]]];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
