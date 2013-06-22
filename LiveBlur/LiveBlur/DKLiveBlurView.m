//
//  DKLiveBlurView.m
//  LiveBlur
//
//  Created by Dmitry Klimkin on 16/6/13.
//  Copyright (c) 2013 Dmitry Klimkin. All rights reserved.
//

#import "DKLiveBlurView.h"
#import <Accelerate/Accelerate.h>

@interface DKLiveBlurView ()

@property (nonatomic, strong) UIImageView *backgroundImageView;
@property (nonatomic, strong) UIView *backgroundGlassView;

@end

@implementation DKLiveBlurView

@synthesize originalImage = _originalImage;
@synthesize backgroundImageView = _backgroundImageView;
@synthesize tableView = _tableView;
@synthesize initialBlurLevel = _initialBlurLevel;
@synthesize backgroundGlassView = _backgroundGlassView;
@synthesize initialGlassLevel = _initialGlassLevel;
@synthesize isGlassEffectOn = _isGlassEffectOn;
@synthesize glassColor = _glassColor;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        _initialBlurLevel = kDKBlurredBackgroundDefaultLevel;
        _initialGlassLevel = kDKBlurredBackgroundDefaultGlassLevel;
        _glassColor = kDKBlurredBackgroundDefaultGlassColor;

        _backgroundImageView = [[UIImageView alloc] initWithFrame: self.bounds];
        
        _backgroundImageView.alpha = 0.0;
        _backgroundImageView.contentMode = UIViewContentModeScaleToFill;
        _backgroundImageView.backgroundColor = [UIColor clearColor];
        
        _backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

        [self addSubview: _backgroundImageView];
        
        _backgroundGlassView = [[UIView alloc] initWithFrame: self.bounds];
        
        _backgroundGlassView.alpha = 0.0;
        _backgroundGlassView.backgroundColor = kDKBlurredBackgroundDefaultGlassColor;
        
        _backgroundGlassView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
                
        [self addSubview: _backgroundGlassView];
    }
    return self;
}

- (void)setGlassColor:(UIColor *)glassColor {
    _glassColor = glassColor;
    _backgroundGlassView.backgroundColor = glassColor;
}

- (void)setTableView:(UITableView *)tableView {
    [_tableView removeObserver: self forKeyPath: @"contentOffset"];
    
	_tableView = tableView;
	
    [_tableView addObserver: self forKeyPath: @"contentOffset" options: 0 context: nil];
}

- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    if ((blur < 0.0f) || (blur > 1.0f)) {
        blur = 0.5f;
    }
    
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef img = image.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
        
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    
    CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (void)setOriginalImage:(UIImage *)originalImage {
    _originalImage = originalImage;
    
    self.image = originalImage;
    
    dispatch_queue_t queue = dispatch_queue_create("Blur queue", NULL);
    
    dispatch_async(queue, ^ {
        
        UIImage *blurredImage = [self blurryImage: self.originalImage withBlurLevel: self.initialBlurLevel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.backgroundImageView.alpha = 0.0;
            self.backgroundImageView.image = blurredImage;
        });
    });
    
    dispatch_release(queue);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    self.backgroundImageView.alpha = self.tableView.contentOffset.y / (2 * self.frame.size.height / 3);
    
    if (self.isGlassEffectOn == YES) {
        self.backgroundGlassView.alpha = MAX(0.0, MIN(self.backgroundImageView.alpha - self.initialGlassLevel, self.initialGlassLevel));
    }
}

@end
