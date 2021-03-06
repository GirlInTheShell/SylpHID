//
// FPSylpHIDDriverInterface.m
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


#import <IOKit/usb/USB.h>
#import <IOKit/hid/IOHIDKeys.h>
#import <IOKit/hid/IOHIDUsageTables.h>

#import "FPSylpHIDDriverInterface.h"


@implementation FPSylpHIDDriverInterface


#pragma mark === Interface Methods =============

+ (NSArray*) interfaces
{
	IOReturn result = kIOReturnSuccess;
	mach_port_t masterPort = 0;
	io_iterator_t objectIterator = 0;
	CFMutableDictionaryRef matchDictionary = 0;
	io_object_t driver = 0;
	NSMutableArray* interfaceList = nil;

	result = IOMasterPort(bootstrap_port, &masterPort);
	if (kIOReturnSuccess != result) {
		NSLog(@"IOMasterPort error with bootstrap_port");
		return nil;
	}

	// Set up a matching dictionary to search I/O Registry by class name for all HID class devices
	matchDictionary = IOServiceMatching("FPSylpHIDDriver");
	if (matchDictionary == NULL) {
		NSLog(@"Failed to get CFMutableDictionaryRef via IOServiceMatching");
		return nil;
	}

	// Now search I/O Registry for matching devices
	result = IOServiceGetMatchingServices(masterPort, matchDictionary, &objectIterator);
	if (kIOReturnSuccess != result) {
		NSLog(@"Couldn't create an object iterator");
		return nil;
	}

	if (0 == objectIterator) // there are no joysticks
		return nil;

	interfaceList = [[NSMutableArray alloc] init];

	// IOServiceGetMatchingServices consumes a reference to the dictionary, so we don't need to release the dictionary ref
	while ((driver = IOIteratorNext(objectIterator))) {
		id intf = [FPSylpHIDDriverInterface interfaceWithDriver: driver];
		if (intf)
			[interfaceList addObject: intf];
	}

	IOObjectRelease(objectIterator);

	return interfaceList;
}


+ (FPSylpHIDDriverInterface*) interfaceWithDriver: (io_object_t)driver
{
	return [[FPSylpHIDDriverInterface alloc] initWithDriver: driver];
}


- (id) initWithDriver: (io_object_t)driver
{
	io_name_t className;

	self = [super init];
	if (!self)
		return nil;

	IOObjectRetain(driver);
	_driver = driver;
	_service = 0;

	// check that driver is FPSylpHIDDriver
	if (kIOReturnSuccess != IOObjectGetClass(_driver, className)) {
		return nil;
	}

	if (0 != strcmp(className, "FPSylpHIDDriver")) {
		return nil;
	}

	if (![self getDeviceProperties]) {
		return nil;
	}

	return self;
}


- (void) dealloc
{
	if (_service) IOServiceClose(_service);
	IOObjectRelease(_driver);
}


- (BOOL) rawReportsActive
{
	return (_service != 0);
}


- (void) enableRawReports
{
	if (_service == 0) {
		IOReturn ret = IOServiceOpen(_driver, mach_task_self(), 0, &_service);
		if (ret != kIOReturnSuccess) {
			NSLog(@"enableRawReports Failure (%x)\n", ret);
			_service = 0;
		}
	}
}


- (void) copyRawReport: (XBPadReport*)report
{
	if (_service != 0) {
		size_t size = sizeof(XBPadReport);
		IOReturn ret = IOConnectCallStructMethod(_service, kSylpHIDDriverClientMethodRawReport, NULL, 0, report, &size);
		if (ret != kIOReturnSuccess)
			NSLog(@"copyRawReport:%p Failure(%x) Service(%d)\n", report, ret, _service);
	}
}


- (io_object_t) driver
{
	return _driver;
}


- (NSString*) deviceType
{
	return _deviceType;
}


- (BOOL) deviceIsPad
{
	return [_deviceType isEqualToString: NSSTR(kDeviceTypePadKey)];
}


- (BOOL) deviceIsRemote
{
	return [_deviceType isEqualToString: NSSTR(kDeviceTypeIRKey)];
}


- (NSString*) vendorID
{
	int key = [[_ioRegistryProperties objectForKey: NSSTR(kIOHIDVendorIDKey)] intValue];
	return [NSString stringWithFormat: @"0x%04x", key];
}


