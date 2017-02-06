
// DatabaseSpecification.java

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

public final class DatabaseSpecification
{

  private static int guessRoomFloor(String room) {
    if (room == null)
      return -1;
    room = room.toLowerCase();
    if (room.indexOf("basement") != -1)
      return 0;
    if (room.indexOf('1') != -1 || room.indexOf("first") != -1)
      return 1;
    if (room.indexOf('2') != -1 || room.indexOf("second") != -1)
      return 2;
    if (room.indexOf('3') != -1 || room.indexOf("third") != -1)
      return 3;
    if (room.indexOf('4') != -1 || room.indexOf("fourth") != -1)
      return 4;
    if (room.indexOf('5') != -1 || room.indexOf("fifth") != -1)
      return 5;
    return -1;
  }

  public static class Teacher
  {
    public int roomFloor;
    public String room;
    public int databaseID;
    public int schedulerID;

    public Teacher(int databaseID, int schedulerID, String room) {
      this.databaseID = databaseID;
      this.schedulerID = schedulerID;
      this.room = room;
      this.roomFloor = guessRoomFloor(room);
    }
  }

  private HashMap<Integer,Teacher> teacherMap;
  private HashMap<Integer,Integer> studentMap;

  public HashMap<Integer,Teacher> teacherMap() { return teacherMap; }
  public HashMap<Integer,Integer> studentMap() { return studentMap; }
  private ArrayList<Teacher> teachers;
  private ArrayList<Integer> students;

  public ArrayList<Integer> students() { return students; }
  public ArrayList<Teacher> teachers() { return teachers; }


  private ArrayList<Date[]> timeSlots;

  public ArrayList<Date[]> timeSlots()
  {
    return timeSlots;
  }

  private static class TeacherPriority
  {
    public TeacherPriority(int studentPriority, int maxConferences)
    {
      this.studentPriority = studentPriority;
      this.maxConferences = maxConferences;
    }
    
    public int studentPriority, teacherPriority;
    public int maxConferences;
  }

  public static Connection getDatabaseConnection(String host, String databaseName,
                                                 String userName, String password)
    throws Exception
  {
    Class.forName("com.mysql.jdbc.Driver");

    String jdbcURL = "jdbc:mysql://" + host + "/" + databaseName;

    return DriverManager.getConnection(jdbcURL, userName, password);
  }

  private TimeZone databaseTimeZone;
  private int slotDuration;

  public int slotDuration() { return slotDuration; }

  public TimeZone databaseTimeZone() { return databaseTimeZone; }

  public DatabaseSpecification(Connection connection,
                               TimeZone databaseTimeZone,
                               int slotDuration)
    throws Exception
  {

    this.slotDuration = slotDuration;
    this.databaseTimeZone = databaseTimeZone;

    // Generate the slots
    timeSlots = new ArrayList<Date[]>();
    {
      PreparedStatement stmt = connection.prepareStatement
        ("SELECT start, end FROM conferencePeriod ORDER BY start");
      ResultSet rs = stmt.executeQuery();

      while (rs.next())
      {
        Date start = rs.getTimestamp(1, Calendar.getInstance(databaseTimeZone));
        Date end = rs.getTimestamp(2, Calendar.getInstance(databaseTimeZone));
        Date d = start;
        while (true) {
          Date next = new Date(d.getTime() + slotDuration * 1000l);
          if (next.after(end))
            break;
          timeSlots.add(new Date[]{d, next});
          d = next;
        }
      }

      stmt.close();
    }

    teacherMap = new HashMap<Integer,Teacher>();
    teachers = new ArrayList<Teacher>();
    {
      PreparedStatement stmt = connection.prepareStatement
        ("SELECT teacherID, room FROM teachers");
      ResultSet rs = stmt.executeQuery();
      while (rs.next())
      {
        int databaseID = rs.getInt(1);
        String room = rs.getString(2);

        int schedulerID = teachers.size();

        Teacher t = new Teacher(databaseID, schedulerID, room);
        teachers.add(t);
        teacherMap.put(databaseID, t);
      }

      stmt.close();
    }

    studentMap = new HashMap<Integer,Integer>();
    students = new ArrayList<Integer>();
      
    {
      PreparedStatement stmt = connection.prepareStatement
        ("SELECT studentID FROM students");
      ResultSet rs = stmt.executeQuery();
      while (rs.next())
      {
        int databaseID = rs.getInt(1);
        int schedulerID = teachers.size() + students.size();
        studentMap.put(databaseID, schedulerID);
        students.add(databaseID);
      }
    }
  }
  
