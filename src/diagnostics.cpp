
// diagnostics.cpp

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

#include "diagnostics.hpp"
#include "specification.hpp"
#include "state.hpp"
#include "cost.hpp"
#include <ostream>
#include <iomanip>
#include <algorithm>
#include <cmath>
#include <string>
#include <vector>

namespace cws
{

  namespace
  {
    int countConferencesScheduled(const State &state,
                                      const Specification &spec)
    {
      int count = 0;
      for (int p = 0; p < spec.firstGroupCount(); ++p)
        count += state.count(p);
      return count;
    }

    int countConferencesRequested(const Specification &spec)
    {
      int count = 0;
      for (int p = 0; p < spec.firstGroupCount(); ++p)
        count += spec.conferenceList(p).size();
      return count;
    }

    /**
     * Determines an upper bound on the number of conferences
     * requested that could be scheduled, given slot constraints.
     */
    int calculateConferencesPossible(const Specification &spec)
    {
      int totalCount = 0;
      for (int p1 = 0; p1 < spec.firstGroupCount(); ++p1)
      {
        int compatibleLimit = 0;
        for (int p2 = 0; p2 < spec.secondGroupCount(); ++p2)
        {
          compatibleLimit +=
            std::min(spec.maximumConferences(p1, p2),
                     spec.compatibleSlots
                     (p1, p2 + spec.firstGroupCount()).size());
        }
        totalCount += std::min(compatibleLimit,
                               spec.validSlots(p1).size());
      }
      return totalCount;
    }

    int calculateTotalWaitTime(const State &state,
                               const Specification &spec,
                               int pStart, int pEnd)
    {
      int total = 0;
      for (int p = pStart; p < pEnd; ++p)
        total += calculateWaitTime(state, spec, p);

      return total;
    }

    int calculateTotalWaitTime(const State &state,
                               const Specification &spec)
    {
      return calculateTotalWaitTime(state, spec, 0,
                                    spec.participantCount());
    }

  }
  
  std::ostream &printSchedule(std::ostream &out,
                              const State &state,
                              const Specification &spec)
  {
    float totalCost = calculateCost(state, spec);
    int conferencesScheduled = countConferencesScheduled(state, spec);
    int conferencesRequested = countConferencesRequested(spec);
    int conferencesPossible = calculateConferencesPossible(spec);
    int totalWaitTime = calculateTotalWaitTime(state, spec);
    int firstGroupWaitTime
      = calculateTotalWaitTime(state, spec, 0, spec.firstGroupCount());
    int secondGroupWaitTime
      = calculateTotalWaitTime(state, spec, spec.firstGroupCount(),
                               spec.participantCount());

    float averageWaitTime = (float)totalWaitTime
      / spec.participantCount();

    float averageFirstGroupWaitTime = (float)firstGroupWaitTime
      / spec.firstGroupCount();

    float averageSecondGroupWaitTime = (float)secondGroupWaitTime
      / spec.secondGroupCount();
    

    out << "Cost: " << std::fixed << totalCost << "  "
        << "Scheduled: " << conferencesScheduled
        << '/' << conferencesPossible
        << '/' << conferencesRequested << "  "
        << "Wait: " << (int)(totalWaitTime / 60) << " total, "
        << std::fixed << std::setprecision(2)
        << averageWaitTime / 60.0f << " average\n";

    int participantIndexWidth = (int)(std::log((double)spec.participantCount())
                                      / std::log((double)10) + 1);

    // Determine the maximum number of requested conferences per
    // participant, for spacing
    int maximumRequestedPerParticipant = 0;
    for (int p = spec.firstGroupCount(); p < spec.participantCount(); ++p)
    {
      int numberRequested = spec.conferenceList(p).size();
      if (numberRequested > maximumRequestedPerParticipant)
        maximumRequestedPerParticipant = numberRequested;
    }

    for (int p = 0; p < spec.participantCount(); ++p)
    {
      if (p == spec.firstGroupCount())
        out << "--\n";
      out << std::setw(participantIndexWidth) << p << ' ';

      int conferenceListSize = 0;
      std::string indicators;
      if (p >= spec.firstGroupCount())
      {
        out << '[';

        typedef Specification::ConferenceList ConferenceList;
        const ConferenceList &conferenceList = spec.conferenceList(p);
        conferenceListSize = conferenceList.size();
      
        for (ConferenceList::const_iterator it
               = conferenceList.begin(),
               end = conferenceList.end();
             it != end;
             ++it)
        {
          int p2 = it->first;
          bool scheduled = (state.count(p, p2) > it->second);
          char indicator = '-';
          if (!scheduled)
          {
            if (spec.compatibleSlots(p, p2).size() <= it->second)
              indicator = '*';
            else if ((state.count(p) < spec.validSlots(p).size())
                     && (state.count(p2) < spec.validSlots(p2).size()))
              indicator = '%';
            else
              indicator = '#';
          }
          indicators += indicator;
          if (it != conferenceList.begin())
            out << ' ';
          out << std::setw(participantIndexWidth) << p2;;
        }

        // Add spaces
        for (int x = conferenceListSize;
             x < maximumRequestedPerParticipant; ++x)
        {
          if (x != 0)
            out << ' ';
          out << std::setw(participantIndexWidth) << ' ';
        }

        out << "] ";

        out << std::left << std::setw(maximumRequestedPerParticipant)
            << indicators << std::right << ' ';
        
      } else
      {
        out << std::setw(maximumRequestedPerParticipant
                         * (participantIndexWidth + 2) + 4)
            << ' ';
      }

      int waitTime = calculateWaitTime(state, spec, p);
      out << '(' << std::setw(3) << waitTime / 60 << ')';

      int firstSlot = state.firstSlot(p),
        lastSlot = state.lastSlot(p);

      for (int slot = 0; slot < spec.slotCount(); ++slot)
      {
        out << ' ' << std::setw(participantIndexWidth);
        int x = state.at(p, slot);
        if (x == -1)
        {
          if (slot < firstSlot || slot > lastSlot)
            out << '.';
          else
            out << '#';
        } else
        {
          out << x;
        }
      }

      out << '\n';
    }

    return out;
  }

