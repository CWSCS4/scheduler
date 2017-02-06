#Note - the lines that are not comments are in this order for a reason!  Do not rearrange them or add new ones, for this will cause the reader of this specification to become very confused.
# Specification arguments
127.0.0.1 scheduler scheduler "" EST 600 10 .0000001 0.3 0 1000 8 100 10 0.1 0 0
# Initial Schedule Generator Specification file
file.spec
# Initial Schedule File
init.sch
# Schedule output file (used by printSchedule)
print.txt
# Optimizer arguments
-v -i 10000 -c .99 -n 10000
# Final schedule file
next.sch
# Conference storing arguments
127.0.0.1 scheduler scheduler "" EST 600
