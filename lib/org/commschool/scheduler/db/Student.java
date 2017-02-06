
package org.commschool.scheduler.db;

import java.util.*;

/**
 *
 *  A proxy student object to facilitate
 *  acess to the database.
 *
 *
 *
 *
 */

public class Student
{
	private Storer dbs;
	private String name;
	private boolean deleted;


	/**
	 *
	 * should be used only from Storer implementers.  I want friend functions!
	 *
	 */
	public Student(String name, Storer dbs)
	{
		this.name = name;
		this.dbs = dbs;
		deleted = false;
	}

	public byte[] getPasswd()
	{
		return dbs.getPasswd(this);
	}

	public String getEmail()
	{
		return dbs.getEmail(this);
	}

	public void setPasswd(byte[] passwd)
	{
		dbs.setPasswd(this,passwd);
	}

	public void setEmail(String email)
	{
		dbs.setEmail(this,email);
	}

	public String getName()
	{
		if (!deleted)
			return name;
		return "deleted";
	}

	public Conference[] getConferences()
	{
		java.util.Iterator it = dbs.getConferences();

		java.util.Vector mine = new java.util.Vector();

		while(it.hasNext())
		{
			Conference c = (Conference)it.next();

			if (c.getStudent().equals(this))
				mine.add(c);
		}

		Conference[] c = new Conference[mine.size()];

		for (int i = 0 ; i < c.length ; i++)
			c[i] = (Conference)mine.get(i);

		return c;
	}

	public Teacher[] getTeachers()
	{
		return getTeachers(false);
	}

	public Teacher[] getTeachersHas()
	{
		return getTeachers(true);
	}

	public Teacher[] getTeachers(boolean has)
	{
		if (!deleted)
			return dbs.getTeachers(this,has);
		return null;
	}

	public TimeSlot[] getTimes()
	{
		if (!deleted)
			return dbs.getTimes(this);
		return null;
	}

	public void removeTime(TimeSlot time)
	{
		if (!deleted)
			dbs.remove(this,time);
	}

	public void setTeachers(Teacher[] t)
	{
		setTeachers(t,false);
	}

	public void setTeachersHas(Teacher[] t)
	{
		setTeachers(t,true);
	}

	public void setTeachers(Teacher[] t, boolean has)
	{
		dbs.setTeachers(this,t,has);
	}

	public void removeTeacher(Teacher teacher)
	{
		removeTeacher(teacher,false);
	}
	public void removeTeacherHas(Teacher teacher)
	{
		removeTeacher(teacher,true);
	}

	public void removeTeacher(Teacher teacher, boolean has)
	{
		if (!deleted)
			dbs.remove(this,teacher,has);
	}

	public void addTeacherHas(Teacher teacher)
	{
		if (!deleted)
			dbs.addHas(this,teacher);
	}

	public void addTeacher(Teacher teacher, int priority)
	{
		if (!deleted)
			dbs.add(this,teacher,priority);
	}


	public void addTime(TimeSlot time)
	{
		if (!deleted)
			dbs.add(this,time);
	}

	public void setDeleted(boolean b)
	{
		deleted = b;
	}

	public boolean equals(Object o)
	{
		return o instanceof Student && ((Student)o).name.equals(name) && ((Student)o).dbs.equals(dbs) && ((Student)o).deleted == deleted;
	}
}