- (NSString*) vendorSource
{
	return [_ioRegistryProperties objectForKey: NSSTR(kIOHIDVendorIDSourceKey)];
}


- (NSString*) productID
{
	int key = [[_ioRegistryProperties objectForKey: NSSTR(kIOHIDProductIDKey)] intValue];
	return [NSString stringWithFormat: @"0x%04x", key];
}


- (NSString*) productName
{
	return [_ioRegistryProperties objectForKey: NSSTR(kIOHIDProductKey)];
}


- (NSString*) manufacturerName
{
	return [_ioRegistryProperties objectForKey: NSSTR(kIOHIDManufacturerKey)];
}


- (NSString*) locationID
{
	return [NSString stringWithFormat: @"%08x", [[_ioRegistryProperties objectForKey: NSSTR(kIOHIDLocationIDKey)] intValue]];
}


- (NSString*) versionNumber
{
	int bcd = [[_ioRegistryProperties objectForKey: NSSTR(kIOHIDVersionNumberKey)] intValue];
	return [NSString stringWithFormat: @"%x.%x", bcd >> 8, bcd & 0xFF];
}


- (NSString*) serialNumber
{
	return [_ioRegistryProperties objectForKey: NSSTR(kIOHIDSerialNumberKey)];
}


- (NSString*) identifier
{
	return [NSString stringWithFormat: @"%@-%@", [self deviceType], [self locationID]];
}


- (NSString*) deviceSpeed
{
	uint64_t speed = 0;
	if (_service != 0) {
		uint32_t size = 1;
		IOReturn ret = IOConnectCallScalarMethod(_service, kSylpHIDDriverClientMethodGetSpeed, NULL, 0, &speed, &size);
		if (ret != kIOReturnSuccess)
			NSLog(@"deviceSpeed Failure(%x) Service(%d)\n", ret, _service);
	}
	NSString* type = (speed == kUSBDeviceSpeedLow  ? @"Low"  :
					  speed == kUSBDeviceSpeedFull ? @"Full" :
					  speed == kUSBDeviceSpeedHigh ? @"High" : @"Super");
	NSString* real = (speed == kUSBDeviceSpeedLow  ? @"1.5 Mb" :
					  speed == kUSBDeviceSpeedFull ? @"12 Mb"  :
					  speed == kUSBDeviceSpeedHigh ? @"480 Mb" : @"5 MB" );
	return [NSString stringWithFormat: @"%@ Speed|(%@/sec)", type, real];
}


- (NSString*) devicePower
{
	uint64_t power[2] = { 0, 0 };
	if (_service != 0) {
		uint32_t size = 2;
		IOReturn ret = IOConnectCallScalarMethod(_service, kSylpHIDDriverClientMethodGetPower, NULL, 0, power, &size);
		if (ret != kIOReturnSuccess)
			NSLog(@"devicePower Failure(%x) Service(%d)\n", ret, _service);
	}
	return [NSString stringWithFormat: @"%llu mA|(%llu mA Max)", power[0], power[1]];
}


- (NSString*) deviceAddress
{
	uint64_t addr = 0;
	if (_service != 0) {
		uint32_t size = 1;
		IOReturn ret = IOConnectCallScalarMethod(_service, kSylpHIDDriverClientMethodGetAddress, NULL, 0, &addr, &size);
		if (ret != kIOReturnSuccess)
			NSLog(@"deviceAddress Failure(%x) Service(%d)\n", ret, _service);
	}
	return [NSString stringWithFormat: @"%llu", addr];
}


- (BOOL) hasOptions
{
	return _deviceOptions != nil && [_deviceOptions count] > 0;
}


- (void) loadDefaultLayout
{
	if (_service != 0) {
		IOReturn ret = IOConnectCallMethod(_service, kSylpHIDDriverClientMethodLoadDefault, NULL, 0, NULL, 0, NULL, NULL, NULL, NULL);
		if (ret != kIOReturnSuccess)
			NSLog(@"loadDefaultLayout Failure(%x) Service(%d)\n", ret, _service);
		else
			[self getDeviceProperties];
	}
}


