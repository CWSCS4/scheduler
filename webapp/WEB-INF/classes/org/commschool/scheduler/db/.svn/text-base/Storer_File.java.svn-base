
package org.commschool.scheduler.db;
import java.io.File;
import java.util.Vector;
import java.util.LinkedList;
import java.util.Date;
import java.text.DateFormat;
import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.PrintWriter;

public class Storer_File implements Storer
{
	boolean printStackTraces = true;

	private File rootDir;
	private File teacherDir;
	private File studentDir;
	private File conferenceDir;

	public Storer_File(File rootDirectory)
	{
		this.rootDir = rootDirectory;
		teacherDir = new File(rootDirectory,"teachers");
		studentDir = new File(rootDirectory,"students");
		conferenceDir = new File(rootDirectory,"conferences");
	}

	public static void initialize(File rootDirectory)
	{
		(new File(rootDirectory , "teachers")).mkdirs();
		(new File(rootDirectory , "students")).mkdirs();
		(new File(rootDirectory , "conferences")).mkdirs();
		(new File(rootDirectory , "timeRange")).mkdirs();
	}

	public void setTimeRanges(TimeSlot[] ts)
	{
		File dir = (new File(rootDir , "timeRange"));

		File[] oldContents = dir.listFiles();

		if (oldContents != null)
			for (int i = 0 ; i < oldContents.length ; i++)
				oldContents[i].delete();

		try
		{
			for (int i = 0 ; i < ts.length ; i++)
				(new File(dir, ts[i].toString())).createNewFile();
		}
		catch(Throwable t)
		{
			throw new CorruptDatabaseException(t,"can't set the time ranges");
		}
	}

	public TimeSlot[] getTimeRanges()
	{
		File dir = (new File(rootDir , "timeRange"));

		File[] oldContents = dir.listFiles();

		if (oldContents == null || oldContents.length == 0)
			return null;

		TimeSlot[] tr = new TimeSlot[oldContents.length];

		for (int i = 0 ; i < tr.length ; i++)
			tr[i] = TimeSlot.parse(oldContents[i].getName());

		return tr;
	}

	public void addTimeRange(TimeSlot ts)
	{
		File dir = (new File(rootDir , "timeRange"));

		try
		{
			(new File(dir, ts.toString())).createNewFile();
		}
		catch(Throwable t)
		{
			throw new CorruptDatabaseException(t,"can't add atime range");
		}
	}

	public void clearConferences()
	{
		File dir = (new File(rootDir , "conferences"));

		File[] oldContents = dir.listFiles();

		if (oldContents != null)
			for (int i = 0 ; i < oldContents.length ; i++)
				oldContents[i].delete();
	}

	public java.util.Iterator getTeachers()
	{
		return new FileIterator(teacherDir, FileIterator.TEACHER, this);
	}

	public java.util.Iterator getStudents()
	{
		return new FileIterator(studentDir, FileIterator.STUDENT, this);
	}

	public java.util.Iterator getConferences()
	{
		return new FileIterator(conferenceDir, FileIterator.CONFERENCE, this);
	}

	public void addConference(Teacher t, Student s, TimeSlot ts)
	{
		Conference c = new Conference(t,s,ts,this);

		String conf = FileSafetyConverter.convertToSaveFormat(c.toString());

		try
		{
			(new File(conferenceDir,conf)).createNewFile();
		}
		catch(Throwable thr)
		{
			throw new CorruptDatabaseException(thr,"can't add a conference");
		}
	}

