package org.commschool.scheduler.db;

public class CorruptDatabaseException extends RuntimeException
{
	Throwable rootCause = null;
	public CorruptDatabaseException(String s)
	{
		super(s);
	}

	public CorruptDatabaseException(Throwable t, String s)
	{
		super(s);
		rootCause = t;
	}

	public void printStackTrace()
	{
		super.printStackTrace();

		System.err.println("\n\n\nRoot cause:\n");

		if (rootCause != null)
			rootCause.printStackTrace();
	}

	/*public StackTraceElement[] getStackTrace()
	{
		StackTraceElement[] ste = super.getStackTrace();

		if (rootCause == null)
			return ste;

		StackTraceElement[] rSte = rootCause.getStackTrace();

		StackTraceElement[] toReturn = new StackTraceElement[ste.length + rSte.length + 1];

		for (int i = 0 ; i < ste.length ; i++)
		{
			toReturn[i] = ste[i];
		}

		toReturn[ste.length] = new StackTraceElement("root cause");

		for (int i = 0 ; i < rSte.length ; i++)
		{
			toReturn[i+ste.length+1] = rSte[i];
		}

		return toReturn;
	}*/
}