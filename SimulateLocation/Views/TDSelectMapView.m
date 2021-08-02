//
//  TDSelectMapView.m
//  ToDo
//
//  Created by wyh on 2019/11/22.
//  Copyright © 2019 wyh. All rights reserved.
//

#import "TDSelectMapView.h"
#import "TDMapAnnotation.h"
#import "TDMapAnnotationView.h"
#import "TDMapCircle.h"

#import "TDLocationService.h"

#import <MapKit/MapKit.h>

static CGFloat const kMapViewDefaultDistance = 500.f;

typedef NS_ENUM(NSInteger, TDMapViewDragGestureState) {
    // Custom MapView's pan gestureRecognizer state for update annotationView's position.
    
    TDMapViewDragGestureStateNotStart ,
    
    TDMapViewDragGestureStateBegin ,
    TDMapViewDragGestureStateChanging,
    TDMapViewDragGestureStateEnd ,
    TDMapViewDragGestureStateCanceled,
};


@interface TDSelectMapView () <MKMapViewDelegate,TDLocationServiceDelegate>

@property (nonatomic, weak) id<TDSelectMapViewDelegate> delegate;

@property (nonatomic, strong) TDMapAnnotation *currentAnnotation;

@property (nonatomic, assign) CLLocationCoordinate2D currentRegionCoordinate;

@property (nonatomic, strong) TDMapCircle *currentOverlay;


@property (nonatomic, assign) BOOL isFirstUpdateLocation;
@property (nonatomic, assign) TDMapViewDragGestureState dragState;

// ui
@property (nonatomic, strong) UIPanGestureRecognizer *mapViewPanGestureRecognizer;
@property (nonatomic, strong) MKMapView *mapView;
@property (nonatomic, strong) UIImageView *centerAddressView;

@end

@implementation TDSelectMapView

- (void)dealloc {
    [TDLocationService stopMonitorUserLocation];
}

- (instancetype)initWithFrame:(CGRect)frame annotation:(TDMapAnnotation *)annotation delegate:(id<TDSelectMapViewDelegate>)delegate {
    if (self = [super initWithFrame:frame]) {
        _currentAnnotation = annotation;
        _delegate = delegate;
        [self initialize];
        [self configUI];
        [self loadCurrentLocation];
    }
    return self;
}

#pragma mark - Methods

- (void)initialize {
    

    if (!_currentAnnotation) {
        _isFirstUpdateLocation = YES;
        [TDLocationService startMonitorUserLocation];
    }else {
        _isFirstUpdateLocation = NO;
        
        [self Map_zoomMapViewToLocation:_currentAnnotation.coordinate withLatitudeDistance:kMapViewDefaultDistance longitudeDistance:kMapViewDefaultDistance animated:NO];
        [self Map_addOverLayFromAnnotation:_currentAnnotation];
        
    }
    _dragState = TDMapViewDragGestureStateNotStart;
    _currentRegionCoordinate = kCLLocationCoordinate2DInvalid;
    
    [TDLocationService registMonitorLocaitonServiceWithHandler:self];
    
}

- (void)loadCurrentLocation {
    
    if (!_currentAnnotation) {
        if (!TDLocationService.sharedLocationService.userLocation) {
            return;
        }
        CLLocationCoordinate2D userCoordinate = [TDLocationConverter transformFromWGSToGCJ:TDLocationService.sharedLocationService.userLocation.coordinate];
        NSString *identifier = [NSString stringWithFormat:@"%f",[NSDate.date timeIntervalSince1970]];
        NSLog(@"Annotation identifier is %@",identifier);
        _currentAnnotation = [TDMapAnnotation annotationWithCoordinate:userCoordinate identifier:identifier];
        
        _currentAnnotation.radius = 100.f;
        [self Map_zoomMapViewToLocation:userCoordinate withLatitudeDistance:kMapViewDefaultDistance longitudeDistance:kMapViewDefaultDistance animated:NO];
        //        [self.mapView selectAnnotation:self.currentAnnotation animated:NO];
        [self Map_addOverLayFromAnnotation:_currentAnnotation];
        [self refreshCurrentLocationInformation];
    }else {
        
        [self Map_zoomMapViewToLocation:_currentAnnotation.coordinate withLatitudeDistance:kMapViewDefaultDistance longitudeDistance:kMapViewDefaultDistance animated:NO];
        //        [self.mapView selectAnnotation:self.currentAnnotation animated:NO];
        [self Map_addOverLayFromAnnotation:_currentAnnotation];
        [self refreshCurrentLocationInformation];        
    }
    
}

