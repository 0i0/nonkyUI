//
//  AppDelegate.m
//  nonky
//
//  Created by Lior hakim on 10/13/17.
//  Copyright © 2017 Lior hakim. All rights reserved.
//

#import "NOAppDelegate.h"
#import "NOWindow.h"
#import "NOPreferencesController.h"

static NSString *const qBaseUrlValue = @"http://localhost:26497";
static NSString *const qDefaultTemplates = @"default-templates";

@interface NOAppDelegate ()

@end

@implementation NOAppDelegate{
    NSStatusItem* statusItem;
    NSArray *templatesArray;
    NOPreferencesController* preferences;
    NSMutableDictionary *windows;
    NSUserDefaults *userDefaults;
    NSMutableDictionary *defaultTemplates;
    
}

@synthesize statusMenu;
@synthesize templatesMenu;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    windows = [[NSMutableDictionary alloc] initWithCapacity:10];
    userDefaults = [NSUserDefaults standardUserDefaults];
    [self setDefaultsIfNecessary];
    defaultTemplates = [[userDefaults objectForKey:qDefaultTemplates] mutableCopy];
    [self loadTemplatesFromDictionary:defaultTemplates];
    statusItem = [self addStatusItemToMenu: statusMenu];
    preferences = [[NOPreferencesController alloc]initWithWindowNibName:@"Preferences"];
    [self getTemplates];
    
}
-(void)setDefaultsIfNecessary{
    if ([userDefaults objectForKey:qDefaultTemplates] == nil) {
        NSDictionary *DefaultTemplates = [[NSDictionary alloc] initWithObjectsAndKeys:@"YES",@"jquery", nil];
        [userDefaults setObject:DefaultTemplates forKey:qDefaultTemplates];
    }
}
- (NSStatusItem*)addStatusItemToMenu:(NSMenu*)menu
{
    NSStatusItem *statusItem = [[NSStatusBar systemStatusBar] statusItemWithLength:NSVariableStatusItemLength];
    
    //NSImage *image = [[NSBundle mainBundle] imageForResource:@"status-icon"];
    //[statusItem setImage: image];
    statusItem.title = @"P";
    statusItem.highlightMode = YES;
    statusItem.menu = menu;
    [statusItem setEnabled:YES];
    return statusItem;
}


- (void)applicationWillTerminate:(NSNotification *)aNotification {
   [[NSStatusBar systemStatusBar] removeStatusItem:statusItem];
}

- (IBAction)showPreferences:(id)sender
{
    [preferences showWindow:nil];
    [NSApp activateIgnoringOtherApps:YES];
    [preferences.window makeKeyAndOrderFront:self];
}

-(void)getTemplates{
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", qBaseUrlValue, @"/api/templates"]]];
    [request setHTTPMethod:@"GET"];
    dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
        NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        [[session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
            if (error) {
                NSLog(@"dataTaskWithRequest error: %@", error);
                return;
            }
            templatesArray = [NSJSONSerialization JSONObjectWithData:data
                                                             options:kNilOptions
                                                               error:&error];
            dispatch_async(dispatch_get_main_queue(), ^{
                for( NSMenuItem *item in [templatesMenu itemArray] ){
                    [templatesMenu removeItem:item];
                }
                for (id object in templatesArray) {
                    NSMenuItem *menuItem = [[NSMenuItem alloc] initWithTitle:object action:@selector(toggleLoadTemplate:) keyEquivalent:@""];
                    [templatesMenu addItem:menuItem];
                    NSString *defaultActiveState = [defaultTemplates objectForKey:object];
                    if([defaultActiveState boolValue]){
                        [menuItem setState:NSOnState];
                    }else{
                        [menuItem setState:NSOffState];
                    }
                    
                }
            });
            
        }] resume];
    });

    //
}

- (void)toggleLoadTemplate:(id)sender{
    if([sender state]==NSOffState){
        [sender setState:NSOnState];
        NSString* templateName = [(NSMenuItem*)sender title];
        [self storeTemplateDefaultActiveStateWithName:templateName andState:YES];
        [self loadTemplateWithName:templateName];
    }else{
        [sender setState:NSOffState];
        NSString* templateName = [(NSMenuItem*)sender title];
        [self storeTemplateDefaultActiveStateWithName:templateName andState:NO];
        [windows removeObjectForKey:templateName];
    }
}
-(void)storeTemplateDefaultActiveStateWithName:(NSString *)templateName andState:(BOOL)active{
    NSString *activeString = active ? @"YES" : @"NO";
    [defaultTemplates setValue:activeString forKey:templateName];
    NSDictionary *DefaultTemplatesStatic = [NSDictionary dictionaryWithDictionary:defaultTemplates];
    [userDefaults setObject:DefaultTemplatesStatic forKey:qDefaultTemplates];
}
-(void)loadTemplatesFromDictionary:(NSDictionary *) dictionary{
    [dictionary enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent usingBlock:^(id key, id object, BOOL *stop) {
         if([object boolValue]){
             NSLog(@"%@-%@",key,object);
             [self loadTemplateWithName:key];
         }
    }];
}
-(void)loadTemplateWithName:(NSString *)templateName{
    NSString* templateURL = [NSString stringWithFormat:@"%@%@%@", qBaseUrlValue,@"/templates/", templateName];
    [windows removeObjectForKey:templateName];
    dispatch_async(dispatch_get_main_queue(), ^{
        NOWindow *window = [[NOWindow alloc] init];
        [windows setObject:window forKey:templateName];
        [window loadUrl:[NSURL URLWithString:templateURL]];
        [window makeKeyAndOrderFront:self];
    });
}


@end
