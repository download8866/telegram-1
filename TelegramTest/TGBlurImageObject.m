//
//  TGBlurImageObject.m
//  Telegram
//
//  Created by keepcoder on 14/12/15.
//  Copyright © 2015 keepcoder. All rights reserved.
//

#import "TGBlurImageObject.h"
#import "DownloadQueue.h"
@implementation TGBlurImageObject

@synthesize thumbData = _thumbData;

-(void)initDownloadItem {
    
    if(_thumbData == nil) {
        [super initDownloadItem];
    } else {
        [DownloadQueue dispatchOnDownloadQueue:^{
            
            [self proccessAndDispatchData:_thumbData];
            
        }];
    }
    
}


-(void)proccessAndDispatchData:(NSData *)data {
    NSImage *image = [[NSImage alloc] initWithData:data];
    
    if(image != nil) {
        
        image = [ImageUtils blurImage:image blurRadius:10 frameSize:self.imageSize];
        
        [TGCache cacheImage:image forKey:[self cacheKey] groups:@[IMGCACHE]];
    }
    
    [[ASQueue mainQueue] dispatchOnQueue:^{
        [self.delegate didDownloadImage:image object:self];
    }];
}

-(void)_didDownloadImage:(DownloadItem *)item {
    [self proccessAndDispatchData:item.result];
}

-(NSString *)cacheKey {
    return [NSString stringWithFormat:@"%@:blurred",[super cacheKey]];
}

@end