#pragma mark - Gesture

- (void)mapViewPanGesture:(UIPanGestureRecognizer *)panGesture {
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:{
            _dragState = TDMapViewDragGestureStateBegin;
//            DDLogDebug(@"MapView pan Began");
        }
            break;
        case UIGestureRecognizerStateChanged:{
            _dragState = TDMapViewDragGestureStateChanging;

//            DDLogDebug(@"MapView pan Changed");
        }
            break;
        case UIGestureRecognizerStateCancelled:{
            _dragState = TDMapViewDragGestureStateCanceled;
//            DDLogDebug(@"MapView pan Cancelled");
        }
            break;
        case UIGestureRecognizerStateEnded:{
            _dragState = TDMapViewDragGestureStateEnd;
//            DDLogDebug(@"MapView pan Ended");
        }
            break;
            
        default:
            break;
    }
}

#pragma mark - Map operation

/**
 Select a annotationView.
 */
- (void)Map_selectAnnotation:(TDMapAnnotation *)annotation animated:(BOOL)animated {
    if (annotation == nil) {
        return;
    }
    [self.mapView selectAnnotation:annotation animated:animated]; // Auto selected.
    [self Map_zoomMapViewToCenter:annotation.coordinate animated:animated];
}

- (void)Map_addOverLayFromAnnotation:(TDMapAnnotation *)annotation {
    if (!annotation) {
        return;
    }
    if (_currentOverlay != nil) {
        [self.mapView removeOverlay:_currentOverlay];
    }
    _currentOverlay = [TDMapCircle circleWithCenterCoordinate:annotation.coordinate radius:annotation.radius];
    [self.mapView addOverlay:_currentOverlay];
    
}


- (void)Map_zoomMapViewToLocation:(CLLocationCoordinate2D)coordinate
             withLatitudeDistance:(CLLocationDistance)latitudeDistance
                longitudeDistance:(CLLocationDistance)longitudeDistance
                         animated:(BOOL)animated {
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(coordinate, latitudeDistance, longitudeDistance);
    [self.mapView setRegion:region animated:animated];
}

- (void)Map_zoomMapViewToCenter:(CLLocationCoordinate2D)coordinate animated:(BOOL)animated {
    if (!CLLocationCoordinate2DIsValid(coordinate)) {
//        [TDToast show:(TDUIToastTypeInfo) message:@"Invalid coordinate, please input double value !"];
        return;
    }
    [self.mapView setCenterCoordinate:coordinate animated:animated];
}

#pragma mark - GeoCode


- (void)refreshPositionIfRegionChanged {
    
//    CGPoint point = CGPointMake(self.view.bounds.size.width*0.5, self.view.bounds.size.height*0.5);
//    CLLocationCoordinate2D pointCoordinate = [self.mapView convertPoint:point toCoordinateFromView:self.view]; //GCJ
    CLLocationCoordinate2D pointCoordinate = _mapView.region.center;
    _currentAnnotation.coordinate = pointCoordinate;
}


- (void)refreshCurrentLocationInformation {
        
    @weakify(self);
    [self reverseGeocodeCurrentDefenseAreaLocationWithLanguage:(TDLocationLocaleLanguageZH_Has) Complete:^(CLPlacemark *placemark, NSError *error) {
        @strongify(self);
        
        NSString *locationName = placemark.name;
        
        if (error) {
            NSLog(@"未获取到位置:%@",error);
            self.currentAnnotation.title = nil;
        }else {
            NSLog(@"获取的当前区域位置:%@",locationName);
            self.currentAnnotation.title = locationName;
            if ([self.delegate respondsToSelector:@selector(mapView:didUpdateCurrentLocation:coordinate:)]) {
                [self.delegate mapView:self didUpdateCurrentLocation:locationName coordinate:self.currentAnnotation.coordinate];
            }
        }
    }];
}

/**
 Reverse geocode according to the current coordinate !
 */
