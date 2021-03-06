//
// FPAppTextFieldCell.m
// "SylpHID"
//
// Created by Paige Marie DePol <pmd@fizzypopstudios.com>
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

#import "FPAppBindingCells.h"


// for adding padding (2px) above text
@implementation FPAppTextFieldCell

- (void) drawInteriorWithFrame: (NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame.origin.y += 2;
	cellFrame.size.height -= 2;
	[super drawInteriorWithFrame: cellFrame inView: controlView];
}

@end


// for adding padding (1px) to right and bottom edge of icon
@implementation FPAppImageCell

- (void) drawInteriorWithFrame: (NSRect)cellFrame inView:(NSView *)controlView
{
	cellFrame.size.width -= 1;
	cellFrame.size.height -= 1;
	[super drawInteriorWithFrame: cellFrame inView: controlView];
}

@end
