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
    yValues = [[NSMutableArray alloc] init];

    data = [[NSMutableArray alloc] init];
    [self normalizeData:values];
    
    graphStyle = STYLE_ONLY_BARS;
    //graphStyle = &style;
    barSpacing = 8.0;
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

- (void) generateYValues:(float)max{

    float auxMultiplier = 1;
    int auxMax = max;
    float aux = 1;
    
    while (auxMax > 10) {
        auxMax /= 10;
        auxMultiplier++;
    }
    aux = auxMax;
    
    for (int i = 1; i < auxMultiplier ; i++) {
        auxMax *= 10;
    }
    
    if((float)auxMax < max){
        auxMax = ++aux;
        for (int i = 1; i < auxMultiplier; i++) {
            auxMax *= 10;
        }
        multiplier = max/auxMax;
    } else {
        auxMax = max;
        multiplier = 1;
    }
    
    for (float i = 5;  i > 0; i--) {
        [yValues addObject:[NSNumber numberWithInt:auxMax*(i/5)]];
    }
    NSLog(@"%@",yValues);
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
    //Check for the type that is being processed
    
    for (NSObject *o in values) {
        
        if([[o class] isSubclassOfClass:[NSArray class]]){
            for (NSNumber *f in (NSArray *) o ) {
                
                if([f floatValue] > [max floatValue]){
                    max = f;
                }
            }
        } else if([[o class] isSubclassOfClass:[NSNumber class]]){
            if([(NSNumber *)o floatValue] > [max floatValue]){
                max = (NSNumber *) o;
            }
        }
        
    }
    
    [self generateYValues:[max floatValue]];
    
    for (NSObject *o in values) {
        
        
        //if you only use simple graphs (eg.: one bar graphs) it will never come here
        if([[o class] isSubclassOfClass:[NSArray class]]){
            
            NSMutableArray *p = [[NSMutableArray alloc] init];
            
            for (NSNumber *f in (NSArray *) o ) {
                
                NSNumber *percentage = [[NSNumber alloc] initWithFloat: [f floatValue]/[max floatValue]];
                [p addObject:percentage];
            }
            
            [data addObject:(NSArray *) p ];
            
        } else if([[o class] isSubclassOfClass:[NSNumber class]]){
            //This is where the one line graphs are changed
            NSNumber *percentage = [[NSNumber alloc] initWithFloat: [(NSNumber *) o floatValue]/[max floatValue]];
            [data addObject:percentage];
        }
                
    }

}

- (void) drawGraph{

    
    float width = graphView.frame.size.width / [data count];
    int currentColor = 0;
    int colorCounter = 0;
    
    for (int i= 0 ; i < [data count] ; i++) {
        
        NSObject *o = [data objectAtIndex:i];
        
        if([[o class] isSubclassOfClass:[NSArray class]]){
            
            for (int j = 0 ; j < [(NSArray *)o count]; j++) {
                
                NSNumber *percentage = [(NSArray *)o objectAtIndex:j];
                
                if([_colors count] > j){
                    
                } else {
                    colorCounter = 0;
                }
                
                float buttonSize = [percentage floatValue] * graphView.frame.size.height * multiplier;
                
                [self addBar:CGRectMake(i * width + barSpacing, graphView.frame.size.height - buttonSize, width - barSpacing, buttonSize) withColor:[_colors objectAtIndex:colorCounter]];
                colorCounter++;
                
            }
            //CGRectMake(i*width + width*0.1, graphView.frame.size.height - buttonSize, width - width*0.2, buttonSize)
        } else if([[o class] isSubclassOfClass:[NSNumber class]]){
        
            float buttonSize = [[data objectAtIndex:i] floatValue] * graphView.frame.size.height * multiplier;
            [self addBar:CGRectMake(i * width + barSpacing, (graphView.frame.size.height - buttonSize), width - barSpacing, buttonSize) withColor:[_colors objectAtIndex:0]];

        }
        
        
        currentColor++;
        
    }
    
    [self animateAllBars];
}

- (void) addBar:(CGRect) frame withColor:(UIColor *)color{
    
    UIButton *b = [[UIButton alloc] initWithFrame:frame];
    
    [b addTarget:self action:@selector(didSelectBar:) forControlEvents:UIControlEventTouchUpInside];
    [b setBackgroundColor:color];

    
    [self roundCornersOnView:b onTopLeft:YES topRight:YES bottomLeft:NO bottomRight:NO radius:b.frame.size.width / 4];
    
    [graphView addSubview:b];
}

- (void) animateAllBars{

    //This will animate all the bars
    NSMutableArray * sub = [[NSMutableArray alloc] init];
    
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
