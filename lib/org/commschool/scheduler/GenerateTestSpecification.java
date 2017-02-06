
// GenerateTestSpecification.java

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

package org.commschool.scheduler;

import java.io.*;
import java.util.*;

public final class GenerateTestSpecification
{

  private static class ReverseComparator<T> implements Comparator<T>
  {
    private Comparator<T> base;
    public ReverseComparator(Comparator<T> base)
    {
      this.base = base;
    }

    public int compare(T o1, T o2)
    {
      return base.compare(o2, o1);
    }
  }

  private static class ComparableComparator<T extends Comparable>
    implements Comparator<T>
  {
    public int compare(T o1, T o2)
    {
      return o1.compareTo(o2);
    }
  }
  
  public static Specification createSpecification
  (int firstGroupCount, int secondGroupCount,
   int slotCount, int slotDuration,
   int minPreferences, int maxPreferences,
   float conferenceValueWeight,
   float waitWeight,
   float unsatisfiedPreferenceWeight)
  {
    int participantCount = firstGroupCount + secondGroupCount;
    Specification spec = new Specification(firstGroupCount
                                           + secondGroupCount,
                                           firstGroupCount,
                                           slotCount);

    Random r = new Random();

    spec.setSlotDuration(slotDuration);
    spec.setConferenceValueWeight(conferenceValueWeight);
    spec.setWaitWeight(waitWeight);
    spec.setUnsatisfiedPreferenceWeight(unsatisfiedPreferenceWeight);
    spec.setTravelWeight(0);

    for (int slot = 0; slot < slotCount; ++slot)
      spec.slotTimeData()[slot] = slot * slotDuration;

    for (int p = 0; p < participantCount; ++p)
    {
      spec.validSlotData()[p] = new int[slotCount];
      for (int i = 0; i < slotCount; ++i)
        spec.validSlotData()[p][i] = i;
    }

    for (int i = 0; i < firstGroupCount * firstGroupCount; ++i)
      spec.travelCostData()[i] = 0;

    for (int p = firstGroupCount; p < participantCount; ++p)
    {
      ArrayList<ArrayList<Integer> > values = new ArrayList<ArrayList<Integer> >();
      for (int i = 0; i < firstGroupCount; ++i)
        values.add(new ArrayList<Integer>());
      int preferenceCount = minPreferences
        + r.nextInt(maxPreferences - minPreferences + 1);
      int total = 0;
      for (int i = 0; i < preferenceCount; ++i)
      {
        int p2 = r.nextInt(firstGroupCount);
        int value = r.nextInt(10) + 1;
        total += value;
        values.get(p2).add(value);
      }

      for (int p2 = 0; p2 < firstGroupCount; ++p2)
      {
        Collections.sort(values.get(p2), new ReverseComparator<Integer>
                         (new ComparableComparator<Integer>()));
        int index = p2 + (p - firstGroupCount) * firstGroupCount;
        spec.conferenceValueData()[index]
          = new int[values.get(p2).size()];
        for (int i = 0; i < values.get(p2).size(); ++i)
        {
          int value = values.get(p2).get(i) * 100 / total;
          spec.conferenceValueData()[index][i] = value;
        }
      }
    }
    return spec;
  }

  public static void main(String[] args) throws Exception
  {
    if (args.length != 9)
    {
      System.err.println
        ("usage: java GenerateTestSpecification <firstGroupCount> \\\n"
         + "              <secondGroupCount> <slotCount> <slotDuration> \\\n"
         + "              <minPreferences> <maxPreferences> \\\n"
         + "              <conferenceValueWeight> <waitWeight> \\\n"
         + "              <unsatisfiedPreferenceWeight>");
      System.exit(1);
      return;
    }

    int firstGroupCount = Integer.parseInt(args[0]);
    int secondGroupCount = Integer.parseInt(args[1]);
    int slotCount = Integer.parseInt(args[2]);
    int slotDuration = Integer.parseInt(args[3]);
    int minPreferences = Integer.parseInt(args[4]);
    int maxPreferences = Integer.parseInt(args[5]);
    float conferenceValueWeight = Float.parseFloat(args[6]);
    float waitWeight = Float.parseFloat(args[7]);
    float unsatisfiedPreferenceWeight = Float.parseFloat(args[8]);

    Specification spec
      = createSpecification(firstGroupCount, secondGroupCount,
                            slotCount, slotDuration,
                            minPreferences, maxPreferences,
                            conferenceValueWeight,
                            waitWeight,
                            unsatisfiedPreferenceWeight);

    Writer writer = new OutputStreamWriter(System.out);
    spec.write(writer);
    writer.flush();
  }
}
