
// neighbor.cpp

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

#include "neighbor.hpp"
#include "schedule.hpp"

#include <cstdlib>

namespace cws
{

  bool generateNeighbor(State &state, const Specification &spec)
  {
    // If there are no participants, or no slots, fail
    if (state.participantCount() == 0)
      return false;

    // Pick a random participant
    int p = std::rand() % state.participantCount();

    // If participant `p' has no scheduled slots, fail
    int scheduledSlots = state.count(p);
    if (scheduledSlots == 0)
      return false;

    int slot1, slot2;

    // Select between a completely random swap and a swap with either
    // the first or last scheduled slot.  The heuristic cannot be used
    // if there is only one scheduled slot.
    int choice = std::rand() % 4;
    bool useHeuristic =
      (scheduledSlots > 1) && (choice < 2);
    
    if (useHeuristic)
    {
      int first = state.firstSlot(p);
      int last = state.lastSlot(p);
      int range = last - first;

      if (choice == 0)
      {
        slot1 = first;
        slot2 = last - std::rand() % range;
      } else
      {
        slot1 = last;
        slot2 = first + std::rand() % range;
      }

      // If either slot1 or slot2 is invalid for participant `p', fail
      if (!spec.validSlot(p, slot1) || !spec.validSlot(p, slot2))
        return false;
    } else
    {
      int i1 = std::rand() % spec.validSlots(p).size();
      int i2 = std::rand() % (spec.validSlots(p).size() - 1);

      if (i2 == i1)
        ++i2;

      slot1 = spec.validSlots(p)[i1];
      slot2 = spec.validSlots(p)[i2];
    }

    return swapConferences(state, spec, p, slot1, slot2);
  }

  bool swapConferences(State &state, const Specification &spec,
                       int p, int slot1, int slot2)
  {
    int pSlot1, pSlot2, pSlot1Slot2 = -1, pSlot2Slot1 = -1;

    pSlot1 = state.at(p, slot1);
    if (pSlot1 != -1)
    {
      // If `slot2' is not valid for `pSlot1', fail
      if (!spec.validSlot(pSlot1, slot2))
        return false;
    }

    pSlot2 = state.at(p, slot2);
    if (pSlot2 != -1)
    {
      // If `slot1' is not valid for `pSlot2', fail
      if (!spec.validSlot(pSlot2, slot1))
        return false;

      if (pSlot1 == pSlot2)
        return false;

      // Unschedule the conference `pSlot2' has scheduled at `slot1'
      pSlot2Slot1 = state.at(pSlot2, slot1);
      if (pSlot2Slot1 != -1)
      {
        state.removeHalf(pSlot2Slot1, pSlot2, slot1);
        state.removeOnly(pSlot2, pSlot2Slot1);
        state.removeSlot(pSlot2, slot2);
        state.at(pSlot2, slot1) = p;
      } else
      {
        state.addSlot(pSlot2, p, slot1);
        state.removeSlot(pSlot2, slot2);
      }

      // If nothing will be scheduled for p at slot2, update the slot
      // information for p
      if (pSlot1 == -1)
      {
        state.removeSlot(p, slot2);
        state.addSlot(p, slot1);
      }

      // Perform half of the swap
      state.at(p, slot1) = pSlot2;

    } else if (pSlot1 == -1)
    {
      // If both `slot1' and `slot2' are unscheduled for `p', fail
      return false;
    }

    if (pSlot1 != -1)
    {
      // Unschedule the conference `pSlot1' has scheduled at `slot2'
      pSlot1Slot2 = state.at(pSlot1, slot2);
      if (pSlot1Slot2 != -1)
      {
        state.removeHalf(pSlot1Slot2, pSlot1, slot2);
        state.removeOnly(pSlot1, pSlot1Slot2);
        state.removeSlot(pSlot1, slot1);
        state.at(pSlot1, slot2) = p;
      } else
      {
        state.addSlot(pSlot1, p, slot2);
        state.removeSlot(pSlot1, slot1);
      }

      // If nothing will be scheduled for p at slot1, update the slot
      // information for p
      if (pSlot2 == -1)
      {
        state.removeSlot(p, slot1);
        state.addSlot(p, slot2);
      }

      // Perform half of the swap
      state.at(p, slot2) = pSlot1;      
    }

    // Attempt to schedule additional conferences for the maximum of 4
    // affected participants

    /*
      Emacs Lisp code to generate various permutations of orderings,
      not used
      
(let ((count 0))
  (flet ((do-permutation
          (seq cur fun)
          (if seq
              (dolist (x seq)
                (do-permutation (remove x seq)
                                (append cur (list x))
                                fun))
            (funcall fun cur)))
         (do-try
          (x)
          (if (not (string= x "p"))
              (insert "if (" x "!= -1)\n"))
          (insert "scheduleConferenceOptimally(state, spec, " x ");\n"))
         (do-case
          (seq)
            (insert "case " (int-to-string count) ":\n")
            (incf count)
            (dolist (x seq)
              (do-try x)
              (insert "\n"))
            (insert "break;\n")))
    (let ((prev (point)))
      (do-permutation '("p" "pSlot1" "pSlot2"
                        "pSlot1Slot2" "pSlot2Slot1")
                      nil 'do-case)
      (indent-region prev (point)))))
      
     */


    if (pSlot1 != -1)
      scheduleConferenceOptimally(state, spec, pSlot1);

    if (pSlot2 != -1)
      scheduleConferenceOptimally(state, spec, pSlot2);

    if (pSlot1Slot2 != -1)
      scheduleConferenceOptimally(state, spec, pSlot1Slot2);

    if (pSlot2Slot1 != -1)
      scheduleConferenceOptimally(state, spec, pSlot2Slot1);

    scheduleConferenceOptimally(state, spec, p);

    return true;
  }

} // namespace cws
