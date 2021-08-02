//
//  TDMapCircle.h
//  ToDo
//
//  Created by wyh on 2019/11/22.
//  Copyright © 2019 wyh. All rights reserved.
//

#import <MapKit/MapKit.h>

@interface TDMapCircle : MKCircle


@end


@interface TDMapCircleRenderer : MKCircleRenderer

- (instancetype)initWithOverlay:(id<MKOverlay>)overlay isAlreadyMonitored:(BOOL)monitored;


@end

