//
//  ViewController.m
//  SimpleBarCharts
//
//  Created by Flávio Silvério on 26/07/15.
//  Copyright (c) 2015 Flávio Silvério. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    SBChart *chart = [[SBChart alloc] initWithFrame:CGRectMake(0, 50, 350, 500) andValues:@[@3,@5,@[@1999,@7,@5,@2],@3,@5,@3,@5,@3,@5,@3,@5] andLabels:@[@"1",@"2",@"1",@"2000",@"1",@"2",@"7",@"6",@"90500"]];
    [self.view addSubview:chart];
    [chart setDelegate:self];
    [chart setColors:@[[UIColor redColor],[UIColor blackColor], [UIColor blueColor]]];
    [chart drawGraph];
    
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) didSelectBar:(id)sender{
    NSLog(@"hey");
}
@end
