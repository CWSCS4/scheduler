
package org.commschool.scheduler.db;

public class Conference
{
	Storer dbs;
	Teacher t;
	Student s;
	TimeSlot ts;

	/**
	 *
	 * call from Storer only
	 *
	 */
	public Conference( Teacher t, Student s , TimeSlot ts,Storer dbs)
	{
		this.t = t;
		this.s = s;
		this.ts = ts;
		this.dbs = dbs;
	}

	public String toString()
	{
		String tName = t.getName();
		String sName = s.getName();

		return "" + tName + " ; " + sName + " ; " + ts.getStart().getTime() + " ; " + ts.getFinish().getTime();
	}

	public static Conference parse(String str , Storer dbs)
	{
		java.util.StringTokenizer st = new java.util.StringTokenizer(str,";");

		String tName = st.nextToken().trim();
		String sName =st.nextToken().trim();

		Teacher t = dbs.getTeacher(tName);
		Student s = dbs.getStudent(sName);

		String start = st.nextToken().trim();
		String finish = st.nextToken().trim();

		TimeSlot ts = new TimeSlot(new java.util.Date(Long.parseLong(start) ), new java.util.Date(Long.parseLong(finish)));


		return new Conference(t,s,ts,dbs);
	}

	public Teacher getTeacher()
	{
		return t;
	}
	public Student getStudent()
	{
		return s;
	}
	public TimeSlot getTimeSlot()
	{
		return ts;
	}


}