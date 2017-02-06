
#CXX = /opt/xmingw/bin/i386-mingw32msvc-g++
CXX = g++
CXXFLAGS = -O3

commonSources = state.cpp specification.cpp io.cpp

allSources = $(commonSources) diagnostics.cpp initial.cpp neighbor.cpp
allSources += schedule.cpp io.cpp sa.cpp generateInitialSchedule.cpp
allSources += printSchedule.cpp simulatedAnnealing.cpp

printScheduleSources = $(commonSources) printSchedule.cpp \
diagnostics.cpp

checkScheduleSources = $(commonSources) checkSchedule.cpp \
diagnostics.cpp

generateInitialScheduleSources = $(commonSources) \
generateInitialSchedule.cpp initial.cpp schedule.cpp

simulatedAnnealingSources = $(commonSources) schedule.cpp neighbor.cpp \
sa.cpp simulatedAnnealing.cpp

printScheduleObjects = $(printScheduleSources:.cpp=.o)
checkScheduleObjects = $(checkScheduleSources:.cpp=.o)
generateInitialScheduleObjects = $(generateInitialScheduleSources:.cpp=.o)
simulatedAnnealingObjects = $(simulatedAnnealingSources:.cpp=.o)

all: simulatedAnnealing printSchedule checkSchedule \
generateInitialSchedule

simulatedAnnealing: $(simulatedAnnealingObjects)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(simulatedAnnealingObjects)

checkSchedule: $(checkScheduleObjects)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(checkScheduleObjects)

printSchedule: $(printScheduleObjects)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(printScheduleObjects)

generateInitialSchedule: $(generateInitialScheduleObjects)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) -o $@ $(generateInitialScheduleObjects)

#%.d: %.cpp
#	$(CXX) $(CPPFLAGS) -M $< > $@; \
#	sed -i 's,\($*\)\.o[ :]*,\1.o $@ : ,g' $@

%.d: %.cpp
	@set -e; rm -f $@; \
	$(CC) -M $(CPPFLAGS) $< > $@.$$$$; \
	sed 's,\($*\)\.o[ :]*,\1.o $@ : ,g' < $@.$$$$ > $@; \
	rm -f $@.$$$$


.PHONY: clean distclean
clean:
	rm -f *.o
	rm -f simulatedAnnealing printSchedule checkSchedule generateInitialSchedule

distclean: clean
	rm -f *.d

include $(allSources:.cpp=.d)
