<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Conferences Scheduled for <%= studentName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/header.jsp" %>
<h2>Conferences Scheduled for <%= studentName %></h2>
<p>You have been scheduled for the following conferences:</p>
<%
ResultSet results = state.executeQuery("SELECT teachers.name, teachers.room, conference.start FROM conference LEFT JOIN teachers ON conference.teacherID = teachers.teacherID WHERE studentID = " + studentID + " ORDER BY start");
%>
<table cols="3">
<tr><th>Teacher</th><th>Time</th><th>Room</th></tr>
<%
while (results.next()) { 
    DateFormat ddf = new SimpleDateFormat("MMMM d 'at' h:mm a"); %>
    <tr><td><%= results.getString(1) %></td><td><%= ddf.format(results.getTimestamp(3)) %></td><td><%= results.getString(2) %></td></tr>
<% } %>
</table>
<h4>Refreshments will be available all day in the library.</h4>
<h4> You are welcome to stop by anytime!</h4>
<p>As the schedule has already been generated,
you can no longer enter or change your preferences.
If there is a problem please call the school.</p>
</body>
</html>
