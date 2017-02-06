
package org.commschool.scheduler.db;

	public class StudentAlreadyExistsException extends RuntimeException
	{
		public StudentAlreadyExistsException(String name)
		{
			super (name + " already exists");
		}
	}