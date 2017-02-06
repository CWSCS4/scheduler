
package org.commschool.scheduler.db;

public class Teacher
{
	private Storer dbs;
	private String name;
	private boolean deleted;





	/**
	 *
	 * should be used only from Storer implementers
	 *
	 */
	public Teacher(String name, Storer dbs)
	{
		this.name = name;
		this.dbs = dbs;
		deleted = false;
	}


	public String getName()
	{
		if (!deleted)
			return name;
		return "deleted";
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

	public void addTime(TimeSlot time)
	{
		if (!deleted)
			dbs.add(this,time);
	}

	public void removeTime(TimeSlot time)
	{
		if (!deleted)
			dbs.remove(this,time);
	}


	public Conference[] getConferences()
	{
		java.util.Iterator it = dbs.getConferences();

		java.util.Vector mine = new java.util.Vector();

		while(it.hasNext())
		{
			Conference c = (Conference)it.next();

			if (c.getTeacher().equals(this))
				mine.add(c);
		}

		Conference[] c = new Conference[mine.size()];

		for (int i = 0 ; i < c.length ; i++)
			c[i] = (Conference)mine.get(i);

		return c;
	}

	public TimeSlot[] getTimes()
	{
		if (!deleted)
			return dbs.getTimes(this);
		return null;
	}

	public Student[] getStudents()
	{
		return getStudents(false);
	}

	public Student[] getStudentsHas()
	{
		return getStudents(true);
	}

	public Student[] getStudents(boolean has)
	{
		if (!deleted)
			return dbs.getStudents(this,has);
		return null;
	}

	public void setDeleted(boolean b)
	{
		deleted = b;
	}

	public boolean equals(Object o)
	{
		return o instanceof Teacher && ((Teacher)o).name.equals(name) && ((Teacher)o).dbs.equals(dbs) && ((Teacher)o).deleted == deleted;
	}
}