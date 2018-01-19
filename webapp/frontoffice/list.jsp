<%@ include file="/include/init.jsp" %>

<%
Statement state = null;

String filter = request.getParameter("filter");
boolean showSignedIn  = true;
boolean showPrefs = true;
boolean showAvail = true;
boolean showStudents = true;
boolean showTeachers = true;

if (filter != null) {
	if (filter.contains("nosignin")) showSignedIn = false;
	if (filter.contains("noprefs")) showPrefs = false;
	if (filter.contains("noavail")) showAvail = false;
	if (filter.contains("students")) showTeachers = false;
	if (filter.contains("teachers")) showStudents = false;
}

int id;
String name;
boolean signedIn, prefs, avail;

state = connect.createStatement();
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>User List</title>
<%@ include file="/include/meta.jsp" %> 
<style type="text/css">
.name {
    width: 20em;
    font-weight: bold;
}
.signedin, .prefs, .avail {
    width: 10em;
    font-weight: bold;
    text-align: center;
}
.signedin-yes, .prefs-yes, .avail-yes {
    color: green;
}
.signedin-no, .prefs-no, .avail-no {
    color: red;
    text-transform: uppercase;
}
</style>
</head>
<body>
<%@ include file="/include/front_office_header.jsp" %>
<h2>User List</h2>
<form method="get" action="list.jsp">
<fieldset>
<legend accesskey="f">Filter</legend>
<select name="filter">
<option value="<%= filter %>"></option>
<option value="">All students and teachers</option>
<option value="students">All students</option>
<option value="students,noprefs">Students without preference information</option>
<option value="students,noavail">Students without availability information</option>
<option value="students,nosignin">Students who have not signed in at all</option>
<option value="teachers">All teachers</option>
<option value="teachers,noprefs">Teachers without preference information</option>
<option value="teachers,noavail">Teachers without availability information</option>
<option value="teachers,nosignin">Teachers who have not signed in at all</option>
</select>
<input type="submit" value="Show"/>
</fieldset>
</form>
<%
Vector teacherHasPreferences = new Vector();
Vector studentHasPreferences = new Vector();
ResultSet results = state.executeQuery( "SELECT ID, isTeacher FROM preferences" );
while (results.next()) {
       if (results.getInt(2) == 0) {
       	  if (!studentHasPreferences.contains(new Integer(results.getInt(1)))) {
	     studentHasPreferences.add(new Integer(results.getInt(1)));
	  }
       } else if (results.getInt(2) == 1) {
       	  if (!teacherHasPreferences.contains(new Integer(results.getInt(1)))) {
	     teacherHasPreferences.add(new Integer(results.getInt(1)));
	  }
       }
}

Vector teacherHasAvailability = new Vector();
Vector studentHasAvailability = new Vector();
results = state.executeQuery( "SELECT ID, type FROM available" );
while (results.next()) {
       if (results.getInt(2) == 0) {
       	  if (!studentHasAvailability.contains(new Integer(results.getInt(1)))) {
	     studentHasAvailability.add(new Integer(results.getInt(1)));
	  }
       } else if (results.getInt(2) == 1) {
       	  if (!teacherHasAvailability.contains(new Integer(results.getInt(1)))) {
	     teacherHasAvailability.add(new Integer(results.getInt(1)));
	  }
       }
}

if (showStudents) { %>
<h3>Students</h3>
<table cols="4">
<tr>
	<th>Name</th>
	<th>Has signed in</th>
	<th>Has specified<br />availability</th>
	<th>Has specified<br />preferences</th>
</tr>
<% results = state.executeQuery( "SELECT studentID, name, hasSignedIn, hasSetAvail, hasSetPrefs FROM students ORDER BY name" );

while (results.next()) { %>
<%
	id = results.getInt(1);
	name = results.getString(2);
	signedIn = results.getInt(3) != 0;
	avail    = results.getInt(4) != 0;
	prefs    = results.getInt(5) != 0;
/*	avail = studentHasAvailability.contains(new Integer(id));
	prefs = studentHasPreferences.contains(new Integer(id)); */
	
	if (signedIn && !showSignedIn) continue;
	if (avail    && !showAvail)    continue;
	if (prefs    && !showPrefs)    continue;
%>

<tr class="student">
<td class="name"><%= name %></td>
<td class="signedin <%= signedIn ? "signedin-yes" : "signedin-no" %>"><%= signedIn ? "Yes" : "No" %></td>
<td class="avail <%= avail ? "avail-yes" : "avail-no" %>"><%= avail ? "Yes" : "No" %></td>
<td class="prefs <%= prefs ? "prefs-yes" : "prefs-no" %>"><%= prefs ? "Yes" : "No" %></td>
</tr>

<% } %>
</table>
<% }

if (showTeachers) { %>
<h3>Teachers</h3>
<table cols="4">
<%
results = state.executeQuery( "SELECT teacherID, name, hasSignedIn, hasSetAvail, hasSetPrefs FROM teachers ORDER BY name" );

while (results.next()) { %>
<%
	id = results.getInt(1);
	name = results.getString(2);
	signedIn = results.getInt(3) == 1;
	avail = results.getInt(4) != 0;
	prefs = results.getInt(5) != 0;
/*	avail = studentHasAvailability.contains(new Integer(id));
	prefs = studentHasPreferences.contains(new Integer(id)); */
	
	if (signedIn && !showSignedIn) continue;
	if (avail    && !showAvail)    continue;
	if (prefs    && !showPrefs)    continue;
%>

<tr>
<td class="name"><%= name %></td>
<td class="signedin <%= signedIn ? "signedin-yes" : "signedin-no" %>"><%= signedIn ? "Yes" : "No" %></td>
<td class="avail <%= avail ? "avail-yes" : "avail-no" %>"><%= avail ? "Yes" : "No" %></td>
<td class="prefs <%= prefs ? "prefs-yes" : "prefs-no" %>"><%= prefs ? "Yes" : "No" %></td>
</tr>
<% } %>
</table>
<% } %>
</body>
</html>
