
// State.java

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

public final class State
{
  private int participantCount, slotCount, dataRowSize;
  private int[] data;

  public State() {}

  public State(int participantCount, int slotCount)
  {
    initialize(participantCount, slotCount);
  }

  public State(Specification spec)
  {
    this(spec.participantCount(), spec.slotCount());
  }

  public void initialize(int participantCount, int slotCount)
  {
    this.participantCount = participantCount;
    this.slotCount = slotCount;
    this.dataRowSize = slotCount + participantCount + 3;
    data = new int[dataSize()];
  }

  public int participantCount() {return participantCount;}
  public int slotCount() {return slotCount;}
  public int dataRowSize() {return dataRowSize;}
  public int dataSize() {return dataRowSize * participantCount;}
  public int[] data() {return data;}

  public int firstSlot(int p)
  {
    return data[dataRowSize() * p];
  }

  public int lastSlot(int p)
  {
    return data[dataRowSize() * p + 1];
  }

  public int count(int p)
  {
    return data[dataRowSize() * p + 2];
  }

  public int at(int p, int slot)
  {
    return data[dataRowSize() * p + 3 + slot];
  }

  public boolean available(int p1, int p2, int slot)
  {
    return at(p1, slot) == -1 && at(p2, slot) == -1;
  }

  public int count(int p1, int p2)
  {
    return data[dataRowSize() * p1 + 3 + slotCount() + p2];
  }

  public void write(Writer writer) throws IOException
  {
    writer.write(String.valueOf(participantCount));
    writer.write(' ');
    writer.write(String.valueOf(slotCount));
    writer.write(' ');

    for (int i = 0; i < dataSize(); ++i)
    {
      if (i != 0)
        writer.write(' ');
      writer.write(String.valueOf(data[i]));
    }
    writer.write('\n');
  }

  public void read(TextDataReader reader) throws IOException
  {
    int participantCount, slotCount;
    participantCount = reader.readInt();
    slotCount = reader.readInt();
    if (slotCount < 0 || participantCount < 0)
      throw new IOException("Integrity check failed");

    initialize(participantCount, slotCount);

    for (int i = 0; i < dataSize(); ++i)
    {
      data[i] = reader.readInt();
    }
  }
}
