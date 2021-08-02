//
//  TDMapAnnotationView.m
//  ToDo
//
//  Created by wyh on 2019/11/22.
//  Copyright © 2019 wyh. All rights reserved.
//

#import "TDMapAnnotationView.h"


@interface TDMapAnnotationView ()

@property (nonatomic, assign) BOOL isZooming;

@end

@implementation TDMapAnnotationView

+ (instancetype)createAnnotationViewWithAnnotation:(id<MKAnnotation>)annotation ReuseIdentifier:(NSString *)reuseIdentifier {
    
    TDMapAnnotationView *annotationView = [[TDMapAnnotationView alloc]initWithAnnotation:annotation reuseIdentifier:reuseIdentifier];
    return annotationView;
}

- (instancetype)initWithAnnotation:(id<MKAnnotation>)annotation reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithAnnotation:annotation reuseIdentifier:reuseIdentifier]) {
        self.canShowCallout = YES;
        self.draggable = NO;
        self.image = [UIImage imageNamed:@"img_location_myDefenseArea"];
    }
    return self;
    
}

- (void)layoutSubviews {
    
    [self updateShadow];
}

- (void)updateShadow {
    
    CALayer *layer = self.layer;
    layer.shadowOpacity = 0.2f;
    layer.shadowRadius = 3.f;
    layer.shadowPath = [UIBezierPath bezierPathWithRect:CGRectMake(self.bounds.size.width*0.5-1.f, self.bounds.size.height, 10.f, 2.f)].CGPath;
}

- (void)zoomInIfDraggingBegin {
    
    if (_isZooming) return;
    
    _isZooming = YES;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        self.transform = CGAffineTransformMakeScale(1.5f, 1.5f);
        
    } completion:^(BOOL finished) {
        
    }];
}

- (void)zoomOutIfDraggingEnd {
    
    if (!_isZooming) return;
    
    [UIView animateWithDuration:0.2f animations:^{
        
        self.transform = CGAffineTransformMakeScale(1.f, 1.f);
        
    } completion:^(BOOL finished) {
       
        self.isZooming = NO;
        
    }];
}

- (void)zoomAnimationDropIfDraggingEnd {
    
    CGPoint mapCenter = CGPointMake(UIScreen.mainScreen.bounds.size.width*0.5, UIScreen.mainScreen.bounds.size.height*0.5);
    
    self.center = CGPointMake(mapCenter.x, mapCenter.y-15);
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.center = mapCenter;
        
    }completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.05 animations:^{
                self.transform = CGAffineTransformMakeScale(1.0, 0.8);
                
            }completion:^(BOOL finished){
                if (finished) {
                    [UIView animateWithDuration:0.1 animations:^{
                        self.transform = CGAffineTransformIdentity;
                    }];
                }
            }];
            
        }
    }];
    
    
}

@end
