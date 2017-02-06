
// io.cpp

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

#include "io.hpp"
#include "specification.hpp"
#include "state.hpp"
#include <istream>
#include <ostream>
#include <iostream>

namespace cws
{
  std::istream &readSpecification(std::istream &in, Specification &spec)
  {
    int participantCount, firstGroupCount, slotCount;
    int slotDuration;
    float conferenceValueWeight, waitWeight,
      unsatisfiedPreferenceWeight, travelWeight, consecutiveWeight;

    // Read general parameters
    in >> participantCount >> firstGroupCount >> slotCount
       >> slotDuration >> conferenceValueWeight >> waitWeight
       >> unsatisfiedPreferenceWeight >> travelWeight >> consecutiveWeight;

    if (!in)
      return in;

    // Perform integrity checks
    if (participantCount < 0
        || firstGroupCount < 0
        || firstGroupCount > participantCount
        || slotDuration < 0
        || conferenceValueWeight < 0
        || waitWeight < 0
        || unsatisfiedPreferenceWeight < 0
        || travelWeight < 0
        || consecutiveWeight < 0)
    {
      in.setstate(std::ios_base::badbit);
      std::cout << "Spec does not pass integrety checks." << std::endl;
      return in;
    }

    spec.setSize(participantCount, firstGroupCount, slotCount);
    spec.setSlotDuration(slotDuration);
    spec.setConferenceValueWeight(conferenceValueWeight);
    spec.setWaitWeight(waitWeight);
    spec.setUnsatisfiedPreferenceWeight(unsatisfiedPreferenceWeight);
    spec.setTravelWeight(travelWeight);
    spec.setConsecutiveWeight(consecutiveWeight);

    // Read slotTimeData
    for (int i = 0; i < slotCount; ++i)
    {
      int value;
      if (in >> value)
        spec.slotTimeData()[i] = value;
      else
        return in;
    }

    // Read travelCostData
    for (int i = 0;
         i < spec.firstGroupCount() * spec.firstGroupCount();
         ++i)
    {
      int value;
      if (in >> value)
      {
        if (value < 0)
        {
          in.setstate(std::ios_base::badbit);
	  std::cout << "Spec has invalid travelCostData." << std::endl;
          return in;
        }
        spec.travelCostData()[i] = value;
      } else
        return in;
    }

    // Read maximumConsecutiveData
    for (int p = 0; p < participantCount; ++p)
    {
      int value;
      if (in >> value)
      {
        if (value < 0)
        {
          in.setstate(std::ios_base::badbit);
	  std::cout << "Spec has invalid maximumConsecutiveData." << std::endl;
          return in;
        }
        spec.maximumConsecutiveData()[p] = value;
      } else
        return in;
    }

    // Read validSlotData
    for (int p = 0; p < participantCount; ++p)
    {
      int length;
      if (in >> length)
      {
        if (length < 0)
        {
          in.setstate(std::ios_base::badbit);
	  std::cout << "Spec has invalid validSlotData." << std::endl;
          return in;
        }
      } else
        return in;

      spec.validSlotData()[p].initialize(length);

      for (int i = 0; i < length; ++i)
      {
        int value;
        if (in >> value)
        {
          if (value < 0 || value >= slotCount)
          {
            in.setstate(std::ios_base::badbit);
	    std::cout << "Spec has more invalid valueSlotData." << std::endl;
            return in;
          }
          spec.validSlotData()[p][i] = value;
        } else
          return in;
      }
    }

    // Read conferenceValueData
    for (int i = 0;
         i < spec.firstGroupCount() * spec.secondGroupCount();
         ++i)
    {
      int length;
      if (in >> length)
      {
        if (length < 0)
        {
          in.setstate(std::ios_base::badbit);
	  std::cout << "Spec has invalid conferenceValueData." << std::endl;
          return in;
        }
      } else
        return in;
      
      spec.conferenceValueData()[i].initialize(length);

      for (int j = 0; j < length; ++j)
      {
        int value;
        if (in >> value)
        {
          if (value < 0)
          {
            in.setstate(std::ios_base::badbit);
	    std::cout << "Spec has more invalid conferenceValueData." << std::endl;
            return in;
          }
          spec.conferenceValueData()[i][j] = value;
        } else
          return in;
      }
    }

    spec.createCache();

    return in;
  }
  
  std::ostream &writeSpecification(std::ostream &out, const Specification &spec)
  {
    // Write general parameters
    out << spec.participantCount() << ' '
        << spec.firstGroupCount() << ' '
        << spec.slotCount() << '\n'
        << spec.slotDuration() << ' '
        << spec.conferenceValueWeight() << ' '
        << spec.waitWeight() << ' '
        << spec.unsatisfiedPreferenceWeight() << ' '
        << spec.travelWeight() << ' '
        << spec.consecutiveWeight() << '\n';

    // Write slotTimeData
    for (int i = 0; i < spec.slotCount(); ++i)
    {
      if (i != 0)
        out << ' ';
      out << spec.slotTime(i);
    }
    out << '\n';

    // Write travelCostData
    for (int p1 = 0; p1 < spec.firstGroupCount(); ++p1)
    {
      for (int p2 = 0; p2 < spec.firstGroupCount(); ++p2)
      {
        if (p1 != 0 || p2 != 0)
          out << ' ';
        out << spec.travelCost(p2, p1);
      }
    }
    out << '\n';

    // Write maximumConsecutiveData
    for (int p = 0; p < spec.participantCount(); ++p)
    {
      if (p != 0)
        out << ' ';
      out << spec.maximumConsecutive(p);
    }
    out << '\n';

    // Write validSlotData
    for (int p = 0; p < spec.participantCount(); ++p)
    {
      out << spec.validSlots(p).size();
      for (int i = 0; i < spec.validSlots(p).size(); ++i)
      {
        out << ' ' << spec.validSlots(p)[i];
      }
      out << '\n';
    }

    // Write conferenceValueData
    for (int p2 = 0; p2 < spec.secondGroupCount(); ++p2)
    {
      for (int p1 = 0; p1 < spec.firstGroupCount(); ++p1)
      {
        out << spec.maximumConferences(p1, p2);
        for (int i = 0; i < spec.maximumConferences(p1, p2); ++i)
        {
          out << ' ' << spec.conferenceValue(p1, p2, i);
        }
        out << '\n';
      }
    }

    return out;
  }

  std::istream &readState(std::istream &in, State &state)
  {
    // Read general parameters
    int participantCount, slotCount;
    in >> participantCount >> slotCount;
    if (in)
    {
      if (state.slotCount() < 0
          || state.participantCount() < 0)
      {
        in.setstate(std::ios_base::badbit);
        return in;
      }
    } else
      return in;

    state.initialize(participantCount, slotCount);

    // Read the data
    for (int i = 0; i < state.dataSize(); ++i)
    {
      int value;
      if (in >> value)
      {
        state.data()[i] = value;
      } else
      {
        state.clear();
        return in;
      }
    }

    return in;
  }
  
  std::ostream &writeState(std::ostream &out, const State &state)
  {
    out << state.participantCount() << ' '
        << state.slotCount() << '\n';

    for (int p = 0; p < state.participantCount(); ++p)
    {
      for (int i = 0; i < state.dataRowSize(); ++i)
      {
        if (i != 0)
          out << ' ';
        out << state.data()[p * state.dataRowSize() + i];
      }
      out << '\n';
    }

    return out;
  }
  
} // namespace cws
