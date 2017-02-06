

// StoreConferences.java

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

import java.sql.ResultSet;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.Timestamp;
import java.sql.PreparedStatement;
import java.sql.Statement;
import java.util.*;
import java.io.InputStreamReader;

public final class StoreConferences
{

  public static void storeConferences(Connection connection,
                                      DatabaseSpecification dbSpec, State state)
    throws Exception
  {

    PreparedStatement stmt
      = connection.prepareStatement
      ("INSERT INTO conference (studentID, teacherID, start, end) VALUES (?, ?, ?, ?)");

    for (int p = dbSpec.teachers().size(); p < state.participantCount(); ++p)
    {
      for (int slot = state.firstSlot(p); slot <= state.lastSlot(p); ++slot)
      {
        int teacher = state.at(p, slot);
        if (teacher == -1)
          continue;

        stmt.setInt(1, dbSpec.students().get(p - dbSpec.teachers().size()));
        stmt.setInt(2, dbSpec.teachers().get(teacher).databaseID);
        Date start = dbSpec.timeSlots().get(slot)[0];
        Date end = dbSpec.timeSlots().get(slot)[1];

        stmt.setTimestamp(3, new Timestamp(start.getTime()), Calendar.getInstance(dbSpec.databaseTimeZone()));
        stmt.setTimestamp(4, new Timestamp(end.getTime()), Calendar.getInstance(dbSpec.databaseTimeZone()));

        stmt.executeUpdate();
      }
    }

    stmt.close();
  }

  public static void main(String[] args) throws Exception
  {
    if (args.length != 6)
    {
      System.err.println
        ("usage: java StoreConferences <databaseHost> <databaseName> \\\n"
         + "              <databaseUser> <databasePassword> \\\n"
         + "              <databaseTimeZone> <slotDuration>");
      System.exit(1);
      return;
    }

    String databaseHost = args[0], databaseName = args[1],
      databaseUser = args[2], databasePassword = args[3];
    TimeZone databaseTimeZone = TimeZone.getTimeZone(args[4]);
    int slotDuration = Integer.parseInt(args[5]);

    State state = new State();
    state.read(new TextDataReader(new InputStreamReader(System.in)));

    Connection connection
      = DatabaseSpecification.getDatabaseConnection(databaseHost, databaseName,
                                                    databaseUser, databasePassword);

    DatabaseSpecification dbSpec = new DatabaseSpecification(connection, databaseTimeZone,
                                                             slotDuration);

    storeConferences(connection, dbSpec, state);

    connection.close();
  }
}
