#!/usr/bin/env python
#Stores the schedule.
import schedule

import os

os.system( "java org.commschool.scheduler.StoreConferences " + schedule.spec[6] + " < " + schedule.spec[5] )