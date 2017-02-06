
package org.commschool.scheduler.db;

	public class TeacherDoesNotExistException extends RuntimeException
	{
		public TeacherDoesNotExistException(String name)
		{
			super (name + " does not exist");
		}
	}