- (BOOL) loadOptions: (NSDictionary*)options
{
	// use a little trick here to avoid code duplication...
	// temporarily set the options dictionary so that the "get" methods pull their values from there, but the "set"
	// methods change the values in the driver instance (ioregistry), which is what this method is supposed to do!
	if (options && [_deviceType isEqualTo: NSSTR(kDeviceTypePadKey)]) {
		// the get* methods will now read from the passed in dictionary
		_deviceOptions = options;
		XBPadOptions ioreg;

		// the set* methods refetch the ioreg properties, so we have to get all the values up front before setting anything
		ioreg.InvertLxAxis = [self leftStickHorizInvert];
		ioreg.DeadzoneLxAxis = [self leftStickHorizDeadzone];
		ioreg.MappingLxAxis = [self leftStickHorizMapping];

		ioreg.InvertLyAxis = [self leftStickVertInvert];
		ioreg.DeadzoneLyAxis = [self leftStickVertDeadzone];
		ioreg.MappingLyAxis = [self leftStickVertMapping];

		ioreg.InvertRxAxis = [self rightStickHorizInvert];
		ioreg.DeadzoneRxAxis = [self rightStickHorizDeadzone];
		ioreg.MappingRxAxis = [self rightStickHorizMapping];

		ioreg.InvertRyAxis = [self rightStickVertInvert];
		ioreg.DeadzoneRyAxis = [self rightStickVertDeadzone];
		ioreg.MappingRyAxis = [self rightStickVertMapping];

		ioreg.MappingDPadUp = [self dpadUpMapping];
		ioreg.MappingDPadDown = [self dpadDownMapping];
		ioreg.MappingDPadLeft = [self dpadLeftMapping];
		ioreg.MappingDPadRight = [self dpadRightMapping];

		ioreg.MappingButtonStart = [self startButtonMapping];
		ioreg.MappingButtonBack = [self backButtonMapping];

		ioreg.MappingLeftClick = [self leftClickMapping];
		ioreg.MappingRightClick = [self rightClickMapping];

		ioreg.AnalogAsDigital = [self analogAsDigital];

		ioreg.ThresholdLowLeftTrigger = [self leftTriggerLowThreshold];
		ioreg.ThresholdHighLeftTrigger = [self leftTriggerHighThreshold];
		ioreg.MappingLeftTrigger = [self leftTriggerMapping];
		ioreg.AlternateLeftTrigger = [self leftTriggerAlternate];

		ioreg.ThresholdLowRightTrigger = [self rightTriggerLowThreshold];
		ioreg.ThresholdHighRightTrigger = [self rightTriggerHighThreshold];
		ioreg.MappingRightTrigger = [self rightTriggerMapping];
		ioreg.AlternateRightTrigger = [self rightTriggerAlternate];

		ioreg.ThresholdLowButtonGreen = [self greenButtonLowThreshold];
		ioreg.ThresholdHighButtonGreen = [self greenButtonHighThreshold];
		ioreg.MappingButtonGreen = [self greenButtonMapping];

		ioreg.ThresholdLowButtonRed = [self redButtonLowThreshold];
		ioreg.ThresholdHighButtonRed = [self redButtonHighThreshold];
		ioreg.MappingButtonRed = [self redButtonMapping];

		ioreg.ThresholdLowButtonBlue = [self blueButtonLowThreshold];
		ioreg.ThresholdHighButtonBlue = [self blueButtonHighThreshold];
		ioreg.MappingButtonBlue = [self blueButtonMapping];

		ioreg.ThresholdLowButtonYellow = [self yellowButtonLowThreshold];
		ioreg.ThresholdHighButtonYellow = [self yellowButtonHighThreshold];
		ioreg.MappingButtonYellow = [self yellowButtonMapping];

		ioreg.ThresholdLowButtonWhite = [self whiteButtonLowThreshold];
		ioreg.ThresholdHighButtonWhite = [self whiteButtonHighThreshold];
		ioreg.MappingButtonWhite = [self whiteButtonMapping];

		ioreg.ThresholdLowButtonBlack = [self blackButtonLowThreshold];
		ioreg.ThresholdHighButtonBlack = [self blackButtonHighThreshold];
		ioreg.MappingButtonBlack = [self blackButtonMapping];

		[self setLeftStickHorizInvert: ioreg.InvertLxAxis];
		[self setLeftStickHorizDeadzone: ioreg.DeadzoneLxAxis];
		[self setLeftStickHorizMapping: ioreg.MappingLxAxis];

		[self setLeftStickVertInvert: ioreg.InvertLyAxis];
		[self setLeftStickVertDeadzone: ioreg.DeadzoneLyAxis];
		[self setLeftStickVertMapping: ioreg.MappingLyAxis];

		[self setRightStickHorizInvert: ioreg.InvertRxAxis];
		[self setRightStickHorizDeadzone: ioreg.DeadzoneRxAxis];
		[self setRightStickHorizMapping: ioreg.MappingRxAxis];

		[self setRightStickVertInvert: ioreg.InvertRyAxis];
		[self setRightStickVertDeadzone: ioreg.DeadzoneRyAxis];
		[self setRightStickVertMapping: ioreg.MappingRyAxis];

		[self setDpadUpMapping: ioreg.MappingDPadUp];
		[self setDpadDownMapping: ioreg.MappingDPadDown];
		[self setDpadLeftMapping: ioreg.MappingDPadLeft];
		[self setDpadRightMapping: ioreg.MappingDPadRight];

		[self setStartButtonMapping: ioreg.MappingButtonStart];
		[self setBackButtonMapping: ioreg.MappingButtonBack];

		[self setLeftClickMapping: ioreg.MappingLeftClick];
		[self setRightClickMapping: ioreg.MappingRightClick];

		[self setAnalogAsDigital: ioreg.AnalogAsDigital];

		[self setLeftTriggerLow: ioreg.ThresholdLowLeftTrigger andHighThreshold: ioreg.ThresholdHighLeftTrigger];
		[self setLeftTriggerMapping: ioreg.MappingLeftTrigger];
		[self setLeftTriggerAlternate: ioreg.AlternateLeftTrigger];

		[self setRightTriggerLow: ioreg.ThresholdLowRightTrigger andHighThreshold: ioreg.ThresholdHighRightTrigger];
		[self setRightTriggerMapping: ioreg.MappingRightTrigger];
		[self setRightTriggerAlternate: ioreg.AlternateRightTrigger];

		[self setGreenButtonLow: ioreg.ThresholdLowButtonGreen andHighThreshold: ioreg.ThresholdHighButtonGreen];
		[self setGreenButtonMapping: ioreg.MappingButtonGreen];

		[self setRedButtonLow: ioreg.ThresholdLowButtonRed andHighThreshold: ioreg.ThresholdHighButtonRed];
		[self setRedButtonMapping: ioreg.MappingButtonRed];

		[self setBlueButtonLow: ioreg.ThresholdLowButtonBlue andHighThreshold: ioreg.ThresholdHighButtonBlue];
		[self setBlueButtonMapping: ioreg.MappingButtonBlue];

		[self setYellowButtonLow: ioreg.ThresholdLowButtonYellow andHighThreshold: ioreg.ThresholdHighButtonYellow];
		[self setYellowButtonMapping: ioreg.MappingButtonYellow];

		[self setWhiteButtonLow: ioreg.ThresholdLowButtonWhite andHighThreshold: ioreg.ThresholdHighButtonWhite];
		[self setWhiteButtonMapping: ioreg.MappingButtonWhite];

		[self setBlackButtonLow: ioreg.ThresholdLowButtonBlack andHighThreshold: ioreg.ThresholdHighButtonBlack];
		[self setBlackButtonMapping: ioreg.MappingButtonBlack];

		return YES;
	}

	return NO;
}


