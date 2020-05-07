#import "FlutterBaiduMapPlugin.h"
#import <BMKLocationkit/BMKLocationComponent.h>
@interface FlutterBaiduMapPlugin()<BMKLocationManagerDelegate>
@property BMKLocationManager *locationManager;
@property(nonatomic, copy) BMKLocatingCompletionBlock completionBlock;
@end

@implementation FlutterBaiduMapPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  FlutterMethodChannel* channel = [FlutterMethodChannel
      methodChannelWithName:@"flutter_baidu_map"
            binaryMessenger:[registrar messenger]];
  FlutterBaiduMapPlugin* instance = [[FlutterBaiduMapPlugin alloc] init];
  [registrar addMethodCallDelegate:instance channel:channel];
}

- (void)handleMethodCall:(FlutterMethodCall*)call result:(FlutterResult)result {
  if ([@"setAK" isEqualToString:call.method]) {
    [[BMKLocationAuth sharedInstance] checkPermisionWithKey:call.arguments authDelegate:self];
    result(@YES);
  } else if ([@"getCurrentLocation" isEqualToString:call.method]) {
    [self initLocation];
    [self getCurrentLocation:result];
  } else {
    result(FlutterMethodNotImplemented);
  }
}

-(void)initLocation
{
    _locationManager = [[BMKLocationManager alloc] init];
    
    _locationManager.delegate = self;
    
    _locationManager.coordinateType = BMKLocationCoordinateTypeBMK09LL;
    _locationManager.distanceFilter = kCLDistanceFilterNone;
    _locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    _locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    _locationManager.pausesLocationUpdatesAutomatically = NO;
    _locationManager.locationTimeout = 10;
    _locationManager.reGeocodeTimeout = 10;
}

-(NSDictionary*)location2map:(BMKLocation*)location{
    
    BMKLocationReGeocode* rgcData = location.rgcData;
    BOOL isInChina = [BMKLocationManager BMKLocationDataAvailableForCoordinate:location.location.coordinate withCoorType:BMKLocationCoordinateTypeBMK09LL];
    
    NSLog(@"rgcData %@",rgcData);
    
    if(rgcData.district==nil || rgcData.adCode == nil){
        //国外定位nil的返回空
        return @{
             @"latitude":@(location.location.coordinate.latitude),
             @"longitude":@(location.location.coordinate.longitude),
             @"country":rgcData.country,
             @"countryCode":rgcData.countryCode,
             @"province":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.province]],
             @"city":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.city]],
             @"cityCode":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.cityCode]],
             @"district":@(""),
             @"street":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.street]],
             @"streetNumber":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.streetNumber]],
             @"locationDescribe":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.locationDescribe]],
             @"adCode":@(""),
             @"isInChina":@(isInChina),
             @"errorCode":@(161),
        };
    }else{
        //国内定位正常
        return @{
             @"latitude":@(location.location.coordinate.latitude),
             @"longitude":@(location.location.coordinate.longitude),
             @"country":rgcData.country,
             @"countryCode":rgcData.countryCode,
             @"province":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.province]],
             @"city":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.city]],
             @"cityCode":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.cityCode]],
             @"district":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.district]],
             @"street":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.street]],
             @"streetNumber":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.streetNumber]],
             @"locationDescribe":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.locationDescribe]],
             @"adCode":[self getNullAndNil:[NSString stringWithFormat:@"%@",rgcData.adCode]],
             @"isInChina":@(isInChina),
             @"errorCode":@(161),
        };
    }
}

-(NSString *)getNullAndNil:(NSString *)tempStr{
    if ( tempStr == nil || tempStr == NULL ||[tempStr isKindOfClass:[NSNull class]] || [[tempStr stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length]==0){
        return @"";
    }else{
        return tempStr;
    }
}

-(void)getCurrentLocation: (FlutterResult)result{

    self.completionBlock = ^(BMKLocation *location, BMKLocationNetworkState state, NSError *error)
    {
        if (error)
        {
            result(@{
                     @"errorCode" : @(error.code)
                     });
        }else {
            if (location) {//得到定位信息，添加annotation
                result([self location2map:location]);
            } else {
                result(@{
                         @"errorCode" : @(123456)
                         });
            }
        }
    };
    [_locationManager requestLocationWithReGeocode:YES withNetworkState:YES completionBlock:self.completionBlock];
}

@end
