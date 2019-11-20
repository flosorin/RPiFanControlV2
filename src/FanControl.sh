#!/bin/bash

### CONSTANTS ###

FAN_PIN=18  # "P" pin of the NPN transistor, used to trigger the fan
MAX_TEMP=70 # Maximum temperature in Celsius, after which we trigger the fan
MIN_TEMP=50 # Minimum temperature in Celsius, below which we turn off the fan 

GPIO_FOLDER="/sys/class/gpio"
FAN_GPIO_FOLDER=${GPIO_FOLDER}/gpio${FAN_PIN}

### FUNCTIONS ###

# SIGINT handler
sigintHandler()
{
    echo "Exiting FanControl"
    echo ${FAN_PIN} > ${GPIO_FOLDER}/unexport
    exit 0
}

configureGPIO()
{
    # Ensure we have permissions to modify GPIOs
    sudo chgrp gpio ${GPIO_FOLDER}/export
    sudo chgrp gpio ${GPIO_FOLDER}/unexport
    sudo chmod 775 ${GPIO_FOLDER}/export
    sudo chmod 775 ${GPIO_FOLDER}/unexport
    sleep 1
    # Export fan GPIO and ensure we have permissions to modify it
    echo ${FAN_PIN} > ${GPIO_FOLDER}/export
    sudo chgrp -HR gpio ${FAN_GPIO_FOLDER}
    sudo chmod -R 775 ${FAN_GPIO_FOLDER}
    sleep 1
    # Configure fan GPIO as output
    echo "out" > ${FAN_GPIO_FOLDER}/direction
}

### PROGRAM EXECUTION ###

# SIGINT management
trap sigintHandler SIGINT

# GPIO configuration
configureGPIO

# Monitoring
while :
do
    # Recover temperature (5 numbers representation, ex: 44123)
    TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)

    # Convert temperature to celsius degrees
    TEMP=$(($TEMP/1000))
    
    # Turn on/off the fan if needed
    if [ "$TEMP" -gt "$MAX_TEMP" ]; then
        echo "1" > ${FAN_GPIO_FOLDER}/value # Fan ON
    elif [ "$TEMP" -lt "$MIN_TEMP" ]; then
        echo "0" > ${FAN_GPIO_FOLDER}/value # Fan OFF
    fi
    
    sleep 30
done
