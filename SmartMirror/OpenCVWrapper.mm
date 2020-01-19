//
//  OpenCVWrapper.m
//  SmartMirror
//
//  Created by Sunny Chen on 2020-01-01.
//  Copyright © 2020 Team 2019053. All rights reserved.
//

#import <opencv2/opencv.hpp>
#import "OpenCVWrapper.h"

@implementation OpenCVWrapper

+ (NSString *)openCVVersionString {
    return [NSString stringWithFormat:@"OpenCV Version %s",  CV_VERSION];
}

@end
