//
//  TDMapCircle.m
//  ToDo
//
//  Created by wyh on 2019/11/22.
//  Copyright © 2019 wyh. All rights reserved.
//

#import "TDMapCircle.h"

@implementation TDMapCircle



@end

@implementation TDMapCircleRenderer

- (instancetype)initWithOverlay:(id<MKOverlay>)overlay isAlreadyMonitored:(BOOL)monitored{
    if (self = [super initWithOverlay:overlay]) {
        self.lineWidth = 1.5f;
        
        if (!monitored) {
            self.strokeColor = [UIColor colorWithHexString:@"0xb9b9b9"];
            self.fillColor = [UIColor colorWithWhite:0 alpha:.1f];
//            self.lineDashPhase = 2;
//            self.lineDashPattern = @[@10,@10];
        }else {
            self.lineDashPhase = 0;
            self.lineDashPattern = nil;
//            self.strokeColor = Color_ThemeColor;            
            self.fillColor = TDRGBHexAlpha(0x4195d5, 0.3);
        }
        
    }
    return self;
}

@end
