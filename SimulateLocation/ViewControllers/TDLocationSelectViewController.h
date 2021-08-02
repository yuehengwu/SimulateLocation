//
//  TDLocationSelectViewController.h
//  ToDo
//
//  Created by wyh on 2019/11/23.
//  Copyright © 2019 wyh. All rights reserved.
//

#import "TDBaseViewController.h"
#import <CoreLocation/CoreLocation.h>

typedef void(^TDSelectResultClosure)(NSString *locationName ,CLLocationCoordinate2D coordinae);

@interface TDLocationSelectViewController : TDBaseViewController

- (instancetype)initWithLocationText:(NSString *)location selecrResult:(TDSelectResultClosure)result;

@end