- (NSDictionary*) deviceOptions
{
	return _deviceOptions;
}


#pragma mark === Private Methods ==============

- (BOOL) getDeviceProperties
{
	CFMutableDictionaryRef ioRegistryProperties = 0;

	// get the ioregistry properties
	if (kIOReturnSuccess != IORegistryEntryCreateCFProperties(_driver, &ioRegistryProperties, kCFAllocatorDefault, 0))
		return NO;
	if (!ioRegistryProperties)
		return NO;
	_ioRegistryProperties = (__bridge NSMutableDictionary*)ioRegistryProperties;

	// set the device type
	_deviceType = [_ioRegistryProperties objectForKey: NSSTR(kTypeKey)];
	if (!_deviceType)
		return NO;
	_deviceOptions = [_ioRegistryProperties objectForKey: NSSTR(kDeviceOptionsKey)];

	return YES;
}


- (void) setOptionWithKey: (NSString*)key andValue: (id)value
{
	NSDictionary* request;
	IOReturn ret;

	request = [NSDictionary dictionaryWithObjectsAndKeys: _deviceType, NSSTR(kTypeKey),
														  key, NSSTR(kClientOptionKeyKey),
														  value, NSSTR(kClientOptionValueKey), nil];
	CFDictionaryRef dict = (__bridge CFDictionaryRef)request;
	ret = IORegistryEntrySetCFProperties(_driver, dict);
	if (ret != kIOReturnSuccess)
		NSLog(@"Failed setting driver properties: 0x%x", ret);
}


