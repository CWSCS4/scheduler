
// GenerateSpecificationFromFileDB.java

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

import org.commschool.scheduler.db.Student;
import org.commschool.scheduler.db.Teacher;
import org.commschool.scheduler.db.TimeSlot;
import org.commschool.scheduler.db.Storer;
import org.commschool.scheduler.db.Storer_File;

import java.io.*;
import java.util.*;

public final class GenerateSpecificationFromFileDB
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
  (File dbPath, int slotDuration,
   float conferenceValueWeight,
   float waitWeight,
   float unsatisfiedPreferenceWeight,
   float consecutiveWeight,
   int maximumConsecutive) throws Exception
  {
    Storer storer = new Storer_File(dbPath);

    ArrayList<Student> students = new ArrayList<Student>();
    ArrayList<Teacher> teachers = new ArrayList<Teacher>();
    HashMap<String,Integer> teacherMap = new HashMap<String,Integer>();

    for (Iterator it = storer.getStudents(); it.hasNext(); )
    {
      Student s = (Student)it.next();
      students.add(s);
    }

    for (Iterator it = storer.getTeachers(); it.hasNext(); )
    {
      Teacher t = (Teacher)it.next();
      teacherMap.put(t.getName(), teachers.size());
      teachers.add(t);
    }

    ArrayList<TimeSlot> slots = new ArrayList<TimeSlot>();
    Date firstSlotDate = null;
    for (TimeSlot ts : storer.getTimeRanges())
    {
      Date d = ts.getStart();
      while (true)
      {
        Date next = new Date(d.getTime() + slotDuration * 1000l);
        if (next.after(ts.getFinish()))
          break;
        if (firstSlotDate == null)
          firstSlotDate = d;
        slots.add(new TimeSlot(d, next));
        d = next;
      }
    }

    int firstGroupCount = teachers.size();
    int secondGroupCount = students.size();
    int slotCount = slots.size();

    int participantCount = firstGroupCount + secondGroupCount;
    Specification spec = new Specification(firstGroupCount
                                           + secondGroupCount,
                                           firstGroupCount,
                                           slotCount);


    spec.setSlotDuration(slotDuration);
    spec.setConferenceValueWeight(conferenceValueWeight);
    spec.setWaitWeight(waitWeight);
    spec.setUnsatisfiedPreferenceWeight(unsatisfiedPreferenceWeight);
    spec.setTravelWeight(0);
    spec.setConsecutiveWeight(consecutiveWeight);

    for (int slot = 0; slot < slotCount; ++slot)
      spec.slotTimeData()[slot]
        = (int)((slots.get(slot).getStart().getTime()
                 - firstSlotDate.getTime()) / 1000l);

    for (int p = 0; p < firstGroupCount; ++p)
    {
      spec.maximumConsecutiveData()[p] = maximumConsecutive;
      ArrayList<Integer> validSlots = new ArrayList<Integer>();
      for (int i = 0; i < slotCount; ++i)
      {
        boolean valid = false;
        for (TimeSlot ts : teachers.get(p).getTimes())
        {
          if (ts.within(slots.get(i)))
          {
            valid = true;
            break;
          }
        }
        if (valid)
          validSlots.add(i);
      }
      spec.validSlotData()[p] = new int[validSlots.size()];
      for (int i = 0; i < validSlots.size(); ++i)
        spec.validSlotData()[p][i] = validSlots.get(i);
    }

    for (int p = firstGroupCount; p < participantCount; ++p)
    {
      ArrayList<Integer> validSlots = new ArrayList<Integer>();
      TimeSlot[] times = students.get(p - firstGroupCount).getTimes();
      for (int i = 0; i < slotCount; ++i)
      {
        boolean valid = false;
        for (TimeSlot ts : times)
        {
          if (ts.within(slots.get(i)))
          {
            valid = true;
            break;
          }
        }
        if (valid)
          validSlots.add(i);
      }
      spec.validSlotData()[p] = new int[validSlots.size()];
      for (int i = 0; i < validSlots.size(); ++i)
        spec.validSlotData()[p][i] = validSlots.get(i);
    }

    for (int i = 0; i < firstGroupCount * firstGroupCount; ++i)
      spec.travelCostData()[i] = 0;

    for (int p = firstGroupCount; p < participantCount; ++p)
    {
      spec.maximumConsecutiveData()[p] = 0;
      ArrayList<ArrayList<Integer> > values = new ArrayList<ArrayList<Integer> >();
      for (int i = 0; i < firstGroupCount; ++i)
        values.add(new ArrayList<Integer>());
      Student s = students.get(p - firstGroupCount);
      int total = 0;
      {
        int value = 10;
        for (Teacher t : s.getTeachers())
        {
          int p2 = teacherMap.get(t.getName());
          values.get(p2).add(value);
          total += value;
          if (value > 1)
            --value;
        }
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
    if (args.length != 7)
    {
      System.err.println
        ("usage: java GenerateSpecificationFromFileDB <dbPath> \\\n"
         + "              <slotDuration> \\\n"
         + "              <conferenceValueWeight> <waitWeight> \\\n"
         + "              <unsatisfiedPreferenceWeight> \\\n"
         + "              <consecutiveWeight> \\\n"
         + "              <maximumConsecutive>");
      System.exit(1);
      return;
    }

    File dbPath = new File(args[0]);
    int slotDuration = Integer.parseInt(args[1]);
    float conferenceValueWeight = Float.parseFloat(args[2]);
    float waitWeight = Float.parseFloat(args[3]);
    float unsatisfiedPreferenceWeight = Float.parseFloat(args[4]);
    float consecutiveWeight = Float.parseFloat(args[5]);
    int maximumConsecutive = Integer.parseInt(args[6]);

    Specification spec
      = createSpecification(dbPath, slotDuration,
                            conferenceValueWeight,
                            waitWeight,
                            unsatisfiedPreferenceWeight,
                            consecutiveWeight,
                            maximumConsecutive);

    Writer writer = new OutputStreamWriter(System.out);
    spec.write(writer);
    writer.flush();
  }
}
