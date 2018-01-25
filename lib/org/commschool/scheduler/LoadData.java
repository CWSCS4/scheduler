package org.commschool.scheduler;

/**
 * LoadData.java - Schedule database data loader.
 * Copyright (C) 2004 Reilly Grant <reillyeon@qotw.net>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software Foundation,
 * Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
 *
 * Also add information on how to contact you by electronic and paper mail.
 */

import com.Ostermiller.util.*;
import java.io.*;
import java.sql.*;

/**
 * LoadData
 *
 * Load scheduler data from CSV files exported from the school database. This
 * system requires the following data files to create a full database: - List of
 * student's classes ( studentName, className, teacherName ) - List of student's
 * advisors ( studentName, advisorName ) - List of birthdays for creating
 * passwords ( studentName, dateOfBirth ) - List of conference rooms (
 * teacherName, room ) * "room" should contain the word or numeral for the floor
 * or "basement"
 *
 * Run this program passing it the name of each file. The database entries for
 * each type of data will need to be cleared from the database before the new
 * data is entered. The database is assumed to be running on the local computer
 * and the database is called "scheduler" and the user "scheduler" has complete
 * permissions to change the database.
 *
 * Syntax: java LoadData [-h hostname] [-u username] [-d database] [-e] [-i] [-c
 * classList.csv] [-a advisorList.csv] [-p birthdayList.csv]
 *
 * -h hostname --server Database server hostname (default: 127.0.0.1) -u
 * username --user Database username (default: scheduler) -d database --database
 * Database name (default: scheduler) -p password --password Database password
 * (default: none) -e --erase Erase the contents of the database -i --initalize
 * Create the template for the database (Not needed after an erase.) -c
 * classList --classes Load class list -a advisors --advisors Load advisor list
 * -b birthdays --birthdays Load password list (Usually birthdays) -r rooms
 * --rooms Load room list -t password --t-passwd Set teacher password
 *
 * Have fun!
 */

public class LoadData {

	String hostname = "127.0.0.1";
	String username = "scheduler";
	String database = "scheduler";
	String dbpass = "";

	File classList = null;
	File advisorList = null;
	File birthdayList = null;
	File roomList = null;
	String tPass = null;
	boolean initDatabase = false;
	boolean eraseDatabase = false;
	boolean shouldMerge = false;

	Connection connect = null;

	public static void main(String[] args) {
		System.out.println("Load Data");
		LoadData load = new LoadData();
		load.run(args);
	}

	public void run(String[] args) {
		if (args.length == 0) {
			printHelp();
			return;
		}

		for (int i = 0; i < args.length; i++) {
			if (args[i].equals("-h") || args[i].equals("--hostname")) {
				hostname = args[++i];
			} else if (args[i].equals("-u") || args[i].equals("--username")) {
				username = args[++i];
			} else if (args[i].equals("-d") || args[i].equals("--database")) {
				database = args[++i];
			} else if (args[i].equals("-p") || args[i].equals("--password")) {
				dbpass = args[++i];
			} else if (args[i].equals("-i") || args[i].equals("--initalize")) {
				initDatabase = true;
			} else if (args[i].equals("-e") || args[i].equals("--erase")) {
				eraseDatabase = true;
			} else if (args[i].equals("-c") || args[i].equals("--classes")) {
				classList = new File(args[++i]);
				if (!classList.canRead()) {
					System.err.println("Cannot read from: " + classList);
					classList = null;
				}
			} else if (args[i].equals("-a") || args[i].equals("--advisors")) {
				advisorList = new File(args[++i]);
				if (!advisorList.canRead()) {
					System.err.println("Cannot read from: " + advisorList);
					advisorList = null;
				}
			} else if (args[i].equals("-b") || args[i].equals("--birthdays")) {
				birthdayList = new File(args[++i]);
				if (!birthdayList.canRead()) {
					System.err.println("Cannot read from: " + birthdayList);
					birthdayList = null;
				}
			} else if (args[i].equals("-r") || args[i].equals("--rooms")) {
				roomList = new File(args[++i]);
				if (!roomList.canRead()) {
					System.err.println("Cannot read from: " + roomList);
					roomList = null;
				}
			} else if (args[i].equals("-t") || args[i].equals("--t-passwd")) {
				tPass = args[++i];
			} else if (args[i].equals("-h") || args[i].equals("--help")) {
				printHelp();
				return;
			} else if (args[i].equals("-m") || args[i].equals("--merge")){
				shouldMerge = true;
			}
		}

		connectDatabase();

		if (initDatabase) {
			initalize();
		}

		if (eraseDatabase) {
			erase();
		}

		if (classList != null) {
			loadClassList();
		}

		if (advisorList != null) {
			loadAdvisorList();
		}

		if (birthdayList != null) {
			loadPasswords();
		}

		if (roomList != null) {
			loadRooms();
		}

		if (tPass != null) {
			setTeacherPassword();
		}

		try {
			connect.close();
		} catch (SQLException e) {
			System.err
					.println("Error closing database, but it doesn't matter because we are done!"
							+ e);
		}
	}

