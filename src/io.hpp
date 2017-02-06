
// io.hpp

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

#ifndef CWS_IO_HPP_INCLUDED
#define CWS_IO_HPP_INCLUDED

#include <iosfwd>

namespace cws
{

  class Specification;
  class State;

  std::istream &readSpecification(std::istream &in, Specification &spec);

  /**
   * Writes `spec' to `out' in text format.
   *
   * Format:
   *
   * General parameters:
   * participantCount firstGroupCount slotCount
   * slotDuration conferenceValueWeight waitWeight \
   * unsatisfiedPreferenceWeight travelWeight
   *
   * slotTimeData (list of ints of length slotCount)
   *
   * travelCostData (list of ints of length firstGroupCount *
   * firstGroupCount, accessed using [p1 + p2 * firstGroupCount])
   *
   * validSlotData (list of length participantCount, each element
   * begins with an integer specifying the number of elements in the
   * list, followed by a list of integers)
   *
   * conferenceValueData (list of length firstGroupCount *
   * secondGroupCount, accessed using [p1 + p2 * firstGroupCount],
   * each element begins with an integer specifying the number of
   * elements in the list, followe by a list of integers)
   *
   */
  std::ostream &writeSpecification(std::ostream &out, const Specification &spec);

  std::istream &readState(std::istream &in, State &state);

  /**
   * Writes `state' to `out' in text format.
   *
   * Format:
   *
   * General parameters:
   * participantCount slotCount
   *
   * data (list of ints of length dataSize)
   */
  std::ostream &writeState(std::ostream &out, const State &state);
  
} // namespace cws

#endif // CWS_IO_HPP_INCLUDED
