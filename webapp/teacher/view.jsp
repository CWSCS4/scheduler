<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Conference Information for <%= teacherName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/teacher_header.jsp" %>
<h2>Conference Information for <%= teacherName %></h2>

You have indicated that you will be available for the following time slots:
<ul><%

ResultSet results = state.executeQuery( "SELECT start, end FROM available WHERE type = 1 AND ID = " + teacherID );

while( results.next() ) { 
        DateFormat tdf = new SimpleDateFormat("h:mm a");
        DateFormat ddf = DateFormat.getDateInstance();
    %><li><%= ddf.format( results.getTimestamp( 1 ) ) + ": " + tdf.format( results.getTimestamp( 1 ) ) %> - <%= tdf.format( results.getTimestamp( 2 ) ) %></li>
<% } %></ul>

<p />

<p>You have selected that you would like to meet with the following students
in the priority listed: (9 is highest priority)</p>
<p>
<% results = state.executeQuery( "SELECT students.name, rank FROM preferences LEFT JOIN students ON preferences.withID = students.studentID WHERE isTeacher = 1 AND ID = " + teacherID + " ORDER BY preferences.rank" ); %>
<table border="1">
<tr><td>Priority</td><td>Student</td></tr>
<%
while(results.next()) { %>
    <tr><td><%= results.getInt( 2 ) %></td><td><%= results.getString( 1 ) %></td></tr>
<% } %>
</table>
<br>

<%
results = state.executeQuery( "SELECT email FROM teachers WHERE teacherID = " + teacherID );
results.first();
%>
<!-- [areyzin] disabled emails
<p>You have indicated that you wish your final schedule to be emailed to
"<%= results.getString( 1 ) %>".</p>
-->

<p>Please click <a href="/teacher/request.jsp">here</a> if you would like to
change this information by redoing the signup procedure.</p>

</body>
</html>
