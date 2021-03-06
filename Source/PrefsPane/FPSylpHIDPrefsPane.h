//
// FPSylpHIDPrefsPane.h
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


#import <Cocoa/Cocoa.h>
#import <PreferencePanes/PreferencePanes.h>
#import "FPSylpHIDNotifier.h"
#import "FPSylpHIDDriverKeys.h"
#import "FPDataSourceApps.h"
#import "MAAttachedWindow.h"


enum eMenuEntriesAxis {
	kMenuAxisDisabled,
	kMenuAxisSeparator1,
    kMenuAxisLeftStickH,
    kMenuAxisLeftStickV,
    kMenuAxisRightStickH,
    kMenuAxisRightStickV,
    kMenuAxisTriggers,
	kMenuAxisSeparator2,
	kMenuAxisGreenRed,
	kMenuAxisBlueYellow,
	kMenuAxisGreenYellow,
	kMenuAxisBlueRed,
	kMenuAxisRedYellow,
	kMenuAxisGreenBlue,
	kMenuAxisWhiteBlack,
	kMenuAxisSeparator3,
	kMenuAxisDPadUpDown,
	kMenuAxisDPadLeftRight,
	kMenuAxisStartBack,
	kMenuAxisClickLeftRight,
	kMenuAxisCount,
};

enum eMenuEntriesButtons {
	kMenuButtonDisabled,
	kMenuButtonSeparator1,
    kMenuButtonLeftTrigger,
    kMenuButtonRightTrigger,
	kMenuButtonSeparator2,
    kMenuButtonDPadUp,
    kMenuButtonDPadDown,
    kMenuButtonDPadLeft,
    kMenuButtonDPadRight,
    kMenuButtonStart,
    kMenuButtonBack,
    kMenuButtonLeftClick,
    kMenuButtonRightClick,
	kMenuButtonSeparator3,
    kMenuButtonGreen,
    kMenuButtonRed,
    kMenuButtonBlue,
    kMenuButtonYellow,
    kMenuButtonBlack,
    kMenuButtonWhite,
	kMenuButtonCount,
};


@interface FPSylpHIDPrefsPane : NSPreferencePane <FPAppBindings, FPDeviceNotifier, NSFileManagerDelegate> {
	// state information
    NSArray* _devices;
    NSTimer* _timer;
	MAAttachedWindow* _popup;
	MAAttachedWindow* _xfade;
    FPSylpHIDNotifier* _notifier;
    XBPadReport _rawReport;
	XBPadOptions _undoMappings;
	NSDictionary* _undoBindings;
	NSString* _lastConfig;
	NSString* _lastDevice;

	NSMutableDictionary* _appConfig;
	FPDataSourceApps* _appData;
	NSString* _appSelectedID;
	NSDictionary* _appAttrs;

	// device popup
    IBOutlet id _devicePopUp;

	// tab view
    IBOutlet id _tabView;
	IBOutlet id _tabMask;

    // error tab message
    IBOutlet id _errorText;
	IBOutlet id _errorImage;

    // popup menus for controller remapping
    IBOutlet id _menuAxisXbox;
    IBOutlet id _menuAxisHID;
    IBOutlet id _menuButtonXbox;
    IBOutlet id _menuButtonHID;

    IBOutlet id _configMenus;

	IBOutlet id _alertView;

    // controller tab
    IBOutlet id _leftTriggerView;
    IBOutlet id _leftTriggerMenu;
    IBOutlet id _leftTriggerMode;
	IBOutlet id _leftTriggerAlt;
    IBOutlet id _leftTriggerLivezone;

    IBOutlet id _rightTriggerView;
    IBOutlet id _rightTriggerMenu;
    IBOutlet id _rightTriggerMode;
	IBOutlet id _rightTriggerAlt;
    IBOutlet id _rightTriggerLivezone;

    IBOutlet id _leftStickView;
    IBOutlet id _leftStickMenuX;
	IBOutlet id _leftStickAlertX;
    IBOutlet id _leftStickDeadzoneX;
    IBOutlet id _leftStickDeadzoneXField;
    IBOutlet id _leftStickInvertX;
    IBOutlet id _leftStickMenuY;
	IBOutlet id _leftStickAlertY;
    IBOutlet id _leftStickDeadzoneY;
    IBOutlet id _leftStickDeadzoneYField;
    IBOutlet id _leftStickInvertY;
    IBOutlet id _leftStickMenuBtn;

    IBOutlet id _rightStickView;
    IBOutlet id _rightStickMenuX;
	IBOutlet id _rightStickAlertX;
    IBOutlet id _rightStickDeadzoneX;
    IBOutlet id _rightStickDeadzoneXField;
    IBOutlet id _rightStickInvertX;
    IBOutlet id _rightStickMenuY;
	IBOutlet id _rightStickAlertY;
    IBOutlet id _rightStickDeadzoneY;
    IBOutlet id _rightStickDeadzoneYField;
    IBOutlet id _rightStickInvertY;
    IBOutlet id _rightStickMenuBtn;

