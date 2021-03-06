//
// FPSylpHIDDriverKeys.h
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


#ifndef _FPSylpHIDDriverKeys_h_
#define _FPSylpHIDDriverKeys_h_


// Request codes for FPSylpHIDUserClient in driver
enum SylpHIDDriverRequestCode {
	kSylpHIDDriverClientMethodRawReport,		// Returns raw report data for use by live-report markers on sliders
	kSylpHIDDriverClientMethodLoadDefault,		// Load default settings into current configuration
	kSylpHIDDriverClientMethodGetSpeed,			// Get speed of USB bus device is plugged into
	kSylpHIDDriverClientMethodGetPower,			// Get power requirements of USB device and Max power avilable
	kSylpHIDDriverClientMethodGetAddress,		// Get USB address for displaying with locationID
	kSylpHIDDriverClientMethodCount
};


// this structure represents the gampad's raw report
typedef struct XBPadReport {
	UInt8
	    r1,				// reserved
	    r2,				// report length (useless)
	    buttons,		// up, down, left, right, start, back, left-click, right-click	// bitfield - digital state
	    r3,				// reserved
	    a,
	    b,
	    x,				// analog buttons (0-255 range, or 0-1 if digital mode enabled)
	    y,
	    black,
	    white,
	    lt,				// left trigger
	    rt;				// right trigger

	UInt8
	    lxlo, lxhi,
	    lylo, lyhi,		// lo/hi bits of signed 16-bit axes
	    rxlo, rxhi,
	    rylo, ryhi;
} XBPadReport;


typedef struct XBPadOptions {
	UInt8 MappingLxAxis;
	bool InvertLxAxis;
	UInt8 DeadzoneLxAxis;

	UInt8 MappingLyAxis;
	bool InvertLyAxis;
	UInt8 DeadzoneLyAxis;

	UInt8 MappingLeftClick;

	UInt8 MappingRxAxis;
	bool InvertRxAxis;
	UInt8 DeadzoneRxAxis;

	UInt8 MappingRyAxis;
	bool InvertRyAxis;
	UInt8 DeadzoneRyAxis;

	UInt8 MappingRightClick;

	UInt8 MappingDPadUp;
	UInt8 MappingDPadDown;
	UInt8 MappingDPadLeft;
	UInt8 MappingDPadRight;

	UInt8 MappingButtonBack;
	UInt8 MappingButtonStart;

	UInt8 AnalogAsDigital;

	UInt8 MappingButtonGreen;
	UInt8 ThresholdLowButtonGreen;
	UInt8 ThresholdHighButtonGreen;

	UInt8 MappingButtonRed;
	UInt8 ThresholdLowButtonRed;
	UInt8 ThresholdHighButtonRed;

	UInt8 MappingButtonBlue;
	UInt8 ThresholdLowButtonBlue;
	UInt8 ThresholdHighButtonBlue;

	UInt8 MappingButtonYellow;
	UInt8 ThresholdLowButtonYellow;
	UInt8 ThresholdHighButtonYellow;

	UInt8 MappingButtonBlack;
	UInt8 ThresholdLowButtonBlack;
	UInt8 ThresholdHighButtonBlack;

	UInt8 MappingButtonWhite;
	UInt8 ThresholdLowButtonWhite;
	UInt8 ThresholdHighButtonWhite;

	UInt8 AlternateLeftTrigger;
	UInt8 MappingLeftTrigger;
	UInt8 ThresholdLowLeftTrigger;
	UInt8 ThresholdHighLeftTrigger;

	UInt8 AlternateRightTrigger;
	UInt8 MappingRightTrigger;
	UInt8 ThresholdLowRightTrigger;
	UInt8 ThresholdHighRightTrigger;
} XBPadOptions;


// min/max defines
#define kButtonMin						0
#define kButtonAnalogMax				255
#define kButtonAnalogMaxF				255.0
#define kButtonDigitalMax				1
#define kStickMin					   -32768.0
#define kStickMax						32767.0
#define kStickRange						32768.0
#define kValueToStickHigh(v)		   ((v) >> 8)
#define kValueToStickLow(v)			   ((v) & 0xFF)
#define kStickHighLowToValue(h,l)	   (((h) << 8) | (l))

// macro for easily generating bitmasks
#define BITMASK(bit)	(1 << bit)

// kHIDUsage_Button_*
#define kHIDUsage_Button_15				15
#define kHIDUsage_Button_16				16

// constants for Digital only buttons
#define kXboxDigitalDPadUp				0
#define kXboxDigitalDPadDown			1
#define kXboxDigitalDPadLeft			2
#define kXboxDigitalDPadRight			3
#define kXboxDigitalButtonStart			4
#define kXboxDigitalButtonBack			5
#define kXboxDigitalLeftClick			6
#define kXboxDigitalRightClick			7
#define kXboxDigitalOffset				10

// constants for AnalogAsDigital bitfield
#define kXboxAnalogButtonGreen			0
#define kXboxAnalogButtonRed			1
#define kXboxAnalogButtonBlue			2
#define kXboxAnalogButtonYellow			3
#define kXboxAnalogButtonBlack			4
#define kXboxAnalogButtonWhite			5
#define kXboxAnalogLeftTrigger			6
#define kXboxAnalogRightTrigger			7

