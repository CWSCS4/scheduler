
// schedule.hpp

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

#ifndef CWS_SCHEDULE_HPP_INCLUDED
#define CWS_SCHEDULE_HPP_INCLUDED

#include "state.hpp"
#include "specification.hpp"

namespace cws
{

  /**
   * Attempts to schedule a single conference for participant `p,'
   * with a primary criterium of maximinzing the value of the
   * conference.  The first available compatible slot is used.
   * Returns `true' if, and only if, a conference is scheduled.
   */
  bool scheduleConference(State &state,
                          const Specification &spec, int p);
  
  /**
   * Attempts to schedule a single conference for participant `p,'
   * with a primary criterium of maximizing the value of the
   * conference, and with a secondary criterium of minimizing the cost
   * due to waiting.  Returns `true' if, and only if, a conference is
   * scheduled.
   */
  bool scheduleConferenceOptimally(State &state,
                                   const Specification &spec, int p);

} // namespace cws

#endif // CWS_SCHEDULE_HPP_INCLUDED
