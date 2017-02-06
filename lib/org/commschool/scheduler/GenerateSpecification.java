
// GenerateSpecification.java

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

import java.sql.*;
import java.util.*;
import java.io.*;

public final class GenerateSpecification
{

  public static void main(String[] args) throws Exception
  {

    if (args.length != 17)
    {
      System.err.println
        ("usage: java StoreConferences <databaseHost> <databaseName> \\\n"
         + "              <databaseUser> <databasePassword> \\\n"
         + "              <databaseTimeZone> <slotDuration> \\\n"
         + "              <conferenceValueWeight> \\\n"
         + "              <waitWeight> \\\n"
         + "              <unsatisfiedPreferenceWeight> \\\n"
         + "              <travelWeight> \\\n"
         + "              <consecutiveWeight> \\\n"
         + "              <maximumConsecutiveForTeachers> \\\n"
         + "              <totalStudentPriority> \\\n"
         + "              <teacherPriorityFactor> \\\n"
         + "              <secondConferenceWeight> \\\n"
         + "              <floorUpFactor> \\\n"
         + "              <floorDownFactor>");
      System.exit(1);
      return;
    }

    String databaseHost = args[0], databaseName = args[1],
      databaseUser = args[2], databasePassword = args[3];
    TimeZone databaseTimeZone = TimeZone.getTimeZone(args[4]);
    int slotDuration = Integer.parseInt(args[5]);
    float conferenceValueWeight = Float.parseFloat(args[6]);
    float waitWeight = Float.parseFloat(args[7]);
    float unsatisfiedPreferenceWeight = Float.parseFloat(args[8]);
    float travelWeight = Float.parseFloat(args[9]);
    float consecutiveWeight = Float.parseFloat(args[10]);
    int maximumConsecutiveForTeachers = Integer.parseInt(args[11]);
    int totalStudentPriority = Integer.parseInt(args[12]);
    float teacherPriorityFactor = Float.parseFloat(args[13]);
    float secondConferenceWeight = Float.parseFloat(args[14]);
    float floorUpFactor = Float.parseFloat(args[15]);
    float floorDownFactor = Float.parseFloat(args[16]);

    Connection connection
      = DatabaseSpecification.getDatabaseConnection(databaseHost, databaseName,
                                                    databaseUser, databasePassword);

    DatabaseSpecification dbSpec = new DatabaseSpecification(connection, databaseTimeZone,
                                                             slotDuration);

    Specification spec
      = dbSpec.getSpecification(connection,
                                conferenceValueWeight,
                                waitWeight,
                                unsatisfiedPreferenceWeight,
                                travelWeight,
                                consecutiveWeight,
                                maximumConsecutiveForTeachers,
                                totalStudentPriority,
                                teacherPriorityFactor,
                                secondConferenceWeight,
                                floorUpFactor,
                                floorDownFactor);

    Writer writer = new OutputStreamWriter(System.out);
    spec.write(writer);
    writer.flush();
  }
}
