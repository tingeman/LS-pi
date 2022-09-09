#!/bin/bash

####################################################################
#
#    lcdonoff
#
#    A utility to turn the terrameter LCD on or off using gpio_out.
#
#    ./lcdonoff ON      will turn the LCD backlight on
#    ./lcdonoff OFF     will turn the LCD backlight off
#     
#    The script can be scheduled as a cronjob, e.g. @reboot
#    
#    The script must be located in /home/root/ together with the
#    files gpio_out and cronscripter_settings.
#
#    2021-05 Thomas Ingeman-Nielsen, tin@byg.dtu.dk
#
####################################################################

# source settings. All changes to directories, etc. done here.
if [[ -z $SCRIPTS_DIR ]]; then
    SCRIPTS_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
fi

source "$SCRIPTS_DIR/cronscripter_settings"


# Will turn off LCD via gpio_out   
lcd_off()                                                                           
{                                                                                  
    $BIN/echo -n `date "+%Y-%m-%d %H:%M:%S(%Z)"` "Turning LCD off: " >> $LOGDIR/logfile
    #$BIN/echo -n `date "+%Y-%m-%d %H:%M:%S(%Z)"` "$GPIO_OUT_BIN/gpio_out LCD_LAMP_ON 0" >> $LOGDIR/logfile 
    $GPIO_OUT_BIN/gpio_out LCD_LAMP_ON 0 1>> $LOGDIR/logfile 2>> $LOGDIR/logfile                                                    
    #$GPIO_OUT_BIN/gpio_out LCD_PWR_ON 0                                                      
    #$GPIO_OUT_BIN/gpio_out LCD_INV_PWR_ON 0                                                  
}                                                                                  
                                             
# Will turn on LCD via gpio_out                                                                                  
lcd_on()                                                                             
{                                                                                  
    $BIN/echo -n `date "+%Y-%m-%d %H:%M:%S(%Z)"` "Turning LCD on: " >> $LOGDIR/logfile
    $GPIO_OUT_BIN/gpio_out LCD_LAMP_ON 1 1>> $LOGDIR/logfile 2>> $LOGDIR/logfile                                                    
    #$GPIO_OUT_BIN/gpio_out LCD_PWR_ON 1                                                      
    #$GPIO_OUT_BIN/gpio_out LCD_INV_PWR_ON 1                                                  
}     


# This is the main program

lcd_switch_allowed=0

if [ -e $RUNFILEDIR/runfile ]
then
    lcd_switch_allowed=1
else
    echo $#
    echo $2
    if [ $# = 2 ]
    then 
        if [ $2 = "FORCE" ]
        then
            echo "forcing switch" 
            lcd_switch_allowed=1
        fi
    fi
fi

if [ $lcd_switch_allowed = 1 ]
then
    if [ $# -ge 1 ]
    then
        if [ $1 = "OFF" ]
        then
            lcd_off
        elif [ $1 = "ON" ]
        then
            lcd_on
        else
            exit
        fi
    fi
else
    $BIN/echo `date "+%Y-%m-%d %H:%M:%S(%Z)"` "LCD switching not permitted (touch $RUNFILEDIR/runfile or provide input argument FORCE)" >> $LOGDIR/logfile
fi

