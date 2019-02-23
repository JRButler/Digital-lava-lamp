#!/usr/bin/env python

import RPi.GPIO as GPIO
import os
import time
import random as random


GPIO.setmode(GPIO.BCM)
GPIO.setup(0, GPIO.IN, pull_up_down=GPIO.PUD_UP)

# Here's the master list of sketches to cycle through
sketchArray = [
	'/home/pi/lavalamp/sketches/Fireworks/application.linux-armv6hf/Fireworks',
	'/home/pi/lavalamp/sketches/rotatingRainbow/application.linux-armv6hf/rotatingRainbow',
	'/home/pi/lavalamp/sketches/grid15x8z_clouds/application.linux-armv6hf/grid15x8z_clouds',
	'/home/pi/lavalamp/sketches/wavyRainbow/application.linux-armv6hf/wavyRainbow',
	'/home/pi/lavalamp/sketches/grid15x8_noise_simple/application.linux-armv6hf/grid15x8_noise_simple',
	'/home/pi/lavalamp/sketches/verticalWaveyRainbowSoundReactive/application.linux-armv6hf/verticalWaveyRainbowSoundReactive',
	'/home/pi/lavalamp/sketches/gradientBlender/application.linux-armv6hf/gradientBlender',
	'/home/pi/lavalamp/sketches/winterIsComing/application.linux-armv6hf/winterIsComing',
	'/home/pi/lavalamp/sketches/redFall/application.linux-armv6hf/redFall',
	'/home/pi/lavalamp/sketches/kelp/application.linux-armv6hf/kelp',
	'/home/pi/lavalamp/sketches/hotFluid/application.linux-armv6hf/hotFluid',
	'/home/pi/lavalamp/sketches/blobbyLamp/application.linux-armv6hf/blobbyLamp',
	'/home/pi/lavalamp/sketches/blobbyLampWarm/application.linux-armv6hf/blobbyLampWarm',
	'/home/pi/lavalamp/sketches/blueBubbles/application.linux-armv6hf/blueBubbles',
	'/home/pi/lavalamp/sketches/flocking/application.linux-armv6hf/flocking',
	'/home/pi/lavalamp/sketches/simpleFire/application.linux-armv6hf/simpleFire',
	'/home/pi/lavalamp/sketches/colourFire/application.linux-armv6hf/colourFire'
	]

modesLength = len(sketchArray)
randomStartSketch = random.randint(0,modesLength)
sketchNumber = randomStartSketch

# here's the path to the startup array test sketch
arraySweep ='/home/pi/lavalamp/sketches/startupArraySweep/application.linux-armv6hf/startupArraySweep'

# start up the arraySweep as a 'power on self test' sorta thing
os.system(""+ arraySweep +" &")

# kill it and move on after a set time - this may vary if you change the sketch
time.sleep(10.85)

#rrrrrrrrrrrroll the flames
os.system("killall java")

# nothing to see here - start a random mode - make sure it's not the same as the one you already drew
firstSketch = random.randint(0,modesLength-1)
# launch it
if firstSketch == sketchNumber:
	# have another go
	firstSketch = random.randint(0,modesLength-1)
else:
	os.system(""+str(sketchArray[firstSketch])+" &")


def changeMode(channel):
	# make sure you got access to the sketchNumber variable
	global sketchNumber

	# make sure if you go past the end you come back around
	if sketchNumber > modesLength-1:
		sketchNumber = 0
		#print 'end of the mode list reached, we going round again'

	# here is where you execute the sketch change
	#print 'switch detected - changing sketch to', sketchArray[sketchNumber]
	os.system("killall java")
	os.system(""+str(sketchArray[sketchNumber])+" &")

	# increment
	sketchNumber +=1

#***************************************************************************************************************************
# this is the main section for implementing GPIO button detection - plus the empty loop that constitutes the running program
#***************************************************************************************************************************

GPIO.add_event_detect(0, GPIO.RISING, callback=changeMode, bouncetime=500)
try:
	while(True):
		# avoid 100% CPU usage
		time.sleep(1)

except KeyboardInterrupt:
	# cleanup GPIO settings before exit
	GPIO.cleanup()

# end
