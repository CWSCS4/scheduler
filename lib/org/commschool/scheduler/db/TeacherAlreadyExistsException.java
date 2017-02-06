
package org.commschool.scheduler.db;

public class TeacherAlreadyExistsException extends RuntimeException
{
	public TeacherAlreadyExistsException (String s)
	{
		super("Teacher " + s + " already exists");
	}
}