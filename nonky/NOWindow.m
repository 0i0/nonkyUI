//
//  NOWindow.m
//  nonky
//
//  Created by Lior hakim on 10/13/17.
//  Copyright © 2017 Lior hakim. All rights reserved.
//

#import "NOWindow.h"
@import WebKit;

@implementation NOWindow {
    WKWebView *webView;
}

- (id)init
{
    
    self = [super
            initWithContentRect: NSMakeRect(0, 0, 100, 100)
            styleMask: NSWindowStyleMaskBorderless
            backing: NSBackingStoreBuffered
            defer: NO
            ];
    
    if (self) {
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setLevel:kCGDesktopWindowLevel];
        [self setCollectionBehavior:(
                                     NSWindowCollectionBehaviorTransient |
                                     NSWindowCollectionBehaviorCanJoinAllSpaces |
                                     NSWindowCollectionBehaviorIgnoresCycle
                                     )];
        
        [self setRestorable:NO];
        [self disableSnapshotRestoration];
        [self setDisplaysWhenScreenProfileChanges:YES];
        [self setReleasedWhenClosed:NO];
        [self fillScreen];
        webView = [[WKWebView alloc]
                              initWithFrame:self.frame];
        [webView setValue:@YES forKey:@"drawsTransparentBackground"];
        [self setContentView:webView];
    }
    
    return self;
}
- (void)loadUrl:(NSURL*)url{
    [webView loadRequest:[NSURLRequest requestWithURL: url]];
}

- (NSSize)screenResolution {
    NSScreen *manscreen = [NSScreen mainScreen];
    NSSize mainScreenSize = [manscreen frame].size;
    CGFloat menuBarThickness = [[NSStatusBar systemStatusBar] thickness];
    
    mainScreenSize.height -= menuBarThickness;
    
    return mainScreenSize;
}
- (NSPoint)screenOrigin {
    NSScreen *mainscreen = [NSScreen mainScreen];
    NSPoint mainScreenOrigin = [mainscreen frame].origin;
    return mainScreenOrigin;
}

- (void)fillScreen {
    self.contentSize = self.screenResolution;
    self.frameOrigin = self.screenOrigin;
}

@end
