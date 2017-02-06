
package org.commschool.scheduler.db;

	public class StudentDoesNotExistException extends RuntimeException
	{
		public StudentDoesNotExistException(String name)
		{
			super (name + " does not exist");
		}
	}