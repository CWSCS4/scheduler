
// cost.hpp

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

#ifndef CWS_COST_HPP_INCLUDED
#define CWS_COST_HPP_INCLUDED

#include "state.hpp"
#include "specification.hpp"
#include <iostream>

namespace cws
{

  /**
   * The cost/energy of a particular state is based on the following
   * factors:
   *
   *     Conference value
   *     Wait time
   *     Travel distance
   */

  inline void calculateConferenceValueFactor
  (const State &state, const Specification &spec, int p1,
   float &conferenceValueFactor);
  
  inline void calculateUnsatisfiedPreferenceFactor
  (const State &state, const Specification &spec, int p2,
   float &unsatisfiedFactor);

  inline int calculateWaitTime
  (const State &state, const Specification &spec, int p1,
   int firstSlot, int lastSlot);

  inline int calculateWaitTimeAndConsecutiveFactor
  (const State &state, const Specification &spec, int p1,
   int firstSlot, int lastSlot,
   int &consecutiveFactor, int maximumConsecutive);

  inline int calculateWaitTime
  (const State &state, const Specification &spec, int p1);

  inline int calculateWaitTimeAndConsecutiveFactor
  (const State &state, const Specification &spec, int p1,
   int &consecutiveFactor, int maximumConsecutive);

  inline int calculateAdjustedWaitTime
  (const Specification &spec, int waitTime,
   int firstSlot, int lastSlot, int newSlot);

  inline float calculateWaitFactor(int waitTime);

  inline void calculateWaitFactor
  (int waitTime, float &waitFactor);

  inline void calculateWaitAndTravelFactor
  (const State &state, const Specification &spec, int p2,
   float &waitFactor, float &travelFactor);

  inline void calculateWaitAndTravelAndConsecutiveFactor
  (const State &state, const Specification &spec, int p2,
   float &waitFactor, float &travelFactor, int &consecutiveFactor,
   int maximumConsecutive);

  inline float calculateCost(const State &state, const Specification &spec);
  
  
  inline void calculateConferenceValueFactor
  (const State &state, const Specification &spec, int p1,
   float &conferenceValueFactor)
  {
    const Array<std::pair<int, Array<int> > > &costList
      = spec.conferenceCostList(p1);

    typedef Array<std::pair<int, Array<int> > >::const_iterator
      const_iterator;

    conferenceValueFactor = 0;

    for (const_iterator it = costList.begin(),
           end = costList.end();
         it != end;
         ++it)
    {
      int p2 = it->first;
      int count = state.count(p1, p2 + spec.firstGroupCount());
      conferenceValueFactor += it->second[count];
    }
  }

  inline void calculateUnsatisfiedPreferenceFactor
  (const State &state, const Specification &spec, int p2,
   float &unsatisfiedFactor)
  {
    int unsatisfied
      = spec.conferenceList(p2).size() - state.count(p2);

    // Square the number of unsatisfied preferences to increase the
    // value of an equal number of unsatisfied preferences for all
    // participants (in the second group)
    unsatisfiedFactor = unsatisfied * unsatisfied;
  }

  inline int calculateWaitTime
  (const State &state, const Specification &spec, int p1,
   int firstSlot, int lastSlot)
  {
    int waitTime = 0;

    if (firstSlot <= lastSlot)
    {
      int previousTime = spec.slotTime(firstSlot);

      for (int slot = firstSlot + 1; slot <= lastSlot; ++slot)
      {
        if (state.at(p1, slot) == -1)
          continue;

        // `p1' has conference scheduled at `slot'
        int currentTime = spec.slotTime(slot);
        waitTime += (currentTime - previousTime - spec.slotDuration());
        previousTime = currentTime;
      }
    }

    return waitTime;
  }

  inline int calculateWaitTimeAndConsecutiveFactor
  (const State &state, const Specification &spec, int p1,
   int firstSlot, int lastSlot,
   int &consecutiveFactor, int maximumConsecutive)
  {
    consecutiveFactor = 0;
    int waitTime = 0;
    int consecutive = 1;

    if (firstSlot <= lastSlot)
    {
      int previousTime = spec.slotTime(firstSlot);

      for (int slot = firstSlot + 1; slot <= lastSlot; ++slot)
      {
        if (state.at(p1, slot) == -1)
          continue;

        // `p1' has conference scheduled at `slot'
        int currentTime = spec.slotTime(slot);
        waitTime += (currentTime - previousTime - spec.slotDuration());
        previousTime = currentTime;

        if (state.at(p1, slot - 1) != -1)
        {
          ++consecutive;
        } else
        {
          int difference = consecutive - maximumConsecutive;
          if (difference > 0)
            consecutiveFactor += difference * difference;
          consecutive = 1;
        }
        
      }

      int difference = consecutive - maximumConsecutive;
      if (difference > 0)
        consecutiveFactor += difference * difference;
    }

    return waitTime;
  }

  inline int calculateWaitTime
  (const State &state, const Specification &spec, int p1)
  {
    int firstSlot = state.firstSlot(p1);
    int lastSlot = state.lastSlot(p1);

    return calculateWaitTime(state, spec, p1, firstSlot, lastSlot);
  }

  inline int calculateWaitTimeAndConsecutiveFactor
  (const State &state, const Specification &spec, int p1,
   int &consecutiveFactor, int maximumConsecutive)
  {
    int firstSlot = state.firstSlot(p1);
    int lastSlot = state.lastSlot(p1);

    return calculateWaitTimeAndConsecutiveFactor(state, spec, p1, firstSlot, lastSlot,
                             consecutiveFactor, maximumConsecutive);
  }