- (void)reverseGeocodeCurrentDefenseAreaLocationWithLanguage:(TDLocationLocaleLanguage)language
                                                    Complete:(void(^)(CLPlacemark *placemark, NSError *error))completion {
        
    CLLocationCoordinate2D reverseCoordinate = _currentAnnotation.coordinate;
            
    [TDLocationService reverseGeocodeLocationWithCoordinate:reverseCoordinate preferredLanguage:language completeHandler:^(CLPlacemark *placemark , NSError *error) {

        completion(placemark,error);
        
        // For debug test
        {
            NSString *Zip = placemark.postalCode; //邮政编码
            NSString *Country = placemark.ISOcountryCode; //国家 (也可以使用ISOcountryCode，eg. US)
            NSString *State = placemark.administrativeArea; //省 / 州
            NSString *City = ({ //市
                NSString *city = nil;
                if (!placemark.locality.length) {
                    city = placemark.administrativeArea;
                }else {
                    city = placemark.locality;
                }
                city;
            });
            NSString *StreetName = placemark.thoroughfare; //街道
            NSString *StreetNumber = placemark.subThoroughfare; //街道号
            NSString *AddressLine = placemark.name; //具体位置
            NSTimeZone *TimeZone = placemark.timeZone; //时区
            
            NSString *debugText = [NSString stringWithFormat:@"Latitude:%g\nLongitude:%g\nZip:%@\nCountry:%@\nState:%@\nCity:%@\nStreetName:%@\nStreetNumber:%@\nAddressLine:%@\nTimeZone:%@\n",self.currentAnnotation.coordinate.latitude,self.currentAnnotation.coordinate.longitude,Zip,Country,State,City,StreetName,StreetNumber,AddressLine,TimeZone.name];
            
            NSLog(@"Debug location:%@",debugText);
                      
        }
    }];
}

#pragma mark - TDLocationServiceDelegate

- (void)TDLocationService:(TDLocationService *)service didUpdateLocation:(CLLocation *)location {
    
    if (!_isFirstUpdateLocation) {
        return;
    }
    
    CLLocationCoordinate2D userCoordinate = [TDLocationConverter transformFromWGSToGCJ:location.coordinate];
        
    if (!_currentAnnotation) {
        _currentAnnotation = [TDMapAnnotation annotationWithCoordinate:userCoordinate identifier:[NSString stringWithFormat:@"%f",[NSDate.date timeIntervalSince1970]*1000]];
        _currentAnnotation.radius = 100.f;
        [self Map_zoomMapViewToLocation:userCoordinate withLatitudeDistance:kMapViewDefaultDistance longitudeDistance:kMapViewDefaultDistance animated:NO];
        //        [self.mapView selectAnnotation:self.currentAnnotation animated:NO];
        [self Map_addOverLayFromAnnotation:_currentAnnotation];
    }
    
    // Show user's location
    [self refreshCurrentLocationInformation];
    
    _isFirstUpdateLocation = NO;
}


#pragma mark - MKMapViewDelegate

- (MKOverlayRenderer *)mapView:(MKMapView *)mapView rendererForOverlay:(id<MKOverlay>)overlay {
    if ([overlay isKindOfClass:TDMapCircle.class]) {
        TDMapCircleRenderer *circleRenderer = [[TDMapCircleRenderer alloc]initWithOverlay:overlay isAlreadyMonitored:YES];
        return circleRenderer;
    }
    return nil;
}


- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation {
    
    if ([annotation isKindOfClass:[TDMapAnnotation class]]) {
        
        TDMapAnnotationView *annotationView = (TDMapAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TDLocationAnnotationViewReuseIdentifier];
        if (!annotationView) {
            annotationView = [TDMapAnnotationView createAnnotationViewWithAnnotation:annotation ReuseIdentifier:TDLocationAnnotationViewReuseIdentifier];
        }
        return annotationView;
    }
    
    return nil;
}

