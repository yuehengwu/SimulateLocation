//
//  TDLocationService.h
//  Arm
//
//  Created by wyh on 2017/12/25.
//  Copyright © 2017年 iTalkBB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "TDLocationConverter.h"

@class TDLocationService;

@protocol TDLocationServiceDelegate <NSObject>

@required

- (void)TDLocationService:(TDLocationService *)service didUpdateLocation:(CLLocation *)location;

@optional

- (NSString *)locationDelegateId;

- (void)TDLocationService:(TDLocationService *)service didEnterRegion:(CLRegion *)region;

- (void)TDLocationService:(TDLocationService *)service didExitRegion:(CLRegion *)region;

- (void)TDLocationService:(TDLocationService *)service didStartMonitoringForRegion:(CLRegion *)region;

- (void)TDLocationService:(TDLocationService *)service monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error;

@end

/**
 Location Request Authorization Enum.
 
 - HSLocationRequestAlways:
 - HSLocationRequestWhenInUse:
 */
typedef NS_ENUM(NSInteger, TDLocationAuthorization) {
    TDLocationRequestAlways ,
    TDLocationRequestWhenInUse ,
};

/**
 Location information's support language,
 
 eg. Location geocoding or reverse geocoding call back language.

 - TDLocationLocaleLanguageZH_Has: Chinese
 - TDLocationLocaleLanguageEN: English
 */
typedef NS_ENUM(NSInteger, TDLocationLocaleLanguage) {
    TDLocationLocaleLanguageZH_Has ,
    TDLocationLocaleLanguageEN,
};

#pragma mark - HSLocationService

/**
 Location Service Manager.
 
 You can use it to set up or get location infomations.
 !Attention:
 <CoreLocation> use WGS but <MapKit> use GCJ ，so maybe you should transform coordinate system.
 */
@interface TDLocationService : NSObject <CLLocationManagerDelegate>

/// Current user's last location.
@property (nonatomic, strong, readonly) CLLocation *userLocation;

/// All delegates.
@property (nonatomic, strong, readonly) NSHashTable<id<TDLocationServiceDelegate>> *locationServiceHandlers;

/// All monitored regions.
@property (nonatomic, assign, readonly) NSSet<CLRegion *> *monitoredRegions;

/**
 Whether the user has location services enabled.
 */
+ (BOOL)locationServicesEnabled;

/**
 Represents the current authorization state of the application.
 */
+ (CLAuthorizationStatus)authorizationStatus;

/**
 Shared instance.
 */
+ (instancetype)sharedLocationService;

/**
 Regist delegate.
 */
+ (BOOL)registMonitorLocaitonServiceWithHandler:(id<TDLocationServiceDelegate>)handler;

/**
 Remove delegate.
 */
+ (BOOL)removeMonitorLocationServiceFromHandler:(id<TDLocationServiceDelegate>)handler;

/**
 Request location authrity.
 */
+ (void)requestLocationAuthrization:(TDLocationAuthorization)authType;

/**
 Whether the region has been already monitored.
 */
+ (BOOL)isAlreadyMonitoredWithRegionIdentifier:(NSString *)identifier;

/**
 Find the region monitored by id.
 */
+ (CLCircularRegion *)findMonitoredRegionFromIdentifier:(NSString *)identifier;

/**
 Start monitor user's location.
 */
+ (void)startMonitorUserLocation;

/**
 Stop monitor user's location.
 */
+ (void)stopMonitorUserLocation;

/**
 Start monitor the region.
 */
+ (void)startMonitoringForRegion:(CLCircularRegion *)region;

/**
 Stop monitor the region by id.
 */
+ (void)stopMonitoringForRegionIdentifier:(NSString *)regionIdentifier;

/**
 If already monitored region，return whether region contains coordinate.
 If not return NO;
 */
+ (BOOL)containsCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 Geocode with completeBlock by address.
 */
+ (void)geocodeAddressString:(NSString *)addressString
             completeHandler:(void (^)(CLPlacemark *, NSError *))completeHandler;

/**
 Reverse with completeBlock by coordinate.
 */
+ (void)reverseGeocodeLocationWithCoordinate:(CLLocationCoordinate2D)coordinate
                           preferredLanguage:(TDLocationLocaleLanguage)language
                             completeHandler:(void (^)(CLPlacemark *, NSError *))completeHandler;

/**
 Clean data.
 */
+ (BOOL)clean;

@end
