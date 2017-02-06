<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN">
<html>

<%@ page import="org.commschool.scheduler.db.*" %>
<%@ page import="java.sql.*" %>
<%@ page import="java.util.*" %>
<%@ page import="java.text.DateFormat" %>

<%
Connection connect = (Connection)session.getAttribute( "db" );
Statement state = null;

int numberOfTimeSlots = 0;

if ( session.getAttribute( "admin" ) != Boolean.TRUE ) {
   %><jsp:forward page="admin.jsp" /><%
}

try {
    state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
} catch ( SQLException e ) {
    %>Internal SQL Error.<%
}
%>

<head>
  <meta http-equiv="content-type"
 content="text/html; charset=ISO-8859-1">
  <title>Set Conference Period</title>
</head>
<body bgcolor="#cccccc">
<img src="images/flower_tech_2.jpg" />
<% if ( request.getParameter( "submitted" ) == null || !request.getParameter( "submitted" ).equals( "yes" ) ) { %>

<br><big><big style="font-weight: bold;">Set Conference Period</big></big><br>

<form action="setperiod.jsp" method="post">

<%
ResultSet results = state.executeQuery( "SELECT * FROM conferencePeriod" );

Calendar current = Calendar.getInstance();

Calendar cal = Calendar.getInstance();
Calendar tocal = Calendar.getInstance();

int j = 0;
for ( j = 0; results.next(); j++ ) {
cal.setTime( results.getTimestamp( 1 ) );
tocal.setTime( results.getTimestamp( 2 ) );
%><p><select name="month<%= j %>">
<option value="-1">
<option value="1" <%= ( cal.get( Calendar.MONTH ) == Calendar.JANUARY ) ? "SELECTED" : "" %>>January
<option value="2" <%= ( cal.get( Calendar.MONTH ) == Calendar.FEBRUARY ) ? "SELECTED" : "" %>>February
<option value="3" <%= ( cal.get( Calendar.MONTH ) == Calendar.MARCH ) ? "SELECTED" : "" %>>March
<option value="4" <%= ( cal.get( Calendar.MONTH ) == Calendar.APRIL ) ? "SELECTED" : "" %>>April
<option value="5" <%= ( cal.get( Calendar.MONTH ) == Calendar.MAY ) ? "SELECTED" : "" %>>May
<option value="6" <%= ( cal.get( Calendar.MONTH ) == Calendar.JUNE ) ? "SELECTED" : "" %>>June
<option value="7" <%= ( cal.get( Calendar.MONTH ) == Calendar.JULY ) ? "SELECTED" : "" %>>July
<option value="8" <%= ( cal.get( Calendar.MONTH ) == Calendar.AUGUST ) ? "SELECTED" : "" %>>August
<option value="9" <%= ( cal.get( Calendar.MONTH ) == Calendar.SEPTEMBER ) ? "SELECTED" : "" %>>September
<option value="10" <%= ( cal.get( Calendar.MONTH ) == Calendar.OCTOBER ) ? "SELECTED" : "" %>>October
<option value="11" <%= ( cal.get( Calendar.MONTH ) == Calendar.NOVEMBER ) ? "SELECTED" : "" %>>November
<option value="12" <%= ( cal.get( Calendar.MONTH ) == Calendar.DECEMBER ) ? "SELECTED" : "" %>>December
</select>
<select name="day<%= j %>">
<option value="-1">
<%for ( int i = 1; i <= 31; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.DAY_OF_MONTH ) == i ) ? "SELECTED" : "" %>><%= i %><%
}%>
</select>
, <select name="year<%= j %>">
<option value="-1">
<option value="<%= current.get( Calendar.YEAR )-1 %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR )-1 ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR )-1 %>
<option value="<%= current.get( Calendar.YEAR ) %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR ) ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR ) %>
<option value="<%= current.get( Calendar.YEAR )+1 %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR )+1 ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR )+1 %>
</select>
 <select name="hour<%= j %>">
<option value="-1">
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.HOUR ) == i ) ? "SELECTED" : "" %>><%= i %><%
}%>
</select>:<select name="minute<%= j %>">
<option value="-1">
<%for ( int i = 0; i < 60; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.MINUTE ) == i ) ? "SELECTED" : "" %>><%= ( i < 10 ) ? "0"+i : ""+i %><%
}%>
</select> <select name="pm<%= j %>">
<option value="-1">
<option value="0" <%= ( cal.get( Calendar.AM_PM ) == Calendar.AM ) ? "SELECTED" : "" %>>am
<option value="1" <%= ( cal.get( Calendar.AM_PM ) == Calendar.PM ) ? "SELECTED" : "" %>>pm
</select> - <select name="tohour<%= j %>">
<option value="-1">
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>" <%= ( tocal.get( Calendar.HOUR ) == i ) ? "SELECTED" : "" %>><%= i %><%
}%>
</select>:<select name="tominute<%= j %>">
<option value="-1">
<%for ( int i = 0; i < 60; i++ ) {
  %><option value="<%= i %>" <%= ( tocal.get( Calendar.MINUTE ) == i ) ? "SELECTED" : "" %>><%= ( i < 10 ) ? "0"+i : ""+i %><%
}%>
</select> <select name="topm<%= j %>">
<option value="-1">
<option value="0" <%= ( tocal.get( Calendar.AM_PM ) == Calendar.AM ) ? "SELECTED" : "" %>>am
<option value="1" <%= ( tocal.get( Calendar.AM_PM ) == Calendar.PM ) ? "SELECTED" : "" %>>pm
</select>
<%
}

