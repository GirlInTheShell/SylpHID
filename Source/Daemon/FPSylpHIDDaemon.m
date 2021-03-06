//
// FPSylpHIDDaemon.m
// "SylpHID"
//
// Created by Darrell Walisser <walisser@mac.com>
// Copyright (c)2007 Darrell Walisser. All Rights Reserved.
// http://sourceforge.net/projects/xhd
//
// Forked and Modifed by macman860 <email address unknown>
// https://macman860.wordpress.com
//
// Forked and Modified by Paige Marie DePol <pmd@fizzypopstudios.com>
// Copyright (c)2015 FizzyPop Studios. All Rights Reserved.
// http://sylphid.fizzypopstudios.com
//
// =========================================================================================================================
// This file is part of the SylpHID Driver, Daemon, and Preference Pane software (collectively known as "SylpHID").
//
// "SylpHID" is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2 of the License, or (at your option) any later version.
//
// "SylpHID" is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty
// of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License along with "SylpHID";
// if not, write to the Free Software Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
// =========================================================================================================================


#import <Foundation/Foundation.h>
#import <IOKit/IOKitLib.h>
#import <signal.h>

#import "FPSylpHIDDriverInterface.h"
#import "FPSylpHIDPrefsLoader.h"


// wait for an xbox device to be connected
// when a device is connected, load settings from disk to configure the device
static void driversDidLoad(void* refcon, io_iterator_t iterator)
{
	io_object_t driver;

	while ((driver = IOIteratorNext(iterator))) {
		@autoreleasepool {
			FPSylpHIDDriverInterface* device = [FPSylpHIDDriverInterface interfaceWithDriver: driver];
			[FPSylpHIDPrefsLoader createDefaultsForDevice: device];
			[FPSylpHIDPrefsLoader loadSavedConfigForDevice: device];
		}
	}
}


static void appBecameActive(NSString* appid)
{
	IOReturn kr = kIOReturnSuccess;
	mach_port_t masterPort = 0;
	CFMutableDictionaryRef matchDictionary = NULL;
	io_iterator_t iterator;
	io_object_t driver;

	kr = IOMasterPort(bootstrap_port, &masterPort);
	if (kIOReturnSuccess != kr) {
		printf("IOMasterPort error with bootstrap_port\n");
		exit(-1);
	}
	matchDictionary = IOServiceMatching("FPSylpHIDDriver");
	if (!matchDictionary) {
		printf("IOServiceMatching returned NULL\n");
		exit(-3);
	}
	kr = IOServiceGetMatchingServices(masterPort, matchDictionary, &iterator);
	if (kIOReturnSuccess != kr) {
		printf("IOServiceGetMatchingServices failed with 0x%x\n", kr);
		exit(-4);
	}
	while ((driver = IOIteratorNext(iterator))) {
		@autoreleasepool {
			FPSylpHIDDriverInterface* device = [FPSylpHIDDriverInterface interfaceWithDriver: driver];
			[FPSylpHIDPrefsLoader loadConfigForDevice: device forAppID: appid];
		}
	}

}


static void registerForDriverLoadedNotification()
{
	IOReturn kr = kIOReturnSuccess;
	mach_port_t masterPort = 0;
	IONotificationPortRef notificationPort = NULL;
	CFRunLoopSourceRef runLoopSource = NULL;
	CFMutableDictionaryRef matchDictionary = NULL;
	io_iterator_t notification;

	kr = IOMasterPort(bootstrap_port, &masterPort);
	if (kIOReturnSuccess != kr) {
		printf("IOMasterPort error with bootstrap_port\n");
		exit(-1);
	}
	notificationPort = IONotificationPortCreate(masterPort);
	if (NULL == notificationPort) {
		printf("Couldn't create notification port\n");
		exit(-2);
	}
	runLoopSource = IONotificationPortGetRunLoopSource(notificationPort);
	CFRunLoopAddSource(CFRunLoopGetCurrent(), runLoopSource, kCFRunLoopDefaultMode);

	matchDictionary = IOServiceMatching("FPSylpHIDDriver");
	if (!matchDictionary) {
		printf("IOServiceMatching returned NULL\n");
		exit(-3);
	}
	kr = IOServiceAddMatchingNotification(notificationPort, kIOMatchedNotification, matchDictionary, driversDidLoad,
	                                      NULL, &notification);
	if (kIOReturnSuccess != kr) {
		printf("IOServiceAddMatchingNotification failed with 0x%x\n", kr);
		exit(-4);
	}
	if (notification)
		driversDidLoad(NULL, notification);
}


static void registerForApplicationChangedNotification()
{
	NSNotificationCenter* center = [[NSWorkspace sharedWorkspace] notificationCenter];

	// register for app activations
	// load config for activated app, if present, otherwise load default config for any connected devices
	[center addObserverForName: NSWorkspaceDidActivateApplicationNotification object: nil queue: nil
					usingBlock: ^(NSNotification* note) {
									appBecameActive([[note.userInfo objectForKey: NSWorkspaceApplicationKey] bundleIdentifier]);
								}];
}


int main (int argc, const char* argv[]) {
	registerForDriverLoadedNotification();
	registerForApplicationChangedNotification();

	CFRunLoopRun();

	return 0;
}
