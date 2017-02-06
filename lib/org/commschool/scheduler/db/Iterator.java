
package org.commschool.scheduler.db;

public class Iterator implements java.util.Iterator
{
	public boolean hasNext()
	{
		return false;
	}

	public Object next()
	{
		return null;
	}

	public void remove()
	{
		throw new UnsupportedOperationException("Remove not allowed");
	}
}