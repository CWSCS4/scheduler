
// Specification.java

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

public final class Specification
{
  private int slotDuration;
  private float conferenceValueWeight;
  private float waitWeight;
  private float unsatisfiedPreferenceWeight;
  private float travelWeight;
  private float consecutiveWeight;
    
  private int participantCount;
  private int slotCount;
  private int firstGroupCount, secondGroupCount;

  private int[][] validSlots;
  private int[][] conferenceValue;
  private int[] travelCost;
  private int[] slotTime;
  private int[] maxConsecutive;

  public Specification(int participantCount,
                       int firstGroupCount,
                       int slotCount)
  {
    setSize(participantCount, firstGroupCount, slotCount);
  }

  public Specification() {}

  public int conferenceValue(int p1, int p2, int existingConferences)
  {
    return conferenceValue[p1 + p2 * firstGroupCount()]
      [existingConferences];
  }

  public int maximumConferences(int p1, int p2)
  {
    return conferenceValue[p1 + p2 * firstGroupCount()].length;
  }

  public int maximumConsecutive(int p)
  {
    return maxConsecutive[p];
  }

  public int[] validSlots(int p1)
  {
    return validSlots[p1];
  }

  public int travelCost(int p1, int p2)
  {
    return travelCost[p1 + p2 * firstGroupCount()];
  }

  public int slotTime(int slot)
  {
    return slotTime[slot];
  }

  public int[][] validSlotData() {return validSlots;}
  public int[][] conferenceValueData() {return conferenceValue;}
  public int[] travelCostData() {return travelCost;}
  public int[] maximumConsecutiveData() {return maxConsecutive;}
  public int[] slotTimeData() {return slotTime;}

  public void setSize(int participantCount,
                      int firstGroupCount,
                      int slotCount)
  {
    this.participantCount = participantCount;
    this.firstGroupCount = firstGroupCount;
    this.secondGroupCount = participantCount - firstGroupCount;
    this.slotCount = slotCount;

    validSlots = new int[participantCount][];
    conferenceValue = new int[firstGroupCount * secondGroupCount][];
    travelCost = new int[firstGroupCount * firstGroupCount];
    slotTime = new int[slotCount];
    maxConsecutive = new int[participantCount];
  }

  public int participantCount() {return participantCount;}
  public int firstGroupCount() {return firstGroupCount;}
  public int secondGroupCount() {return secondGroupCount;}
  public int slotCount() {return slotCount;}
  public int slotDuration() {return slotDuration;}
  public float conferenceValueWeight() {return conferenceValueWeight;}
  public float waitWeight() {return waitWeight;}
  public float unsatisfiedPreferenceWeight() {return unsatisfiedPreferenceWeight;}
  public float travelWeight() {return travelWeight;}
  public float consecutiveWeight() {return consecutiveWeight;}

  public void setSlotDuration(int slotDuration)
  {
    this.slotDuration = slotDuration;
  }

  public void setConferenceValueWeight(float conferenceValueWeight)
  {
    this.conferenceValueWeight = conferenceValueWeight;
  }

  public void setWaitWeight(float waitWeight)
  {
    this.waitWeight = waitWeight;
  }

  public void setUnsatisfiedPreferenceWeight(float unsatisfiedPreferenceWeight)
  {
    this.unsatisfiedPreferenceWeight = unsatisfiedPreferenceWeight;
  }

  public void setTravelWeight(float travelWeight)
  {
    this.travelWeight = travelWeight;
  }

  public void setConsecutiveWeight(float consecutiveWeight)
  {
    this.consecutiveWeight = consecutiveWeight;
  }

