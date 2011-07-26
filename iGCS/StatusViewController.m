/*
 * iGCS is an iOS app for the Paparazzi UAV Ground Control Station
 * Copyright (C) 2011 David Mobach
 * 
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 * 
 * For more information about this software please visit:
 * https://github.com/davidmobach/iGCS
 */

#import "StatusViewController.h"
#import "NSObject+DDExtensions.h"
#import "ivy.h"

void BatteryCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	objc_msgSend(refToStatusViewController, sel_getUid("updateBatteryLabel:"), arg);
}

void AirspeedCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	//convert airspeed string to int
	int speed = atoi(arg);
	objc_msgSend(refToStatusViewController, sel_getUid("updateAirspeed:"), speed);
}

void GndspeedCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	//convert gndspeed string to int
	int speed = atoi(arg);
    speed = speed/100;  //convert to m/s
	objc_msgSend(refToStatusViewController, sel_getUid("updateGndspeed:"), speed);
}


void AltitudeCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	objc_msgSend(refToStatusViewController, sel_getUid("updateAltitude:"), arg);
}

void ThrottleCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	objc_msgSend(refToStatusViewController, sel_getUid("updateThrottle:"), arg);
}


void AutopilotModeCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	int mode = atoi(arg);
	objc_msgSend(refToStatusViewController, sel_getUid("updateAutopilotMode:"), mode);
}

@implementation StatusViewController
@synthesize batteryLabel;
@synthesize singlePicker;
@synthesize pickerData;
@synthesize autopilotMode;
@synthesize altitudeTextField;
@synthesize airspeedTextField;
@synthesize gndspeedTextField;
@synthesize throttleProgressView;
@synthesize throttleLabel;


- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        // Initialization code
    }
    return self;
}

- (void) awakeFromNib
{
	refToStatusViewController = self; // this cannot go in initWithNibName for some reason....
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	IvyBindMsg (BatteryCallback, 0, ".*BAT [-+]?[a-zA-Z0-9]* ([-+]?[a-zA-Z0-9]*)");
	IvyBindMsg (ThrottleCallback, 0, ".*BAT ([a-zA-Z0-9]*)");
	IvyBindMsg (AirspeedCallback, 0, ".*AIRSPEED ([-+]?[a-zA-Z0-9]*)");
    IvyBindMsg (GndspeedCallback, 0, ".*GPS [a-zA-Z0-9]* [a-zA-Z0-9]* [a-zA-Z0-9]* [a-zA-Z0-9]* [-+]?[a-zA-Z0-9]* ([a-zA-Z0-9]*)");
	IvyBindMsg (AltitudeCallback, 0, ".*ESTIMATOR ([-+]?[a-zA-Z0-9]*)");
	IvyBindMsg (AutopilotModeCallback, 0, ".*PPRZ_MODE ([a-zA-Z0-9])*");
	NSArray *array = [[NSArray alloc] initWithObjects:@"0",@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",
					  @"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",
					  @"22",@"23",@"24",@"25",@"26",@"27",@"28",@"29",@"30",@"31",@"32",
					  @"33",@"34",@"35",@"36",@"37",@"38",@"39",@"40",@"41",@"42",@"43",
					  @"44",@"45",@"46",@"47",@"48",@"49",@"50",@"51",@"52",@"53",@"54",nil];
	self.pickerData = array;
	[array release];
}

- (void) updateBatteryLabel:(char *) arg
{
	//	IvySendMsg ("start updateBatteryLabel %s", arg);
	NSString *voltage = [NSString stringWithFormat:@"%s",arg];
	[batteryLabel performSelectorOnMainThread:@selector(setText:)withObject:voltage waitUntilDone:NO];
	[voltage release];
}

- (void) updateAirspeed:(int) speed
{
	//	IvySendMsg ("start updateAirspeed %i", speed);		
	//[singlePicker selectRow:1 inComponent:0 animated:YES];
	//[singlePicker reloadComponent:0];
	//[singlePicker performSelectorOnMainThread:@selector(reloadComponent:)withObject:0 waitUntilDone:NO];
	[[singlePicker dd_invokeOnMainThread] selectRow:speed inComponent:0 animated:YES];	
	NSString *airspeed = [NSString stringWithFormat:@"%i",speed];
	[airspeedTextField performSelectorOnMainThread:@selector(setText:)withObject:airspeed waitUntilDone:NO];
	[airspeed release];
}

- (void) updateGndspeed:(int) speed
{
	NSString *gndspeed = [NSString stringWithFormat:@"%i",speed];
	[gndspeedTextField performSelectorOnMainThread:@selector(setText:)withObject:gndspeed waitUntilDone:NO];
	[gndspeed release];
}


- (void) updateAltitude:(char *) alt
{
	NSString *altitude = [NSString stringWithFormat:@"%s",alt];
	[altitudeTextField performSelectorOnMainThread:@selector(setText:)withObject:altitude waitUntilDone:NO];
	[altitude release];
}

- (void) updateThrottle:(char *) thr
{
	//	IvySendMsg ("start updateThrottle %s", thr);
	float value = atof(thr);
	float scaledValue = value / 10000;
	[[throttleProgressView dd_invokeOnMainThread] setProgress:scaledValue];
	
	int percValue = value / 100;
	NSString *perc = [NSString stringWithFormat:@"%i",percValue];
	[throttleLabel performSelectorOnMainThread:@selector(setText:)withObject:perc waitUntilDone:NO];
	[perc release];
	//	IvySendMsg ("end updateThrottle %f", scaledValue);
}

- (void) updateAutopilotMode:(int) mode	
{
	//	IvySendMsg ("start AutopilotMode %i", mode);
	//		[[apMode dd_invokeOnMainThread] setText:@"broel"];
	//		NSString *voltage = [NSString stringWithFormat:@"%i",mode];
	//int *test = &mode;
	if (mode < 3) [[autopilotMode dd_invokeOnMainThread] setSelectedSegmentIndex:mode];
	//		[autopilotMode performSelectorOnMainThread:@selector(setSelectedSegmentIndex:)withObject:test waitUntilDone:NO];
	
	//	IvySendMsg ("end updateAutopilotMode");
}

#pragma mark -
#pragma mark Picker Data Source Methods
- (NSInteger) numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
	return [self.pickerData count];
}

#pragma mark Picker Delegate Methods
- (NSString *) pickerView:(UIPickerView *)pickerView
			  titleForRow:(NSInteger)row
			 forComponent:(NSInteger)component
{
	return [self.pickerData objectAtIndex:row];
}




/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)dealloc {
	[singlePicker release];
	[pickerData release];
    [super dealloc];
}


@end