// contants for axis elements
#define kXboxAxisLeftStickHoriz			0
#define kXboxAxisLeftStickVert			1
#define kXboxAxisRightStickHoriz		2
#define kXboxAxisRightStickVert			3

// constants for pseudo elements
#define kXboxPseudoBothTriggers			0
#define kXboxPseudoGreenRed				1
#define kXboxPseudoBlueYellow			2
#define kXboxPseudoGreenYellow			3
#define kXboxPseudoBlueRed				4
#define kXboxPseudoRedYellow			5
#define kXboxPseudoGreenBlue			6
#define kXboxPseudoWhiteBlack			7
#define kXboxPseudoDPadUpDown			8
#define kXboxPseudoDPadLeftRight		9
#define kXboxPseudoStartBack			10
#define kXboxPseudoClickLeftRight		11

// constants for 'cookie' identifiers
#define kCookiePadDisabled				0

#define kCookiePadFirstDigitalButton    6
#define kCookiePadLastDigitalButton		13
#define kCookiePadDPadUp			   (kCookiePadFirstDigitalButton + kXboxDigitalDPadUp)
#define kCookiePadDPadDown			   (kCookiePadFirstDigitalButton + kXboxDigitalDPadDown)
#define kCookiePadDPadLeft			   (kCookiePadFirstDigitalButton + kXboxDigitalDPadLeft)
#define kCookiePadDPadRight			   (kCookiePadFirstDigitalButton + kXboxDigitalDPadRight)
#define kCookiePadButtonStart		   (kCookiePadFirstDigitalButton + kXboxDigitalButtonStart)
#define kCookiePadButtonBack		   (kCookiePadFirstDigitalButton + kXboxDigitalButtonBack)
#define kCookiePadLeftClick			   (kCookiePadFirstDigitalButton + kXboxDigitalLeftClick)
#define kCookiePadRightClick		   (kCookiePadFirstDigitalButton + kXboxDigitalRightClick)

#define kCookiePadFirstAnalogButton		14
#define kCookiePadLastAnalogButton		19
#define kCookiePadButtonGreen		   (kCookiePadFirstAnalogButton + kXboxAnalogButtonGreen)
#define kCookiePadButtonRed			   (kCookiePadFirstAnalogButton + kXboxAnalogButtonRed)
#define kCookiePadButtonBlue		   (kCookiePadFirstAnalogButton + kXboxAnalogButtonBlue)
#define kCookiePadButtonYellow		   (kCookiePadFirstAnalogButton + kXboxAnalogButtonYellow)
#define kCookiePadButtonBlack		   (kCookiePadFirstAnalogButton + kXboxAnalogButtonBlack)
#define kCookiePadButtonWhite		   (kCookiePadFirstAnalogButton + kXboxAnalogButtonWhite)

#define kCookiePadFirstTrigger			20
#define kCookiePadLastTrigger			21
#define kCookiePadLeftTrigger			kCookiePadFirstTrigger
#define kCookiePadRightTrigger			kCookiePadLastTrigger

#define kCookiePadFirstAxis				22
#define kCookiePadLastAxis				25
#define kCookiePadLxAxis			   (kCookiePadFirstAxis + kXboxAxisLeftStickHoriz)
#define kCookiePadLyAxis			   (kCookiePadFirstAxis + kXboxAxisLeftStickVert)
#define kCookiePadRxAxis			   (kCookiePadFirstAxis + kXboxAxisRightStickHoriz)
#define kCookiePadRyAxis			   (kCookiePadFirstAxis + kXboxAxisRightStickVert)

// pseudo cookie values for mapping buttons to an axis
#define kCookiePadPseudo				100
#define kCookiePadTriggers			   (kCookiePadPseudo + kXboxPseudoBothTriggers)
#define kCookiePadGreenRed			   (kCookiePadPseudo + kXboxPseudoGreenRed)
#define kCookiePadBlueYellow		   (kCookiePadPseudo + kXboxPseudoBlueYellow)
#define kCookiePadGreenYellow		   (kCookiePadPseudo + kXboxPseudoGreenYellow)
#define kCookiePadBlueRed			   (kCookiePadPseudo + kXboxPseudoBlueRed)
#define kCookiePadRedYellow			   (kCookiePadPseudo + kXboxPseudoRedYellow)
#define kCookiePadGreenBlue			   (kCookiePadPseudo + kXboxPseudoGreenBlue)
#define kCookiePadWhiteBlack		   (kCookiePadPseudo + kXboxPseudoWhiteBlack)
#define kCookiePadDPadUpDown		   (kCookiePadPseudo + kXboxPseudoDPadUpDown)
#define kCookiePadDPadLeftRight		   (kCookiePadPseudo + kXboxPseudoDPadLeftRight)
#define kCookiePadStartBack			   (kCookiePadPseudo + kXboxPseudoStartBack)
#define kCookiePadClickLeftRight	   (kCookiePadPseudo + kXboxPseudoClickLeftRight)

