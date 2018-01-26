<%@ include file="/include/init.jsp" %>
<%@ include file="/include/doctype.jsp" %>

<%
Statement state = null;
state = connect.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Duplicate Student</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<% if (request.getParameter("submitted") == null || !request.getParameter("submitted").equals("yes")) { %>
<h2>Duplicate Student</h2>
<form action="Duplicate_Student.jsp" method="post">
<p>Student: <select name="student_name">
<%
ResultSet students = state.executeQuery("SELECT name, studentID FROM students ORDER BY name");
while (students.next()) { %>
<option value="<%= students.getInt(2) %>"><%= students.getString(1) %></option>
<% } %>
</select>
<p>By default duplicate will have the same availibility and conference preferences.</p>
<p><input type="submit" value="Continue"/></p>
<input type="hidden" name="submitted" value="yes"/>
</form>
<% } else {
//Duplicate Students Page
ResultSet results=state.executeQuery("SELECT MAX(studentID) FROM students");
results.next();
int duplicateID=results.getInt(1)+1;
PreparedStatement getName =connect.prepareStatement("SELECT name FROM students WHERE studentID = ?");
getName.setInt(1, Integer.parseInt(request.getParameter("student_name")));
results=getName.executeQuery();
results.next();
String name=results.getString(1);
PreparedStatement getPass =connect.prepareStatement("SELECT password FROM students WHERE studentID = ?");
getPass.setInt(1, Integer.parseInt(request.getParameter("student_name")));
results=getPass.executeQuery();
results.next();
String pass=results.getString(1);
PreparedStatement getAvail =connect.prepareStatement("SELECT hasSetAvail FROM students WHERE studentID = ?");
getAvail.setInt(1, Integer.parseInt(request.getParameter("student_name")));
results=getAvail.executeQuery();
results.next();
int avail=results.getInt(1);
PreparedStatement getPrefs =connect.prepareStatement("SELECT hasSetPrefs FROM students WHERE studentID = ?");
getPrefs.setInt(1, Integer.parseInt(request.getParameter("student_name")));
results=getPrefs.executeQuery();
results.next();
int prefs=results.getInt(1);
PreparedStatement duplicate = connect.prepareStatement("INSERT INTO students (studentID,name,password,hasSetAvail,hasSetPrefs) VALUES (?, ?, ?, ?, ?)");
duplicate.setInt(1,duplicateID);
duplicate.setString(2,name);
duplicate.setString(3,pass);
duplicate.setInt(4,avail);
duplicate.setInt(5,prefs);
duplicate.executeUpdate();
//Duplicate Preferences Table
PreparedStatement getPrefsTable =connect.prepareStatement("SELECT * FROM preferences WHERE ID = ?");
getPrefsTable.setInt(1, Integer.parseInt(request.getParameter("student_name")));
results=getPrefsTable.executeQuery();
while(results.next()){
    int isTeacher=results.getInt(2);
    int withID=results.getInt(3);
    int rank=results.getInt(4);
    int max_conferences=results.getInt(5);
    PreparedStatement duplicatePrefs = connect.prepareStatement("INSERT INTO preferences VALUES (?, ?, ?, ?, ?)");
    duplicatePrefs.setInt(1,duplicateID);
    duplicatePrefs.setInt(2,isTeacher);
    duplicatePrefs.setInt(3,withID);
    duplicatePrefs.setInt(4,rank);
    duplicatePrefs.setInt(5,max_conferences);
    duplicatePrefs.executeUpdate();
}
//Duplicate Availible Table
PreparedStatement getAvailableTable =connect.prepareStatement("SELECT * FROM available WHERE ID = ?");
getAvailableTable.setInt(1, Integer.parseInt(request.getParameter("student_name")));
results=getAvailableTable.executeQuery();
while(results.next()){
    int type=results.getInt(2);
    Timestamp start=results.getTimestamp(3);
    Timestamp end=results.getTimestamp(4);
    PreparedStatement duplicateAvailability = connect.prepareStatement("INSERT INTO available VALUES (?, ?, ?, ?)");
    duplicateAvailability.setInt(1,duplicateID);
    duplicateAvailability.setInt(2,type);
    duplicateAvailability.setTimestamp(3,start);
    duplicateAvailability.setTimestamp(4,end);
    duplicateAvailability.executeUpdate();
}
//Duplicate classmembers table
PreparedStatement getClassMembersTable =connect.prepareStatement("SELECT * FROM classmembers WHERE studentID = ?");
getClassMembersTable.setInt(1, Integer.parseInt(request.getParameter("student_name")));
results=getClassMembersTable.executeQuery();
while(results.next()){
    int classID=results.getInt(1);
    PreparedStatement duplicateCourses = connect.prepareStatement("INSERT INTO classmembers VALUES (?, ?)");
    duplicateCourses.setInt(2,duplicateID);
    duplicateCourses.setInt(1,classID);
    duplicateCourses.executeUpdate();
}
%>  <jsp:forward page="index.jsp" /><% 



}%>
</body>
</html>
