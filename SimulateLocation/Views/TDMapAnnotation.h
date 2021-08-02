//
//  TDMapAnnotation.h
//  ToDo
//
//  Created by wyh on 2019/11/22.
//  Copyright © 2019 wyh. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TDLocationInfo.h"

@interface TDMapAnnotation : NSObject <MKAnnotation>

/// GCJ coordinate , use in MapKit.
@property (nonatomic, assign) CLLocationCoordinate2D coordinate;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *subtitle;

@property (nonatomic, assign) CGFloat radius;

@property (nonatomic, copy) NSString *identifier;

+ (instancetype)annotationWithCoordinate:(CLLocationCoordinate2D)coordinate identifier:(NSString *)identifier;

@end

@interface TDMapAnnotation (ConvertToLocationInfo)

- (TDLocationInfo *)convertToLocationInfo;

@end