- (NSMutableDictionary*) elementWithCookieRec: (int)cookie elements: (NSArray*)elements
{
	NSUInteger i, count;

	for (i = 0, count = [elements count]; i < count; i++) {
		NSMutableDictionary* element = [elements objectAtIndex: i];
		NSArray* subElements;

		if (cookie == [[element objectForKey: NSSTR(kIOHIDElementCookieKey)] intValue])
			return element;
		else {
			subElements = [element objectForKey: NSSTR(kIOHIDElementKey)];
			if (subElements) {
				element = [self elementWithCookieRec: cookie elements: subElements];
				if (element)
					return element;
			}
		}
	}

	return nil;
}


- (NSMutableDictionary*) elementWithCookie: (int)cookie
{
	NSArray* elements = [_ioRegistryProperties objectForKey: NSSTR(kIOHIDElementKey)];
	return elements ? [self elementWithCookieRec: cookie elements: elements] : nil;
}


- (void) commitElements
{
	NSArray* elements = [_ioRegistryProperties objectForKey: NSSTR(kIOHIDElementKey)];
	IOReturn ret;

	if (elements) {
		NSDictionary* request = [NSDictionary dictionaryWithObjectsAndKeys: elements, NSSTR(kClientOptionSetElementsKey), nil];

		if (request) {
			CFDictionaryRef dict = (__bridge CFDictionaryRef)request;
			ret = IORegistryEntrySetCFProperties(_driver, dict);
			if (ret != kIOReturnSuccess)
				NSLog(@"Failed setting driver properties: 0x%x", ret);
		}
	}
}


#pragma mark === Left Stick ==================
#pragma mark --- Horizontal ----------------------

- (int) leftStickHorizMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingLxAxisKey)] intValue];
}


- (void) setLeftStickHorizMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingLxAxisKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (BOOL) leftStickHorizInvert
{
	return idToBOOL([_deviceOptions objectForKey: NSSTR(kOptionInvertLxAxisKey)]);
}


- (void) setLeftStickHorizInvert: (BOOL)inverts
{
	[self setOptionWithKey: NSSTR(kOptionInvertLxAxisKey) andValue: BOOLtoID(inverts)];
	[self getDeviceProperties];
}


- (int) leftStickHorizDeadzone
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionDeadzoneLxAxisKey)] intValue];
}


- (void) setLeftStickHorizDeadzone: (int)pcent
{
	[self setOptionWithKey: NSSTR(kOptionDeadzoneLxAxisKey) andValue: NSNUM(pcent)];
	[self getDeviceProperties];
}


#pragma mark --- Vertical ------------------------

- (int) leftStickVertMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingLyAxisKey)] intValue];
}


- (void) setLeftStickVertMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingLyAxisKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (BOOL) leftStickVertInvert
{
	return idToBOOL([_deviceOptions objectForKey: NSSTR(kOptionInvertLyAxisKey)]);
}


- (void) setLeftStickVertInvert: (BOOL)inverts
{
	[self setOptionWithKey: NSSTR(kOptionInvertLyAxisKey) andValue: BOOLtoID(inverts)];
	[self getDeviceProperties];
}


- (int) leftStickVertDeadzone
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionDeadzoneLyAxisKey)] intValue];
}


- (void) setLeftStickVertDeadzone: (int)pcent
{
	[self setOptionWithKey: NSSTR(kOptionDeadzoneLyAxisKey) andValue: NSNUM(pcent)];
	[self getDeviceProperties];
}


#pragma mark === Right Stick =================
#pragma mark --- Horizontal ----------------------