	public Teacher[] getTeachers(Student student,boolean has)
	{
		File studeDir = new File(studentDir, student.getName());

		File[] teachers;

		if (!has)
			teachers = (new File(studeDir,"teachers")).listFiles();
		else
			teachers = (new File(studeDir,"teachersHas")).listFiles();

		if (has)
		{

			Teacher[] s = new Teacher[teachers.length];

			for (int i = 0 ; i < s.length ; i++)
			{
				try
				{
					s[i] = getTeacher(teachers[i].getName());
				}
				catch(TeacherDoesNotExistException e)
				{
					throw new RuntimeException("DB Error: " + teachers[i].getName() + " should exist.  DB seems to be corrupt.");
				}
			}

			return s;
		}

		// !has

		Teacher[] toReturn = new Teacher[teachers.length];

		for(int i = 0 ; i < teachers.length ; i++)
		{
			String s = (FileSafetyConverter.convertFromSaveFormat(teachers[i].getName()));

			try
			{
				toReturn[getFirstNum(s)] = getTeacher(removeFirstNum(s).trim());
			}
			catch(TeacherDoesNotExistException e)
			{
				throw new RuntimeException("DB Error: " + removeFirstNum(s).trim() + " should exist.  DB seems to be corrupt.");
			}
		}

		return toReturn;

	}

	public Student[] getStudents(Teacher teacher, boolean has)
	{
		File teachDir = new File(teacherDir, teacher.getName());

		File[] students;

		if (!has)
			students = (new File(teachDir,"students")).listFiles();
		else
			students = (new File(teachDir,"studentsHas")).listFiles();

		if (has)
		{

			Student[] s = new Student[students.length];

			for (int i = 0 ; i < s.length ; i++)
			{
				try
				{
					s[i] = getStudent(students[i].getName());
				}
				catch(StudentDoesNotExistException e)
				{
					throw new RuntimeException("DB Error: " + students[i].getName() + " should exist.  DB seems to be corrupt.");
				}
			}

			return s;
		}

		// !has

		Student[] toReturn = new Student[students.length];

		for(int i = 0 ; i < students.length ; i++)
		{
			String s = (FileSafetyConverter.convertFromSaveFormat(students[i].getName()));
			try
			{
				toReturn[getFirstNum(s)] = getStudent(students[i].getName());
			}
			catch(StudentDoesNotExistException e)
			{
				throw new RuntimeException("DB Error: " + students[i].getName() + " should exist.  DB seems to be corrupt.");
			}
		}

		return toReturn;

	}

	public TimeSlot[] getTimes(Teacher teacher)
	{
		File teachDir = new File(teacherDir, FileSafetyConverter.convertToSaveFormat(teacher.getName()));

		File[] times = (new File(teachDir,"times")).listFiles();

		TimeSlot[] s = new TimeSlot[times.length];

		for (int i = 0 ; i < s.length ; i++)
		{
			try
			{
				s[i] = TimeSlot.parse(times[i].getName());
			}
			catch(Exception e)
			{
				throw new RuntimeException("DB Error: " + times[i].getName() + " is not a valid TimeSlot.  DB seems to be corrupt.");
			}
		}

		return s;
	}

	public TimeSlot[] getTimes(Student student)
	{
		File studeDer = new File(studentDir, FileSafetyConverter.convertToSaveFormat(student.getName()));

		File[] times = (new File(studeDer,"times")).listFiles();

		TimeSlot[] s = new TimeSlot[times.length];

		for (int i = 0 ; i < s.length ; i++)
		{
			try
			{
				s[i] = TimeSlot.parse(times[i].getName());
			}
			catch(Exception e)
			{
				throw new RuntimeException("DB Error: " + times[i].getName() + " is not a valid TimeSlot.  DB seems to be corrupt.");
			}
		}

		return s;
	}

