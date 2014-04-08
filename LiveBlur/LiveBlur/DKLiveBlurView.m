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
@synthesize scrollView = _scrollView;
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

- (void)setScrollView:(UIScrollView *)scrollView {
    [_scrollView removeObserver: self forKeyPath: @"contentOffset"];
    
	_scrollView = scrollView;
	
    [_scrollView addObserver: self forKeyPath: @"contentOffset" options: 0 context: nil];
}

- (UIImage *)applyBlurOnImage: (UIImage *)imageToBlur
                   withRadius:(CGFloat)blurRadius {
    if ((blurRadius <= 0.0f) || (blurRadius > 1.0f)) {
        blurRadius = 0.5f;
    }
    
    int boxSize = (int)(blurRadius * 100);
    boxSize -= (boxSize % 2) + 1;
    
    CGImageRef rawImage = imageToBlur.CGImage;
    
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    void *pixelBuffer;
    
    CGDataProviderRef inProvider = CGImageGetDataProvider(rawImage);
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    inBuffer.width = CGImageGetWidth(rawImage);
    inBuffer.height = CGImageGetHeight(rawImage);
    inBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    pixelBuffer = malloc(CGImageGetBytesPerRow(rawImage) * CGImageGetHeight(rawImage));
        
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(rawImage);
    outBuffer.height = CGImageGetHeight(rawImage);
    outBuffer.rowBytes = CGImageGetBytesPerRow(rawImage);
    
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL,
                                       0, 0, boxSize, boxSize, NULL,
                                       kvImageEdgeExtend);
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    CGContextRef ctx = CGBitmapContextCreate(outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(imageToBlur.CGImage));
    
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    CFRelease(inBitmapData);
    CGImageRelease(imageRef);
    
    return returnImage;
}

- (void)setOriginalImage:(UIImage *)originalImage {
    _originalImage = originalImage;
    
    self.image = originalImage;
    
    dispatch_queue_t queue = dispatch_queue_create("Blur queue", NULL);
    
    dispatch_async(queue, ^ {
        
        UIImage *blurredImage = [self applyBlurOnImage: self.originalImage withRadius: self.initialBlurLevel];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            self.backgroundImageView.alpha = 0.0;
            self.backgroundImageView.image = blurredImage;
        });
    });
    
    dispatch_release(queue);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context {
    
    // closer to zero, less blur applied
    [self setBlurLevel:(self.scrollView.contentOffset.y + self.scrollView.contentInset.top) / (2 * CGRectGetHeight(self.bounds) / 3)];
}

- (void)setBlurLevel:(float)blurLevel {
    self.backgroundImageView.alpha = blurLevel;
    
    if (self.isGlassEffectOn) {
        self.backgroundGlassView.alpha = MAX(0.0, MIN(self.backgroundImageView.alpha - self.initialGlassLevel, self.initialGlassLevel));
    }
}

@end
