
// state.cpp

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

#include "state.hpp"
#include "specification.hpp"
#include <cstring>

namespace cws
{
  State::State(int participantCount, int slotCount)
    : participantCount_(participantCount),
      slotCount_(slotCount),
      dataRowSize_(slotCount + participantCount + 3)
  {
    data_ = new int[dataSize()];
    clear();
  }

  State::State(const Specification &spec)
    : participantCount_(spec.participantCount()),
      slotCount_(spec.slotCount()),
      dataRowSize_(spec.slotCount() + spec.participantCount() + 3)
  {
    data_ = new int[dataSize()];
    clear();
  }

  State::State(const State &s)
    : participantCount_(s.participantCount()),
      slotCount_(s.slotCount()),
      dataRowSize_(s.slotCount() + s.participantCount() + 3)
  {
    data_ = new int[dataSize()];
    std::memcpy(data_, s.data(), dataSize() * sizeof(int));
  }

  State &State::operator=(const State &s)
  {
    std::memcpy(data_, s.data(), dataSize() * sizeof(int));
    return *this;
  }

  State::~State()
  {
    delete[] data_;
  }

  void State::clear()
  {
    for (int p = 0; p < participantCount(); ++p)
    {
      firstSlot(p) = slotCount();
      lastSlot(p) = 0;
      count(p) = 0;
      for (int slot = 0; slot < slotCount(); ++slot)
        at(p, slot) = -1;
      for (int p2 = 0; p2 < participantCount(); ++p2)
        count(p, p2) = 0;
    }
  }

  State::State()
    : participantCount_(0),
      slotCount_(0),
      dataRowSize_(0),
      data_(0)
  {}
    
  void State::initialize(int participantCount, int slotCount)
  {
    delete[] data_;
    participantCount_ = participantCount;
    slotCount_ = slotCount;
    dataRowSize_ = slotCount_ + participantCount_ + 3;
    data_ = new int[dataSize()];
  }
  
} // namespace cws