    IBOutlet id _buttonGreenView;
    IBOutlet id _buttonGreenMenu;
    IBOutlet id _buttonGreenMode;
    IBOutlet id _buttonGreenLivezone;

    IBOutlet id _buttonRedView;
    IBOutlet id _buttonRedMenu;
    IBOutlet id _buttonRedMode;
    IBOutlet id _buttonRedLivezone;

    IBOutlet id _buttonBlueView;
    IBOutlet id _buttonBlueMenu;
    IBOutlet id _buttonBlueMode;
    IBOutlet id _buttonBlueLivezone;

    IBOutlet id _buttonYellowView;
    IBOutlet id _buttonYellowMenu;
    IBOutlet id _buttonYellowMode;
    IBOutlet id _buttonYellowLivezone;

    IBOutlet id _buttonBlackView;
    IBOutlet id _buttonBlackMenu;
    IBOutlet id _buttonBlackMode;
    IBOutlet id _buttonBlackLivezone;

    IBOutlet id _buttonWhiteView;
    IBOutlet id _buttonWhiteMenu;
    IBOutlet id _buttonWhiteMode;
    IBOutlet id _buttonWhiteLivezone;

    IBOutlet id _buttonBackView;
    IBOutlet id _buttonBackMenu;

    IBOutlet id _buttonStartView;
    IBOutlet id _buttonStartMenu;

    IBOutlet id _dPadView;
    IBOutlet id _dpadUpMenu;
    IBOutlet id _dpadDownMenu;
    IBOutlet id _dpadLeftMenu;
    IBOutlet id _dpadRightMenu;

    // configuration
    IBOutlet id _configPopUp;
    IBOutlet id _configButtons;

    // buttons
    IBOutlet id _btnCredits;
    IBOutlet id _btnDonate;
        
    // popup views
	IBOutlet id _createView;
	IBOutlet id _createText;
	IBOutlet id _createCopy;
	IBOutlet id _createOK;
	IBOutlet id _createNO;

	IBOutlet id _editView;
	IBOutlet id _editText;
	IBOutlet id _editOK;
	IBOutlet id _editNO;

	IBOutlet id _deleteView;
	IBOutlet id _deleteApps;
	IBOutlet id _deleteOK;
	IBOutlet id _deleteNO;

	IBOutlet id _defaultView;
	IBOutlet id _defaultOK;
	IBOutlet id _defaultNO;

	IBOutlet id _actionView;
	IBOutlet id _actionEdit;
	IBOutlet id _actionUndo;
	IBOutlet id _actionApps;
	IBOutlet id _actionInfo;
	IBOutlet id _actionTip;
	IBOutlet id _actionBase;
	IBOutlet id _actionNO;

	IBOutlet id _creditsView;
	IBOutlet id _creditsScroll;
	IBOutlet id _creditsText;
	IBOutlet id _creditsOK;

	IBOutlet id _donateView;
	IBOutlet id _donateScroll;
	IBOutlet id _donateText;
	IBOutlet id _donateOK;

	IBOutlet id _appsView;
	IBOutlet id _appsTable;
	IBOutlet id _appsBlank;
	IBOutlet id _appsAction;
	IBOutlet id _appsOK;

	IBOutlet id _usbView;
	IBOutlet id _usbVendorID;
	IBOutlet id _usbProductID;
	IBOutlet id _usbVendorName;
	IBOutlet id _usbProductName;
	IBOutlet id _usbVersionNumber;
	IBOutlet id _usbSerialNumber;
	IBOutlet id _usbLocationID;
	IBOutlet id _usbBusSpeed;
	IBOutlet id _usbPowerReqs;
	IBOutlet id _usbOK;

    // strings
    IBOutlet id _textVersion;
	IBOutlet id _textIdentifier;
	IBOutlet id _textMapping;
}

- (IBAction) configCreateEnd: (id)sender;
- (IBAction) configDeleteEnd: (id)sender;
- (IBAction) configActionsPick: (id)sender;
- (IBAction) configEditEnd: (id)sender;

- (IBAction) appEditAction: (id)sender;
- (IBAction) appEditEnd: (id)sender;

- (IBAction) closePopUpWindow: (id)sender;

- (IBAction) selectDevice: (id)sender;
- (IBAction) selectConfig: (id)sender;

- (IBAction) changePadOption: (id)sender;

- (IBAction) clickConfigSegment: (id)sender;
- (IBAction) clickMenuSegment: (id)sender;
- (IBAction) clickCredits: (id)sender;
- (IBAction) clickDonate: (id)sender;

- (IBAction) clickedHelp: (id)sender;

@end
