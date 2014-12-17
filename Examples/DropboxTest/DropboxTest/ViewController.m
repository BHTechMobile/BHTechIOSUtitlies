//
//  ViewController.m
//  DropboxTest
//
//  Created by Nong Trung Nghia on 12/16/14.
//  Copyright (c) 2014 BHTech Mobile. All rights reserved.
//

#import "ViewController.h"
#import "DropboxServices.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)link:(id)sender {
    [[DropboxServices sharedServices] startSessionFromViewController:self success:^{
        NSLog(@"success");
    } failure:^(NSError * error) {
        NSLog(@"failure:%@",error);
    }];
}

- (IBAction)download:(id)sender {
    [[DropboxServices sharedServices] downloadPhoto:@"/IMG_0099.JPG" success:^(id response) {
        dispatch_async(dispatch_get_main_queue(), ^{
            _imageView.image = response;
        });
    } failure:^(NSError * error) {
        NSLog(@"%@",error);
    } progress:NULL];
}

- (IBAction)upload:(id)sender {
    [[DropboxServices sharedServices] uploadPhotosAtPath:[[NSBundle mainBundle] pathForResource:@"test1" ofType:@"jpg"] success:^(id response) {
        NSLog(@"%@",response);
    } failure:^(NSError * error) {
        NSLog(@"%@",error);
    } progress:NULL];
}

- (IBAction)list:(id)sender {
    [[DropboxServices sharedServices] browseListPhotosSuccess:^(id response) {
        NSLog(@"%@",response);
    } failure:^(NSError * error) {
        NSLog(@"%@",error);
    }];
}
- (IBAction)unlink:(id)sender {
    [[DropboxServices sharedServices] unlink];
}

@end
