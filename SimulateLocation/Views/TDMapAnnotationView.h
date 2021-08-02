//
//  TDMapAnnotationView.h
//  ToDo
//
//  Created by wyh on 2019/11/22.
//  Copyright © 2019 wyh. All rights reserved.
//

#import <MapKit/MapKit.h>

static NSString * const TDLocationAnnotationViewReuseIdentifier = @"TDLocationAnnotationViewReuseIdentifier";

@interface TDMapAnnotationView : MKAnnotationView

+ (instancetype)createAnnotationViewWithAnnotation:(id<MKAnnotation>)annotation ReuseIdentifier:(NSString *)reuseIdentifier;

- (void)zoomInIfDraggingBegin;

- (void)zoomOutIfDraggingEnd;

- (void)zoomAnimationDropIfDraggingEnd;

@end


