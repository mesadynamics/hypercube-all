//
//  main.m
//  Amnesty Hypercube
//
//  Created by Danny Espinoza on 2/21/07.
//  Copyright Mesa Dynamics, LLC 2007. All rights reserved.
//

#import <Cocoa/Cocoa.h>
//#include <stdlib.h>

//void sleepForLeaks(void);

int main(int argc, char *argv[])
{
	//atexit(sleepForLeaks);
	
    return NSApplicationMain(argc,  (const char **) argv);
}

/*
void sleepForLeaks(void)
{
	for(;;)
		sleep(60);
}
*/