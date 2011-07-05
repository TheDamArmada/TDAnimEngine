TDAnimEngine
============



# Description #

TDAnimEngine allows you to create cut-out characters and animations in Maya an export it to be use directly into Cocos2D through XML.
It's not a sprite based tool. It's for characters made out different pieces that will animate rotating its different components.

The library is composed of two parts:  
. **Maya Scripts**: containing 1 script to export the character and 1 script to export the animations  
. **XCode lib**: the TDAnimEngine classes to be added to your XCode project  

What you can do:  
. create a character in Maya and recreate it in Cocos2D (including Z-depth, rotations and parenting)   
. access the different pieces using from Cocos2D using the same name than you used in Maya  
. use SpriteSheets instead of pngs   
. create rotation based animation in Maya and apply them to your character in Cocos2D   
. control events when an animation has looped, has stopped, etc   
. define custom events that will be launch at specific frames  


# Dependencies: #

**TBXML** is needed to parse the generated XML files.  
Get it here: [TBXML](https://github.com/Tpbradley/TBXML)

  
# General Usage #

##Maya Scripts##

***MayaToCocos2DNodes.mel***: use this script on a Maya model (made out of polygonal planes) to generate an XML that will contain all the necessary information to recreate it on Cocos2D. Use a 1/100 ratio to recreate the different pieces (ie: if an image it's 200x200 pixels, in Maya you should create a plane 0.2 x 0.2).
  
Please visit the **[tutorial](http://fbgpc.thedamarmada.com/2011/06/maya-to-cocos2d/)** for a detail explanation on how to use this script.

***MayaAnimToXMLNodeBased.mel***: use this script to, having a model in Maya, create a rotation based animation (or Direct Kinematics) and export it as XML so it can be used on Cocos2D. So far, we've worked out just rotations. In a future we might support translation and scales.

Please visit the **[tutorial](http://fbgpc.thedamarmada.com/2011/07/maya-to-cocos2d-part-22/)** for a detail explanation on how to use this script.

##TDAnimEngine Lib##

It's composed of a number of classes. The main one is: 

***TDAnimCharacter***: this is the class responsible of creating the different CCSprites the character might be made of. Extend this class when having multiple characters in one scene for easier control.  


###RECREATING THE CHARACTER###
There are two ways of recreating a character based on the XML generated in Maya:

***PNG'S BASED***

    TDAnimCharacter *robot = [TDAnimCharacter characterFromConfigFile:"FILENAME"];
	[robot setPosition:ccp(120, 120)];
	[self addChild:robot];
	
It requires you have included in your Resources the same PNGs used in Maya to create the character. The class will load them as textures of the recreated CCSprites.  

***SPRITESHEET BASED***

	TDAnimCharacter *robot = [TDAnimCharacter characterFromConfigFile:"FILENAME" andAtlasInfoFile:"FILENAME"];
	[robot setPosition:ccp(120, 120)];
	[self addChild:robot];
	
It requires you have a SpriteSheet png for the character and it's generated PLIST with the same name. 

###IMPORTING ANIMATIONS###
To import animations to your character use:
	
	[robot createCharacterAnimationsFromXML:"FILENAME"];
	
The animations can be in the same XML file than the character config XML. We recommend to keep them in different files so the Config file can be reused.

To play an animation:

	[robot playAnimation:"ANIMATION NAME" loop:(YES/NO) wait:(YES/NO)];
	
Where:   
*ANIMATION NAME*: the name of the animation as you set it up on the Maya script  
*LOOP*: will the character repeat the animation over and over?  
*WAIT*: will the character wait until the current animation being played finishes?  

## CUSTOM EVENTS ##

You can add custom events to your animation file.  
The events are animation specific, meaning that you can define events for the "walk" cycle or for the "jump" cycle.  
Example:

	<events>
		<animation id="walk">
			<event type="big_step" frame ='1' />
			<event type="small_step" frame ='10' />
			<event type="big_step" frame ='22' />			
		</animation>
	</events>
	

To use the events:

create your own class extending from TDAnimCharacter
	
	interface MyRobot : TDAnimCharacter
	

On the implementation, overwrite *executeEvent*  method:

	-(void) executeEvent:(TDAnimEvent *)_evt
	{
		if ([_evt.type isEqualToString:@"big_step")
			self.position = ccpAdd(self.position, ccp(100, 0));
			
		if ([_evt.type isEqualToString:@"small_step"])
			self.position = ccpAdd(self.position, ccp(20, 0));			
	}
	
So, when you play the animation "walk" and the playhead gets to frame 1 and 22, your character will move the right by 100px. It will move 20px when the playhead hits the frame number 10.

Take a look at the example. It includes the Maya files, the TBXML library, the required pngs and the XCode project.

We will add more tutorials as we can.

The Dam Armada
	
