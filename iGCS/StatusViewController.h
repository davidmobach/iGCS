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


#import <UIKit/UIKit.h>
#define kAltitudeComponent 0
#define kAirspeedComponent 1

void *refToStatusViewController;

@interface StatusViewController : UIViewController 
<UIPickerViewDelegate, UIPickerViewDataSource>
{
	IBOutlet UILabel *batteryLabel;
	NSOperationQueue *queue;
	IBOutlet UIPickerView *singlePicker;
	NSArray *pickerData;
	IBOutlet UISegmentedControl *autopilotMode;
	IBOutlet UITextField *altitudeTextField;
	IBOutlet UITextField *airspeedTextField;
	IBOutlet UITextField *gndspeedTextField;
	IBOutlet UIProgressView *throttleProgressView;
	IBOutlet UILabel *throttleLabel;
}

@property (retain, nonatomic) UILabel *batteryLabel;
@property (retain, nonatomic) UIPickerView *singlePicker;
@property (retain, nonatomic) NSArray *pickerData;
@property (retain, nonatomic) UISegmentedControl *autopilotMode;
@property (retain, nonatomic) UITextField *altitudeTextField;
@property (retain, nonatomic) UITextField *airspeedTextField;
@property (retain, nonatomic) UITextField *gndspeedTextField;
@property (retain, nonatomic) UIProgressView *throttleProgressView;
@property (retain, nonatomic) UILabel *throttleLabel;

- (void) updateBatteryLabel: (char *) arg;
- (void) updateAirspeed: (int) airspeed;
- (void) updateGroundspeed: (int) gndspeed;
- (void) updateAutopilotMode: (int) mode;
- (void) updateAltitude: (char *) altitude;
- (void) updateThrottle: (char *) throttle;

@end