- (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation {
    
    
}

- (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated {
    
    
}


/**
 This function will call back when every drag decelerating end and first load map.
 */
- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated {
//    DDLogDebug(@"regionDidChangeAnimated:");
    
    if (_dragState != TDMapViewDragGestureStateNotStart) {
        NSLog(@"当前地区经度:%g，纬度:%g",_currentAnnotation.coordinate.longitude,_currentAnnotation.coordinate.latitude);
        [self refreshCurrentLocationInformation];
        [self zoomAnimationDropIfDraggingEnd];
        [self Map_addOverLayFromAnnotation:_currentAnnotation];
//        [(HSDLocationAnnotationView *)[_mapView viewForAnnotation:_currentAnnotation] zoomAnimationDropIfDraggingEnd];
        _dragState = TDMapViewDragGestureStateNotStart;
    }
}

/**
 This function will call back when mapView is changing include
 */
- (void)mapViewDidChangeVisibleRegion:(MKMapView *)mapView {
    
//    DDLogDebug(@"mapViewDidChangeVisibleRegion:");
    
    if (_dragState != TDMapViewDragGestureStateNotStart) {
        [self refreshPositionIfRegionChanged];
    }
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view didChangeDragState:(MKAnnotationViewDragState)newState
   fromOldState:(MKAnnotationViewDragState)oldState {
    
    TDMapAnnotationView *areaView = (TDMapAnnotationView *)view;
    
    switch (newState) {
        case MKAnnotationViewDragStateStarting: {
            [areaView zoomInIfDraggingBegin];
            
        } break;
        case MKAnnotationViewDragStateDragging: {
            
            
        } break;
        case MKAnnotationViewDragStateEnding: {
            
            [areaView zoomOutIfDraggingEnd];
            _currentAnnotation.coordinate = view.annotation.coordinate;
//            DDLogDebug(@"point x:%g\n y:%g",view.centerOffset.x,view.centerOffset.y);
            
            [self Map_selectAnnotation:_currentAnnotation animated:YES];
            [self refreshCurrentLocationInformation];
            
        } break;
        case MKAnnotationViewDragStateCanceling:
        {
            [areaView zoomOutIfDraggingEnd];
        }
            break;
        default:
        {
            [areaView zoomOutIfDraggingEnd];
        }
            break;
    }
}


#pragma mark - UI


- (void)zoomAnimationDropIfDraggingEnd {
    
    CGPoint mapCenter = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5);
    
    _centerAddressView.center = CGPointMake(mapCenter.x, mapCenter.y-_centerAddressView.bounds.size.height*0.5);
    
    [UIView animateWithDuration:0.2 animations:^{
        
        self.centerAddressView.center = mapCenter;
        
    }completion:^(BOOL finished){
        if (finished) {
            [UIView animateWithDuration:0.05 animations:^{
                self.centerAddressView.transform = CGAffineTransformMakeScale(1.0, 0.8);
                
            }completion:^(BOOL finished){
                if (finished) {
                    [UIView animateWithDuration:0.1 animations:^{
                        self.centerAddressView.transform = CGAffineTransformIdentity;
                    }];
                }
            }];
            
        }
    }];
}

- (void)configUI {
    
    // UI
    _mapView = ({
        MKMapView *mapView = [[MKMapView alloc]init];
        [self addSubview:mapView];
        [mapView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        mapView.delegate = self;
        mapView.showsUserLocation = NO;
        
        // find pan gesture
        for (UIView *view in mapView.subviews) {
            NSString *viewName = NSStringFromClass([view class]);
            if ([viewName isEqualToString:@"_MKMapContentView"]) {
                UIView *contentView = view;//[self.mapView valueForKey:@"_contentView"];
                for (UIGestureRecognizer *gestureRecognizer in contentView.gestureRecognizers) {
                    if ([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                        _mapViewPanGestureRecognizer = (UIPanGestureRecognizer *)gestureRecognizer;
                        [gestureRecognizer addTarget:self action:@selector(mapViewPanGesture:)];
                    }
                }
            }
        }
        
        mapView;
    });
    
    _centerAddressView = ({
        UIImageView *centerView = [[UIImageView alloc]initWithImage:[UIImage imageNamed:@"icon_current_location"]];
        [self addSubview:centerView];
        centerView.bounds = CGRectMake(0, 0, 34.f, 34.f);
        centerView.center = CGPointMake(self.bounds.size.width*0.5, self.bounds.size.height*0.5-centerView.bounds.size.height*0.5);
        [centerView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.mas_centerX);
            make.centerY.equalTo(self.mas_centerY);
            make.size.equalTo([NSValue valueWithCGSize:CGSizeMake(30, 30)]);
        }];
        centerView;
    });
}

@end
