/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013 Jeevanandam M.
 *               2012, 2013 Jason Schroth
 *               2010, 2011 Saptarshi Guha
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

#import <objc/objc-runtime.h>

#import "RwhMailBundle.h"
#import "RwhMailMacros.h"
#import "RwhMailConstants.h"
#import "RwhMailPreferences.h"
#import "RwhMailPreferencesModule.h"
#import "RwhMailMessage.h"
#import "NSObject+RwhMailBundle.h"

@interface RwhMailBundle (PrivateMethods)
+ (void)registerBundle;
@end

@implementation RwhMailBundle

#pragma mark Class methods

+ (void)initialize {
    [super initialize];
    
    // Make sure the initializer is only run once.
    // Usually is run, for every class inheriting from RwhMailBundle.
    if (self != [RwhMailBundle class])
        return;
    
    Class mvMailBundleClass = NSClassFromString(@"MVMailBundle");
    // If this class is not available that means Mail.app
    // doesn't allow bundles anymore. Fingers crossed that this never happens!
    if (!mvMailBundleClass) {
        NSLog(@"Mail.app doesn't support bundles anymore, So have a Beer!");
        
        return;
    }
    
    // Registering RWH mail bundle
    [mvMailBundleClass registerBundle];
    
    // assigning default value if not present
    [self assignRwhMailDefaultValues];
    
    // for smooth upgrade to new UI
    [self smoothValueTransToNewRwhMailPrefUI];
    
    // add the RwhMailMessage methods to the ComposeBackEnd class
    [self addRwhMailMessageMethodsToComposeBackEnd];
    
    [self addRwhMailPreferencesToNSPreferences];
    
    // RWH Bundle registered successfully
    NSLog(@"RWH %@ mail bundle registered", [self bundleVersionString]);
    NSLog(@"RWH %@ Oh it's a wonderful life", [self bundleVersionString]);
    
    if (![self isEnabled]) {
        NSLog(@"RWH mail bundle is disabled in mail preferences");
    }
}

+ (BOOL)isEnabled {
    return GET_BOOL_USER_DEFAULT(RwhMailBundleEnabled);
}

+ (NSBundle *)bundle {
    static NSBundle *bundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bundle = [NSBundle bundleForClass:[RwhMailBundle class]];
    });
    return bundle;
}

+ (NSString *)bundleNameAndVersion {
    return [NSMutableString stringWithFormat:@"%@ %@", [self bundleName], [self bundleVersionString]];
}

+ (NSString *)bundleName {
    return [[[self bundle] infoDictionary] objectForKey:RwhMailBundleNameKey];
}

+ (NSString *)bundleVersionString {
    return [[[self bundle] infoDictionary] objectForKey:RwhMailBundleShortVersionKey];
}

+ (NSString *)bundleShortName {
    return RwhMailBundleShortName;
}

+ (NSString *)bundleCopyright {
    return [[[self bundle] infoDictionary] objectForKey:RwhMailCopyRightKey];
}

+ (NSImage *)bundleLogo {
    static NSImage *logo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        logo = [self loadImage:@"ReplyWithHeader" setSize:NSMakeSize(128, 128)];
    });
    return logo;
}

+ (NSImage *) loadImage:(NSString *)name setSize:(NSSize)size {
    NSImage *image = [[NSImage alloc]
                      initByReferencingFile:[[self bundle] pathForImageResource:name]];
    [image setName:name];
    [image setSize:size];
    
    return image;
}

+ (void)assignRwhMailDefaultValues {
    RWH_LOG();
    
    if (!GET_USER_DEFAULT(RwhMailBundleEnabled)) {
        SET_BOOL_USER_DEFAULT(YES, RwhMailBundleEnabled);
    }
    
    if (!GET_USER_DEFAULT(RwhMailForwardHeaderEnabled)) {
        SET_BOOL_USER_DEFAULT(YES, RwhMailForwardHeaderEnabled);
    }
    
    if (!GET_USER_DEFAULT(RwhMailEntourage2004SupportEnabled)) {
        SET_BOOL_USER_DEFAULT(NO, RwhMailEntourage2004SupportEnabled);
    }
    
    if (!GET_USER_DEFAULT(RwhMailReplyHeaderText)) {
        SET_USER_DEFAULT(RwhMailDefaultReplyHeaderText, RwhMailReplyHeaderText);
    }
    
    if (!GET_USER_DEFAULT(RwhMailForwardHeaderText)) {
        SET_USER_DEFAULT(RwhMailDefaultForwardHeaderText, RwhMailForwardHeaderText);
    }
}

+ (void)smoothValueTransToNewRwhMailPrefUI {
    RWH_LOG();
    
    if (GET_BOOL_USER_DEFAULT(@"enableBundle")) {
        SET_BOOL_USER_DEFAULT(GET_BOOL_USER_DEFAULT(@"enableBundle"), RwhMailBundleEnabled);
        
        REMOVE_USER_DEFAULT(@"enableBundle");
    }
    
    if (GET_BOOL_USER_DEFAULT(@"replaceForward")) {
        SET_BOOL_USER_DEFAULT(GET_BOOL_USER_DEFAULT(@"replaceForward"), RwhMailForwardHeaderEnabled);
        
        REMOVE_USER_DEFAULT(@"replaceForward");
    }
    
    if (GET_BOOL_USER_DEFAULT(@"entourage2004Support")) {
        SET_BOOL_USER_DEFAULT(GET_BOOL_USER_DEFAULT(@"entourage2004Support"), RwhMailEntourage2004SupportEnabled);
        
        REMOVE_USER_DEFAULT(@"entourage2004Support");
    }
    
    if (GET_USER_DEFAULT(@"headerText")) {
        SET_USER_DEFAULT(GET_USER_DEFAULT(@"headerText"), RwhMailReplyHeaderText);
        
        REMOVE_USER_DEFAULT(@"headerText");
    }
    
    if (GET_USER_DEFAULT(@"forwardHeader")) {
        SET_USER_DEFAULT(GET_USER_DEFAULT(@"forwardHeader"), RwhMailForwardHeaderText);
        
        REMOVE_USER_DEFAULT(@"forwardHeader");
    }
}

+ (void)addRwhMailMessageMethodsToComposeBackEnd {
    [RwhMailMessage rwhAddMethodsToClass:NSClassFromString(@"ComposeBackEnd")];
    
    // now switch the _continueToSetupContentsForView method in the ComposeBackEnd implementation
    // so that the newly added rwhContinueToSetupContentsForView method is called instead...
    [NSClassFromString(@"ComposeBackEnd")
     rwhSwizzle:@selector(_continueToSetupContentsForView:withParsedMessages:)
     meth:@selector(rwhContinueToSetupContentsForView:withParsedMessages:)
     classMeth:NO // it is an implementation method
     ];
}

+ (void)addRwhMailPreferencesToNSPreferences {
    [RwhMailPreferences rwhAddMethodsToClass:NSClassFromString(@"NSPreferences")];
    
    [NSClassFromString(@"NSPreferences")
     rwhSwizzle:@selector(sharedPreferences)
     meth:@selector(rwhSharedPreferences)
     classMeth:YES
     ];
}

#pragma mark MVMailBundle class methods

+ (BOOL)hasPreferencesPanel {
    // LEOPARD Invoked on +initialize. Else, invoked from +registerBundle.
    return YES;
}

+ (NSString*)preferencesOwnerClassName {
    return NSStringFromClass([RwhMailPreferencesModule class]);
}

+ (NSString*)preferencesPanelName {
    return [self bundleShortName];
}

@end
