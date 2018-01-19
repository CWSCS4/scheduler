
package org.commschool.scheduler.db;
import java.util.*;
import java.text.*;


/**
 *
 * A class to provide a thin wrapper around two
 * java.util.Date's to ease passing around
 *
 **/
public class TimeSlot
{
	// this means that times within 1000 * 60 = 60000 ms ( 1 min ) get treated as equal
	public static int ACCURACY = 60000;

	private Date start;
	private Date finish;

	/**
	 * @param start beginning of available time slot
	 * @param finish end of availiable time slot
	 */

	public TimeSlot(Date start, Date finish)
	{
		this.start = start;
		this.finish = finish;
	}

	public Date getStart()
	{
		return start;
	}

	public Date getFinish()
	{
		return finish;
	}

	public boolean equals(Object o)
	{
		return o instanceof TimeSlot && ((TimeSlot)o).start.equals(start) && ((TimeSlot)o).finish.equals(finish);
	}

	public static TimeSlot parse(String st)
	{
		String s = FileSafetyConverter.convertFromSaveFormat(st);

		int semi = s.indexOf(";");

		if (semi == -1)
			return null;

		try
		{
			//Date start  = DateFormat.getDateInstance().parse( s.substring(0,semi) );
			//Date finish = DateFormat.getDateInstance().parse( s.substring(semi + 1, s.length()) );

			Date start = new Date(Long.parseLong((s.substring(0,semi)).trim()));
			Date finish = new Date(Long.parseLong((s.substring(semi + 1, s.length())).trim()));

			return new TimeSlot(start,finish);
		}
		catch(Exception def)
		{
			def.printStackTrace();

			return null;
		}
	}

	public boolean within(TimeSlot t)
	{
		Date tStart = new Date(t.start.getTime() - ACCURACY);
		Date tFinish = new Date(t.finish.getTime() + ACCURACY);

		boolean startAfterTStart = start.compareTo(tStart) >= 0 ;
		boolean finishBeforeTFinish = finish.compareTo(tFinish) <= 0;

		return startAfterTStart && finishBeforeTFinish;
	}

	public String toString()
	{
		//String st = (DateFormat.getDateInstance().format(start)) + " ; " + (DateFormat.getDateInstance().format(finish));
		String st = start.getTime() + " ; " + finish.getTime();
		String s = FileSafetyConverter.convertToSaveFormat(st);
		return s;
	}
}