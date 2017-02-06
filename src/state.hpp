
// state.hpp

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

#ifndef CWS_STATE_HPP_INCLUDED
#define CWS_STATE_HPP_INCLUDED

namespace cws
{

  class Specification; // forward declare

  /**
   * Class `State' represents a possibly sub-optimal/intermediate
   * solution state.
   */
  class State
  {
  public:

    /**
     * Constructs a representation of a state without any scheduled
     * conferences.  `participantCount' and `slotCount' specify the
     * number of participants and time slots for the constructed state
     * to support.
     *
     * Pre-conditions:
     * participantCount >= 0
     * slotCount >= 0
     *
     * Post-conditions:
     * this->participantCount() == participantCount
     * this->slotCount() == slotCount
     */
    State(int participantCount, int slotCount);

    /**
     * Constructs a representation of a state without any scheduled
     * conferences, suitable for use with the specification `spec'.
     *
     * Post-conditions:
     * this->participantCount() == spec.participantCount()
     * this->slotCount() == spec.slotCount()
     */
    State(const Specification &spec);

    /**
     * Copy constructor
     */
    State(const State &s);
    
    State();

    void initialize(int participantCount, int slotCount);

    /**
     * Sets this equal to `s'.
     *
     * Pre-conditions:
     * participantCount() == s.participantCount()
     * slotCount() == s.slotCount()
     */
    State &operator=(const State &s);

    /**
     * Destructor
     */
    ~State();

    /**
     * Clears the state
     */
    void clear();

    /**
     * Returns the number of participants supported by this state
     * representation.
     */
    int participantCount() const;

    /**
     * Returns the number of time slots supported by this state
     * representation.
     */
    int slotCount() const;

    /**
     * Returns the index of the first slot filled in the schedule of
     * participant `p'.
     */

    int firstSlot(int p) const;

    /**
     * Returns a reference to the index of the first slot filled in
     * the schedule of participant `p'.
     */
    int &firstSlot(int p);

    /**
     * Returns the index of the first slot last in the schedule of
     * participant `p'.
     */
    int lastSlot(int p) const;

    /**
     * Returns a reference to the index of the last slot filled in
     * the schedule of participant `p'.
     */
    int &lastSlot(int p);

    /**
     * Returns true if, and only if, slot `slot' is available in the
     * schedules of both participants `p1' and `p2'.
     *
     * Pre-conditions:
     * 0 <= p1 < participantCount()
     * 0 <= p2 < participantCount()
     * 0 <= slot <= slotCount()
     */
    bool available(int p1, int p2, int slot) const;

    /**
     * If `p' is scheduled for a conference at time slot `slot', the
     * other participant in the conference is returned.  Otherwise, -1
     * is returned.
     *
     * Pre-conditions:
     * 0 <= p < participantCount()
     * 0 <= slot <= slotCount()
     */
    int at(int p, int slot) const;

    /**
     * A reference to the participant with whom `p' is scheduled for a
     * conference at time slot `slot' is returned.  A referenced
     * value of -1 indicates that no conference is scheduled at that
     * time slot for `p'.
     *
     * Pre-conditions:
     * 0 <= p < participantCount()
     * 0 <= slot < slotCount()
     */
    int &at(int p, int slot);

    /**
     * The number of conferences involving both participants `p1' and
     * `p2' is returned.
     *
     * Pre-conditions:
     * 0 <= p1 < participantCount()
     * 0 <= p2 < participantCount()
     */
    int count(int p1, int p2) const;

    /**
     * A reference to the number of conferences involving both
     * participants `p1' and `p2' is returned.
     *
     * Pre-conditions:
     * 0 <= p1 < participantCount()
     * 0 <= p2 < participantCount()
     */
    int &count(int p1, int p2);

    /**
     * The number of conferences involving participant `p' is
     * returned.
     *
     * Pre-conditions:
     * 0 <= p < participantCount()
     */
    int count(int p) const;

    /**
     * A reference to the number of conferences involving participant
     * `p' is returned.
     *
     * Pre-conditions:
     * 0 <= p < participantCount()
     */
    int &count(int p);

    /**
     * Adds a conference between `p1' and `p2' at time slot `slot' to
     * the state.
     *
     * Pre-conditions:
     * 0 <= p1 < participantCount()
     * 0 <= p2 < participantCount()
     * 0 <= slot < participantCount()
     * p1 != p2
     */
    void add(int p1, int p2, int slot);

    /**
     * Updates the slot information for `p' to reflect a conference
     * added to slot `slot'.  Only the stored first and last slot
     * indices are modified.
     */
    void addSlot(int p, int slot);
    
    /**
     * Updates the slot information for `p1' to reflect a conference
     * with `p2' added to slot `slot'.
     */
    void addSlot(int p1, int p2, int slot);

    /**
     * Removes a conference between `p1' and `p2' at time slot `slot',
     * but only from the perspective of `p1', and slot information,
     * including firstSlot, lastSlot are not changed.
     */
    void removeOnly(int p1, int p2);

    /**
     * Updates the slot information for `p' to reflect a conference
     * removed from slot `slot'.
     */
    void removeSlot(int p, int slot);