	public void addStudent(String studentName ,TimeSlot[] times,
	                       Teacher[] teachers, Teacher[] teachersHas,
	                       byte[] passwd, String email)
	                       throws StudentAlreadyExistsException,
	                              TeacherDoesNotExistException
	{
		if (existsStudent(studentName))
			throw new StudentAlreadyExistsException(studentName);

		try
		{

			for (int i = 0 ; i < teachers.length ; i++)
			{
				if(!existsTeacher(teachers[i].getName()))
					throw new TeacherDoesNotExistException(FileSafetyConverter.convertToSaveFormat(teachers[i].getName()));

				// make a new file, teacherDir/teacherName/students/studentName


				File f = (new File(new File (new File(teacherDir , FileSafetyConverter.convertToSaveFormat(teachers[i].getName())) , "students") , FileSafetyConverter.convertToSaveFormat(studentName) ));
				//System.out.println("Creating Student at: " + f.getAbsolutePath());

				f.createNewFile();
			}

			for (int i = 0 ; i < teachersHas.length ; i++)
			{
				if(!existsTeacher(teachersHas[i].getName()))
					throw new TeacherDoesNotExistException(FileSafetyConverter.convertToSaveFormat(teachersHas[i].getName()));

				// make a new file, teacherDir/teacherName/students/studentName
				(new File(new File (new File(teacherDir , FileSafetyConverter.convertToSaveFormat(teachersHas[i].getName())) , "studentsHas") , FileSafetyConverter.convertToSaveFormat(studentName) )).createNewFile();
			}

			File nSDir = new File(studentDir, FileSafetyConverter.convertToSaveFormat(studentName));
			nSDir.mkdir();



			File emailDir = new File(nSDir,"email");
			emailDir.mkdir();

			try
			{
				(new File(emailDir,FileSafetyConverter.convertToSaveFormat(email))).createNewFile();
			}
			catch(Throwable t)
			{
				if (printStackTraces)
					t.printStackTrace();
				throw new CorruptDatabaseException(t,"Can't make email file");
			}


			File passwdDir = new File(nSDir,"passwd");
			passwdDir.mkdir();

			String passwdString = FileSafetyConverter.convertToSaveFormat(byteArrToString(passwd));

			try
			{
				(new File(passwdDir,passwdString)).createNewFile();
			}
			catch(Throwable t)
			{
				if (printStackTraces)
					t.printStackTrace();
				throw new CorruptDatabaseException(t,"Can't make passwd file");
			}



			File tmes = new File(nSDir,"times");
			tmes.mkdir();

			for (int i = 0 ; i < times.length ; i++)
			{
				(new File(tmes, times[i].toString())).createNewFile();
			}

			File thDir = new File(nSDir, "teachersHas");
			thDir.mkdir();

			for (int i = 0 ; i < teachersHas.length ; i++)
			{
				(new File(thDir, FileSafetyConverter.convertToSaveFormat(teachersHas[i].getName()) )).createNewFile();
			}

			File tDir = new File(nSDir,"teachers");
			tDir.mkdir();

			for (int i = 0 ; i < teachers.length ; i++)
			{
				(new File(tDir,i + " ; " + FileSafetyConverter.convertToSaveFormat(teachers[i].getName()))).createNewFile();
			}
		}
		catch(java.io.IOException ioe)
		{
			if (printStackTraces)
				ioe.printStackTrace();
			throw new CorruptDatabaseException(ioe,"Can't add student");
		}
	}

	public void addTeacher(String teacherName,TimeSlot[] times,
						   byte[] passwd, String email)
						   throws TeacherAlreadyExistsException
	{
		if (existsTeacher(teacherName))
			throw new TeacherAlreadyExistsException(teacherName);



			File nSDir = new File(teacherDir, FileSafetyConverter.convertToSaveFormat(teacherName));
			nSDir.mkdir();

			File students = new File(nSDir,"students");
			students.mkdir();

			File studentsHas = new File(nSDir,"studentsHas");
			studentsHas.mkdir();

			File emailDir = new File(nSDir,"email");
			emailDir.mkdir();

			try
			{
				(new File(emailDir,FileSafetyConverter.convertToSaveFormat(email))).createNewFile();
			}
			catch(Throwable t)
			{
				if (printStackTraces)
					t.printStackTrace();
				throw new CorruptDatabaseException(t,"Can't make email file");
			}


			File passwdDir = new File(nSDir,"passwd");
			passwdDir.mkdir();

			String passwdString = FileSafetyConverter.convertToSaveFormat(byteArrToString(passwd));

			try
			{
				(new File(passwdDir,passwdString)).createNewFile();
			}
			catch(Throwable t)
			{
				if (printStackTraces)
					t.printStackTrace();
				throw new CorruptDatabaseException(t,"Can't make passwd file");
			}

			File tmes = new File(nSDir,"times");
			tmes.mkdir();

			for (int i = 0 ; i < times.length ; i++)
			{
				try
				{
					File f = (new File(tmes, times[i].toString()));
					//System.out.println("Creating Teacher at: " + f.getAbsolutePath());

					f.createNewFile();
				}
				catch(java.io.IOException ioe)
				{
					if (printStackTraces)
						ioe.printStackTrace();
					throw new CorruptDatabaseException("can't add time to teacher");
				}
			}

	}

