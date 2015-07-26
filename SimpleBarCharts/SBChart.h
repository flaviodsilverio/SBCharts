//
//  SBChart.h
//  SimpleBarCharts
//
//  Created by Flávio Silvério on 26/05/15.
//  Copyright (c) 2015 Flávio Silvério. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SBChartDelegate <NSObject>

@required

@optional
- (void) didSelectBar:(id) sender;

@end

typedef enum GraphStyle
{
    
    STYLE_ONLY_BARS = 0,
    STYLE_BOTTOM_AXIS = 1,
    STYLE_BOTTOM_AND_SIDE_AXIS = 2
    
} GraphStyle;

@interface SBChart : UIView
{
    GraphStyle graphStyle;
    NSArray *bottomLabels;
    NSMutableArray *data;
    UIView *graphView;
    UIView *bottomView;
    UIView *leftView;

}

@property (weak) id <SBChartDelegate> delegate; 

@property (strong, nonatomic) UIFont *font;
@property (strong, nonatomic) NSArray *colors;

- (id) initWithFrame:(CGRect)frame andValues:(NSArray *)values andLabels:(NSArray *)labels;
- (void) drawGraph;


@end
