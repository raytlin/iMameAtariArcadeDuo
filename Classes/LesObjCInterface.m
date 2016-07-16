//
//  LesObjCInterface.m
//  iMAME4all
//
//  Created by Les Bird on 12/1/13.
//
//

#import "LesObjCInterface.h"
#import "EmulatorController.h"
#import "minimal.h"

#import <GameController/GameController.h>

static GCController *gameController;
int mfi_controller_used;

extern unsigned long gp2x_pad_status;
extern int btnStates[NUM_BUTTONS];
extern int dpad_state;
extern unsigned long iCadeUsed;
float mfi_analog_x[4];
float mfi_analog_y[4];

@implementation LesObjCInterface

+(const char *)getBundlePath
{
	const char *userPath = [[[NSBundle mainBundle] bundlePath] cStringUsingEncoding:NSASCIIStringEncoding];
	return userPath;
}

+(const char *)getDocumentsPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	const char *userPath = [[paths objectAtIndex:0] cStringUsingEncoding:NSASCIIStringEncoding];
	
	return userPath;
}

+(const char *)getRomPath
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	const char *userPath = [[paths objectAtIndex:0] cStringUsingEncoding:NSASCIIStringEncoding];
	
	return userPath;
}

+(void)pollMFIController
{
	if (gameController == nil)
	{
		if ([[GCController controllers] count] == 0)
		{
            mfi_controller_used = 0;
			return;
		}
		/*
		// find controller with index 0 (player 1)
		for (int i = 0; i < [[GCController controllers] count]; i++)
		{
			GCController *controller = [[GCController controllers] objectAtIndex:i];
			if (controller != nil && controller.playerIndex == 0)
			{
				gameController = controller;
				iCadeUsed = YES; // set this to turn off the virtual joysticks
				
				break;
			}
		}
		*/
		if (gameController == nil)
		{
			// no controller has index 0 so connect the first one and make it player 1
			gameController = [[GCController controllers] objectAtIndex:0];
			gameController.playerIndex = 0;
            mfi_controller_used = 1;
			iCadeUsed = YES; // set this to turn off the virtual joysticks
		}
	}
}

extern int iOS_exitGame;

+(void)handleMFIController
{
	[LesObjCInterface pollMFIController];
	
	if (gameController != nil)
	{
		gp2x_pad_status &= ~GP2X_LEFT;
		gp2x_pad_status &= ~GP2X_RIGHT;
		gp2x_pad_status &= ~GP2X_UP;
		gp2x_pad_status &= ~GP2X_DOWN;
		gp2x_pad_status &= ~GP2X_X;
		btnStates[BTN_X] = BUTTON_NO_PRESS;
		gp2x_pad_status &= ~GP2X_B;
		btnStates[BTN_B] = BUTTON_NO_PRESS;
		gp2x_pad_status &= ~GP2X_A;
		btnStates[BTN_A] = BUTTON_NO_PRESS;
		gp2x_pad_status &= ~GP2X_Y;
		btnStates[BTN_Y] = BUTTON_NO_PRESS;

		if (gameController.gamepad.dpad.up.isPressed)
		{
			gp2x_pad_status |= GP2X_UP;
		}
		
		if (gameController.gamepad.dpad.down.isPressed)
		{
			gp2x_pad_status |= GP2X_DOWN;
		}
		
		if (gameController.gamepad.dpad.left.isPressed)
		{
			gp2x_pad_status |= GP2X_LEFT;
		}
		
		if (gameController.gamepad.dpad.right.isPressed)
		{
			gp2x_pad_status |= GP2X_RIGHT;
		}
		
		if (gameController.gamepad.buttonA.isPressed)
		{
            gp2x_pad_status |= GP2X_X;
            btnStates[BTN_X] = BUTTON_PRESS;
		}
		
		if (gameController.gamepad.buttonB.isPressed)
		{
            gp2x_pad_status |= GP2X_B;
            btnStates[BTN_B] = BUTTON_PRESS;
		}
		
		if (gameController.gamepad.buttonX.isPressed)
		{
            gp2x_pad_status |= GP2X_A;
            btnStates[BTN_A] = BUTTON_PRESS;
		}
		
		if (gameController.gamepad.buttonY.isPressed)
		{
            if (gameController.gamepad.rightShoulder.isPressed)
            {
                // exit game
                iOS_exitGame = 1;
            }
            else
            {
                gp2x_pad_status |= GP2X_Y;
                btnStates[BTN_Y] = BUTTON_PRESS;
            }
		}
		
		if (gameController.gamepad.leftShoulder.isPressed)
		{
            gp2x_pad_status |= GP2X_SELECT;
            btnStates[BTN_SELECT] = BUTTON_PRESS;
		}
		else
		{
            gp2x_pad_status &= ~GP2X_SELECT;
            btnStates[BTN_SELECT] = BUTTON_NO_PRESS;
		}
		
		if (gameController.gamepad.rightShoulder.isPressed)
		{
            gp2x_pad_status |= GP2X_START;
            btnStates[BTN_START] = BUTTON_PRESS;
		}
		else
		{
            gp2x_pad_status &= ~GP2X_START;
            btnStates[BTN_START] = BUTTON_NO_PRESS;
		}
		
		GCExtendedGamepad *extpad = gameController.extendedGamepad;
		if (extpad != nil)
		{
			float x1,y1,x2,y2;
			x1 = extpad.leftThumbstick.xAxis.value;
			mfi_analog_x[0] = x1;
			
			if (x1 < 0)
			{
				gp2x_pad_status |= GP2X_LEFT;
			}
			
			if (x1 > 0)
			{
				gp2x_pad_status |= GP2X_RIGHT;
			}
			
			y1 = extpad.leftThumbstick.yAxis.value;
			mfi_analog_y[0] = y1;
			
			if (y1 > 0)
			{
				gp2x_pad_status |= GP2X_UP;
			}

			if (y1 < 0)
			{
				gp2x_pad_status |= GP2X_DOWN;
			}

			x2 = extpad.rightThumbstick.xAxis.value;
			mfi_analog_x[1] = x2;
			
			if (x2 < 0)
			{
				gp2x_pad_status |= GP2X_A;
				btnStates[BTN_A] = BUTTON_PRESS;
			}
			
			if (x2 > 0)
			{
				gp2x_pad_status |= GP2X_B;
				btnStates[BTN_B] = BUTTON_PRESS;
			}

			y2 = extpad.rightThumbstick.yAxis.value;
			mfi_analog_y[1] = y2;
			
			if (y2 < 0)
			{
				gp2x_pad_status |= GP2X_X;
				btnStates[BTN_X] = BUTTON_PRESS;
			}
			
			if (y2 > 0)
			{
				gp2x_pad_status |= GP2X_Y;
				btnStates[BTN_Y] = BUTTON_PRESS;
			}
		}
	}
}

@end

const char *getBundleFolder()
{
    return [LesObjCInterface getBundlePath];
}

const char *getDocumentsFolder()
{
    return [LesObjCInterface getDocumentsPath];
}

const char *getRomFolder()
{
    return [LesObjCInterface getRomPath];
}

void pollMFIController()
{
	return [LesObjCInterface pollMFIController];
}

bool hasMFIController()
{
	if (gameController != nil)
	{
		return true;
	}
	return false;
}

void handleMFIController()
{
	[LesObjCInterface handleMFIController];
}