	public String byteArrToString(byte[] b)
	{
		char[] c = new char[b.length * 2];

		for (int i = 0 ; i < b.length ; i++)
		{
			int u1 = (b[i] + 128) % 16;
			int u2 = (b[i] + 128) >>> 4;

			c[2*i    ] = toChar(u1);
			c[2*i + 1] = toChar(u2);
		}

		return new String(c);
	}

	public byte[] byteArrFromString(String s)
	{
		byte[] b = new byte[s.length() / 2];

		for (int i = 0 ; i < b.length ; i++)
			b[i] = (byte)((toInt(s.charAt(2 * i )) + (toInt(s.charAt(2 * i + 1)) << 4)) - 128);

		return b;
	}

	public char toChar(int i)
	{
		if (i >= 0 && i <= 9)
			return (char)((int)'0' + i);
		else if (i >= 10 && i <= 15)
			return (char)((int)'A' + i - 10);
		else
			throw new RuntimeException(i + " is out of range to be a hex digit");
	}

	public int toInt(char c)
	{
		if (c >= '0' && c <= '9')
			return (int)c - (int)'0';
		else if (c >= 'A' && c <= 'F')
			return (int)c - (int)'A' + 10;
		else
			throw new RuntimeException(c + " is out of range to be a hex digit");
	}

	public Student getStudent(String studentName) throws StudentDoesNotExistException
	{
		if (!existsStudent(studentName))
			throw new StudentDoesNotExistException(studentName);

		return new Student(studentName,this);
	}

	public boolean existsTeacher(String teacher)
	{
		return (new File (teacherDir,FileSafetyConverter.convertToSaveFormat(teacher))).exists();
	}
	public boolean existsStudent(String student)
	{
		return (new File (studentDir,FileSafetyConverter.convertToSaveFormat(student))).exists();
	}

	public Teacher getTeacher(String teacherName) throws TeacherDoesNotExistException
	{
		if (!existsTeacher(teacherName))
			throw new TeacherDoesNotExistException(teacherName);

		return new Teacher(teacherName,this);

	}

	public void add(Student student, TimeSlot time)
	{
		try
		{
			(new File(new File(new File(studentDir, FileSafetyConverter.convertToSaveFormat(student.getName())), "times") , time.toString())).createNewFile();
		}
		catch(java.io.IOException ioe)
		{
			if (printStackTraces)
				ioe.printStackTrace();
			throw new CorruptDatabaseException(ioe,"can't add student");
		}
	}

	public void add(Teacher teacher, TimeSlot time)
	{
		try
		{
			(new File(new File(new File(teacherDir, teacher.getName()), "times") , time.toString())).createNewFile();
		}
		catch(java.io.IOException ioe)
		{
			if (printStackTraces)
				ioe.printStackTrace();
			throw new CorruptDatabaseException(ioe,"can't add teacher");
		}
	}

	public void addHas(Student student, Teacher teacher)
	{
		try
		{
			(new File(new File(new File(teacherDir , teacher.getName()) , "studentsHas") , student.getName())).createNewFile();
			(new File(new File(new File(studentDir , student.getName()) , "teachersHas") , teacher.getName())).createNewFile();
		}
		catch(java.io.IOException ioe)
		{
			if (printStackTraces)
				ioe.printStackTrace();
			throw new CorruptDatabaseException(ioe,"can't add has relationship");
		}
	}


