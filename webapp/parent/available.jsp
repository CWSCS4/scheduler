<%@ include file="/include/init.jsp" %>

<%
int numberOfTimeSlots = 0;

Statement state = connect.createStatement();
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Availability Information</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<h2>Availability Information for <%= studentName %>'s Teachers</h2>
<%
ResultSet results = state.executeQuery("SELECT teachers.teacherID, teachers.name, classes.name, start, end FROM available LEFT JOIN teachers ON available.ID = teachers.teacherID LEFT JOIN classes ON teachers.teacherID = classes.teacherID LEFT JOIN classMembers ON classMembers.classID = classes.classID WHERE available.type = 1 AND classMembers.studentID = " + studentID);

int lastID = -1;

while (results.next()) {
    if (lastID != results.getInt(1)) {
       %></ul><p><%= results.getString(2) %> (<%= results.getString(3) %>):
       <ul><%
    }
    lastID = results.getInt(1);
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance();
    %><li><%= ddf.format(results.getTimestamp(4) ) + " " + tdf.format(results.getTimestamp(4)) %> - <%= tdf.format(results.getTimestamp(5)) %></li>
<% } %>
</body>
</html>
