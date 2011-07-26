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

#import "MapViewController.h"
#import "NSObject+DDExtensions.h"
#import "ivy.h"
#import "UAVMapAnnotation.h"

void GPSCallback (IvyClientPtr app, void *data, int argc, char **argv)
{
	char *arg1 = (argc < 1) ? "" : argv[0];
	char *arg2 = (argc < 1) ? "" : argv[1];
	//IvySendMsg ("start GPSCallback %s %s", arg1, arg2);
	objc_msgSend(refToMapViewController, sel_getUid("updateGPS:"), argv);
	//IvySendMsg ("end GPSCallback");
}



@implementation MapViewController
@synthesize mapView;
@synthesize UAV_annotation;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void) awakeFromNib
{
	refToMapViewController = self; // this cannot go in initWithNibName for some reason....
	self.view.backgroundColor = [UIColor groupTableViewBackgroundColor];
	IvyBindMsg (GPSCallback, 0, ".*GPS [a-zA-Z0-9]* ([a-zA-Z0-9]*) ([a-zA-Z0-9]*)");
	
}


- (void)viewDidLoad
{
    [super viewDidLoad];
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

- (void)dealloc {
	[UAV_annotation release];
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

// create a custom icon here
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
	
	//NSLog(@"E: %f", UTMEasting);
	//NSLog(@"N: %f", UTMNorthing);
	
	//NSLog(@"Lat: %f", Lat);
	//NSLog(@"Lon: %f", Lon);
	
	CLLocation *loc=[[CLLocation alloc] initWithLatitude:Lat longitude:Lon];
    // set the annotation on the new coordinate on the map
	[[UAV_annotation dd_invokeOnMainThread] setCoordinate:loc.coordinate];
    
    // attempt at rotating image (not working yet...)
    //UAV_annotation.image = [UIImage rotateImage:UAV_annotation.image andRotateAngle:180];
    
    // center the map on the new coordinate
    [[mapView dd_invokeOnMainThread] setCenterCoordinate:loc.coordinate animated:NO];
    
	[loc release];	
	
	/*
	 coordinate.latitude = Lat;
	 coordinate.longitude = Lon;
	 mapView.mapType = MKMapTypeSatellite;
	 mapView.region = MKCoordinateRegionMakeWithDistance(coordinate, 5000, 5000);
	 CLLocationCoordinate2D newCoord = {coordinate.latitude, coordinate.longitude};
	 MapDemoAnnotation* annotation = [[MapDemoAnnotation alloc] initWithCoordinate:newCoord];
	 [mapView addAnnotation:annotation];
	 [annotation release];
	 */	
	
	//	NSLog(@"Lat: %s", lat);
	
	
	
	//	double *Lat;
	//	double *Lon;
	//	char *utm_zone = "U";
	
	//	UTMtoLL2(UTMNorthing, UTMEasting, utm_zone);
	//	UTMtoLL(UTMNorthing, UTMEasting, utm_zone, Lat, Lon);
	//IvySendMsg ("end updateGPS");
}



@end