    /**
     * Removes a conference between `p1' and `p2' at time slot
     * `slot', but only from the perspective of `p1'.
     *
     * Pre-conditions:
     * 0 <= p1 < participantCount()
     * 0 <= p2 < participantCount()
     * 0 <= slot < participantCount()
     * p1 != p2
     */
    void removeHalf(int p1, int p2, int slot);

    /**
     * Removes a conference between `p1' and `p2' at time slot `slot'
     * from the state.  This is equivalent to:
     * removeHalf(p1, p2, slot);
     * removeHalf(p2, p1, slot);
     *
     * Pre-conditions:
     * 0 <= p1 < participantCount()
     * 0 <= p2 < participantCount()
     * 0 <= slot < participantCount()
     * p1 != p2
     */
    void remove(int p1, int p2, int slot);

    /**
     * Returns the number of integers per row in the interal
     * integer-array representation.  There is one row per
     * participant, and each row stores the conference scheduled in
     * each time slot for the participant, the indices of the first
     * and last filled slot, the number of conferences sheduled for
     * the participant, and the number of conferences scheduled with
     * each other participant.  This is equal to: participantCount() +
     * slotCount() + 3
     */
    int dataRowSize() const;

    /**
     * Returns the number of integers in the internal integer-array
     * representation.  This is equal to:
     * participantCount() * dataRowSize()
     */
    int dataSize() const;

    /**
     * Returns the interal integer-array representation.  This
     * representation can be serialized.  The state is represented
     * internally in rows, with one row per participant.  The first
     * two elements in each row specify the first and last filled
     * slot.  The third element specifies the number of conferences
     * scheduled for the participant.  The following slotCount()
     * elements in each row specify which conferences are scheduled in
     * each time slot for the participant.  The remaining
     * participantCount() elements specify the number of conferences
     * scheduled with each other participant.
     */
    const int *data() const;

    int *data();
    
  private:
    int *data_;
    int participantCount_;
    int slotCount_;
    int dataRowSize_;
  }; // class cws::State

  inline int State::participantCount() const
  {
    return participantCount_;
  }

  inline int State::slotCount() const
  {
    return slotCount_;
  }

  inline int State::firstSlot(int p) const
  {
    return data_[dataRowSize() * p];
  }

  inline int &State::firstSlot(int p)
  {
    return data_[dataRowSize() * p];
  }

  inline int State::lastSlot(int p) const
  {
    return data_[dataRowSize() * p + 1];
  }

  inline int &State::lastSlot(int p)
  {
    return data_[dataRowSize() * p + 1];
  }

  inline bool State::available(int p1, int p2, int slot) const
  {
    return at(p1, slot) == -1 && at(p2, slot) == -1;
  }

  inline int State::at(int p, int slot) const
  {
    return data_[dataRowSize() * p + 3 + slot];
  }

  inline int &State::at(int p, int slot)
  {
    return data_[dataRowSize() * p + 3 + slot];
  }

  inline int State::count(int p) const
  {
    return data_[dataRowSize() * p + 2];
  }

  inline int &State::count(int p)
  {
    return data_[dataRowSize() * p + 2];
  }

  inline int State::count(int p1, int p2) const
  {
    return data_[dataRowSize() * p1 + 3 + slotCount() + p2];
  }

  inline int &State::count(int p1, int p2)
  {
    return data_[dataRowSize() * p1 + 3 + slotCount() + p2];
  }

  inline void State::add(int p1, int p2, int slot)
  {
    addSlot(p1, p2, slot);
    addSlot(p2, p1, slot);
    
    ++(count(p1));
    ++(count(p2));
    ++(count(p1, p2));
    ++(count(p2, p1));
  }

  inline void State::addSlot(int p, int slot)
  {
    if (firstSlot(p) > slot) firstSlot(p) = slot;
    if (lastSlot(p) < slot) lastSlot(p) = slot;
  }

  inline void State::addSlot(int p1, int p2, int slot)
  {
    at(p1, slot) = p2;
    addSlot(p1, slot);
  }

  inline void State::removeOnly(int p1, int p2)
  {
    --(count(p1, p2));
    --(count(p1));
  }

  inline void State::removeSlot(int p, int slot)
  {
    at(p, slot) = -1;
    
    int first = firstSlot(p);
    if (first == slot)
    {
      while (++first < slotCount())
        if (at(p, first) != -1)
          break;
      firstSlot(p) = first;
    }

    int last = lastSlot(p);
    if (last == slot)
    {
      while (--last >= 0)
        if (at(p, last) != -1)
          break;
      lastSlot(p) = last;
    }
  }

  inline void State::removeHalf(int p1, int p2, int slot)
  {
    removeOnly(p1, p2);
    removeSlot(p1, slot);
  }

  inline void State::remove(int p1, int p2, int slot)
  {
    removeHalf(p1, p2, slot);
    removeHalf(p2, p1, slot);
  }

  inline int State::dataSize() const
  {
    return participantCount_ * dataRowSize_;
  }

  inline int State::dataRowSize() const
  {
    return dataRowSize_;
  }

  inline const int *State::data() const
  {
    return data_;
  }

  inline int *State::data()
  {
    return data_;
  }
  
} // namespace cws

#endif // CWS_STATE_HPP_INCLUDED
