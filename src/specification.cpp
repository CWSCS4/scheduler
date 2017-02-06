
// specification.cpp

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

#include "specification.hpp"

// Used by Specification::createConferenceLists()
#include <map>
#include <algorithm>

namespace cws
{

  Specification::Specification(int participantCount,
                               int firstGroupCount,
                               int slotCount)
    : participantCount_(participantCount),
      slotCount_(slotCount),
      firstGroupCount_(firstGroupCount),
      secondGroupCount_(participantCount - firstGroupCount),
      compatibleSlots_(participantCount_ * participantCount_),
      validSlot_(participantCount * slotCount),
      validSlots_(participantCount),
      conferenceList_(participantCount),
      conferenceValue_(firstGroupCount_ * secondGroupCount_),
      conferenceCostList_(firstGroupCount_),
      travelCost_(firstGroupCount * firstGroupCount),
      maxConsecutive_(participantCount),
      slotTime_(slotCount),
      slotDuration_(0),
      conferenceValueWeight_(0),
      waitWeight_(0),
      unsatisfiedPreferenceWeight_(0),
      travelWeight_(0),
      consecutiveWeight_(0)
  {}

  Specification::Specification()
    : participantCount_(0),
      slotCount_(0),
      firstGroupCount_(0),
      secondGroupCount_(0),
      slotDuration_(0),
      conferenceValueWeight_(0),
      waitWeight_(0),
      unsatisfiedPreferenceWeight_(0),
      travelWeight_(0),
      consecutiveWeight_(0)
  {}

  void Specification::setSize(int participantCount,
                              int firstGroupCount,
                              int slotCount)
  {
    participantCount_ = participantCount;
    slotCount_ = slotCount;
    firstGroupCount_ = firstGroupCount;
    secondGroupCount_ = participantCount - firstGroupCount;
    compatibleSlots_.initialize(participantCount_ * participantCount_);
    validSlot_.initialize(participantCount_ * slotCount_);
    validSlots_.initialize(participantCount_);
    conferenceList_.initialize(participantCount_);
    conferenceValue_.initialize(firstGroupCount_ * secondGroupCount_);
    conferenceCostList_.initialize(firstGroupCount_);
    travelCost_.initialize(firstGroupCount * firstGroupCount);
    slotTime_.initialize(slotCount);
    maxConsecutive_.initialize(participantCount);
  }

  void Specification::createCache()
  {
    createConferenceLists();
    createConferenceCostList();
    createSlotDataCache();
  }

  void Specification::createSlotDataCache()
  {
    // First generate valid slot cache
    for (int p = 0; p < participantCount(); ++p)
    {
      // Set validSlot to false for all slots
      for (int slot = 0; slot < slotCount(); ++slot)
        validSlot_[p + slot * participantCount()] = false;

      for (int i = 0; i < validSlots(p).size(); ++i)
        validSlot_[p + validSlots(p)[i] * participantCount()] = true;
    }

    // Then generate compatible slot lists
    for (int p1 = 0; p1 < participantCount(); ++p1)
    {
      for (int p2 = 0; p2 < participantCount(); ++p2)
      {
        int count = 0;
        for (int i = 0; i < validSlots(p1).size(); ++i)
        {
          if (validSlot(p2, validSlots(p1)[i]))
            ++count;
        }

        compatibleSlots_[p1 + p2 * participantCount()]
          .initialize(count);
        count = 0;

        for (int i = 0; i < validSlots(p1).size(); ++i)
        {
          int slot = validSlots(p1)[i];
          if (validSlot(p2, slot))
          {
            compatibleSlots_[p1 + p2 * participantCount()][count]
              = slot;
            ++count;
          }
        }
      }
    }
  }

  void Specification::createConferenceLists()
  {
    for (int p1 = 0; p1 < firstGroupCount(); ++p1)
    {
      typedef std::multimap<int, std::pair<int, int> > MapType;
      std::multimap<int, std::pair<int, int> > map;
      for (int p2 = 0; p2 < secondGroupCount(); ++p2)
      {
        for (int i = 0; i < maximumConferences(p1, p2); ++i)
        {
          int value = conferenceValue(p1, p2, i);
          map.insert
            (std::make_pair
             (value, std::make_pair(p2 + firstGroupCount(), i)));
        }
      }

      conferenceList_[p1].initialize((int)map.size());
      int count = 0;
      for (MapType::const_iterator it = map.begin(),
             end = map.end();
           it != end;
           ++it)
      {
        conferenceList_[p1][count] = it->second;
        ++count;
      }
    }

    for (int p2 = 0; p2 < secondGroupCount(); ++p2)
    {
      typedef std::multimap<int, std::pair<int, int> > MapType;
      std::multimap<int, std::pair<int, int> > map;
      for (int p1 = 0; p1 < firstGroupCount(); ++p1)
      {
        for (int i = 0; i < maximumConferences(p1, p2); ++i)
        {
          int value = conferenceValue(p1, p2, i);
          map.insert(std::make_pair(value, std::make_pair(p1, i)));
        }
      }

      conferenceList_[p2 + firstGroupCount()]
        .initialize((int)map.size());
      
      int count = 0;
      for (MapType::const_iterator it = map.begin(),
             end = map.end();
           it != end;
           ++it)
      {
        conferenceList_[p2 + firstGroupCount()][count] = it->second;
        ++count;
      }
    }
  }

  void Specification::createConferenceCostList()
  {
    for (int p1 = 0; p1 < firstGroupCount(); ++p1)
    {
      int count = 0;

      // First determine the number of participants in the second
      // group for which a conference with `p1' is valuable.
      for (int p2 = 0; p2 < secondGroupCount(); ++p2)
      {
        if (maximumConferences(p1, p2) > 0)
          ++count;
      }

      conferenceCostList_[p1].initialize(count);
      count = 0;

      for (int p2 = 0; p2 < secondGroupCount(); ++p2)
      {
        int maxConferences = maximumConferences(p1, p2);
        if (maxConferences == 0)
          continue;

        conferenceCostList_[p1][count].first = p2;
        conferenceCostList_[p1][count]
          .second.initialize(maxConferences + 1);

        conferenceCostList_[p1][count].second[maxConferences] = 0;

        int value = 0;
        for (int i = maxConferences - 1; i >= 0; --i)
        {
          value += conferenceValue(p1, p2, i);
          conferenceCostList_[p1][count].second[i] = value;
        }
        
        ++count;
      }
    }
  }
  
} // namespace cws
