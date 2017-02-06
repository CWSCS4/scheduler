
// specification.hpp

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

#ifndef CWS_SPECIFICATION_HPP_INCLUDED
#define CWS_SPECIFICATION_HPP_INCLUDED

#include "array.hpp"

#include <utility>

namespace cws
{

  /**
   * Class `Specification' stores the scheduling constraints such that
   * they can be accessed efficiently by the scheduling mechanism.
   */

  class Specification
  {
  public:
    
    Specification(int participantCount,
                  int firstGroupCount,
                  int slotCount);

    Specification();

    /**
     * Returns the value of an additional conference between
     * participants `p1' and `p2', assuming `existingConferences'
     * conferences have already been scheduled between the two
     * participants.  `p1' and `p2' specify the index of a participant
     * in the first and second group, respectively.
     *
     * Pre-conditions:
     * 0 <= p1 < firstGroupCount()
     * 0 <= p2 < secondGroupCount()
     */
    int conferenceValue(int p1, int p2, int existingConferences) const;

    /**
     * Returns the maximum number of conferences between participants
     * `p1' and `p2' that have been requested.  `p1' and `p2' specify
     * the index of a participant in the first and second group,
     * respectively.
     *
     * Pre-conditions:
     * 0 <= p1 < firstGroupCount()
     * 0 <= p2 < secondGroupCount()
     */
    int maximumConferences(int p1, int p2) const;

    const Array<std::pair<int, Array<int> > > &
    conferenceCostList(int p1) const;

    typedef Array<std::pair<int, int> > ConferenceList;
    typedef Array<int> CompatibleSlotList;

    const Array<int> &validSlots(int p1) const;
    const Array<int> &compatibleSlots(int p1, int p2) const;
    bool validSlot(int participant, int slot) const;

    const ConferenceList &conferenceList(int participant) const;

    int maximumConsecutive(int p) const;

    int travelCost(int p1, int p2) const;
    
    int slotTime(int slot) const;

    int participantCount() const;
    int firstGroupCount() const;
    int secondGroupCount() const;
    int slotCount() const;

    int slotDuration() const;
    float conferenceValueWeight() const;
    float waitWeight() const;
    float unsatisfiedPreferenceWeight() const;
    float travelWeight() const;
    float consecutiveWeight() const;

    void setSlotDuration(int slotDuration);
    void setConferenceValueWeight(float weight);
    void setWaitWeight(float weight);
    void setUnsatisfiedPreferenceWeight(float weight);
    void setTravelWeight(float weight);
    void setConsecutiveWeight(float weight);

    Array<Array<int> > &validSlotData();
    Array<Array<int> > &conferenceValueData();
    Array<int> &travelCostData();
    Array<int> &slotTimeData();
    Array<int> &maximumConsecutiveData();
    void setSize(int participantCount, int firstGroupCount,
                 int slotCount);

    void createCache();
    void createConferenceLists();
    void createConferenceCostList();
    void createSlotDataCache();
    
  private:

    // 2-d: participantCount x participantCount
    // Access using: [p1 + p2 * participantCount]
    
    // The element at (p1, p2) is a list of compatible slot indices
    // for p1 and p2.
    Array<Array<int> > compatibleSlots_;

    // 2-d: participantCount x slotCount
    // Access using: [participant + slot * participantCount]

    // The element at (participant, slot) indicates whether `slot' is
    // valid for `participant'.

    Array<bool> validSlot_;

    // 1-d: participantCount

    // The elemnt at (participant) is a list of valid slots for the
    // participant.
    Array<Array<int> > validSlots_;

    // 1-d: participantCount
    
    // The element at (p) is a list of (participant, existingCount)
    // pairs.  The list is sorted by the value of the conference, with
    // the most valuable conference listed first.  `existingCount'
    // specifies the number of existing conferences with `participant'
    // for which this element applies.
    Array<ConferenceList> conferenceList_;

    // 2-d: firstGroupCount x secondGroupCount
    // Access using: [p1 + p2 * firstGroupCount]
    // (p1 in group one, p2 in group two)

    // The element at (p1, p2) is a list of conference values for each
    // number of existing conferences.  (p1, p2)[i] specifies the
    // value of an additional conference between p1 and p2, assuming
    // that there are already `i' conferences between p1 and p2.
    Array<Array<int> > conferenceValue_;

    // 1-d: firstGroupCount

    // conferenceCostList_[p1] is a list of pairs.  The first element
    // of each pair specifies the participant in the second group for
    // which the entry applies.  The second element is a list, where
    // conferenceCostList_[p1][j].second[c] specifies the cost of
    // having only `c' conferences between `p1' and
    // conferenceCostList_[p1][j].first.
    Array<Array<std::pair<int, Array<int> > > > conferenceCostList_;

