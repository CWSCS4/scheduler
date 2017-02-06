
// diagnostics.hpp

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

#ifndef CWS_DIAGNOSTICS_HPP_INCLUDED
#define CWS_DIAGNOSTICS_HPP_INCLUDED

#include <iosfwd>

namespace cws
{

  class Specification;
  class State;

  std::ostream &printSchedule(std::ostream &out,
                              const State &state,
                              const Specification &spec);

  std::ostream &checkScheduleIntegrity(std::ostream &out,
                                       const State &state,
                                       const Specification &spec);

} // namespace cws

#endif // CWS_DIAGNOSTICS_HPP_INCLUDED
