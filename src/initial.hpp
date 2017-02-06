
// initial.hpp

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

#ifndef CWS_INITIAL_HPP_INCLUDED
#define CWS_INITIAL_HPP_INCLUDED

#include "state.hpp"
#include "specification.hpp"

namespace cws
{

  void generateInitialSchedule(State &state,
                               const Specification &spec);
  
} // namespace cws

#endif // CWS_INITIAL_HPP_INCLUDED