  public Specification getSpecification(Connection connection,
                                        float conferenceValueWeight,
                                        float waitWeight,
                                        float unsatisfiedPreferenceWeight,
                                        float travelWeight,
                                        float consecutiveWeight,
                                        int maximumConsecutiveForTeachers,
                                        int totalStudentPriority,
                                        float teacherPriorityFactor,
                                        float secondConferenceWeight,
                                        float floorUpFactor,
                                        float floorDownFactor)
    throws Exception
  {
    Specification specification
      = new Specification(students.size() + teachers.size(),
                          teachers.size(),
                          timeSlots.size());

    specification.setSlotDuration(slotDuration);
    specification.setConferenceValueWeight(conferenceValueWeight);
    specification.setWaitWeight(waitWeight);
    specification.setUnsatisfiedPreferenceWeight(unsatisfiedPreferenceWeight);
    specification.setTravelWeight(travelWeight);
    specification.setConsecutiveWeight(consecutiveWeight);

    for (int i = 0; i < timeSlots.size(); ++i)
    {
      specification.slotTimeData()[i]
        = (int)((timeSlots.get(i)[0].getTime() - timeSlots.get(0)[0].getTime())
                / 1000l);
    }

    for (int i = 0; i < teachers.size(); ++i)
    {
      specification.maximumConsecutiveData()[i]
        = maximumConsecutiveForTeachers;

      for (int j = 0; j < teachers.size(); ++j)
      {
        int f1 = teachers.get(i).roomFloor;
        int f2 = teachers.get(j).roomFloor;

        int cost = 0;

        if (f1 != -1 && f2 != -1 && f1 != f2)
        {
          if (f1 > f2)
            cost = (int)(floorDownFactor * (f1 - f2));
          else
            cost = (int)(floorUpFactor * (f2 - f1));
        }

        specification.travelCostData()[i + teachers.size() * j] = cost;
      }
    }

    {
      
      PreparedStatement stmt
        = connection.prepareStatement
        ("SELECT start, end FROM available WHERE ID = ? AND type = ?");


      for (int p = 0; p < specification.participantCount(); ++p)
      {
        int databaseID, type;
        if (p < teachers.size())
        {
          databaseID = teachers.get(p).databaseID;
          type = 1;
        } else
        {
          databaseID = students.get(p - teachers.size());
          type = 0;
        }
        stmt.setInt(1, databaseID);
        stmt.setInt(2, type);
          
        ArrayList<Date[]> available = new ArrayList<Date[]>();
        ArrayList<Integer> slots = new ArrayList<Integer>();

        ResultSet rs = stmt.executeQuery();
        while (rs.next())
        {
          Date start = rs.getTimestamp(1, Calendar.getInstance(databaseTimeZone));
          Date end = rs.getTimestamp(2, Calendar.getInstance(databaseTimeZone));

          available.add(new Date[]{start, end});
        }

        rs.close();

        for (int i = 0; i < timeSlots.size(); ++i)
        {
          Date start = timeSlots.get(i)[0];
          Date end = timeSlots.get(i)[1];
          boolean contained = false;
          for (Date[] s : available)
          {
            if (!s[0].after(start) && !s[1].before(end))
            {
              contained = true;
              break;
            }
          }

          if (contained)
            slots.add(i);
        }

        specification.validSlotData()[p] = new int[slots.size()];
        for (int i = 0; i < slots.size(); ++i)
          specification.validSlotData()[p][i] = slots.get(i);
      }
      stmt.close();
    }

    // Read preferences relating to each student
    {
      PreparedStatement stmt1 = connection.prepareStatement
        ("SELECT withID, rank, max_conferences FROM preferences WHERE ID = ? AND isTeacher = 0 AND rank > 0");
      PreparedStatement stmt2 = connection.prepareStatement
        ("SELECT ID, rank FROM preferences WHERE withID = ? AND isTeacher = 1 AND rank > 0");

      for (int p = teachers.size(); p < specification.participantCount(); ++p)
      {

        int databaseID = students.get(p - teachers.size());
        stmt1.setInt(1, databaseID);

        TeacherPriority[] priorities = new TeacherPriority[teachers.size()];

        ResultSet rs = stmt1.executeQuery();
        while (rs.next())
        {
          int teacher = rs.getInt(1);
          int priority = rs.getInt(2);
          int maxConferences = rs.getInt(3);

          priorities[teacherMap.get(teacher).schedulerID] = new TeacherPriority(priority, maxConferences);
        }
        rs.close();

        stmt2.setInt(1, databaseID);
        rs = stmt2.executeQuery();

        while (rs.next())
        {
          int teacher = rs.getInt(1);
          int priority = rs.getInt(2);

          TeacherPriority tp = priorities[teacherMap.get(teacher).schedulerID];
          if (tp != null)
          {
            tp.teacherPriority = priority;
          }
        }
        rs.close();

        int total = 0;

        for (int i = 0; i < priorities.length; ++i)
        {
          if (priorities[i] != null)
            total += priorities[i].studentPriority;
        }

        for (int i = 0; i < priorities.length; ++i)
        {
          int teacher = i;          
          int offset = teacher + (p - teachers.size()) * teachers.size();

          if (priorities[i] == null)
          {
            specification.conferenceValueData()[offset] = new int[0];            
          } else
          {

            TeacherPriority tp = priorities[i];
            int studentPriority = tp.studentPriority * totalStudentPriority / total;
            int teacherPriority = (int)(tp.teacherPriority * teacherPriorityFactor);

            int priority = studentPriority + teacherPriority;
            
            if (tp.maxConferences == 2)
            {
              specification.conferenceValueData()[offset] = new int[2];
              specification.conferenceValueData()[offset][0] = (int)(2 * priority * (1 - secondConferenceWeight));
              specification.conferenceValueData()[offset][1] = (int)(2 * priority * secondConferenceWeight);
            } else
            {
              specification.conferenceValueData()[offset] = new int[1];
              specification.conferenceValueData()[offset][0] = priority;
            }
          }
        }
      }

      stmt1.close();
      stmt2.close();
    }

    return specification;
  }
}
