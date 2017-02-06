package org.commschool.scheduler.db;

import java.io.*;
import java.util.*;
import com.Ostermiller.util.CSVParser;
import java.security.*;

public class DbPopulator
{
	//Format: StudentFName StudentLName,AdvisorFName AdvisorLName
	public static void inputStudentAdvisorList(String rootDir, String fName)
	{
		CSVParser csv = null;
		try
		{
			csv = new CSVParser(new FileInputStream(fName));
		}
		catch(IOException e)
		{
			System.err.println("ERROR: Bad filename or file is not in csv format:\n   " + fName);
			System.exit(1);
		}

		String[][] all = null;

		try
		{
			all = csv.getAllValues();
		}
		catch(IOException e)
		{
			System.err.println("ERROR: The file does not seem to be in csv format.");
			System.exit(1);
		}

		for (int i = 0 ; i < all.length ; i++)
		{
			if (all[i].length == 2 )
			{
				String student = all[i][0];
				String teacher = all[i][1];

				addTeacherStudentRelationship(student,teacher,rootDir);
			}
		}
	}

	//Format: StudentFName StudentLName,course,"TeacherLName, TeacherFName"
	public static void inputStudentTeacherList(String rootDir, String fName)
	{
		CSVParser csv = null;
		try
		{
			csv = new CSVParser(new FileInputStream(fName));
		}
		catch(IOException e)
		{
			System.err.println("ERROR: Bad filename or file is not in csv format:\n   " + fName);
			System.exit(1);
		}

		String[][] all = null;

		try
		{
			all = csv.getAllValues();
		}
		catch(IOException e)
		{
			System.err.println("ERROR: The file does not seem to be in csv format.");
			System.exit(1);
		}

		for (int i = 0 ; i < all.length ; i++)
		{
			if (all[i].length == 3 )
			{
				String student    = all[i][0];
				String course     = all[i][1];
				String teacherBad = all[i][2];

				String teacher = parseBadTeacher(teacherBad);

				if (teacher != null)
					addTeacherStudentRelationship(student,teacher,rootDir);
			}
		}
	}


	//Format "StudentFName StudentLName,password"
	public static void inputStudentPasswordList(String rootDir, String fName)
	{
		Storer s = new Storer_File(new File(rootDir));


		CSVParser csv = null;
		try
		{
			csv = new CSVParser(new FileInputStream(fName));
		}
		catch(IOException e)
		{
			System.err.println("ERROR: Bad filename or file is not in csv format:\n   " + fName);
			System.exit(1);
		}

		String[][] all = null;

		try
		{
			all = csv.getAllValues();
		}
		catch(IOException e)
		{
			System.err.println("ERROR: The file does not seem to be in csv format.");
			System.exit(1);
		}

		for (int i = 0 ; i < all.length ; i++)
		{
			if (all[i].length == 2 )
			{
				try
				{
					(s.getStudent(all[i][0])).setPasswd(hashPlaintextPassword(all[i][1]));
					System.out.println( all[i][0] + "--" + all[i][1] + "-");
				}
				catch(StudentDoesNotExistException sdnee)
				{
					System.err.println("ERROR: Student " + all[i][0] + " does not seem to be in the database.");
					System.exit(1);
				}
			}
		}
	}

	public static byte[] hashPlaintextPassword(String pass)
	{
		try
		{
			MessageDigest md = MessageDigest.getInstance("MD5");

	    	return md.digest(pass.getBytes());
		}
		catch(Exception e)
		{
			System.err.println("Can't find MD5 Hash capability.  Update your java VM. AHHHHHHH!!!!!");
			System.exit(1);
		}
		return null;
	}

	public static String parseBadTeacher(String t)
	{
		StringTokenizer st = new StringTokenizer(t,",");

		if (st.countTokens() != 2)
			return null;

		String teacherLN = st.nextToken();
		String teacherFN = st.nextToken();

		return teacherFN + " " + teacherLN;
	}

	public static void addTeacherStudentRelationship(String student, String teacher, String rootDir)
	{
		File root = new File(rootDir);
		File stu = new File(root,"students");
		File tea = new File(root,"teachers");

		student = FileSafetyConverter.convertToSaveFormat(student.trim());
		teacher = FileSafetyConverter.convertToSaveFormat(teacher.trim());

		System.out.println(student + " : " + teacher);

		try
		{
			File stus = new File(stu,student);
			stus.mkdir();

			File teas = new File(tea,teacher);
			teas.mkdir();

			File teachersHas = new File(stus,"teachersHas");
			File studentsHas = new File(teas,"studentsHas");

			teachersHas.mkdirs();
			studentsHas.mkdirs();

			(new File(stus , "email")).mkdirs();
			(new File(stus , "passwd")).mkdirs();
			(new File(stus , "teachers")).mkdirs();
			(new File(stus , "times")).mkdirs();

			(new File(teas , "email")).mkdirs();
			(new File(teas , "passwd")).mkdirs();
			(new File(teas , "students")).mkdirs();
			(new File(teas , "times")).mkdirs();

			(new File( teachersHas , teacher)).createNewFile();
			(new File( studentsHas , student)).createNewFile();
		}
		catch(IOException e)
		{
			System.err.println("ERROR: Can't write to the Database.");
			System.exit(1);
		}
	}


	public static void printHelp()
	{
		out("Proper usage:");
		out("   java DbPopulator <action> <rootDir> <inputFileName>\n");

		out("Actions are identifiers of filetype.  Allowed are:");
		out("   -sa : Format \"StudentFName StudentLName,AdvisorFName AdvisorLName\"");
		out("   -st : Format \"StudentFName StudentLName,course,\"TeacherLName, TeacherFName\"\"");
		out("   -sp : Format \"StudentFName StudentLName,password\"");

		out("\nExample Usage:  java DbPopulator -sa \"C:\\dbFileSystem\" FinalAdvisorList.csv");

	}

	public static void out(String s)
	{
		System.out.println(s);
	}

	public static void main(String[] args)
	{
		out("DbPopulator, Copyleft 2004\n");

		if (args.length != 3 || !(args[0].equals("-sa") || args[0].equals("-st") || args[0].equals("-sd") || args[0].equals("-sp")))
		{
			if (args.length != 0)
				out("ERROR: Improper usage.\n\n");

			printHelp();

			System.exit(0);
		}

		if (args[0].equals("-sa"))
		{
			inputStudentAdvisorList(args[1],args[2]);
			System.exit(0);
		}

		if (args[0].equals("-st"))
		{
			inputStudentTeacherList(args[1],args[2]);
			System.exit(0);
		}

		if (args[0].equals("-sp"))
		{
			inputStudentPasswordList(args[1],args[2]);
			System.exit(0);
		}

		throw new RuntimeException("Program should not reach this point: progamming error")	;
	}
}