	public void add(Student student , Teacher teacher , int priority)
	{
		try
		{
			String tName = FileSafetyConverter.convertToSaveFormat(teacher.getName());
			String sName = FileSafetyConverter.convertToSaveFormat(student.getName());

			(new File(new File(new File(teacherDir ,tName ) , "students") ,sName)).createNewFile();

			File studentsTeacherDir = new File(new File(studentDir,sName) , "teachers");

			File[] allTeachers = studentsTeacherDir.listFiles();

			if (allTeachers.length == 0)
				(new File(studentsTeacherDir, 0 + " ; " + teacher.getName() )).createNewFile();
			else
			{

				String[] tec = new String[allTeachers.length + 1];

				for (int i = 0 ; i < allTeachers.length ; i++)
				{
					String s = (allTeachers[i].getName());

					tec[getFirstNum(s)] = removeFirstNum(s).trim();
				}

				for (int i = tec.length - 1 ; i > priority ; i--)
					tec[i] = tec[i-1];
				tec[priority] = tName;

				for (int i = 0 ; i < allTeachers.length ; i++)
					allTeachers[i].delete();

				for (int i = 0 ; i < tec.length ; i++)
					(new File(studentsTeacherDir, i + " ; " +tec[i])).createNewFile();
			}

		}
		catch(java.io.IOException ioe)
		{
			if(printStackTraces)
				ioe.printStackTrace();

			throw new CorruptDatabaseException(ioe,"can't add student to teacher");
		}
	}

	public void remove(Student student, Teacher teacher, boolean has)
	{

		// remove the relationship from the teacher's area

		String tName = FileSafetyConverter.convertToSaveFormat(teacher.getName());
		String sName = FileSafetyConverter.convertToSaveFormat(student.getName());
		if (!has)
		{
			(new File(new File(new File(teacherDir,tName),"students"),sName)).delete();
		}
		else
		{
			(new File(new File(new File(teacherDir,tName),"studentsHas"),sName)).delete();
			(new File(new File(new File(studentDir,sName),"teachersHas"),tName)).delete();
		}


		if (!has)
		{
			// remove the relationship from the student's area without killing priority
			File studentsTeacherDir = (new File(new File(studentDir,sName),"teachers"));
			File[] teachersDir = studentsTeacherDir.listFiles();

			String[] chopped = new String[teachersDir.length - 1];

			int shift = 0;
			for (int i = 0 ; i < teachersDir.length ; i++)
			{
				String nme = teachersDir[i].getName();
				teachersDir[i].delete();

				if (nme.indexOf(tName) != -1)
				{
					shift++;
				}
				else
				{
					chopped[i-shift] = removeFirstNum(nme).trim();
				}
			}

			try
			{
				for (int i = 0 ; i < chopped.length ; i++)
					(new File(studentsTeacherDir,i + " ; " + chopped[i])).createNewFile();
			}
			catch(Throwable t)
			{
				if (printStackTraces)
					t.printStackTrace();
				throw new CorruptDatabaseException(t,"can't re-write after removal of teacher");
			}

		}
	}

	private String removeFirstNum(String s)
	{
		return s.substring(s.indexOf(';') + 1 , s.length());
	}

	private int getFirstNum(String s)
	{
		return Integer.parseInt((s.substring(0, s.indexOf(';'))).trim());
	}

	public void remove(Student student , TimeSlot time)
	{
		(new File(new File(new File(studentDir, FileSafetyConverter.convertToSaveFormat(student.getName())), "times") , time.toString())).delete();
	}

	public void remove(Teacher teacher, TimeSlot time)
	{
		(new File(new File(new File(teacherDir, FileSafetyConverter.convertToSaveFormat(teacher.getName())), "times") , time.toString())).delete();
	}

	public void remove(Student student)
	{
		File f = new File (studentDir,FileSafetyConverter.convertToSaveFormat(student.getName()));
		f.delete();
		student.setDeleted(true);
	}