  std::ostream &checkScheduleIntegrity(std::ostream &out,
                              const State &state,
                              const Specification &spec)
  {
    // Check that state is compatible with spec
    if (state.participantCount() != spec.participantCount())
    {
      out << "State participant count ("
          << state.participantCount()
          << ") != Specification participant count ("
          << spec.participantCount() << ")\n";
      return out;
    }

    if (state.slotCount() != spec.slotCount())
    {
      out << "State slot count ("
          << state.slotCount()
          << ") != Specification slot count ("
          << spec.slotCount() << ")\n";
      return out;
    }
    
    // Manually calculate firstSlot, lastSlot, and counts
    for (int p1 = 0; p1 < state.participantCount(); ++p1)
    {
      int firstSlot = state.slotCount(), lastSlot = 0, count = 0;
      std::vector<int> counts(state.participantCount(), 0);

      for (int slot = 0; slot < state.slotCount(); ++slot)
      {
        int p2 = state.at(p1, slot);
        if (p2 < -1 || p2 >= state.participantCount())
        {
          out << "Invalid participant index ("
              << p2 << ") scheduled in slot "
              << slot << " for participant " << p1 << '\n';
          p2 = -1;
        }
        
        if (p2 != -1)
        {
          if (slot < firstSlot)
            firstSlot = slot;
          if (slot > lastSlot)
            lastSlot = slot;
          counts[p2]++;
          count++;

          int x = state.at(p2, slot);

          if (x != p1)
          {
            out << "state.at(" << p1 << ", " << slot << ") == " << p2
                << ", but state.at(" << p2 << ", " << slot << ") == "
                << x << "\n";
          }
        }
      }

      if (firstSlot != state.firstSlot(p1))
      {
        out << "Stored firstSlot for participant " << p1
            << " (" << state.firstSlot(p1) << ") != actual firstSlot ("
            << firstSlot << ")\n";
      }

      if (lastSlot != state.lastSlot(p1))
      {
        out << "Stored lastSlot for participant " << p1
            << " (" << state.lastSlot(p1) << ") != actual lastSlot ("
            << lastSlot << ")\n";
      }

      if (count != state.count(p1))
      {
        out << "Stored conference count for participant " << p1
            << " (" << state.count(p1) << ") != actual count ("
            << count << ")\n";
      }

      for (int p2 = 0; p2 < state.participantCount(); ++p2)
      {
        int c = counts[p2];
        if (c != state.count(p1, p2))
        {
          out << "Stored conference count for (" << p1 << ", " << p2
              << ") (" << state.count(p1, p2) << ") != actual count ("
              << c << ")\n";
        }

        if (c > 0)
        {
          if (p1 < spec.firstGroupCount()
              && p2 < spec.firstGroupCount())
          {
            out << "Participant " << p1
                << " in the first group is scheduled to meet with another "
                << "participant in the first group (" << p2 << ")\n";
          } else if (p1 >= spec.firstGroupCount()
                     && p2 >= spec.firstGroupCount())
          {
            out << "Participant " << p1
                << " in the second group is scheduled to meet with another "
                << "participant in the second group (" << p2 << ")\n";
          } else
          {
            int firstP, secondP;
            if (p1 < spec.firstGroupCount())
            {
              firstP = p1;
              secondP = p2 - spec.firstGroupCount();
            } else
            {
              firstP = p2;
              secondP = p1 - spec.firstGroupCount();
            }

            if (c > spec.maximumConferences(firstP, secondP))
            {
              out << "The number of conferences scheduled between "
                  << p1 << " and " << p2 << " (" << c
                  << ") exceeds the maximum number requested ("
                  << spec.maximumConferences(firstP, secondP) << ")\n";
            }
          }
        }

      }
    }
  }
  
  
} // namespace cws