numberOfTimeSlots = j+3;

for ( int k = j; k < j + 3; k++ ) {
// display 3 blank timeslots.
%><p><select name="month<%= k %>">
<option value="-1">
<option value="1">January
<option value="2">February
<option value="3">March
<option value="4">April
<option value="5">May
<option value="6">June
<option value="7">July
<option value="8">August
<option value="9">September
<option value="10">October
<option value="11">November
<option value="12">December
</select>
<select name="day<%= k %>">
<option value="-1">
<%for ( int i = 1; i <= 31; i++ ) {
  %><option value="<%= i %>"><%= i %><%
}%>
 </select>
, <select name="year<%= k %>">
<option value="-1">
<option value="<%= current.get( Calendar.YEAR )-1 %>"><%= current.get( Calendar.YEAR )-1 %>
<option value="<%= current.get( Calendar.YEAR ) %>"><%= current.get( Calendar.YEAR ) %>
<option value="<%= current.get( Calendar.YEAR )+1 %>"><%= current.get( Calendar.YEAR )+1 %>
</select>
 <select name="hour<%= k %>">
<option value="-1">
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>"><%= i %><%
}%>
</select>:<select name="minute<%= k %>">
<option value="-1">
<%for ( int i = 0; i < 60; i++ ) { 
  %><option value="<%= i %>"><%= ( i < 10 ) ? "0"+i : ""+i %><% }%>
</select> <select name="pm<%= k %>">
<option value="-1">
<option value="0">am
<option value="1">pm
</select> - <select name="tohour<%= k %>">
<option value="-1">
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>"><%= i %><%
}%>
</select>:<select name="tominute<%= k %>">
<option value="-1">
<%for ( int i = 0; i < 60; i++ ) {
  %><option value="<%= i %>"><%= ( i < 10 ) ? "0"+i : ""+i %><% }%>
</select> <select name="topm<%= k %>">
<option value="-1">
<option value="0">am
<option value="1">pm
</select>
<%
}
%>

<p><input type="submit" value="Continue"/>
<input type="hidden" name="submitted" value="yes"/>
</form>



<% } else { %>

<%
boolean errors = false;
boolean blank = false;

ResultSet results = state.executeQuery( "SELECT * FROM conferencePeriod" );

numberOfTimeSlots = 3;
while ( results.next() ) {
    numberOfTimeSlots++;
}

state.executeUpdate( "TRUNCATE TABLE conferencePeriod" );

results = state.executeQuery( "SELECT * FROM conferencePeriod" );

for ( int i = 0; i < numberOfTimeSlots; i++ ) {
    int month = -1;
    int day = -1;
    int year = -1;
    int hour = -1;
    int minute = -1;
    int pm = -1;
    int tohour = -1;
    int tominute = -1;
    int topm = -1;

    try {
    	month = Integer.parseInt( request.getParameter( "month" + i ) )-1;
   	day = Integer.parseInt( request.getParameter( "day" + i ) );
   	year = Integer.parseInt( request.getParameter( "year" + i ) );
   	hour = Integer.parseInt( request.getParameter( "hour" + i ) );
   	minute = Integer.parseInt( request.getParameter( "minute" + i ) );
	pm = Integer.parseInt( request.getParameter( "pm" + i ) );
   	tohour = Integer.parseInt( request.getParameter( "tohour" + i ) );
   	tominute = Integer.parseInt( request.getParameter( "tominute" + i ) );
	topm = Integer.parseInt( request.getParameter( "topm" + i ) );
    } catch ( NumberFormatException e ) { %>Your browser is screwed up.<% }

    if ( !(month == -1 || day == -1 || year == -1 || hour == -1 || minute == -1 || pm == -1 || tohour == -1 || tominute == -1 || topm == -1 ) ) {
      Calendar cal = Calendar.getInstance();
      Calendar tocal = Calendar.getInstance();
      cal.set( year, month, day, hour, minute, 0 );
      tocal.set( year, month, day, tohour, tominute, 0 );
      cal.set( Calendar.AM_PM, pm );
      tocal.set( Calendar.AM_PM, topm );
      cal.set( Calendar.HOUR, hour );
      tocal.set( Calendar.HOUR, tohour );
      TimeSlot time = new TimeSlot( cal.getTime(), tocal.getTime() );
      if ( time.getStart().compareTo( time.getFinish() ) > 0 ) {
      	 errors = true;
      	 %><p><%= time.getStart() %> - <%= time.getFinish() %> ends before it begins.<%
      } else {
	results.moveToInsertRow();
	results.updateTimestamp( 1, new java.sql.Timestamp( time.getStart().getTime() ) );
	results.updateTimestamp( 2, new java.sql.Timestamp( time.getFinish().getTime() ) );
	results.insertRow();
      }
    }    
}

results.close();

%>
<% if ( errors ) { %>
<p>Please use your brower's "Back" button to go back and correct the errors in your submission.

<% } else { %>
<jsp:forward page="admin.jsp"/>
<% } %>
<% } %>
</body>
</html>
