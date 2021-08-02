//
//  TDLocationInfo.h
//  ToDo
//
//  Created by wyh on 2019/11/23.
//  Copyright © 2019 wyh. All rights reserved.
//


#import <CoreGraphics/CoreGraphics.h>
#import <CoreLocation/CoreLocation.h>

@class TDMapAnnotation;

@interface TDLocationInfo : NSObject

@property (nonatomic, copy) NSString *locationName;

@property (nonatomic, copy) NSString *locationDetailName;

@property (nonatomic, copy) NSString *identifier;

@property (nonatomic, assign) NSInteger radius;

@property (nonatomic, assign) CGFloat latitude;

@property (nonatomic, assign) CGFloat longitude;

@property (nonatomic, assign) BOOL isRepeat;

- (void)updateWithAnnotation:(TDMapAnnotation *)annotation;

- (CLCircularRegion *)convertToRegionWithIdentifier:(NSString *)identifier;

- (TDMapAnnotation *)convertToAnnotation;

@end

