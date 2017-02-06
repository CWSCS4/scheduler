
// sa.hpp

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

#ifndef CWS_SA_HPP_INCLUDED
#define CWS_SA_HPP_INCLUDED

#include "state.hpp"
#include "specification.hpp"

namespace cws
{

  class SimulatedAnnealingAgent
  {
  public:
    typedef enum IterationResult { NO_UPDATE, REJECTED, POSITIVE,
                                   NEGATIVE, IMPROVEMENT };

    SimulatedAnnealingAgent(const Specification &spec,
                            const State &initialState);

    const Specification &specification() const;
    const State &currentState() const;
    float currentCost() const;
    const State &bestState() const;
    float bestCost() const;

    void resetCurrent();

    IterationResult performIteration(float temperature);

    int iterationCount() const;
    int changeCount() const;
    int improvementCount() const;
    int lastChange() const;
    int lastImprovement() const;
    
  private:
    const Specification &specification_;
    State currentState_, bestState_, tempState_;
    float currentCost_, bestCost_;
    int iterationCount_, changeCount_, improvementCount_;
    int lastChange_, lastImprovement_;
  };

  inline const Specification &SimulatedAnnealingAgent::specification() const
  {
    return specification_;
  }

  inline const State &SimulatedAnnealingAgent::currentState() const
  {
    return currentState_;
  }

  inline const State &SimulatedAnnealingAgent::bestState() const
  {
    return bestState_;
  }

  inline float SimulatedAnnealingAgent::currentCost() const
  {
    return currentCost_;
  }

  inline float SimulatedAnnealingAgent::bestCost() const
  {
    return bestCost_;
  }

  inline int SimulatedAnnealingAgent::iterationCount() const
  {
    return iterationCount_;
  }

  inline int SimulatedAnnealingAgent::changeCount() const
  {
    return changeCount_;
  }

  inline int SimulatedAnnealingAgent::improvementCount() const
  {
    return improvementCount_;
  }

  inline int SimulatedAnnealingAgent::lastChange() const
  {
    return lastChange_;
  }

  inline int SimulatedAnnealingAgent::lastImprovement() const
  {
    return lastImprovement_;
  }

  inline void SimulatedAnnealingAgent::resetCurrent()
  {
    currentCost_ = bestCost_;
    currentState_ = bestState_;
    tempState_ = bestState_;
  }

} // namespace cws

#endif // CWS_SA_HPP_INCLUDED
