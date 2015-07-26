//
//  SBChart.m
//  SimpleBarCharts
//
//  Created by Flávio Silvério on 26/05/15.
//  Copyright (c) 2015 Flávio Silvério. All rights reserved.
//

#import "SBChart.h"

@implementation SBChart


- (id) initWithFrame:(CGRect)frame andValues:(NSArray *)values andLabels:(NSArray *)labels{

    self = [super initWithFrame:frame];
    bottomLabels = labels;
    [self subdivideViews];
    
    data = [[NSMutableArray alloc] init];
    [self normalizeData:values];
    
    graphStyle = STYLE_BOTTOM_AND_SIDE_AXIS;
    //graphStyle = &style;
    
    [self configureView];
    
    
    return self;
}

- (void) configureView{

    switch (graphStyle) {
            
        case STYLE_ONLY_BARS:
            graphView = [[UIView alloc] initWithFrame:self.frame];
            [self addSubview:graphView];
            break;
            
        case STYLE_BOTTOM_AND_SIDE_AXIS:
            [self subdivideViews];
            break;
            
        case STYLE_BOTTOM_AXIS:
            
            break;
            
        default:
            graphView = [[UIView alloc] initWithFrame:self.frame];
            [self addSubview:graphView];
            break;
    }
    
}

- (void) subdivideViews{

    bottomView = [[UIView alloc] initWithFrame:CGRectMake(50, self.frame.size.height - 50, self.frame.size.width-50, 60)];
    [self generateLabels:bottomView isLeftView:NO isBottomView:YES];
    [self addSubview:bottomView];
    
    
    leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 50, self.frame.size.height-50)];
    [self addSubview:leftView];
    
    graphView = [[UIView alloc] initWithFrame:CGRectMake(50, 0, self.frame.size.width - 50, self.frame.size.height - 50)];
    [self addSubview:graphView];
    
    
}

- (void) generateLabels:(UIView *)view isLeftView:(BOOL)leftView isBottomView:(BOOL)bottomView{
    
    if(leftView) {
    
    } else if (bottomView) {

        float width = view.frame.size.width / [bottomLabels count];
        
        for (int i = 0 ; i < [bottomLabels count] ; i ++) {
            
            UILabel *l = [[UILabel alloc] initWithFrame:CGRectMake(i * width, 5, width, 25)];
            [l setText:[bottomLabels objectAtIndex:i]];
            [l setBackgroundColor:[UIColor yellowColor]];
            [view addSubview:l];
        }
        
    }
    
}

#pragma mark - Normalizing the data and drwaing the graph

- (void) normalizeData:(NSArray *)values{

    NSNumber *max = [[NSNumber alloc] initWithInt:0];
    
    //Here we find the Max of all the values that are being sent over
    for (NSArray *v in values) {
        
        for (NSNumber *f in v) {
            
            (f > max) ? max = f : 0;
            
        }
        
    }
    
    for (NSArray *v in values) {
        
        NSMutableArray *percentages = [[NSMutableArray alloc] init];
        
        for (NSNumber *f in v) {
            
            NSNumber *percentage = [[NSNumber alloc] initWithFloat: [f floatValue]/[max floatValue]];
            [percentages addObject:percentage];
        }
        
        [data addObject:percentages];
        
    }

}

- (void) drawGraph{

    float biggerArray = 0.0;
    
    for (NSArray *array in data) {
        if([array count] > biggerArray)
            biggerArray = [array count];
    }
    
    float width = graphView.frame.size.width / biggerArray;
    int currentColor = 0;
    
    for (NSArray *percentages in data) {
        
        for (int i = 0 ; i < [percentages count] ; i ++) {
            
            float buttonSize = [[percentages objectAtIndex:i] floatValue] * graphView.frame.size.height;
            UIButton *b = [[UIButton alloc] initWithFrame:CGRectMake(i*width + width*0.1, graphView.frame.size.height - buttonSize, width - width*0.2, buttonSize)];
            
            [b addTarget:self action:@selector(didSelectBar:) forControlEvents:UIControlEventTouchUpInside];
            
            if (_colors != nil) {
                
                if ([_colors count] == currentColor){
                    currentColor = 0;
                }
                
                [b setBackgroundColor:[_colors objectAtIndex:currentColor]];
                
                
            } else {
                [b setBackgroundColor:[UIColor blueColor]];
            }
            
            [self roundCornersOnView:b onTopLeft:YES topRight:YES bottomLeft:NO bottomRight:NO radius:b.frame.size.width / 4];
            
            [graphView addSubview:b];
        }
        
        currentColor++;
        
    }
    
    [self animateAllBars];
}


- (void) animateAllBars{

    NSMutableArray * sub = [[NSMutableArray alloc] init];
   // [NSValue valueWithCGRect:CGRectMake(0,0,10,10)]];
    
    for (int i = 0 ; i < [[graphView subviews] count]; i++) {
        
        UIView *currentView = [[graphView subviews] objectAtIndex:i];
        
        if([[currentView class] isSubclassOfClass:[UIButton class]]){
         
            CGRect frame = [currentView frame];
            
            [sub addObject:[NSValue valueWithCGRect:frame]];
            
            [[[graphView subviews] objectAtIndex:i] setFrame:CGRectMake(frame.origin.x + frame.size.width,
                                                                        frame.origin.y + frame.size.height,
                                                                        frame.size.width,
                                                                        0
                                                                        )];
        }
    }
    
    
    
    [UIView animateWithDuration:0.5 animations:^{
        int aux = 0;

        for (int i = 0; i < [[graphView subviews] count]; i ++) {
            if([[[[graphView subviews] objectAtIndex:i] class] isSubclassOfClass:[UIButton class]]){
                [[[graphView subviews] objectAtIndex:i] setFrame:[[sub objectAtIndex:aux] CGRectValue]];
                aux++;
            }
        }
        
    }];

}

#pragma mark - Rounding the corners of a view

-(UIView *)roundCornersOnView:(UIView *)view onTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius {
    
    if (tl || tr || bl || br) {
        UIRectCorner corner = 0; //holds the corner
        //Determine which corner(s) should be changed
        if (tl) {
            corner = corner | UIRectCornerTopLeft;
        }
        if (tr) {
            corner = corner | UIRectCornerTopRight;
        }
        if (bl) {
            corner = corner | UIRectCornerBottomLeft;
        }
        if (br) {
            corner = corner | UIRectCornerBottomRight;
        }
        
        UIView *roundedView = view;
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:roundedView.bounds byRoundingCorners:corner cornerRadii:CGSizeMake(radius, radius)];
        CAShapeLayer *maskLayer = [CAShapeLayer layer];
        maskLayer.frame = roundedView.bounds;
        maskLayer.path = maskPath.CGPath;
        roundedView.layer.mask = maskLayer;
        return roundedView;
    } else {
        return view;
    }
    
}

- (void) didSelectBar:(id) sender{
    
    if([self.delegate respondsToSelector:@selector(didSelectBar:)]){
        [self.delegate didSelectBar:sender];
    }
}

@end
