//
//  VerifyWidget
//
//  Created by Danny Espinoza on 7/14/07.
//  Copyright 2007 Mesa Dynamics, LLC. All rights reserved.
//

#include <iostream>
using namespace std;

int getWidgetVersion();

char* data = NULL;

int
main(
	int argc,
	char* const argv[])
{
	if(argc == 3) {
		int version1 = 0;
		
		char version[256];
		data = argv[1];
		sprintf(version, "%d", getWidgetVersion());
				
		if(strcmp(version, argv[2]) == 0)
			return 0;
	}
	else
		cerr << "Usage: verifyWidget widgetID widgetVersion\n";
		
    return 1;
}

int getWidgetVersion()
{
   	int base1 = 0;
	int base2 = 0;
	int base3 = 0;
	int base4 = 0;

	char* element = data;
					
	while(*element) {
		int h = (int) (*element);
		
		base1 += h;
		element++;
		
		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base2 += h;
			element++;
		}
		
		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base3 += h;
			element++;
		}

		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base2 += h;
			element++;
		}

		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base4 += h;
			element++;
		}
		
		if(*element) {
			h = (int) (*element);
			
			base1 += h;
			base2 += h;
			base3 += h;
			element++;
		}
	}
	
	return (base1 + (base2 << 8) + (base3 << 16) + (base4 << 24));
}