  inline int calculateAdjustedWaitTime
  (const Specification &spec, int waitTime,
   int firstSlot, int lastSlot, int newSlot)
  {
    if (firstSlot > lastSlot)
      return spec.slotDuration();
    if (newSlot < firstSlot)
      return waitTime + spec.slotTime(firstSlot)
        - spec.slotTime(newSlot) - spec.slotDuration();
    if (newSlot > lastSlot)
      return waitTime + spec.slotTime(newSlot)
        - spec.slotTime(lastSlot) - spec.slotDuration();
    return waitTime;
  }

  inline float calculateWaitFactor(int waitTime)
  {
    // Square the waitTime to increase the value of equality
    return (float)waitTime * (float)waitTime;
  }

  inline void calculateWaitFactor
  (int waitTime, float &waitFactor)
  {
    waitFactor = calculateWaitFactor(waitTime);
  }

  inline void calculateWaitAndTravelFactor
  (const State &state, const Specification &spec, int p2,
   float &waitFactor, float &travelFactor)
  {
    int waitTime = 0;
    int travelTotal = 0;
    
    int firstSlot = state.firstSlot(p2);
    int lastSlot = state.lastSlot(p2);

    if (firstSlot <= lastSlot)
    {
    
      int previousTime = spec.slotTime(firstSlot);

      for (int slot = firstSlot + 1; slot <= lastSlot; ++slot)
      {
        int currentConference = state.at(p2, slot);
        if (currentConference == -1)
          continue;

        // `p2' has conference scheduled at `slot'
        int currentTime = spec.slotTime(slot);
        waitTime += (currentTime - previousTime - spec.slotDuration());
        previousTime = currentTime;

        int previousConference = state.at(p2, slot - 1);
        if (previousConference != -1)
          travelTotal += spec.travelCost(previousConference,
                                         currentConference);
      }
    }

    calculateWaitFactor(waitTime, waitFactor);

    // Square the travelTotal to increase the value of equality
    travelFactor = (float)travelTotal * (float)travelTotal;
  }

  inline void calculateWaitAndTravelAndConsecutiveFactor
  (const State &state, const Specification &spec, int p2,
   float &waitFactor, float &travelFactor,
   int &consecutiveFactor, int maximumConsecutive)
  {
    consecutiveFactor = 0;
    int waitTime = 0;
    int travelTotal = 0;
    
    int firstSlot = state.firstSlot(p2);
    int lastSlot = state.lastSlot(p2);

    int consecutive = 1;

    if (firstSlot <= lastSlot)
    {
    
      int previousTime = spec.slotTime(firstSlot);

      for (int slot = firstSlot + 1; slot <= lastSlot; ++slot)
      {
        int currentConference = state.at(p2, slot);
        if (currentConference == -1)
          continue;

        // `p2' has conference scheduled at `slot'
        int currentTime = spec.slotTime(slot);
        waitTime += (currentTime - previousTime - spec.slotDuration());
        previousTime = currentTime;

        int previousConference = state.at(p2, slot - 1);
        if (previousConference != -1)
        {
          travelTotal += spec.travelCost(previousConference,
                                         currentConference);
          ++consecutive;
        } else
        {
          int difference = consecutive - maximumConsecutive;
          if (difference > 0)
            consecutiveFactor += difference * difference;
          consecutive = 1;
        }
      }
      int difference = consecutive - maximumConsecutive;
      if (difference > 0)
        consecutiveFactor += difference * difference;
    }

    calculateWaitFactor(waitTime, waitFactor);

    // Square the travelTotal to increase the value of equality
    travelFactor = (float)travelTotal * (float)travelTotal;
  }
  

  inline float calculateCost(const State &state, const Specification &spec)
  {
    float cost = 0.0f;

    for (int p1 = 0; p1 < spec.firstGroupCount(); ++p1)
    {
      float conferenceValueFactor, waitFactor;

      calculateConferenceValueFactor
        (state, spec, p1, conferenceValueFactor);

      int maximumConsecutive = spec.maximumConsecutive(p1);
      if (maximumConsecutive > 0)
      {
        int consecutiveFactor;
        calculateWaitFactor
          (calculateWaitTimeAndConsecutiveFactor(state, spec, p1,
                                                 consecutiveFactor,
                                                 maximumConsecutive),
           waitFactor);
        cost += spec.consecutiveWeight() * consecutiveFactor;
      } else
      {
        calculateWaitFactor
        (calculateWaitTime(state, spec, p1), waitFactor);
      }

      cost += spec.conferenceValueWeight() * conferenceValueFactor;
      cost += spec.waitWeight() * waitFactor;
    }

    for (int p2 = spec.firstGroupCount();
         p2 < spec.participantCount(); ++p2)
    {
      float unsatisfiedFactor, waitFactor, travelFactor;

      calculateUnsatisfiedPreferenceFactor
        (state, spec, p2, unsatisfiedFactor);

      int maximumConsecutive = spec.maximumConsecutive(p2);
      if (maximumConsecutive > 0)
      {
        int consecutiveFactor;
        calculateWaitAndTravelAndConsecutiveFactor
          (state, spec, p2, waitFactor, travelFactor,
           consecutiveFactor, maximumConsecutive);
        cost += spec.consecutiveWeight() * consecutiveFactor;
      } else
      {
        calculateWaitAndTravelFactor
          (state, spec, p2, waitFactor, travelFactor);
      }

      cost += spec.unsatisfiedPreferenceWeight() * unsatisfiedFactor;
      cost += spec.waitWeight() * waitFactor;
      cost += spec.travelWeight() * travelFactor;
    }

    // Divide by participant count to normalize
    return cost / spec.participantCount();
  }
  
} // namespace cws

#endif // CWS_COST_HPP_INCLUDED
