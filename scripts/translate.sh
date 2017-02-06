#!/bin/sh
#Translates the more human readable .hsc format into the less human readable .spc format
echo -e \#Note \- the lines that are not comments are in this order for a reason!\ \ Do not rearrange them or add new ones, for this will cause the reader of this specification to become very confused.\\n\# Specification arguments > spec.spc
declare file=$( grep ^\[^\#\] spec.hsc )
declare $file
declare spec_args=$host\ $name\ $username\ $password\ $timezone\ $duration\ $conferenceValueWeight\ $waitWeight\ $unsatisfiedPreferenceWeight\ $travelWeight\ $consecutiveWeight\ $maximumConsecutiveForTeachers\ $totalStudentPriority\ $teacherPriorityFactor\ $secondConferenceWeight\ $floorUpFactor\ $floorDownFactor
echo $spec_args >> spec.spc
echo \# Initial Schedule Generator Specification file >> spec.spc
echo $spec_file >> spec.spc
echo \# Initial Schedule File >> spec.spc
echo $init_file >> spec.spc
echo \# Schedule output file \(used by printSchedule\) >> spec.spc
echo $sch_out >> spec.spc
declare simAnn_args=$verbosity\ -i\ $initial_temp\ -c\ $coolness\ -n\ $iterations
echo \# Optimizer arguments >> spec.spc
echo $simAnn_args >> spec.spc
echo \# Final schedule file >> spec.spc
echo $final >> spec.spc
declare store_args=$host\ $name\ $username\ $password\ $timezone\ $duration
echo \# Conference storing arguments >> spec.spc
echo $store_args >> spec.spc