    // 1-d: participantCount

    // The integer at (p) specifies the maximum number of consecutive
    // conferences to schedule for participant `p' before a cost
    // penalty is incurred.  0 indicates the lack of a limit.
    Array<int> maxConsecutive_;

    // 2-d: firstGroupCount x firstGroupCount
    // Access using: [p1 + p2 * firstGroupCount]
    // (p1 and p2 in group one)
    
    // The integer at (p1, p2) specifies the travel cost between p1's
    // room and p2's room.
    Array<int> travelCost_;

    // 1-d: slotCount

    // The integer at (slot) specifies the offset in seconds of the
    // beginning of slot `slot' since the beginning of the conference
    // sessions.  slotTime_[0] equals zero.
    Array<int> slotTime_;

    int slotDuration_;
    float conferenceValueWeight_;
    float waitWeight_;
    float unsatisfiedPreferenceWeight_;
    float travelWeight_;
    float consecutiveWeight_;
    
    int participantCount_;
    int slotCount_;
    int firstGroupCount_, secondGroupCount_;
    
  }; // class cws::Specification

  inline int Specification::conferenceValue
  (int p1, int p2, int existingConferences) const
  {
    return conferenceValue_[p1 + p2 * firstGroupCount_]
      [existingConferences];
  }

  inline int Specification::maximumConferences(int p1, int p2) const
  {
    return conferenceValue_[p1 + p2 * firstGroupCount_].size();
  }

  inline const Array<std::pair<int, Array<int> > > &
  Specification::conferenceCostList(int p1) const
  {
    return conferenceCostList_[p1];
  }

  inline const Array<int> &
  Specification::validSlots(int p) const
  {
    return validSlots_[p];
  }

  inline const Array<int> &
  Specification::compatibleSlots(int p1, int p2) const
  {
    return compatibleSlots_[p1 + p2 * participantCount_];
  }

  inline bool Specification::validSlot(int participant, int slot) const
  {
    return validSlot_[participant + slot * participantCount_];
  }

  inline const Specification::ConferenceList &
  Specification::conferenceList(int participant) const
  {
    return conferenceList_[participant];
  }

  inline int Specification::maximumConsecutive(int p) const
  {
    return maxConsecutive_[p];
  }

  inline int Specification::travelCost(int p1, int p2) const
  {
    return travelCost_[p1 + p2 * firstGroupCount_];
  }
  
  inline int Specification::slotTime(int slot) const
  {
    return slotTime_[slot];
  }

  inline int Specification::participantCount() const
  {
    return participantCount_;
  }

  inline int Specification::firstGroupCount() const
  {
    return firstGroupCount_;
  }

  inline int Specification::secondGroupCount() const
  {
    return secondGroupCount_;
  }

  inline int Specification::slotCount() const
  {
    return slotCount_;
  }

  inline int Specification::slotDuration() const
  {
    return slotDuration_;
  }

  inline float Specification::conferenceValueWeight() const
  {
    return conferenceValueWeight_;
  }
  
  inline float Specification::waitWeight() const
  {
    return waitWeight_;
  }

  inline float Specification::unsatisfiedPreferenceWeight() const
  {
    return unsatisfiedPreferenceWeight_;
  }
  
  inline float Specification::travelWeight() const
  {
    return travelWeight_;
  }

  inline float Specification::consecutiveWeight() const
  {
    return consecutiveWeight_;
  }

  inline void Specification::setSlotDuration(int slotDuration)
  {
    slotDuration_ = slotDuration;
  }

  inline void Specification::setConferenceValueWeight(float weight)
  {
    conferenceValueWeight_ = weight;
  }
  
  inline void Specification::setWaitWeight(float weight)
  {
    waitWeight_ = weight;
  }
  
  inline void Specification::setUnsatisfiedPreferenceWeight(float weight)
  {
    unsatisfiedPreferenceWeight_ = weight;
  }
  
  inline void Specification::setTravelWeight(float weight)
  {
    travelWeight_ = weight;
  }

  inline void Specification::setConsecutiveWeight(float weight)
  {
    consecutiveWeight_ = weight;
  }

  inline Array<Array<int> > &Specification::validSlotData()
  {
    return validSlots_;
  }
  
  inline Array<Array<int> > &Specification::conferenceValueData()
  {
    return conferenceValue_;
  }
  
  inline Array<int> &Specification::travelCostData()
  {
    return travelCost_;
  }

  inline Array<int> &Specification::slotTimeData()
  {
    return slotTime_;
  }

  inline Array<int> &Specification::maximumConsecutiveData()
  {
    return maxConsecutive_;
  }

} // namespace cws

#endif // CWS_SPECIFICATION_HPP_INCLUDED
