<%@ include file="/include/init.jsp" %>

<%
Statement state = null;
int numberOfTimeSlots = 0;
state = connect.createStatement(ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE);
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Add Conference</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/admin_header.jsp" %>
<% if (request.getParameter("submitted") == null || !request.getParameter("submitted").equals("yes")) { %>
<h2>Add Conference</h2>
<form action="add_conference.jsp" method="post">

<p>Student: <select name="student_name">
<%
ResultSet students = state.executeQuery("SELECT name, studentID FROM students ORDER BY name");
while (students.next()) { %>
<option value="<%= students.getInt(2) %>"><%= students.getString(1) %></option>
<% } %>
</select></p>

<p>Teacher: <select name="teacher_name">
<%
ResultSet teachers = state.executeQuery( "SELECT name, teacherID FROM teachers ORDER BY name" );
while (teachers.next()) { %>
<option value="<%= teachers.getInt( 2 ) %>"><%= teachers.getString( 1 ) %></option>
<% } %>
</select></p>

<%
ResultSet period = state.executeQuery( "SELECT * FROM conferencePeriod" );
Calendar current = Calendar.getInstance();
Calendar cal = Calendar.getInstance();
period.next();
cal.setTime( period.getTimestamp( 1 ) );
%>

<p><select name="month">
<option value="-1"></option>
<option value="1" <%= ( cal.get( Calendar.MONTH ) == Calendar.JANUARY ) ? "SELECTED" : "" %>>January</option>
<option value="2" <%= ( cal.get( Calendar.MONTH ) == Calendar.FEBRUARY ) ? "SELECTED" : "" %>>February</option>
<option value="3" <%= ( cal.get( Calendar.MONTH ) == Calendar.MARCH ) ? "SELECTED" : "" %>>March</option>
<option value="4" <%= ( cal.get( Calendar.MONTH ) == Calendar.APRIL ) ? "SELECTED" : "" %>>April</option>
<option value="5" <%= ( cal.get( Calendar.MONTH ) == Calendar.MAY ) ? "SELECTED" : "" %>>May</option>
<option value="6" <%= ( cal.get( Calendar.MONTH ) == Calendar.JUNE ) ? "SELECTED" : "" %>>June</option>
<option value="7" <%= ( cal.get( Calendar.MONTH ) == Calendar.JULY ) ? "SELECTED" : "" %>>July</option>
<option value="8" <%= ( cal.get( Calendar.MONTH ) == Calendar.AUGUST ) ? "SELECTED" : "" %>>August</option>
<option value="9" <%= ( cal.get( Calendar.MONTH ) == Calendar.SEPTEMBER ) ? "SELECTED" : "" %>>September</option>
<option value="10" <%= ( cal.get( Calendar.MONTH ) == Calendar.OCTOBER ) ? "SELECTED" : "" %>>October</option>
<option value="11" <%= ( cal.get( Calendar.MONTH ) == Calendar.NOVEMBER ) ? "SELECTED" : "" %>>November</option>
<option value="12" <%= ( cal.get( Calendar.MONTH ) == Calendar.DECEMBER ) ? "SELECTED" : "" %>>December</option>
</select>
<select name="day">
<option value="-1"></option>
<%for ( int i = 1; i <= 31; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.DAY_OF_MONTH ) == i ) ? "SELECTED" : "" %>><%= i %></option><%
}%>
</select>
, <select name="year">
<option value="-1"></option>
<option value="<%= current.get( Calendar.YEAR )-1 %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR )-1 ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR )-1 %></option>
<option value="<%= current.get( Calendar.YEAR ) %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR ) ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR ) %></option>
<option value="<%= current.get( Calendar.YEAR )+1 %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR )+1 ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR )+1 %></option>
</select>
 <select name="hour">
<option value="-1"></option>
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.HOUR ) == i % 12 ) ? "SELECTED" : "" %>><%= i %></option><%
}%>
</select>:<select name="minute">
<option value="-1"></option>
<%for ( int i = 0; i < 60; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.MINUTE ) == i ) ? "SELECTED" : "" %>><%= ( i < 10 ) ? "0"+i : ""+i %></option><%
}%>
</select> <select name="pm">
<option value="-1"></option>
<option value="0" <%= ( cal.get( Calendar.AM_PM ) == Calendar.AM ) ? "SELECTED" : "" %>>am</option>
<option value="1" <%= ( cal.get( Calendar.AM_PM ) == Calendar.PM ) ? "SELECTED" : "" %>>pm</option>
</select> <p>

<p><input type="submit" value="Continue"/></p>
<input type="hidden" name="submitted" value="yes"/>
</form>
<% } else {
state.executeUpdate("INSERT INTO conferences values ");
}
%><jsp:forward page="admin.jsp" /><%
} %>
</body>
</html>
