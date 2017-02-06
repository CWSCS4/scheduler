
// neighbor.hpp

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

#ifndef CWS_NEIGHBOR_HPP_INCLUDED
#define CWS_NEIGHBOR_HPP_INCLUDED

#include "state.hpp"
#include "specification.hpp"

namespace cws
{

  /**
   * Attempts to replace `state' with a neighbor.  Heuristics are used
   * to attempt to increase the probability of picking a neighbor that
   * will be an improvement.  Returns `true' if, and only if, `state'
   * is changed to a neighboring state.
   */
  bool generateNeighbor(State &state, const Specification &spec);

  /**
   * Swaps the conferences for participant `p' at slot `slot1' and
   * slot `slot2'.  Conflicting conferences are initially removed from
   * the state.  An attempt is then made to schedule additional
   * conferences for each of the affected participants.
   */
  bool swapConferences(State &state, const Specification &spec,
                       int p, int slot1, int slot2);
  
} // namespace cws

#endif // CWS_NEIGHBOR_HPP_INCLUDED
