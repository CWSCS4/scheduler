
// schedule.cpp

// Copyright 2004 Jeremy Bertram Maitin-Shepard.

// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License Version
// 2 as published by the Free Software Foundation.

// This program is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
// General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307
// USA

#include "schedule.hpp"
#include "cost.hpp"

namespace cws
{

  bool scheduleConference(State &state,
                          const Specification &spec, int p1)
  {
    // Loop through the conference list for `p1'
    typedef Specification::ConferenceList ConferenceList;
    typedef Specification::CompatibleSlotList CompatibleSlotList;

    const ConferenceList &conferenceList = spec.conferenceList(p1);

    for (ConferenceList::const_iterator it = conferenceList.begin(),
           end = conferenceList.end();
         it != end;
         ++it)
    {
      int p2 = it->first;
      // Check if this entry in the conference list is appropriate for
      // scheduling
      if (state.count(p1, p2) == it->second)
      {
        // Select the first compatible slot
        const CompatibleSlotList &compatibleSlots
          = spec.compatibleSlots(p1, p2);

        for (CompatibleSlotList::const_iterator slotIt
               = compatibleSlots.begin(),
               slotEnd = compatibleSlots.end();
             slotIt != slotEnd;
             ++slotIt)
        {
          int slot = *slotIt;
          if (state.available(p1, p2, slot))
          {
            state.add(p1, p2, slot);
            return true;
          }
        }
      }
    }
    
    return false;
  }
  
  bool scheduleConferenceOptimally(State &state,
                                   const Specification &spec, int p1)
  {
    // Loop through the conference list for `p1'
    typedef Specification::ConferenceList ConferenceList;
    typedef Specification::CompatibleSlotList CompatibleSlotList;

    const ConferenceList &conferenceList = spec.conferenceList(p1);

    int first1 = state.firstSlot(p1),
      last1 = state.lastSlot(p1),
      wait1 = calculateWaitTime(state, spec, p1, first1, last1);

    for (ConferenceList::const_iterator it = conferenceList.begin(),
           end = conferenceList.end();
         it != end;
         ++it)
    {
      int p2 = it->first;
      // Check if this entry in the conference list is appropriate for
      // scheduling
      if (state.count(p1, p2) == it->second)
      {
        // Select a compatible slot so as to minimize the wait factor
        int first2 = state.firstSlot(p2),
          last2 = state.lastSlot(p2),
          wait2 = calculateWaitTime(state, spec, p2, first2, last2);

        int bestSlot = -1;
        float bestWaitFactor = 0;

        const CompatibleSlotList &compatibleSlots
          = spec.compatibleSlots(p1, p2);

        for (CompatibleSlotList::const_iterator slotIt
               = compatibleSlots.begin(),
               slotEnd = compatibleSlots.end();
             slotIt != slotEnd;
             ++slotIt)
        {
          int slot = *slotIt;
          if (state.available(p1, p2, slot))
          {
            // TODO: Check if this condition actually improves
            // performance
            if (slot > first1 && slot < last1
                && slot > first2 && slot < last2)
            {
              bestSlot = slot;
              break;
            }
            
            float waitFactor
              = calculateWaitFactor(calculateAdjustedWaitTime
                                    (spec, wait1, first1, last1, slot))
              + calculateWaitFactor(calculateAdjustedWaitTime
                                    (spec, wait2, first2, last2, slot));
            if (bestSlot == -1 || waitFactor < bestWaitFactor)
            {
              bestSlot = slot;
              bestWaitFactor = waitFactor;
            }
          }
        }

        if (bestSlot != -1)
        {
          state.add(p1, p2, bestSlot);
          return true;
        }
      }
    }
    
    return false;
  }
    
} // namespace cws
