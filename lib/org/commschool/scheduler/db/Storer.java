

package org.commschool.scheduler.db;

/**
 *
 *  Interface for acessing the storage class.
 *  Methods designed to be used from here are bold.
 *
 */

public interface Storer
{

	/**
	 *
	 * <b> allows acess to all the teachers </b>
	 *
	 */
	public java.util.Iterator getTeachers();

	public void setTimeRanges(TimeSlot[] ts);
	public TimeSlot[] getTimeRanges();
	public void addTimeRange(TimeSlot ts);


	public void clearConferences();


	/**
	 *
	 * <b> allows acess to all the students </b>
	 *
	 */
	public java.util.Iterator getStudents();


	/**
	 *
	 * allows access to conferences.  returns null if there are none set yet
	 *
	 */
	public java.util.Iterator getConferences();


	/**
	 *
	 * use "student.getTeachers()"
	 *
	 */
	public Teacher[] getTeachers(Student student,boolean has);

	/**
	 *
	 * use "teacher.getStudents()"
	 *
	 */
	public Student[] getStudents(Teacher teacher, boolean has);

	public boolean existsTeacher(String teacher);

	public boolean existsStudent(String student);



	/**
	 *
	 * use "student.setTeachers(...)" and "student.setTeachersHas(...)"
	 *
	 */
	public void setTeachers(Student s, Teacher[] t, boolean has);


	public void addConference(Teacher t, Student s, TimeSlot ts);


	/**
	 *
	 * use "teacher.getTimes()"
	 *
	 */
	public TimeSlot[] getTimes(Teacher teacher);

	/**
	 *
	 * use "student.getTimes()"
	 *
	 */
	public TimeSlot[] getTimes(Student student);

	/**
	 *
	 * use Teacher.getEmail()
	 *
	 */

	public String getEmail(Teacher teacher);

	/**
	 *
	 * use Student.getEmail()
	 *
	 */
	public String getEmail(Student student);

	/**
	 *
	 * use Teacher.setEmail()
	 *
	 */

	public void setEmail(Teacher teacher, String email);

	/**
	 *
	 * use Student.setEmail()
	 *
	 */
	public void setEmail(Student student, String email);


	/**
	 *
	 * use Teacher.getPasswd()
	 *
	 */
	public byte[] getPasswd(Teacher teacher);

	/**
	 *
	 * use Student.getPasswd()
	 *
	 */
	public byte[] getPasswd(Student student);

	/**
	 *
	 * use Teacher.setPasswd()
	 *
	 */
	public void setPasswd(Teacher teacher, byte[] passwd);

	/**
	 *
	 * use Student.setPasswd()
	 *
	 */
	public void setPasswd(Student student, byte[] passwd);



	public void addStudent(String studentName ,TimeSlot[] times,Teacher[] teachers,
	                       Teacher[] teachersHas, byte[] passwd, String email)
	                       throws StudentAlreadyExistsException, TeacherDoesNotExistException;

	public void addTeacher(String teacherName,TimeSlot[] times,
	                       byte[] passwd, String email)
	                       throws TeacherAlreadyExistsException;

	/**
	 *
	 * <b>allows acess to a student from its name.</b>
	 *
	 * @exception StudentDoesNotExistException if student is not already in the database
	 *
	 */
	public Student getStudent(String studentName) throws StudentDoesNotExistException;

	/**
	 *
	 * <b>allows acess to a teacher from its name.</b>
	 *
	 * @exception TeacherDoesNotExistException if teacher is not already in the database
	 *
	 */
	public Teacher getTeacher(String teacherName) throws TeacherDoesNotExistException;

	/**
	 *
	 * use "student.addTime(TimeSlot time)"
	 *
	 */
	public void add(Student student, TimeSlot time);

	/**
	 *
	 * use "teacher.addTime(TimeSlot time)"
     *
	 */
	public void add(Teacher teacher, TimeSlot time);

	/**
	 *
	 * use "student.addTeacher(...)"
     *
	 */
	public void add(Student student , Teacher teacher , int priority);

	/**
	 *
	 * use "student.addHas(...)"
	 *
	 */
	public void addHas(Student student , Teacher teacher);

	/**
	 *
	 * use "student.removeTeacher(Teacher teacher)"
	 *
	 */
	public void remove(Student student, Teacher teacher, boolean has);

	/**
	 *
	 * use "student.removeTime(TimeSlot time)"
	 *
	 */
	public void remove(Student student , TimeSlot time);

	/**
	 *
	 * use "teacher.removeTime(TimeSlot time)"
	 *
	 */
	public void remove(Teacher teacher, TimeSlot time);


	/**
	 *
	 * use Student.remove()
	 *
	 */
	public void remove(Student student);



	/**
	 *
	 * use Teacher.remove()
	 *
	 */
	public void remove(Teacher teacher);


}