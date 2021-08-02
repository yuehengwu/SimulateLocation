//
//  TDLocationService.m
//  Arm
//
//  Created by wyh on 2017/12/25.
//  Copyright © 2017年 iTalkBB. All rights reserved.
//

#import "TDLocationService.h"

static CGFloat const minDistanceFilter = 20; // The minimum monitor meter.

@interface TDLocationService()

/// User's location .
@property (nonatomic, strong) CLLocation *userLocation;
/// CLLocation manager.
@property (nonatomic, strong) CLLocationManager *locationManager;
/// Geocoder manager.
@property (nonatomic, strong) CLGeocoder *geocoder;

@property (nonatomic, strong) NSHashTable<id<TDLocationServiceDelegate>> *locationServiceHandlers;

@end

@implementation TDLocationService

static TDLocationService *_locationService = nil;

+ (instancetype)sharedLocationService {
    if (_locationService == nil) {
        _locationService = [[TDLocationService alloc]init];
        [_locationService initializeLocationManager];
    }
    return _locationService;
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _locationService = [super allocWithZone:zone];
        [_locationService initializeLocationManager];
    });
    return _locationService;
}

#pragma mark - Private

- (void)initializeLocationManager {
    if (!_locationManager) {
        _locationManager = [[CLLocationManager alloc]init];
        _locationManager.delegate = self;
        
//        _locationManager.allowsBackgroundLocationUpdates = YES;
        _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        _locationManager.distanceFilter = minDistanceFilter;
//        _locationManager.pausesLocationUpdatesAutomatically = YES;
        
    }
    
}

+ (void)checkLocaitonServiceAndAuthrizationEnabled {
    
    if (![TDLocationService locationServicesEnabled]) {
        NSLog(@"User location service disbled, plz check out i-Phone.");
        return;
    }
    
    if([self authorizationStatus] == kCLAuthorizationStatusDenied){
        NSLog(@"User has denied authorize location service.");
    }
    
    if([self authorizationStatus] == kCLAuthorizationStatusNotDetermined){
        [self requestLocationAuthrization:(TDLocationRequestWhenInUse)];
    }
    
}

#pragma mark - API

+ (void)requestLocationAuthrization:(TDLocationAuthorization)authType {
   
    switch (authType) {
            case TDLocationRequestAlways:
        {
            if([self authorizationStatus] != kCLAuthorizationStatusAuthorizedAlways){
                [[TDLocationService sharedLocationService].locationManager requestAlwaysAuthorization];
            }
        }
            break;
            case TDLocationRequestWhenInUse:
        {
            if([self authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse){
                [[TDLocationService sharedLocationService].locationManager requestWhenInUseAuthorization];
            }
        }
            break;
        default:
            break;
    }
}

+ (BOOL)registMonitorLocaitonServiceWithHandler:(id<TDLocationServiceDelegate>)handler {
        
    
    if (![[TDLocationService sharedLocationService].locationServiceHandlers containsObject:handler]) {
        [[TDLocationService sharedLocationService].locationServiceHandlers addObject:handler];
        return YES;
    }
    NSLog(@"Current Location Service already contain this register");
    return NO;
}

+ (BOOL)removeMonitorLocationServiceFromHandler:(id<TDLocationServiceDelegate>)handler {
    
    if ([[TDLocationService sharedLocationService].locationServiceHandlers containsObject:handler]) {
        [[TDLocationService sharedLocationService].locationServiceHandlers removeObject:handler];
        return YES;
    }
        
    NSLog(@"Current Location Service don't contain this register, Plz check code.");
    return NO;
}

+ (BOOL)isAlreadyMonitoredWithRegionIdentifier:(NSString *)identifier {
    __block BOOL isContain = NO;
    [[TDLocationService sharedLocationService].monitoredRegions enumerateObjectsUsingBlock:^(__kindof CLRegion * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            isContain = YES;
            *stop = YES;
        }
    }];
    return isContain;
}

+ (CLCircularRegion *)findMonitoredRegionFromIdentifier:(NSString *)identifier {
    __block CLCircularRegion *region = nil;
    [[TDLocationService sharedLocationService].monitoredRegions enumerateObjectsUsingBlock:^(CLRegion * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:identifier]) {
            region = (CLCircularRegion *)obj;
            *stop = YES;
        }
    }];
    return region;
}