- (int) rightStickHorizMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingRxAxisKey)] intValue];
}


- (void) setRightStickHorizMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingRxAxisKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (BOOL) rightStickHorizInvert
{
	return idToBOOL([_deviceOptions objectForKey: NSSTR(kOptionInvertRxAxisKey)]);
}


- (void) setRightStickHorizInvert: (BOOL)inverts
{
	[self setOptionWithKey: NSSTR(kOptionInvertRxAxisKey) andValue: BOOLtoID(inverts)];
	[self getDeviceProperties];
}


- (int) rightStickHorizDeadzone
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionDeadzoneRxAxisKey)] intValue];
}


- (void) setRightStickHorizDeadzone: (int)pcent
{
	[self setOptionWithKey: NSSTR(kOptionDeadzoneRxAxisKey) andValue: NSNUM(pcent)];
	[self getDeviceProperties];
}


#pragma mark --- Vertical ------------------------

- (int) rightStickVertMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingRyAxisKey)] intValue];
}


- (void) setRightStickVertMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingRyAxisKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (BOOL) rightStickVertInvert
{
	return idToBOOL([_deviceOptions objectForKey: NSSTR(kOptionInvertRyAxisKey)]);
}


- (void) setRightStickVertInvert: (BOOL)inverts
{
	[self setOptionWithKey: NSSTR(kOptionInvertRyAxisKey) andValue: BOOLtoID(inverts)];
	[self getDeviceProperties];
}


- (int) rightStickVertDeadzone
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionDeadzoneRyAxisKey)] intValue];
}


- (void) setRightStickVertDeadzone: (int)pcent
{
	[self setOptionWithKey: NSSTR(kOptionDeadzoneRyAxisKey) andValue: NSNUM(pcent)];
	[self getDeviceProperties];
}


#pragma mark === Digital Button Mappings ========
#pragma mark --- Directional Pad ------------------

- (int) dpadUpMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingDPadUpKey)] intValue];
}

- (void) setDpadUpMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingDPadUpKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) dpadDownMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingDPadDownKey)] intValue];
}


- (void) setDpadDownMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingDPadDownKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) dpadLeftMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingDPadLeftKey)] intValue];
}


- (void) setDpadLeftMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingDPadLeftKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) dpadRightMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingDPadRightKey)] intValue];
}


- (void) setDpadRightMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingDPadRightKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


#pragma mark --- Start / Back ---------------------

- (int) startButtonMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingButtonStartKey)] intValue];
}


- (void) setStartButtonMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingButtonStartKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) backButtonMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingButtonBackKey)] intValue];
}


- (void) setBackButtonMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingButtonBackKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


#pragma mark --- Left / Right Click -----------------

- (int) leftClickMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingLeftClickKey)] intValue];
}


- (void) setLeftClickMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingLeftClickKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) rightClickMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingRightClickKey)] intValue];
}


- (void) setRightClickMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingRightClickKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


#pragma mark === Analog Button Mappings ========

- (int) analogAsDigital
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionAnalogAsDigitalKey)] intValue];
}


- (void) setAnalogAsDigital: (int)mask
{
	NSMutableDictionary* element;
	int max, i;

	for (i = kCookiePadFirstAnalogButton; i < kCookiePadLastAnalogButton; i++) {
		max = (mask & BITMASK((i - kCookiePadFirstAnalogButton))) ? kButtonDigitalMax : kButtonAnalogMax;
		element = [self elementWithCookie: i];

		if (element) {
			[element setObject: NSNUM(max) forKey: NSSTR(kIOHIDElementMaxKey)];
			[element setObject: NSNUM(max) forKey: NSSTR(kIOHIDElementScaledMaxKey)];
		}
	}

	for (i = kCookiePadFirstTrigger; i < kCookiePadLastTrigger; i++) {
		max = (mask & BITMASK((i - kCookiePadFirstTrigger))) ? kButtonDigitalMax : kButtonAnalogMax;
		element = [self elementWithCookie: i];

		if (element) {
			[element setObject: NSNUM(max) forKey: NSSTR(kIOHIDElementMaxKey)];
			[element setObject: NSNUM(max) forKey: NSSTR(kIOHIDElementScaledMaxKey)];
		}
	}

	// update elements structure in ioregistry/driver
	[self commitElements];
	[self setOptionWithKey: NSSTR(kOptionAnalogAsDigitalKey) andValue: NSNUM(mask)];
	[self getDeviceProperties];
}


