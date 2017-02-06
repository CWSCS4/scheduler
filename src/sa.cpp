
// sa.cpp

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

#include "sa.hpp"
#include "neighbor.hpp"
#include "cost.hpp"

#include <cstdlib>
#include <cmath>

namespace cws
{

  SimulatedAnnealingAgent::SimulatedAnnealingAgent
  (const Specification &spec, const State &initialState)
    : specification_(spec),
      currentState_(initialState),
      bestState_(initialState),
      tempState_(initialState),
      iterationCount_(0),
      changeCount_(0),
      improvementCount_(0),
      lastChange_(0),
      lastImprovement_(0)
  {
    currentCost_ = calculateCost(currentState(), specification());
    bestCost_ = currentCost_;
  }

  SimulatedAnnealingAgent::IterationResult
  SimulatedAnnealingAgent::performIteration(float temperature)
  {
    ++iterationCount_;
    if (generateNeighbor(tempState_, specification()))
    {
      float cost = calculateCost(tempState_, specification());
      bool negative = cost <= currentCost();
      bool accept = negative;
      if (!accept)
      {
        float chance = std::rand() * 1.0f / RAND_MAX;
        float value = std::exp(-(cost - currentCost()) / temperature);
        if (value > chance)
          accept = true;
      }

      if (accept)
      {
        currentCost_ = cost;
        currentState_ = tempState_;
        lastChange_ = iterationCount_;
        ++changeCount_;
        if (cost < bestCost())
        {
          bestCost_ = cost;
          bestState_ = tempState_;
          lastImprovement_ = iterationCount_;
          ++improvementCount_;
          return IMPROVEMENT;
        } else if (negative)
        {
          return NEGATIVE;
        } else
        {
          return POSITIVE;
        }
      } else
      {
        tempState_ = currentState_;
        return REJECTED;
      }
    } else
    {
      return NO_UPDATE;
    }
  }
  
} // namespace cws
