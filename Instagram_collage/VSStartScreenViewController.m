//
//  VSStartScreenViewController.m
//  Instagram_collage
//
//  Created by Admin on 24.07.14.
//  Copyright (c) 2014 MSU. All rights reserved.
//

#import "VSStartScreenViewController.h"


@interface VSStartScreenViewController ()

@end

@implementation VSStartScreenViewController

@synthesize userNameTextField;
@synthesize makeCollageButton;
@synthesize userId;
@synthesize previewViewController;
@synthesize topPhotos, activityIndicator;

NSString *CLIENT_ID = @"5eafaf236c394dcb9751df90580620c1";

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        userId = [[NSMutableString alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [activityIndicator setHidden:YES];
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

-(NSString *) getUserIdfromUserName:(NSString *)userName{
    //собираем строку запроса поиска для получения userId
    NSMutableString *stringResponse;
    stringResponse = [NSMutableString stringWithString:@"https://api.instagram.com/v1/users/search?q="];
    [stringResponse appendString:userName];
    [stringResponse appendString:@"&client_id="];
    [stringResponse appendString:CLIENT_ID];
    
    //оформляем строку в запрос
    NSURL *response = [ NSURL URLWithString:stringResponse ];
    //получаем json со списком результатов поиска
    NSData *responseData = [self getJSON:response];
    
    NSError *error = [[NSError alloc] init];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableLeaves error:&error];
    
    NSArray *dataArray = [jsonObject objectForKey:@"data"];
    
    //выбираем из списка первый результат
    NSString *getId = [[dataArray objectAtIndex:0] objectForKey:@"id"];
    
    //если то, что мы искали совпадает с первым результатом в списке, то вернуть id
    if( [userName isEqualToString:[[dataArray objectAtIndex:0] objectForKey:@"username"]] ){
        NSLog(@"id:%@",getId);
        
        return getId;
    }
    else{
        //если не совпадает, то считаем, что такого пользователя нет
        NSLog(@"Нет такого пользователя");
        return nil;
    }
    
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
    [stringWithURL appendString:@"&client_id="];
    [stringWithURL appendString:CLIENT_ID];
    
    //получаем из строки запрос
    NSURL *responseForList = [NSURL URLWithString:stringWithURL];
    //получаем и возвращаем наш JSON
    return [self getJSON:responseForList];
}

-(unsigned int)getMediaCountForUser
{
    NSMutableString *stringWithURL = [NSMutableString stringWithString:@"https://api.instagram.com/v1/users/"];
    [stringWithURL appendString:userId];
    [stringWithURL appendString:@"/"];
    //добавляем идентификатор нашего клиента
    [stringWithURL appendString:@"?client_id="];
    [stringWithURL appendString:CLIENT_ID];
    
    NSError *error = [[NSError alloc] init];
    NSURL *responseForInfo = [NSURL URLWithString:stringWithURL];
    NSData *json = [self getJSON:responseForInfo];
    NSDictionary *jsonObject = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves error:&error];
    
    return [[[[jsonObject objectForKey:@"data"] objectForKey:@"counts" ] objectForKey:@"media"] intValue];
}

