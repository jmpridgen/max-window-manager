//
//  AppDelegate.m
//  windowManagerAppNoStory
//
//  Created by James M. Pridgen on 9/10/16.
//  Copyright © 2016 James M. Pridgen. All rights reserved.
//

#import "AppDelegate.h"
#import "AppKit/AppKit.h"
#import <objc/runtime.h>

@interface AppDelegate ()


@end

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    //Create status bar
    NSStatusBar *statusBar = [NSStatusBar systemStatusBar];
    statusItem = [statusBar statusItemWithLength:-2];
    NSImage *myImage = [[NSImage alloc] initByReferencingFile:@"/Users/max/Documents/XCode/windowManagerAppNoStory/windowManagerAppNoStory/Assets.xcassets/windowManagerIcon.imageset/windowManagerIcon.png"];
    //Use template rendering to allow for proper dark mode icon
    myImage.template = YES;
    [statusItem setImage:myImage];
    //Create menu
    [statusItem setMenu:[self createStatusBarMenu]];
}

- (NSMenu *)createStatusBarMenu{
    NSMenu * menu = [[NSMenu alloc] init];
    
    NSMenuItem *fullScreen = [[NSMenuItem alloc] initWithTitle:@"Full Screen" action:@selector(fullScreen) keyEquivalent:@""];
    [fullScreen setTarget:self];
    [menu addItem:fullScreen];
    
    NSMenuItem *leftSide = [[NSMenuItem alloc] initWithTitle:@"To Left" action:@selector(leftSide) keyEquivalent:@""];
    [leftSide setTarget:self];
    [menu addItem:leftSide];
    
    NSMenuItem *rightSide = [[NSMenuItem alloc] initWithTitle:@"To Right" action:@selector(rightSide) keyEquivalent:@""];
    [rightSide setTarget:self];
    [menu addItem:rightSide];
    
    NSMenuItem *separator =[NSMenuItem separatorItem];
    [menu addItem:separator];
    
    NSMenuItem *quit = [[NSMenuItem alloc] initWithTitle:@"Quit" action:@selector(quitMe) keyEquivalent:@""];
    [quit setTarget:self];
    [menu addItem:quit];
    
    return menu;
}

-(void)fullScreen{
    NSScreen *myScreen = [NSScreen mainScreen];
    CGRect myScreenSize = [myScreen frame];
    myScreenSize = [self convertRect:myScreenSize];
    [self positionWindow:myScreenSize];
}

-(void)leftSide{
    NSScreen *myScreen = [NSScreen mainScreen];
    CGRect myScreenSize = [myScreen frame];
    CGRect desiredSize = myScreenSize;
    desiredSize.size.width = desiredSize.size.width/2;
    desiredSize = [self convertRect:desiredSize];
    [self positionWindow:desiredSize];
}

-(void)rightSide{
    NSScreen *myScreen = [NSScreen mainScreen];
    CGRect myScreenSize = [myScreen frame];
    CGRect desiredSize = myScreenSize;
    desiredSize.size.width = desiredSize.size.width/2;
    desiredSize.origin.x=myScreenSize.origin.x+desiredSize.size.width;
    desiredSize = [self convertRect:desiredSize];
    [self positionWindow:desiredSize];
}

-(CGRect)convertRect:(CGRect) oldRect{
    NSArray *myScreens = [NSScreen screens];
    NSScreen *primaryScreen;
    for (NSScreen *screen in myScreens) {
        CGFloat screenX = screen.frame.origin.x;
        CGFloat screenY = screen.frame.origin.y;
        if (screenX == 0 && screenY == 0){
            primaryScreen = screen;
            oldRect.origin.y = -oldRect.origin.y + primaryScreen.frame.size.height - oldRect.size.height;
            break;
        }
    }
    return oldRect;
}

-(void)quitMe{
    [NSApp terminate:self];
}

-(void)positionWindow: (CGRect) myRect{
    NSArray *runningApps = [[NSWorkspace sharedWorkspace] runningApplications];
    for (NSRunningApplication *myApp in runningApps)
    {
        if ([myApp isActive])
        {
            AXUIElementRef myAppRef = AXUIElementCreateApplication([myApp processIdentifier]);
            //NSLog(@"something to print");
            CFArrayRef windowList;
            AXUIElementCopyAttributeValues(myAppRef, kAXWindowsAttribute, 0, 99999, &windowList);
            if (!windowList || CFArrayGetCount(windowList)<0) continue;
            for (CFIndex i = 0; i < CFArrayGetCount(windowList); i++)
            {
                AXUIElementRef windowRef = CFArrayGetValueAtIndex(windowList, i);
                //Determine whether window is mainwindow
                CFTypeRef isMainRef;
                AXUIElementCopyAttributeValue(windowRef, kAXMainAttribute, &isMainRef);
                if(!isMainRef) continue;
                bool isMain = CFBooleanGetValue(isMainRef);
                if (isMain == TRUE)
                {
                    AXValueRef newSizeRef = AXValueCreate(kAXValueCGSizeType, &myRect.size);
                    AXValueRef newPosRef = AXValueCreate(kAXValueCGPointType,&myRect.origin);
                    AXUIElementSetAttributeValue(windowRef, kAXPositionAttribute,newPosRef);
                    AXUIElementSetAttributeValue(windowRef, kAXSizeAttribute, newSizeRef);
                }
            }
        }
    }
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}

@end