// keys for client configuration
#define kClientOptionKeyKey						"OptionKey"
#define kClientOptionValueKey					"OptionValue"
#define kClientOptionSetElementsKey				"Elements"

// keys for XML configuration
#define kDeviceDataKey							"DeviceData"
#define kKnownDevicesKey						"KnownDevices"

// device types
#define kDeviceTypePadKey						"Pad"
#define kDeviceTypeIRKey						"IR"

// top-level device properties
#define kDeviceGenericPropertiesKey				"GenericProperties"
#define kDeviceHIDReportDescriptorKey			"HIDReportDescriptor"
#define kDeviceUSBStringTableKey				"USBStrings"
#define kDeviceOptionsKey						"Options"
#define kDeviceButtonMapKey						"ButtonMap"

// axis
#define kOptionMappingLxAxisKey					"MappingLxAxis"
#define kOptionInvertLxAxisKey					"InvertLxAxis"
#define kOptionDeadzoneLxAxisKey				"DeadzoneLxAxis"

#define kOptionMappingLyAxisKey					"MappingLyAxis"
#define kOptionInvertLyAxisKey					"InvertLyAxis"
#define kOptionDeadzoneLyAxisKey				"DeadzoneLyAxis"

#define kOptionMappingLeftClickKey				"MappingLeftClick"

#define kOptionMappingRxAxisKey					"MappingRxAxis"
#define kOptionInvertRxAxisKey					"InvertRxAxis"
#define kOptionDeadzoneRxAxisKey				"DeadzoneRxAxis"

#define kOptionMappingRyAxisKey					"MappingRyAxis"
#define kOptionInvertRyAxisKey					"InvertRyAxis"
#define kOptionDeadzoneRyAxisKey				"DeadzoneRyAxis"

#define kOptionMappingRightClickKey				"MappingRightClick"

// buttons
#define kOptionAnalogAsDigitalKey				"AnalogAsDigital"

#define kOptionMappingButtonGreenKey			"MappingButtonGreen"
#define kOptionThresholdLowButtonGreenKey		"ThresholdLowButtonGreen"
#define kOptionThresholdHighButtonGreenKey		"ThresholdHighButtonGreen"

#define kOptionMappingButtonRedKey				"MappingButtonRed"
#define kOptionThresholdLowButtonRedKey			"ThresholdLowButtonRed"
#define kOptionThresholdHighButtonRedKey		"ThresholdHighButtonRed"

#define kOptionMappingButtonBlueKey				"MappingButtonBlue"
#define kOptionThresholdLowButtonBlueKey		"ThresholdLowButtonBlue"
#define kOptionThresholdHighButtonBlueKey		"ThresholdHighButtonBlue"

#define kOptionMappingButtonYellowKey			"MappingButtonYellow"
#define kOptionThresholdLowButtonYellowKey		"ThresholdLowButtonYellow"
#define kOptionThresholdHighButtonYellowKey		"ThresholdHighButtonYellow"

#define kOptionMappingButtonBlackKey			"MappingButtonBlack"
#define kOptionThresholdLowButtonBlackKey		"ThresholdLowButtonBlack"
#define kOptionThresholdHighButtonBlackKey		"ThresholdHighButtonBlack"

#define kOptionMappingButtonWhiteKey			"MappingButtonWhite"
#define kOptionThresholdLowButtonWhiteKey		"ThresholdLowButtonWhite"
#define kOptionThresholdHighButtonWhiteKey		"ThresholdHighButtonWhite"

// dpad
#define kOptionMappingDPadUpKey					"MappingDPadUp"
#define kOptionMappingDPadDownKey				"MappingDPadDown"
#define kOptionMappingDPadLeftKey				"MappingDPadLeft"
#define kOptionMappingDPadRightKey				"MappingDPadRight"

// start/back
#define kOptionMappingButtonStartKey			"MappingButtonStart"
#define kOptionMappingButtonBackKey				"MappingButtonBack"

// triggers
#define kOptionAlternateLeftTriggerKey			"AlternateLeftTrigger"
#define kOptionMappingLeftTriggerKey			"MappingLeftTrigger"
#define kOptionThresholdLowLeftTriggerKey		"ThresholdLowLeftTrigger"
#define kOptionThresholdHighLeftTriggerKey		"ThresholdHighLeftTrigger"

#define kOptionAlternateRightTriggerKey			"AlternateRightTrigger"
#define kOptionMappingRightTriggerKey			"MappingRightTrigger"
#define kOptionThresholdLowRightTriggerKey		"ThresholdLowRightTrigger"
#define kOptionThresholdHighRightTriggerKey		"ThresholdHighRightTrigger"

// generic device properties
#define kGenericInterfacesKey					"Interfaces"
#define kGenericEndpointsKey					"Endpoints"
#define kGenericMaxPacketSizeKey				"MaxPacketSize"
#define kGenericPollingIntervalKey				"PollingInterval"
#define kGenericAttributesKey					"Attributes"

// general usage keys
#define kVendorKey								"Vendor"
#define kNameKey								"Name"
#define kTypeKey								"Type"

#endif // _FPSylpHIDDriverKeys_h_