+ (BOOL)clean {
    if (_locationService != nil) {
        [_locationService.geocoder cancelGeocode];
        [self stopMonitorUserLocation];
        if([_locationService.locationServiceHandlers count] > 0){
            [_locationService.locationServiceHandlers removeAllObjects];// Release all handlers.
        }
        _locationService = nil;
        return YES;
    }
    NSLog(@"HSLocationService has not been already started，so don't need to clean");
    return NO;
}

+ (void)startMonitorUserLocation {
    [self checkLocaitonServiceAndAuthrizationEnabled];
    
    [[TDLocationService sharedLocationService].locationManager startUpdatingLocation];
    NSLog(@"Start monitor user's location.");
}

+ (void)stopMonitorUserLocation {
    [[TDLocationService sharedLocationService].locationManager stopUpdatingLocation];
}

+ (void)startMonitoringForRegion:(CLCircularRegion *)region {
    [self checkLocaitonServiceAndAuthrizationEnabled];
    // Check whether monitored .
    if ([self isAlreadyMonitoredWithRegionIdentifier:region.identifier]) {
        [TDLocationService stopMonitoringForRegionIdentifier:region.identifier];
    }
    // Limit the max radius can be monitored.
    CLLocationDistance maxRadiusDistance = [TDLocationService sharedLocationService].locationManager.maximumRegionMonitoringDistance;
    if (region.radius > maxRadiusDistance) {
        region = [[CLCircularRegion alloc]initWithCenter:region.center radius:maxRadiusDistance identifier:region.identifier];
    }
    [[TDLocationService sharedLocationService].locationManager startMonitoringForRegion:region];
}

+ (void)stopMonitoringForRegionIdentifier:(NSString *)regionIdentifier {
    [[TDLocationService sharedLocationService].monitoredRegions enumerateObjectsUsingBlock:^(CLRegion * _Nonnull obj, BOOL * _Nonnull stop) {
        if ([obj.identifier isEqualToString:regionIdentifier]) {
            [[TDLocationService sharedLocationService].locationManager stopMonitoringForRegion:obj];
            *stop = YES;
        }
    }];
}

+ (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate {
    __block BOOL isContain = NO;
    [[TDLocationService sharedLocationService].monitoredRegions enumerateObjectsUsingBlock:^(CLRegion * _Nonnull region, BOOL * _Nonnull stop) {
        if([(CLCircularRegion *)region containsCoordinate:coordinate]){
            isContain = YES;
            *stop = YES;
        }
    }];
    return isContain;
}

+ (void)geocodeAddressString:(NSString *)addressString completeHandler:(void (^)(CLPlacemark *, NSError *))completeHandler {
    
    [[TDLocationService sharedLocationService].geocoder geocodeAddressString:addressString completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
        if (error || placemarks.count == 0) {
            if (completeHandler) completeHandler(nil,error);
            return ;
        }
        CLPlacemark *placemark = [placemarks firstObject];
        
        if(completeHandler) completeHandler(placemark,nil);
    }];
}

+ (void)reverseGeocodeLocationWithCoordinate:(CLLocationCoordinate2D)coordinate
                           preferredLanguage:(TDLocationLocaleLanguage)language
                             completeHandler:(void (^)(CLPlacemark *, NSError *))completeHandler {
    
    CLLocation *location = [[CLLocation alloc]initWithLatitude:coordinate.latitude longitude:coordinate.longitude];
    
    NSLocale *locale ;
    switch (language) {
        case TDLocationLocaleLanguageEN:
            locale = [NSLocale localeWithLocaleIdentifier:@"en"];
            break;
        case TDLocationLocaleLanguageZH_Has:
            locale = [NSLocale localeWithLocaleIdentifier:@"zh_Hans"];
            break;
        default:
            locale = [NSLocale systemLocale];
            break;
    }
    
    if (@available(iOS 11.0, *)) {
        [[TDLocationService sharedLocationService].geocoder reverseGeocodeLocation:location
                                                                   preferredLocale:locale
                                                                 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                                                                       
                                                                       if (error || placemarks.count == 0) {
                                                                           if(completeHandler) completeHandler(nil,error);
                                                                           return;
                                                                       }
                                                                       CLPlacemark *placemark = [placemarks firstObject];
                                                                       
                                                                       if(completeHandler) completeHandler(placemark,nil);
                                                                       
                                                                   }];
    } else {
        // Fallback on earlier versions
        [[TDLocationService sharedLocationService].geocoder reverseGeocodeLocation:location
                                                                 completionHandler:^(NSArray<CLPlacemark *> * _Nullable placemarks, NSError * _Nullable error) {
                                                                       
                                                                     if (error || placemarks.count == 0) {
                                                                         if(completeHandler) completeHandler(nil,error);
                                                                         return;
                                                                     }
                                                                     CLPlacemark *placemark = [placemarks firstObject];
                                                                     
                                                                     if(completeHandler) completeHandler(placemark,nil);
                                                                     
                                                                   }];
    }
}


