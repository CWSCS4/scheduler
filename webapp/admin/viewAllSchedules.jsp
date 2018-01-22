<%@ include file="/include/init.jsp" %>
<% Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );%>
<% Statement state2 = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );%>

<%@ include file="/include/doctype.jsp" %>


<% ResultSet distinctStudentIDs = state.executeQuery( "SELECT distinct studentID, name FROM students"); %>

<html>
<head>
    <%@ include file="/include/meta.jsp" %>
    <title>Conference Schedules</title>
</head>
<body>
<% while (distinctStudentIDs.next()) { 
    ResultSet results = state2.executeQuery( "SELECT teachers.name, teachers.room, conference.start, students.name FROM ((conference LEFT JOIN students ON students.studentID = conference.studentID) LEFT JOIN teachers ON teachers.teacherID = conference.teacherID) WHERE students.studentID = " + distinctStudentIDs.getInt(1));%>
    <h2 style="page-break-before:always">Conferences for <%= distinctStudentIDs.getString(2) %> </h2>
    <p> Welcome! You have been scheduled for the following conferences. Each one will last for 8 minutes, and starts at the indicated time.</p>
    <table cols="3">
        <tr><th>Teacher</th><th>Time</th><th>Room</th></tr>
        <% while (results.next()) { 
            DateFormat tdf = new SimpleDateFormat("h:mm a");
            Timestamp start = (results.getTimestamp(3));
        %>   <tr><td><%= results.getString(1) %></td><td><%=  tdf.format(start) %> </td><td><%= results.getString(2) %></td></tr>
        <% } %>
    </table>
    <h4>Refreshments will be available all day in the library.</h4>
    <h4> You are welcome to stop by anytime!</h4>
    
<% } %>

</body>
</html>
    