  public void write(Writer writer) throws IOException
  {
    // Write general parameters
    writer.write(String.valueOf(participantCount));
    writer.write(' ');
    writer.write(String.valueOf(firstGroupCount));
    writer.write(' ');
    writer.write(String.valueOf(slotCount));
    writer.write(' ');
    writer.write(String.valueOf(slotDuration));
    writer.write(' ');
    writer.write(String.valueOf(conferenceValueWeight));
    writer.write(' ');
    writer.write(String.valueOf(waitWeight));
    writer.write(' ');
    writer.write(String.valueOf(unsatisfiedPreferenceWeight));
    writer.write(' ');
    writer.write(String.valueOf(travelWeight));
    writer.write(' ');
    writer.write(String.valueOf(consecutiveWeight));
    writer.write('\n');

    // Write slotTimeData
    for (int i = 0; i < slotCount; ++i)
    {
      if (i != 0)
        writer.write(' ');
      writer.write(String.valueOf(slotTime(i)));
    }
    writer.write('\n');

    // Write travelCostData
    for (int p1 = 0; p1 < firstGroupCount(); ++p1)
    {
      for (int p2 = 0; p2 < firstGroupCount(); ++p2)
      {
        if (p1 != 0 || p2 != 0)
          writer.write(' ');
        writer.write(String.valueOf(travelCost(p2, p1)));
      }
    }
    writer.write('\n');

    // Write maximumConsecutiveData
    for (int p = 0; p < participantCount(); ++p)
    {
      if (p != 0)
        writer.write(' ');
      writer.write(String.valueOf(maximumConsecutive(p)));
    }
    writer.write('\n');

    // Write validSlotData
    for (int p = 0; p < participantCount(); ++p)
    {
      writer.write(String.valueOf(validSlots(p).length));
      for (int i = 0; i < validSlots(p).length; ++i)
      {
        writer.write(' ');
        writer.write(String.valueOf(validSlots(p)[i]));
      }
      writer.write('\n');
    }

    // Write conferenceValueData
    for (int p2 = 0; p2 < secondGroupCount(); ++p2)
    {
      for (int p1 = 0; p1 < firstGroupCount(); ++p1)
      {
        if (p1 != 0)
          writer.write("  ");
        writer.write(String.valueOf(maximumConferences(p1, p2)));
        for (int i = 0; i < maximumConferences(p1, p2); ++i)
        {
          writer.write(' ');
          writer.write(String.valueOf(conferenceValue(p1, p2, i)));
        }
      }
      writer.write('\n');
    }
  }

  public void read(TextDataReader reader) throws IOException
  {
    int participantCount, firstGroupCount, slotCount;
    int slotDuration;
    float conferenceValueWeight, waitWeight,
      unsatisfiedPreferenceWeight, travelWeight, consecutiveWeight;

    participantCount = reader.readInt();
    firstGroupCount = reader.readInt();
    slotCount = reader.readInt();
    slotDuration = reader.readInt();
    conferenceValueWeight = reader.readFloat();
    waitWeight = reader.readFloat();
    unsatisfiedPreferenceWeight = reader.readFloat();
    travelWeight = reader.readFloat();
    consecutiveWeight = reader.readFloat();

    if (participantCount < 0
        || firstGroupCount < 0
        || firstGroupCount < participantCount
        || slotDuration < 0
        || conferenceValueWeight < 0
        || waitWeight < 0
        || unsatisfiedPreferenceWeight < 0
        || travelWeight < 0
        || consecutiveWeight < 0)
    {
      throw new IOException("Integrity check failed");
    }

    setSize(participantCount, firstGroupCount, slotCount);
    setSlotDuration(slotDuration);
    setConferenceValueWeight(conferenceValueWeight);
    setWaitWeight(waitWeight);
    setUnsatisfiedPreferenceWeight(unsatisfiedPreferenceWeight);
    setTravelWeight(travelWeight);
    setConsecutiveWeight(consecutiveWeight);
    
    // Read slotTimeData
    for (int i = 0; i < slotCount; ++i)
    {
      slotTime[i] = reader.readInt();
    }

    // Read travelCostData
    for (int i = 0;
         i < firstGroupCount() * secondGroupCount();
         ++i)
    {
      int value = reader.readInt();
      if (value < 0)
      {
        throw new IOException("Invalid travel cost: " + value);
      }
      travelCost[i] = value;
    }

    // Read maximumConsecutiveData
    for (int p = 0; p < participantCount(); ++p)
    {
      int value = reader.readInt();
      if (value < 0)
        throw new IOException("Invalid maximum number of consecutive conferences: " + value);
      maxConsecutive[p] = value;
    }

    // Read validSlotData
    for (int p = 0; p < participantCount(); ++p)
    {
      int length = reader.readInt();;
      if (length < 0)
      {
        throw new IOException("Invalid length: " + length);
      }
      
      validSlots[p] = new int[length];

      for (int i = 0; i < length; ++i)
      {
        int value = reader.readInt();
        if (value < 0 || value >= slotCount)
          throw new IOException("Invalid slot: " + value);
        validSlots[p][i] = value;
      }
    }

    // Read conferenceValueData
    for (int i = 0;
         i < firstGroupCount() * secondGroupCount();
         ++i)
    {
      int length = reader.readInt();;
      if (length < 0)
      {
        throw new IOException("Invalid length: " + length);
      }
      
      conferenceValue[i] = new int[length];

      for (int j = 0; i < length; ++j)
      {
        int value = reader.readInt();
        if (value < 0)
        {
          throw new IOException("Invalid value: " + value);
        }
        conferenceValue[i][j] = value;
      }
    }
  }

  
}
