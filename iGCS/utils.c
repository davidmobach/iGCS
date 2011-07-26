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

#include "stdlib.h"
#include "math.h"
#include "utils.h"


void UTMtoLL(double UTMNorthing, double UTMEasting, char* UTMZone, double *Lat,  double *Long )
{
	//converts UTM coords to lat/long.  Equations from USGS Bulletin 1532 
	//East Longitudes are positive, West longitudes are negative. 
	//North latitudes are positive, South latitudes are negative
	//Lat and Long are in decimal degrees. 
	//Written by Chuck Gantz- chuck.gantz@globalstar.com
	
	double k0 = 0.9996;
	double a = 6378137; // WGS-84
	double eccSquared = 0.00669438; //WGS-84
	double eccPrimeSquared;
	double e1 = (1-sqrt(1-eccSquared))/(1+sqrt(1-eccSquared));
	double N1, T1, C1, R1, D, M;
	double LongOrigin;
	double mu, phi1, phi1Rad;
	double x, y;
	int ZoneNumber;
	char* ZoneLetter;
	int NorthernHemisphere; //1 for northern hemispher, 0 for southern
	
	/* 
	 x = UTMEasting ; 
	 ZoneNumber=0; 
	 for(int iLoop=0;iLoop<60;iLoop++) 
	 if(x>=833978.55644) 
	 { 
	 x-=833978.55644; 
	 ZoneNumber++; 
	 } 
	 */ 
	
	x = UTMEasting - 500000.0; //remove 500,000 meter offset for longitude
	y = UTMNorthing;
	
	ZoneNumber = strtoul(UTMZone, &ZoneLetter, 10);
    ZoneNumber = 31;
	ZoneLetter = "U";
	if((*ZoneLetter - 'N') >= 0)
		NorthernHemisphere = 1;//point is in northern hemisphere
	else
	{
		NorthernHemisphere = 0;//point is in southern hemisphere
		y -= 10000000.0;//remove 10,000,000 meter offset used for southern hemisphere
	}
	
	LongOrigin = (ZoneNumber - 1)*6 - 180 + 3;  //+3 puts origin in middle of zone
	
	eccPrimeSquared = (eccSquared)/(1-eccSquared);
	
	M = y / k0;
	mu = M/(a*(1-eccSquared/4-3*eccSquared*eccSquared/64-5*eccSquared*eccSquared*eccSquared/256));
	
	phi1Rad = mu	+ (3*e1/2-27*e1*e1*e1/32)*sin(2*mu) 
	+ (21*e1*e1/16-55*e1*e1*e1*e1/32)*sin(4*mu)
	+(151*e1*e1*e1/96)*sin(6*mu);
	phi1 = phi1Rad*rad2deg;
	
	N1 = a/sqrt(1-eccSquared*sin(phi1Rad)*sin(phi1Rad));
	T1 = tan(phi1Rad)*tan(phi1Rad);
	C1 = eccPrimeSquared*cos(phi1Rad)*cos(phi1Rad);
	R1 = a*(1-eccSquared)/pow(1-eccSquared*sin(phi1Rad)*sin(phi1Rad), 1.5);
	D = x/(N1*k0);
	
	*Lat = phi1Rad - (N1*tan(phi1Rad)/R1)*(D*D/2-(5+3*T1+10*C1-4*C1*C1-9*eccPrimeSquared)*D*D*D*D/24
										   +(61+90*T1+298*C1+45*T1*T1-252*eccPrimeSquared-3*C1*C1)*D*D*D*D*D*D/720);
	*Lat = *Lat * rad2deg;
	
	*Long = (D-(1+2*T1+C1)*D*D*D/6+(5-2*C1+28*T1-3*C1*C1+8*eccPrimeSquared+24*T1*T1)
			 *D*D*D*D*D/120)/cos(phi1Rad);
	*Long = LongOrigin + *Long * rad2deg;
	
}