	public void printHelp() {
		System.out
				.println("Syntax:\n"
						+ "         java LoadData [-h hostname] [-u username] [-d database] [-e] [-i]\n"
						+ "                       [-c classList.csv] [-a advisorList.csv]\n"
						+ "                       [-p birthdayList.csv]\n"
						+ "\n"
						+ "         -h hostname   --server     Database server hostname\n"
						+ "                                      (default: 127.0.0.1)\n"
						+ "         -p password   --password   Database password\n"
						+ "                                      (default: none)\n"
						+ "         -u username   --user       Database username (default: scheduler)\n"
						+ "         -d database   --database   Database name (default: scheduler)\n"
						+ "         -e            --erase      Erase the contents of the database\n"
						+ "         -i            --initalize  Create the template for the database\n"
						+ "                                        (Not needed after an erase.)\n"
						+ "         -c classList  --classes    Load class list\n"
						+ "         -a advisors   --advisors   Load advisor list\n"
						+ "         -b birthdays  --birthdays  Load password list (Usually birthdays)\n"
						+ "         -r rooms      --rooms      Load lists of conference rooms\n"
						+ "         -t password   --t-passwd   Set teacher password\n"
						+ "			-m			  --merge	   Prompt to merge siblings");
	}

	public void connectDatabase() {
		try {
			Class.forName("com.mysql.jdbc.Driver").newInstance();
			connect = DriverManager.getConnection("jdbc:mysql://" + hostname
					+ "/" + database, username, dbpass);
			connect.setAutoCommit(true);
		} catch (Exception e) {
			System.err.println("Error opening database: " + e);
			System.exit(-1);
		}
	}

	public void initalize() {
		// Create the tables.
		System.out
				.println("Initializing a blank database has not been implemented yet.");
	}

