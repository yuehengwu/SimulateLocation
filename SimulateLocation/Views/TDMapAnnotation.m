//
//  TDMapAnnotation.m
//  ToDo
//
//  Created by wyh on 2019/11/22.
//  Copyright © 2019 wyh. All rights reserved.
//

#import "TDMapAnnotation.h"

@implementation TDMapAnnotation

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate identifier:(NSString *)identifier {
    TDMapAnnotation *annotation = [[TDMapAnnotation alloc]initWithCoordinate:coordinate Title:nil Radius:0 Identifier:identifier];
    return annotation;
}

- (instancetype)initWithCoordinate:(CLLocationCoordinate2D)coordinate
                             Title:(NSString *)title
                            Radius:(CGFloat)radius
                        Identifier:(NSString *)identifier {
    self = [super init];
    if (self) {
        self.coordinate = coordinate;
        self.title = title;
        self.radius = radius;
        self.identifier = identifier;
    }
    return self;
}

- (TDLocationInfo *)convertToLocationInfo {
    
    TDLocationInfo *info = [[TDLocationInfo alloc]init];
    info.locationName = _title;
    info.locationDetailName = _subtitle;
    info.radius = _radius;
    info.identifier = _identifier;
    info.latitude = _coordinate.latitude;
    info.longitude = _coordinate.longitude;

    return info;
}

@end
