/*
 * The MIT License (MIT)
 *
 * Copyright (c) 2013-2017 Jeevanandam M.
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

//
//  NSPreferences+MailHeader.h
//  ReplyWithHeader
//
//  Created by Jeevanandam M. on 9/30/13.
//
// Inspried by GPGMail NSPreferences extension approach to resize the Preferences to show all items

#import "NSPreferences.h"

@interface NSPreferences (MailHeader)

+ (id)MHSharedPreferences;

/**
 Called when the preference pane is first shown, or the user
 resizes the preference pane.
 */
- (NSSize)MHWindowWillResize:(id)window toSize:(NSSize)toSize;

/**
 Called whenever the user clicks on a toolbar item.
 */
- (void)MHToolbarItemClicked:(id)toolbarItem;

/**
 Called whenever the preference pane is displayed.
 */
- (void)MHShowPreferencesPanelForOwner:(id)owner;

/**
 Helper function to resize the preference pane window to fit all
 toolbar items.
 */
- (void)resizeWindowToShowAllToolbarItems:(NSWindow *)window;

/**
 Helper function - Returns the window size necessary to fit all toolbar items.
 */
- (NSSize)sizeForWindowShowingAllToolbarItems:(NSWindow *)window;

@end