- (void) setMapsTrigger: (int)cookie toElement: (int)usage
{
	if (cookie == kCookiePadLeftTrigger || cookie == kCookiePadRightTrigger) {
		int usagePage = (usage < kHIDUsage_GD_X ? kHIDPage_Button : kHIDPage_GenericDesktop);
		NSMutableDictionary*element = [self elementWithCookie: cookie];
		if (element) {
			[element setObject: NSNUM(usagePage) forKey: NSSTR(kIOHIDElementUsagePageKey)];
			[element setObject: NSNUM(usage) forKey: NSSTR(kIOHIDElementUsageKey)];
		}
		[self commitElements];
		[self setOptionWithKey: cookie == kCookiePadLeftTrigger ? NSSTR(kOptionAlternateLeftTriggerKey)
																: NSSTR(kOptionAlternateRightTriggerKey)
					  andValue: BOOLtoID(usagePage == kHIDPage_Button)];
		[self getDeviceProperties];
	}
}


#pragma mark --- Left Trigger ---------------------

- (BOOL) leftTriggerAlternate
{
	return idToBOOL([_deviceOptions objectForKey: NSSTR(kOptionAlternateLeftTriggerKey)]);
}


- (void) setLeftTriggerAlternate: (bool)flag
{
	[self setMapsTrigger: kCookiePadLeftTrigger toElement: (flag ? kHIDUsage_Button_15 : kHIDUsage_GD_Z)];
}


- (int) leftTriggerMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingLeftTriggerKey)] intValue];
}


- (void) setLeftTriggerMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingLeftTriggerKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) leftTriggerLowThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdLowLeftTriggerKey)] intValue];
}


- (int) leftTriggerHighThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdHighLeftTriggerKey)] intValue];
}


- (void) setLeftTriggerLow: (int)low andHighThreshold: (int)high
{
	[self setOptionWithKey: NSSTR(kOptionThresholdLowLeftTriggerKey) andValue: NSNUM(low)];
	[self setOptionWithKey: NSSTR(kOptionThresholdHighLeftTriggerKey) andValue: NSNUM(high)];
	[self getDeviceProperties];
}


#pragma mark --- Right Trigger --------------------

- (BOOL) rightTriggerAlternate
{
	return idToBOOL([_deviceOptions objectForKey: NSSTR(kOptionAlternateRightTriggerKey)]);
}


- (void) setRightTriggerAlternate: (bool)flag
{
	[self setMapsTrigger: kCookiePadRightTrigger toElement: (flag ? kHIDUsage_Button_16 : kHIDUsage_GD_Rz)];
}


- (int) rightTriggerMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingRightTriggerKey)] intValue];
}


- (void) setRightTriggerMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingRightTriggerKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) rightTriggerLowThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdLowRightTriggerKey)] intValue];
}


- (int) rightTriggerHighThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdHighRightTriggerKey)] intValue];
}


- (void) setRightTriggerLow: (int)low andHighThreshold: (int)high
{
	[self setOptionWithKey: NSSTR(kOptionThresholdLowRightTriggerKey) andValue: NSNUM(low)];
	[self setOptionWithKey: NSSTR(kOptionThresholdHighRightTriggerKey) andValue: NSNUM(high)];
	[self getDeviceProperties];
}


#pragma mark --- Green (A) -----------------------

- (int) greenButtonMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingButtonGreenKey)] intValue];
}


- (void) setGreenButtonMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingButtonGreenKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) greenButtonLowThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdLowButtonGreenKey)] intValue];
}


- (int) greenButtonHighThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdHighButtonGreenKey)] intValue];
}


- (void) setGreenButtonLow: (int)low andHighThreshold: (int)high
{
	[self setOptionWithKey: NSSTR(kOptionThresholdLowButtonGreenKey) andValue: NSNUM(low)];
	[self setOptionWithKey: NSSTR(kOptionThresholdHighButtonGreenKey) andValue: NSNUM(high)];
	[self getDeviceProperties];
}


#pragma mark --- Red (B) -------------------------