	public void remove(Teacher teacher)
	{
		File f = new File (teacherDir,FileSafetyConverter.convertToSaveFormat(teacher.getName()));
		f.delete();
		teacher.setDeleted(true);
	}


	private class FileIterator extends Iterator
	{
		public static final int STUDENT = 0 , TEACHER = 1, CONFERENCE = 2;

		File dir;

		int index;

		int type;

		File[] dirContents;

		Storer dbs;

		boolean isStudentIterator;

		public FileIterator(File dir, int type, Storer dbs)
		{
			this.dir = dir;
			this.dbs = dbs;
			this.type = type;

			index = -1;

			dirContents = dir.listFiles();
		}

		public boolean hasNext()
		{
			return index + 1 < dirContents.length;
		}

		public Object next()
		{
			index++;

			String s = FileSafetyConverter.convertFromSaveFormat(dirContents[index].getName());

			if (type == STUDENT)
			{
				try
				{
					return dbs.getStudent(s);
				}
				catch(StudentDoesNotExistException sdnee)
				{
					throw new RuntimeException("Database Error: Student " + s + " should exist");
				}
			}
			else if(type == TEACHER)
			{
				try
				{
					return dbs.getTeacher(s);
				}
				catch(TeacherDoesNotExistException sdnee)
				{
					throw new RuntimeException("Database Error: Teacher " + s + " should exist");
				}
			}
			else if(type == CONFERENCE)
			{
				try
				{
					return Conference.parse(s,dbs);
				}
				catch(TeacherDoesNotExistException sdnee)
				{
					throw new RuntimeException("Database Error: Teacher " + s + " should exist");
				}
			}
			throw new Error("Database Error types are really screwed up");
		}
	}

	public void setTeachers(Student s, Teacher[] t, boolean has)
	{

		String sName =  FileSafetyConverter.convertToSaveFormat(s.getName());

		String stuStr = "students";
		if (has)
			stuStr = "studentsHas";


/**/    //remove old teacher linkage
/**/	Teacher[] oldTeachersToRemoveFromWherever;
/**/
/**/	if (has)
/**/		oldTeachersToRemoveFromWherever = s.getTeachersHas();
/**/	else
/**/		oldTeachersToRemoveFromWherever = s.getTeachers();
/**/
/**/
/**/	for (int i = 0 ; i < oldTeachersToRemoveFromWherever.length; i++)
/**/	{
/**/		String otfName = FileSafetyConverter.convertToSaveFormat(oldTeachersToRemoveFromWherever[i].getName());
/**/
/**/		File dir = new File(new File(teacherDir , otfName) , stuStr);
/**/
/**/		(new File(dir,sName)).delete();
/**/	}



		String dirName = "teachers";
		if (has)
			dirName = "teachersHas";

		File activeDir = new File((new File(studentDir , sName)) , dirName);


		//remove the old teachers
		File[] oldTeachers = activeDir.listFiles();
		for (int i = 0 ; i < oldTeachers.length ; i++)
			oldTeachers[i].delete();


		//add the new ones and linkages
		try
		{
			for (int i = 0 ; i < t.length ; i++)
			{
				String tName = FileSafetyConverter.convertToSaveFormat(t[i].getName());

				(new File(new File(new File(teacherDir,tName) , stuStr), sName)).createNewFile();

				if (!has)
					tName = i + " ; " + tName;

				(new File(activeDir,tName)).createNewFile();
			}
		}
		catch(Exception e)
		{
			throw new CorruptDatabaseException(e,"cannot write to db.  not good.");
		}
	}


	public String getEmail(Teacher teacher)
	{
		String tName = FileSafetyConverter.convertToSaveFormat(teacher.getName());
		File emailDir = new File(new File(teacherDir,tName) , "email");

		File[] emails = emailDir.listFiles();

		if (emails.length == 0)
			return null;
		else
			return FileSafetyConverter.convertFromSaveFormat(emails[0].getName());
	}


