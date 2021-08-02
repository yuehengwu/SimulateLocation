//
//  TDLocationInfo.m
//  ToDo
//
//  Created by wyh on 2019/11/23.
//  Copyright © 2019 wyh. All rights reserved.
//

#import "TDLocationInfo.h"
#import "TDMapAnnotation.h"
#import "TDLocationConverter.h"

@implementation TDLocationInfo

- (void)updateWithAnnotation:(TDMapAnnotation *)annotation {
    
    if (!annotation) {
        return;
    }
    
    _locationName = annotation.title;
    _locationDetailName = annotation.subtitle;
    _latitude = annotation.coordinate.latitude;
    _longitude = annotation.coordinate.longitude;
    _identifier = annotation.identifier;
    _radius = annotation.radius;
}

- (CLCircularRegion *)convertToRegionWithIdentifier:(NSString *)identifier {
    
    CLLocationCoordinate2D coordinate = [TDLocationConverter transformFromGCJToWGS:CLLocationCoordinate2DMake(_latitude, _longitude)];
    
    CLCircularRegion *region = [[CLCircularRegion alloc]initWithCenter:coordinate radius:_radius identifier:identifier];
    return region;
}

- (TDMapAnnotation *)convertToAnnotation {
    TDMapAnnotation *annotation = [TDMapAnnotation annotationWithCoordinate:CLLocationCoordinate2DMake(_latitude, _longitude) identifier:_identifier];
    annotation.title = _locationName;
    annotation.subtitle = _locationDetailName;
    annotation.radius = _radius;
    return annotation;
}

@end
