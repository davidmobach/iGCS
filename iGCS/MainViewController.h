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
#import <MapKit/MapKit.h>
#import "UAVMapAnnotation.h"

void *refToMainViewController;

@interface MainViewController : UIViewController <MKMapViewDelegate> {
	IBOutlet MKMapView *mapView;
	UAVMapAnnotation *UAV_annotation;
    IBOutlet UILabel *batteryLabel;
	IBOutlet UISegmentedControl *autopilotMode;
	IBOutlet UITextField *altitudeTextField;
	IBOutlet UITextField *airspeedTextField;
	IBOutlet UITextField *gndspeedTextField;
	IBOutlet UIProgressView *throttleProgressView;
	IBOutlet UILabel *throttleLabel;
}

@property (nonatomic, retain) MKMapView *mapView;
@property (nonatomic, retain) UAVMapAnnotation *UAV_annotation;
@property (retain, nonatomic) UILabel *batteryLabel;
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
- (void) updateGPS: (char **) latlon;

@end