	public String getEmail(Student student)
	{
		String sName = FileSafetyConverter.convertToSaveFormat(student.getName());
		File emailDir = new File(new File(studentDir,sName) , "email");

		File[] emails = emailDir.listFiles();

		if (emails.length == 0)
			return null;
		else
			return FileSafetyConverter.convertFromSaveFormat(emails[0].getName());
	}



	public void setEmail(Teacher teacher, String email)
	{
		String tName = FileSafetyConverter.convertToSaveFormat(teacher.getName());
		File emailDir = new File(new File(teacherDir,tName) , "email");

		String emailStr =  FileSafetyConverter.convertToSaveFormat(email);

		File[] emails = emailDir.listFiles();

		if (emails.length > 0)
			emails[0].delete();

		try
		{
			(new File(emailDir , emailStr)).createNewFile();
		}
		catch(Throwable t)
		{
			if (printStackTraces)
				t.printStackTrace();
			throw new CorruptDatabaseException(t,"could not give teacher an email adress");
		}
	}


	public void setEmail(Student student, String email)
	{

		String sName = FileSafetyConverter.convertToSaveFormat(student.getName());
		File emailDir = new File(new File(studentDir,sName) , "email");

		String emailStr =  FileSafetyConverter.convertToSaveFormat(email);

		File[] emails = emailDir.listFiles();

		if (emails.length > 0)
			emails[0].delete();

		try
		{
			(new File(emailDir , emailStr)).createNewFile();
		}
		catch(Throwable t)
		{
			if (printStackTraces)
				t.printStackTrace();
			throw new CorruptDatabaseException("could not give student an email adress");
		}
	}


	public byte[] getPasswd(Teacher teacher)
	{
		String tName = FileSafetyConverter.convertToSaveFormat(teacher.getName());
		File passwdDir = new File(new File(teacherDir,tName) , "passwd");

		File[] passwds = passwdDir.listFiles();

		if (passwds.length == 0)
			return null;
		else
			return byteArrFromString(FileSafetyConverter.convertFromSaveFormat(passwds[0].getName()));
	}


	public byte[] getPasswd(Student student)
	{
		String sName = FileSafetyConverter.convertToSaveFormat(student.getName());
		File passwdDir = new File(new File(studentDir,sName) , "passwd");

		File[] passwds = passwdDir.listFiles();

		if (passwds.length == 0)
			return null;
		else
			return byteArrFromString(FileSafetyConverter.convertFromSaveFormat(passwds[0].getName()));
	}


	public void setPasswd(Teacher teacher, byte[] passwd)
	{
		String tName = FileSafetyConverter.convertToSaveFormat(teacher.getName());
		File passwdDir = new File(new File(teacherDir,tName) , "passwd");

		String passwdStr = FileSafetyConverter.convertToSaveFormat(byteArrToString(passwd));

		File[] passwds = passwdDir.listFiles();

		if (passwds.length > 0)
			passwds[0].delete();

		try
		{
			(new File(passwdDir , passwdStr)).createNewFile();
		}
		catch(Throwable t)
		{
			if (printStackTraces)
				t.printStackTrace();
			throw new CorruptDatabaseException(t,"can't set teacher passwd");
		}
	}


	public void setPasswd(Student student, byte[] passwd)
	{
		String sName = FileSafetyConverter.convertToSaveFormat(student.getName());
		File passwdDir = new File(new File(studentDir,sName) , "passwd");

		String passwdStr =  FileSafetyConverter.convertToSaveFormat(byteArrToString(passwd));

		File[] passwds = passwdDir.listFiles();

		if (passwds.length > 0)
			passwds[0].delete();

		try
		{
			(new File(passwdDir , passwdStr)).createNewFile();
		}
		catch(Throwable t)
		{
			if (printStackTraces)
				t.printStackTrace();
			throw new CorruptDatabaseException(t,"cant set student's password");
		}
	}

	public boolean equals(Object o)
	{
		return o instanceof Storer_File && ((Storer_File)o).rootDir.equals(rootDir) ;
	}
}