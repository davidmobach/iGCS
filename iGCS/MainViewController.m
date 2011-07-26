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

#import "MainViewController.h"
#import "NSObject+DDExtensions.h"
#import "ivy.h"
#import "UAVMapAnnotation.h"

void iPadMainViewControllerBatteryCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	objc_msgSend(refToMainViewController, sel_getUid("updateBatteryLabel:"), arg);
}

void iPadMainViewControllerAirspeedCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];

	//convert airspeed string to int
	int speed = atoi(arg);
	
	objc_msgSend(refToMainViewController, sel_getUid("updateAirspeed:"), speed);
}

void iPadMainViewControllerGndspeedCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
    
	//convert gndspeed string to int
	int speed = atoi(arg);
    
	speed = speed/100; // convert to meters per second
    //IvySendMsg ("in AirspeedCallback %i", speed);
	objc_msgSend(refToMainViewController, sel_getUid("updateGndspeed:"), speed);
}


void iPadMainViewControllerAltitudeCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	objc_msgSend(refToMainViewController, sel_getUid("updateAltitude:"), arg);
}

void iPadMainViewControllerThrottleCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	objc_msgSend(refToMainViewController, sel_getUid("updateThrottle:"), arg);
}


void iPadMainViewControllerAutopilotModeCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg = (argc < 1) ? "" : argv[0];
	int mode = atoi(arg);
	objc_msgSend(refToMainViewController, sel_getUid("updateAutopilotMode:"), mode);
}


void iPadMainViewControllerGPSCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg1 = (argc < 1) ? "" : argv[0];
	char *arg2 = (argc < 1) ? "" : argv[1];
	objc_msgSend(refToMainViewController, sel_getUid("updateGPS:"), argv);
}


@implementation MainViewController
@synthesize mapView;
@synthesize UAV_annotation;
@synthesize batteryLabel;
//@synthesize singlePicker;
//@synthesize pickerData;
@synthesize autopilotMode;
@synthesize altitudeTextField;
@synthesize airspeedTextField;
@synthesize gndspeedTextField;
@synthesize throttleProgressView;
@synthesize throttleLabel;



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) awakeFromNib
{
	refToMainViewController = self; // this cannot go in initWithNibName for some reason....
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	IvyBindMsg (iPadMainViewControllerGPSCallback, 0, ".*GPS [a-zA-Z0-9]* ([a-zA-Z0-9]*) ([a-zA-Z0-9]*)");
	IvyBindMsg (iPadMainViewControllerBatteryCallback, 0, ".*BAT [-+]?[a-zA-Z0-9]* ([-+]?[a-zA-Z0-9]*)");
	IvyBindMsg (iPadMainViewControllerThrottleCallback, 0, ".*BAT ([a-zA-Z0-9]*)");
	IvyBindMsg (iPadMainViewControllerAirspeedCallback, 0, ".*AIRSPEED ([-+]?[a-zA-Z0-9]*)");
    IvyBindMsg (iPadMainViewControllerGndspeedCallback, 0, ".*GPS [a-zA-Z0-9]* [a-zA-Z0-9]* [a-zA-Z0-9]* [a-zA-Z0-9]* [-+]?[a-zA-Z0-9]* ([a-zA-Z0-9]*)");
	IvyBindMsg (iPadMainViewControllerAltitudeCallback, 0, ".*ESTIMATOR ([-+]?[a-zA-Z0-9]*)");
	IvyBindMsg (iPadMainViewControllerAutopilotModeCallback, 0, ".*PPRZ_MODE ([a-zA-Z0-9])*");	
}



- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
    //MKMapView *mapView = (MKMapView*)self.view;
	CLLocationCoordinate2D coordinate;
	
	double n = 5805246;
	double e = 646018;
	double Lat = 0.0, Lon = 0.0, *Lat_ptr = &Lat, *Lon_ptr = &Lon;
	
	UTMtoLL(n, e, "U", Lat_ptr, Lon_ptr);
		
	coordinate.latitude = Lat;
	coordinate.longitude = Lon;
	mapView.mapType = MKMapTypeSatellite;
	mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 750, 750);
	CLLocationCoordinate2D newCoord = {coordinate.latitude, coordinate.longitude};
	UAV_annotation = [[UAVMapAnnotation alloc] initWithCoordinate:newCoord];
	[mapView addAnnotation:UAV_annotation];
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}


- (void)dealloc {
	[UAV_annotation release];
    [super dealloc];
}

- (MKAnnotationView *) mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>) annotation{
	//NSLog(@"we getting there...");
	MKAnnotationView *annView=[[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"currentloc"];
	//annView.pinColor = MKPinAnnotationColorGreen;
	UIImage *myImg = [[UIImage alloc] initWithContentsOfFile:[NSString stringWithFormat:@"%@/airplane.png", [[NSBundle mainBundle] bundlePath]]];
	
    //CGAffineTransform  tran = CGAffineTransformIdentity;
	//tran = CGAffineTransformRotate(tran, degreesToRadians(180.0));
	//[myImg rotate:UIImageOrientationRight];
	//myImg = [UIImage rotateImage:myImg andRotateAngle:UIImageOrientationRight];
	[annView setImage:myImg];
    
    // attempt at storing reference to the image for rotation of the image based on heading later
    //UAV_annotation.image = myImg;
	
    
    return annView;
}

- (void) updateGPS:(char **)utm
{
	//IvySendMsg ("start updateGPS");
	char *utm_east = utm[0];
	char *utm_north = utm[1];
	//	char *utm_zone = 
	
	double UTMNorthing = atof(utm_north)/100;
	double UTMEasting = atof(utm_east)/100;
	
	double Lat = 0.0, Lon = 0.0, *Lat_ptr = &Lat, *Lon_ptr = &Lon;
	
	UTMtoLL(UTMNorthing, UTMEasting, "U", Lat_ptr, Lon_ptr);
	
	CLLocation *loc=[[CLLocation alloc] initWithLatitude:Lat longitude:Lon];
    // set the annotation on the new coordinate on the map
	[[UAV_annotation dd_invokeOnMainThread] setCoordinate:loc.coordinate];
    
    // attempt at rotating image (not working yet...)
    //UAV_annotation.image = [UIImage rotateImage:UAV_annotation.image andRotateAngle:180];
    
    // center the map on the new coordinate
    [[mapView dd_invokeOnMainThread] setCenterCoordinate:loc.coordinate animated:NO];
    
	[loc release];	

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
//	[[singlePicker dd_invokeOnMainThread] selectRow:speed inComponent:0 animated:YES];	
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


@end