	public void erase() {
		// Remove all data from tables. Leave permanent configuration.
		try {
			Statement state = connect.createStatement(
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
			state.executeUpdate("DELETE FROM available");
			state.executeUpdate("DELETE FROM classMembers");
			state.executeUpdate("DELETE FROM classes");
			state.executeUpdate("DELETE FROM conference");
			state.executeUpdate("DELETE FROM preferences");
			state.executeUpdate("DELETE FROM students");
			state.executeUpdate("DELETE FROM teachers");
		} catch (SQLException e) {
			System.err.println("Error erasing data! " + e);
		}
	}

	public void loadClassList() {
		System.out.println("Loading Class List");
		try {
			PreparedStatement queryStudent = connect.prepareStatement(
					"SELECT studentID, name FROM students WHERE name = ?",
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
			PreparedStatement queryTeacher = connect.prepareStatement(
					"SELECT teacherID, name FROM teachers WHERE name = ?",
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
			PreparedStatement queryClass = connect
					.prepareStatement(
							"SELECT classID, name, teacherID FROM classes WHERE name = ? AND teacherID = ?",
							ResultSet.TYPE_SCROLL_INSENSITIVE,
							ResultSet.CONCUR_UPDATABLE);
			PreparedStatement queryMembers = connect
					.prepareStatement(
							"SELECT classID, studentID FROM classMembers WHERE classID = ? AND studentID = ?",
							ResultSet.TYPE_SCROLL_INSENSITIVE,
							ResultSet.CONCUR_UPDATABLE);

			CSVParser parse = new CSVParser(new FileInputStream(classList));

			String[] line;
			for (line = parse.getLine(); line != null; line = parse.getLine()) {
				System.out.println(line);
				System.out.println("hi");
				String name = cleanStudentName(line[0]);
				queryStudent.setString(1, name);
				ResultSet results = queryStudent.executeQuery();
				int studentID = 0;
				if (results.first()) {
					studentID = results.getInt(1);
				} else {
					results.moveToInsertRow();
					results.updateString(2, name);
					results.insertRow();
					results.close();
					results = queryStudent.executeQuery();
					results.first();
					studentID = results.getInt(1);
				}
				results.close();

				String tname = cleanTeacherName(line[2]);
				int teacherID = 0;
				queryTeacher.setString(1, tname);
				results = queryTeacher.executeQuery();
				if (results.first()) {
					teacherID = results.getInt(1);
				} else {
					results.moveToInsertRow();
					results.updateString(2, tname);
					results.insertRow();
					results.close();
					results = queryTeacher.executeQuery();
					results.first();
					teacherID = results.getInt(1);
				}
				results.close();

				int classID = 0;
				queryClass.setString(1, line[1]);
				queryClass.setInt(2, teacherID);
				results = queryClass.executeQuery();
				if (results.first()) {
					classID = results.getInt(1);
				} else {
					results.moveToInsertRow();
					results.updateString(2, line[1]);
					results.updateInt(3, teacherID);
					results.insertRow();
					results.close();
					results = queryClass.executeQuery();
					results.first();
					classID = results.getInt(1);
				}
				results.close();

				queryMembers.setInt(1, classID);
				queryMembers.setInt(2, studentID);
				results = queryMembers.executeQuery();
				if (results.first()) {
					System.out.println("Duplicate entry! (" + name + ","
							+ line[1] + "," + tname + ") Ignoring.");
				} else {
					results.moveToInsertRow();
					results.updateInt(1, classID);
					results.updateInt(2, studentID);
					results.insertRow();
				}
				results.close();
			}

			queryStudent.close();
			queryTeacher.close();
			queryClass.close();
			queryMembers.close();
		} catch (Exception e) {
			System.err.println("Error loading classes! " + e);
			e.printStackTrace();
			System.exit(-3);
		}
	}

	public void loadAdvisorList() {
		try {
			PreparedStatement queryStudent = connect.prepareStatement(
					"SELECT studentID, name FROM students WHERE name = ?",
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
			PreparedStatement queryTeacher = connect.prepareStatement(
					"SELECT teacherID, name FROM teachers WHERE name = ?",
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
			PreparedStatement queryClass = connect
					.prepareStatement(
							"SELECT classID, name, teacherID FROM classes WHERE name = ? AND teacherID = ?",
							ResultSet.TYPE_SCROLL_INSENSITIVE,
							ResultSet.CONCUR_UPDATABLE);
			PreparedStatement queryMembers = connect
					.prepareStatement(
							"SELECT classID, studentID FROM classMembers WHERE classID = ? AND studentID = ?",
							ResultSet.TYPE_SCROLL_INSENSITIVE,
							ResultSet.CONCUR_UPDATABLE);

			CSVParser parse = new CSVParser(new FileInputStream(advisorList));
			String[] line;
			for (line = parse.getLine(); line != null; line = parse.getLine()) {
				String name = cleanStudentName(line[0]);
				queryStudent.setString(1, name);
				ResultSet results = queryStudent.executeQuery();
				int studentID = 0;
				if (results.first()) {
					studentID = results.getInt(1);
				} else {
					results.moveToInsertRow();
					results.updateString(2, name);
					results.insertRow();
					results.close();
					results = queryStudent.executeQuery();
					results.first();
					studentID = results.getInt(1);
				}
				results.close();

				String tname = cleanTeacherName(line[1]);
				int teacherID = 0;
				queryTeacher.setString(1, tname);
				results = queryTeacher.executeQuery();
				if (results.first()) {
					teacherID = results.getInt(1);
				} else {
					results.moveToInsertRow();
					results.updateString(2, tname);
					results.insertRow();
					results.close();
					results = queryTeacher.executeQuery();
					results.first();
					teacherID = results.getInt(1);
				}
				results.close();

				int classID = 0;
				queryClass.setString(1, "Advisor");
				queryClass.setInt(2, teacherID);
				results = queryClass.executeQuery();
				if (results.first()) {
					classID = results.getInt(1);
				} else {
					results.moveToInsertRow();
					results.updateString(2, "Advisor");
					results.updateInt(3, teacherID);
					results.insertRow();
					results.close();
					results = queryClass.executeQuery();
					results.first();
					classID = results.getInt(1);
				}
				results.close();

				queryMembers.setInt(1, classID);
				queryMembers.setInt(2, studentID);
				results = queryMembers.executeQuery();
				if (results.first()) {
					System.out.println("Duplicate entry! (" + line[0]
							+ ",Advisor," + line[1] + ") Ignoring.");
				} else {
					results.moveToInsertRow();
					results.updateInt(1, classID);
					results.updateInt(2, studentID);
					results.insertRow();
				}
				results.close();
			}

			queryStudent.close();
			queryTeacher.close();
			queryClass.close();
			queryMembers.close();
		} catch (Exception e) {
			System.err.println("Error loading advisor list! " + e);
			System.exit(-2);
		}
	}

	public void loadPasswords() {
		try {
			PreparedStatement hashPassword = connect
					.prepareStatement("SELECT PASSWORD( ? )");
			PreparedStatement queryStudent = connect
					.prepareStatement(
							"SELECT studentID, name, password FROM students WHERE name = ?",
							ResultSet.TYPE_SCROLL_INSENSITIVE,
							ResultSet.CONCUR_UPDATABLE);

			CSVParser parse = new CSVParser(new FileInputStream(birthdayList));

			String[] line;
			for (line = parse.getLine(); line != null; line = parse.getLine()) {
				String name = cleanStudentName(line[0]);
				hashPassword.setString(1, line[1]);
				ResultSet results = hashPassword.executeQuery();
				results.first();
				String pass = results.getString(1);
				results.close();

				queryStudent.setString(1, name);
				results = queryStudent.executeQuery();
				if (results.first()) {
					results.updateString(3, pass);
					results.updateRow();
				} else {
					results.moveToInsertRow();
					results.updateString(2, name);
					results.updateString(3, pass);
					results.insertRow();
				}
				results.close();
			}

			hashPassword.close();
			queryStudent.close();
		} catch (Exception e) {
			System.err.println("Error loading password list! " + e);
			System.exit(-4);
		}
	}

	public void loadRooms() {
		try {
			PreparedStatement queryTeacher = connect
					.prepareStatement(
							"SELECT teacherID, name, room FROM teachers WHERE name = ?",
							ResultSet.TYPE_SCROLL_INSENSITIVE,
							ResultSet.CONCUR_UPDATABLE);

			CSVParser parse = new CSVParser(new FileInputStream(roomList));

			String[] line;
			for (line = parse.getLine(); line != null; line = parse.getLine()) {
				String name = cleanTeacherName(line[0]);
				queryTeacher.setString(1, name);
				ResultSet results = queryTeacher.executeQuery();
				if (results.first()) {
					results.updateString(3, line[1]);
					results.updateRow();
				} else {
					results.moveToInsertRow();
					results.updateString(2, name);
					results.updateString(3, line[1]);
					results.insertRow();
				}
				results.close();
			}

			queryTeacher.close();
		} catch (Exception e) {
			System.err.println("Error loading room list! " + e);
			System.exit(-5);
		}
	}

	public void findAndMergeSiblings(){
		PreparedStatement statement = connect.prepareStatement("SELECT students.studentID, s2.studentID, students.name, s2.name " + 
															   "FROM students JOIN students AS s2 ON SUBSTRING_INDEX(students.name, ',', 1) " + 
															   "LIKE SUBSTRING_INDEX(s2.name, ',', 1) WHERE students.studentID < s2.studentID;");
		ResultSet matches = statement.executeQuery();

		while(matches.next()){

			if(promptSiblings(matches.getString(3), matches.getString(4))){
				mergeSiblings(matches.getInt(1), matches.getString(3), matches.getInt(2), matches.getString(4));
			}
		}

	}

	public Boolean promptSiblings(String name1, String name2){
		System.out.printf("%s and %s detected as potential siblings. Merge into one? (Y/N): ", name1, name2);
		String input = System.console().readLine();
		if(input.equalsIgnoreCase("y") || input.equalsIgnoreCase("yes")){
			return true;
		} else if (input.equalsIgnoreCase("n") || input.equalsIgnoreCase("no")) {
			return false;
		} else {
			return promptSiblings(name1, name2);
		}
	}

	public void mergeSiblings(int id1, String name1, int id2, String name2){
		System.out.printf("Merging %s and %s\n", name1, name2);
		// Move the 2nd student's classes and student row to the first's
		PreparedStatement moveClasses = connect.prepareStatement("UPDATE classMembers SET studentID = " + id1 + " WHERE studentID = " + id2 + ";");
		PreparedStatement moveStudent = connect.prepareStatement("DELETE FROM students WHERE studentID = " + id2 + ";");
		moveClasses.execute();
		moveStudent.execute();
		// Delete duplicate classes and students
		// DO this on friday
	}

	public void setTeacherPassword() {
		try {
			PreparedStatement hashPassword = connect
					.prepareStatement("SELECT PASSWORD( ? )");
			hashPassword.setString(1, tPass);
			ResultSet results = hashPassword.executeQuery();
			results.first();
			String pass = results.getString(1);
			results.close();
			hashPassword.close();

			PreparedStatement queryTeachers = connect.prepareStatement(
					"SELECT teacherID, password FROM teachers",
					ResultSet.TYPE_SCROLL_INSENSITIVE,
					ResultSet.CONCUR_UPDATABLE);
			results = queryTeachers.executeQuery();
			while (results.next()) {
				results.updateString(2, pass);
				results.updateRow();
			}
			results.close();
			queryTeachers.close();
		} catch (Exception e) {
			System.err.println("Error setting teacher passwords! " + e);
			System.exit(-6);
		}
	}

	public String cleanStudentName(String name) {
		/*
		 * int i = name.indexOf( ',' ); if ( i >= 0 ) { return name.substring(
		 * i+2, name.length() ) + " " + name.substring( 0, i ); } return name;
		 */
		return cleanTeacherName(name); // Now that we are formatting the names
										// the same way, use the same code.
	}

	public String cleanTeacherName(String name) {
		int i = name.indexOf(',');
		if (i < 0) {
			i = name.indexOf(' ');
			return name.substring(i + 1, name.length()) + ", "
					+ name.substring(0, i);
		}
		return name;
	}

	public String firstNameOf(String name){
		int i = name.indexOf(',')
		name.substring(i + 1, name.length());
	}

	public String lastNameOf(String name){
		int i = name.indexOf(',');
		return name.substring(0, i);
	}
}