-(NSMutableArray *) getMostPopular4Photos
{
    NSMutableArray *mostPopularImages = [NSMutableArray arrayWithCapacity:4];
    int countLikesOfMostPopularImages[4];
    
    for( unsigned int i = 0; i < 4; i++){
        countLikesOfMostPopularImages[i] = -1;
        [mostPopularImages addObject:@""];
    }
    
    int currentLikes;
    unsigned int iterator = 0;
    
    NSData *json;
    
    NSError *error = [[NSError alloc] init];
    NSMutableDictionary *jsonObject;// = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves error:&error];
    
    NSArray *array;// = [jsonObject objectForKey:@"data"];
    
    NSMutableDictionary *currentElem;
    
    BOOL isFirstPortion = YES;
    
    NSString *previous_max_id;
    
    unsigned int barrier = [self getMediaCountForUser];
    unsigned int currentAmountOfMedia = 0;
    
    do{
        //получить JSON
        if ( isFirstPortion ){
            json = [self getJSONWithImagesList:@""];
            isFirstPortion = NO;
        }
        else
            json = [self getJSONWithImagesList:previous_max_id];
        
        if(json == nil)
            break;
        
        jsonObject = [NSJSONSerialization JSONObjectWithData:json options:NSJSONReadingMutableLeaves error:&error];
        //массив с ссылками изображений и прочей информацией
        array = [jsonObject objectForKey:@"data"];
        
        //получить четверку топовых изображений среди уже полученных списков с изображениями
        for( unsigned int indexCurrentLocalMaximum = 0; indexCurrentLocalMaximum < 4; indexCurrentLocalMaximum++ ){
            
            iterator = 0;
            //просматриваем массив и находим максимумы последовательно
            for (iterator = 0; iterator < [array count]; iterator++) {
                
                //берем только тип изображения
                if( [[[array objectAtIndex:iterator] objectForKey:@"type"] isEqualToString:@"image"] ){
                    
                    //посмотрим количество лайков
                    currentElem = [[array objectAtIndex:iterator] objectForKey:@"likes"];
                    currentLikes = [[currentElem objectForKey:@"count"] intValue];
                    
                    //возможно это изображение уже было взято на наибольшей позиции
                    //все изображения должны быть разными
                    BOOL isAlredyInArray = FALSE;
                    
                    //просматриваем на поиск наибольшего
                    if( currentLikes > countLikesOfMostPopularImages[indexCurrentLocalMaximum]){
                        
                        //просматриваем не брали ли мы уже его
                        for ( int j = 0; j < indexCurrentLocalMaximum && isAlredyInArray == FALSE; j++) {
                            
                            NSString *currentURLString = [[[[array objectAtIndex:iterator] objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"];
                            //сравниваем для этого ссылки на изображения
                            isAlredyInArray = [ currentURLString isEqualToString:[ mostPopularImages objectAtIndex:j ] ];
                            
                        }
                        
                        //если его еще нет, то добавим его
                        if( isAlredyInArray == FALSE ){
                            
                            [mostPopularImages replaceObjectAtIndex:indexCurrentLocalMaximum withObject:[[[[array objectAtIndex:iterator] objectForKey:@"images"] objectForKey:@"thumbnail"] objectForKey:@"url"]];
                            countLikesOfMostPopularImages[indexCurrentLocalMaximum] = currentLikes;
                        }
                    }
                }
            }
        }
        //теперь необходимо узнать id последнего поста, чтобы продолжить поиск
        previous_max_id = [NSString stringWithString:[[array lastObject] objectForKey:@"created_time"]];
        currentAmountOfMedia += [array count];
        NSLog(@"count = %i",[array count]);
        NSLog(@"count = %i",currentAmountOfMedia);
        
    }while ( currentAmountOfMedia < barrier );
    
    for( iterator = 0; iterator < 4; iterator++){
        
        if( countLikesOfMostPopularImages[iterator] == -1 ){
            return nil;
        }
    }
    
    return mostPopularImages;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)makeImage:(id)sender {

    
    //получаем userId
    userId = [self getUserIdfromUserName:[userNameTextField text]];
    
    topPhotos = [self getMostPopular4Photos];
    
    if ( !previewViewController)
    {
        previewViewController = [ [ VSPreviewViewController alloc ] init ];
    }
    
    for( unsigned int i = 0; i < 4; i++)
        [previewViewController.imagesData replaceObjectAtIndex:i withObject:[NSData dataWithContentsOfURL:[NSURL URLWithString:[topPhotos objectAtIndex:i]]]];
    
    previewViewController.userId = [NSString stringWithString:userId];
    
    [self.navigationController pushViewController:previewViewController animated:YES];
}
@end
