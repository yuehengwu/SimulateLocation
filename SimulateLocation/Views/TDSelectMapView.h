//
//  TDSelectMapView.h
//  ToDo
//
//  Created by wyh on 2019/11/22.
//  Copyright © 2019 wyh. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TDMapAnnotation.h"

@class TDSelectMapView;

@protocol TDSelectMapViewDelegate <NSObject>

- (void)mapView:(TDSelectMapView *)mapView didUpdateCurrentLocation:(NSString *)location coordinate:(CLLocationCoordinate2D)coordinate;

@end

@interface TDSelectMapView : UIView

@property (nonatomic, strong, readonly) TDMapAnnotation *currentAnnotation;

- (instancetype)initWithFrame:(CGRect)frame annotation:(TDMapAnnotation *)annotation  delegate:(id<TDSelectMapViewDelegate>)delegate;

- (void)Map_selectAnnotation:(TDMapAnnotation *)annotation animated:(BOOL)animated;
- (void)Map_addOverLayFromAnnotation:(TDMapAnnotation *)annotation;

@end