- (int) redButtonMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingButtonRedKey)] intValue];
}


- (void) setRedButtonMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingButtonRedKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) redButtonLowThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdLowButtonRedKey)] intValue];
}


- (int) redButtonHighThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdHighButtonRedKey)] intValue];
}


- (void) setRedButtonLow: (int)low andHighThreshold: (int)high
{
	[self setOptionWithKey: NSSTR(kOptionThresholdLowButtonRedKey) andValue: NSNUM(low)];
	[self setOptionWithKey: NSSTR(kOptionThresholdHighButtonRedKey) andValue: NSNUM(high)];
	[self getDeviceProperties];
}


#pragma mark --- Blue (X) ------------------------

- (int) blueButtonMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingButtonBlueKey)] intValue];
}


- (void) setBlueButtonMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingButtonBlueKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) blueButtonLowThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdLowButtonBlueKey)] intValue];
}


- (int) blueButtonHighThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdHighButtonBlueKey)] intValue];
}


- (void) setBlueButtonLow: (int)low andHighThreshold: (int)high
{
	[self setOptionWithKey: NSSTR(kOptionThresholdLowButtonBlueKey) andValue: NSNUM(low)];
	[self setOptionWithKey: NSSTR(kOptionThresholdHighButtonBlueKey) andValue: NSNUM(high)];
	[self getDeviceProperties];
}


#pragma mark --- Yellow (Y) ----------------------

- (int) yellowButtonMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingButtonYellowKey)] intValue];
}


- (void) setYellowButtonMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingButtonYellowKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) yellowButtonLowThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdLowButtonYellowKey)] intValue];
}


- (int) yellowButtonHighThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdHighButtonYellowKey)] intValue];
}


- (void) setYellowButtonLow: (int)low andHighThreshold: (int)high
{
	[self setOptionWithKey: NSSTR(kOptionThresholdLowButtonYellowKey) andValue: NSNUM(low)];
	[self setOptionWithKey: NSSTR(kOptionThresholdHighButtonYellowKey) andValue: NSNUM(high)];
	[self getDeviceProperties];
}


#pragma mark --- Black Button ---------------------

- (int) blackButtonMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingButtonBlackKey)] intValue];
}


- (void) setBlackButtonMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingButtonBlackKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) blackButtonLowThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdLowButtonBlackKey)] intValue];
}


- (int) blackButtonHighThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdHighButtonBlackKey)] intValue];
}


- (void) setBlackButtonLow: (int)low andHighThreshold: (int)high
{
	[self setOptionWithKey: NSSTR(kOptionThresholdLowButtonBlackKey) andValue: NSNUM(low)];
	[self setOptionWithKey: NSSTR(kOptionThresholdHighButtonBlackKey) andValue: NSNUM(high)];
	[self getDeviceProperties];
}


#pragma mark --- White Button --------------------

- (int) whiteButtonMapping
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionMappingButtonWhiteKey)] intValue];
}


- (void) setWhiteButtonMapping: (int)map
{
	[self setOptionWithKey: NSSTR(kOptionMappingButtonWhiteKey) andValue: NSNUM(map)];
	[self getDeviceProperties];
}


- (int) whiteButtonLowThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdLowButtonWhiteKey)] intValue];
}


- (int) whiteButtonHighThreshold
{
	return [[_deviceOptions objectForKey: NSSTR(kOptionThresholdHighButtonWhiteKey)] intValue];
}


- (void) setWhiteButtonLow: (int)low andHighThreshold: (int)high
{
	[self setOptionWithKey: NSSTR(kOptionThresholdLowButtonWhiteKey) andValue: NSNUM(low)];
	[self setOptionWithKey: NSSTR(kOptionThresholdHighButtonWhiteKey) andValue: NSNUM(high)];
	[self getDeviceProperties];
}


@end


#pragma mark === Utility Functions ===============

BOOL idToBOOL(id obj)
{
	return [obj intValue] ? YES : NO;
}


id NSNUM(SInt32 num)
{
	CFNumberRef cfNumber;
	id obj;

	cfNumber = CFNumberCreate(kCFAllocatorDefault, kCFNumberSInt32Type, &num);

	obj = (__bridge id)cfNumber;

	return obj;
}
