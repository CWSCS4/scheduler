<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Conferences Scheduled for <%= teacherName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/teacher_header.jsp" %>
<h2>Conferences Scheduled for <%= teacherName %></h2>
<h3>Location: <%= teacherRoom %></h3>
<p>You have been scheduled for the following conferences:</p>
<%

ResultSet results = state.executeQuery( "SELECT students.name, start FROM conference LEFT JOIN students ON conference.studentID = students.studentID WHERE teacherID = " + teacherID + " ORDER BY start" );
%>
<table border="1">
<tr><td>Student</td><td>Time</td></tr>
<%
while (results.next()) {
	DateFormat ddf = new SimpleDateFormat("MMMM, d @ h:mm a"); %>
    <tr>
		<td><%= results.getString(1) %></td>
		<td><%= ddf.format(results.getTimestamp(2)) %></td>
	</tr>
<% } %>
</table>
</body>
</html>