#pragma mark - CLLocation Delegate

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations {
    
    CLLocation *recentLocation = locations.lastObject;
    
    NSLog(@"current location:%@",recentLocation);
    
    if ((recentLocation.coordinate.latitude == self.userLocation.coordinate.latitude && recentLocation.coordinate.longitude == self.userLocation.coordinate.longitude)) {
        return;
    }
    self.userLocation = recentLocation;
    
    if (self.locationServiceHandlers.count > 0) {
        
        for (id<TDLocationServiceDelegate> delegate in [TDLocationService sharedLocationService].locationServiceHandlers) {
            if ([delegate respondsToSelector:@selector(TDLocationService:didUpdateLocation:)]) {
                [delegate TDLocationService:self didUpdateLocation:recentLocation];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region {
    
    NSLog(@"LocationService monitor did enter %@ \n Region:%@",region.identifier,region);
    
    if (self.locationServiceHandlers.count > 0) {
        
        for (id<TDLocationServiceDelegate> delegate in [TDLocationService sharedLocationService].locationServiceHandlers) {
            if (![delegate respondsToSelector:@selector(TDLocationService:didEnterRegion:)]) {
                return ;
            }
            // Call back current delegate.
            if ([delegate.locationDelegateId isEqualToString:region.identifier]) {
                [delegate TDLocationService:self didEnterRegion:region];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region {
    NSLog(@"LocationService monitor did exit %@ \n Region:%@",region.identifier,region);
    
    if (self.locationServiceHandlers.count > 0) {
        
        for (id<TDLocationServiceDelegate> delegate in [TDLocationService sharedLocationService].locationServiceHandlers) {
            if (![delegate respondsToSelector:@selector(TDLocationService:didExitRegion:)]) {
                return ;
            }
            // Call back current delegate.
            if ([delegate.locationDelegateId isEqualToString:region.identifier]) {
                [delegate TDLocationService:self didExitRegion:region];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region {
    NSLog(@"LocationManager start monitor region. Region: %@ \n",region);
    
    // Don't need to call back for present.
    if (self.locationServiceHandlers.count > 0) {
        
        for (id<TDLocationServiceDelegate> delegate in [TDLocationService sharedLocationService].locationServiceHandlers) {
            if (![delegate respondsToSelector:@selector(TDLocationService:didStartMonitoringForRegion:)]) {
                return ;
            }
            // Call back current delegate.
            if ([delegate.locationDelegateId isEqualToString:region.identifier]) {
                [delegate TDLocationService:self didStartMonitoringForRegion:region];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error {
    NSLog(@"LocationManager monitor region failed. \n Error:%@",error);
    
    // Handle error .
    if (self.locationServiceHandlers.count > 0) {
        
        for (id<TDLocationServiceDelegate> delegate in [TDLocationService sharedLocationService].locationServiceHandlers) {
            if (![delegate respondsToSelector:@selector(TDLocationService:monitoringDidFailForRegion:withError:)]) {
                return ;
            }
            // Call back current delegate.
            if ([delegate.locationDelegateId isEqualToString:region.identifier]) {
                [delegate TDLocationService:self monitoringDidFailForRegion:region withError:error];
            }
        }
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error {
    NSLog(@"locationManager didFailWithError: %@",error);
}

#pragma mark - Lazy

+ (BOOL)locationServicesEnabled {
    return [CLLocationManager locationServicesEnabled];
}

+ (CLAuthorizationStatus)authorizationStatus {
    return [CLLocationManager authorizationStatus];
}

- (NSSet<CLRegion *> *)monitoredRegions {
    return [self.locationManager monitoredRegions];
}

- (CLGeocoder *)geocoder {
    if (!_geocoder) {
        _geocoder = [[CLGeocoder alloc]init];
    }
    return _geocoder;
}

- (NSHashTable<id<TDLocationServiceDelegate>> *)locationServiceHandlers {
    if (!_locationServiceHandlers) {
        _locationServiceHandlers = [NSHashTable weakObjectsHashTable];;
    }
    return _locationServiceHandlers;
}

@end
