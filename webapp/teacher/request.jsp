<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
int numberOfTimeSlots = 0;
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Request Conferences for <%= teacherName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/teacher_header.jsp" %>
<% if (request.getParameter("submitted") == null || !request.getParameter("submitted").equals("yes")) { %>
<h2>Set Available Meeting Times (Step 1)</h2>
<form action="/teacher/request.jsp" method="post">
<%
ResultSet results = state.executeQuery("SELECT * FROM conferencePeriod");
%>
<p>Conferences will take place at the following times.
Please be sure you specify that you are available within
at least one of these time periods:</p>
<ul><%
while (results.next()) { 
    DateFormat tdf = DateFormat.getTimeInstance();
    DateFormat ddf = DateFormat.getDateInstance();
    %><li><%= ddf.format(results.getTimestamp(1)) + " " + tdf.format(results.getTimestamp(1)) %> - <%= tdf.format(results.getTimestamp(2)) %></li>
<% } %></ul>

<%
results.first();
Calendar example = Calendar.getInstance();
example.setTime(results.getTimestamp(1));
%>

<p>Please enter the times that you will be available for conferences. 
(Month, Date, Year, Begin Time - Stop Time)
<p><input type="radio" name="timetype" value="all">I will be available for the entire conference period.<br />
<input type="radio" name="timetype" value="none">I will not be attending any conferences.<br />
<input type="radio" name="timetype" value="custom" checked="checked">I will select a custom set of times below:</p>
<%
results = state.executeQuery("SELECT * FROM available WHERE type = 1 AND ID = " + teacherID);
Calendar current = Calendar.getInstance();

Calendar cal = Calendar.getInstance();
Calendar tocal = Calendar.getInstance();

int j = 0;
for (j = 0; results.next(); j++) {
cal.setTime(results.getTimestamp(3));
tocal.setTime(results.getTimestamp(4));

int hour = cal.get(Calendar.HOUR);
if (hour == 0)
    hour = 12;
int tohour = tocal.get(Calendar.HOUR);
if (tohour == 0)
    tohour = 12;

%><p><select name="month<%= j %>">
<option value="-1">
<option  value="1" <%= ( cal.get(Calendar.MONTH) == Calendar.JANUARY)   ? "SELECTED" : "" %>>January</option>
<option  value="2" <%= ( cal.get(Calendar.MONTH) == Calendar.FEBRUARY)  ? "SELECTED" : "" %>>February</option>
<option  value="3" <%= ( cal.get(Calendar.MONTH) == Calendar.MARCH)     ? "SELECTED" : "" %>>March</option>
<option  value="4" <%= ( cal.get(Calendar.MONTH) == Calendar.APRIL)     ? "SELECTED" : "" %>>April</option>
<option  value="5" <%= ( cal.get(Calendar.MONTH) == Calendar.MAY)       ? "SELECTED" : "" %>>May</option>
<option  value="6" <%= ( cal.get(Calendar.MONTH) == Calendar.JUNE)      ? "SELECTED" : "" %>>June</option>
<option  value="7" <%= ( cal.get(Calendar.MONTH) == Calendar.JULY)      ? "SELECTED" : "" %>>July</option>
<option  value="8" <%= ( cal.get(Calendar.MONTH) == Calendar.AUGUST)    ? "SELECTED" : "" %>>August</option>
<option  value="9" <%= ( cal.get(Calendar.MONTH) == Calendar.SEPTEMBER) ? "SELECTED" : "" %>>September</option>
<option value="10" <%= ( cal.get(Calendar.MONTH) == Calendar.OCTOBER)   ? "SELECTED" : "" %>>October</option>
<option value="11" <%= ( cal.get(Calendar.MONTH) == Calendar.NOVEMBER)  ? "SELECTED" : "" %>>November</option>
<option value="12" <%= ( cal.get(Calendar.MONTH) == Calendar.DECEMBER)  ? "SELECTED" : "" %>>December</option>
</select>
<select name="day<%= j %>">
<option value="-1"></option>
<% for (int i = 1; i <= 31; i++) {
  %><option value="<%= i %>" <%= (cal.get(Calendar.DAY_OF_MONTH) == i) ? "SELECTED" : "" %>><%= i %></option><%
}%>
</select>
, <select name="year<%= j %>">
<option value="-1">
<option value="<%= current.get(Calendar.YEAR) - 1 %>" <%= (cal.get(Calendar.YEAR) == current.get(Calendar.YEAR) - 1) ? "SELECTED" : "" %>><%= current.get(Calendar.YEAR) - 1 %></option>
<option value="<%= current.get(Calendar.YEAR)     %>" <%= (cal.get(Calendar.YEAR) == current.get(Calendar.YEAR)    ) ? "SELECTED" : "" %>><%= current.get(Calendar.YEAR)     %></option>
<option value="<%= current.get(Calendar.YEAR) + 1 %>" <%= (cal.get(Calendar.YEAR) == current.get(Calendar.YEAR) + 1) ? "SELECTED" : "" %>><%= current.get(Calendar.YEAR) + 1 %></option>
</select>
 <select name="hour<%= j %>">
<option value="-1"></option>
<% for (int i = 1; i < 13; i++) {
  %><option value="<%= i %>" <%= (hour == i % 12) ? "SELECTED" : "" %>><%= i %></option><%
}%>
</select>:<select name="minute<%= j %>">
<option value="-1">
<% for (int i = 0; i < 60; i += 10) {
  %><option value="<%= i %>" <%= (cal.get(Calendar.MINUTE) == i) ? "SELECTED" : "" %>><%= (i < 10) ? "0" + i : "" + i %></option><%
}%>
</select> <select name="pm<%= j %>">
<option value="-1"></option>
<option value="0" <%= ( cal.get( Calendar.AM_PM ) == Calendar.AM ) ? "SELECTED" : "" %>>am</option>
<option value="1" <%= ( cal.get( Calendar.AM_PM ) == Calendar.PM ) ? "SELECTED" : "" %>>pm</option>
</select> - <select name="tohour<%= j %>">
<option value="-1">
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>" <%= ( tohour == i % 12) ? "SELECTED" : "" %>><%= i %><%
}%>
</select>:<select name="tominute<%= j %>">
<option value="-1">
<%for ( int i = 0; i < 60; i += 10 ) {
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
<option value="1" <%= ( example.get( Calendar.MONTH ) == Calendar.JANUARY ) ? "SELECTED" : "" %>>January
<option value="2" <%= ( example.get( Calendar.MONTH ) == Calendar.FEBRUARY ) ? "SELECTED" : "" %>>February
<option value="3" <%= ( example.get( Calendar.MONTH ) == Calendar.MARCH ) ? "SELECTED" : "" %>>March
<option value="4" <%= ( example.get( Calendar.MONTH ) == Calendar.APRIL ) ? "SELECTED" : "" %>>April
<option value="5" <%= ( example.get( Calendar.MONTH ) == Calendar.MAY ) ? "SELECTED" : "" %>>May
<option value="6" <%= ( example.get( Calendar.MONTH ) == Calendar.JUNE ) ? "SELECTED" : "" %>>June
<option value="7" <%= ( example.get( Calendar.MONTH ) == Calendar.JULY ) ? "SELECTED" : "" %>>July
<option value="8" <%= ( example.get( Calendar.MONTH ) == Calendar.AUGUST ) ? "SELECTED" : "" %>>August
<option value="9" <%= ( example.get( Calendar.MONTH ) == Calendar.SEPTEMBER ) ? "SELECTED" : "" %>>September
<option value="10" <%= ( example.get( Calendar.MONTH ) == Calendar.OCTOBER ) ? "SELECTED" : "" %>>October
<option value="11" <%= ( example.get( Calendar.MONTH ) == Calendar.NOVEMBER ) ? "SELECTED" : "" %>>November
<option value="12" <%= ( example.get( Calendar.MONTH ) == Calendar.DECEMBER ) ? "SELECTED" : "" %>>December
</select>
<select name="day<%= k %>">
<option value="-1">
<%for ( int i = 1; i <= 31; i++ ) {
  %><option value="<%= i %>" <%= ( example.get( Calendar.DAY_OF_MONTH ) == i ) ? "SELECTED" : "" %>><%= i %><%
}%>
 </select>
, <select name="year<%= k %>">
<option value="<%= example.get( Calendar.YEAR )-1 %>"><%= example.get( Calendar.YEAR )-1 %>
<option value="<%= example.get( Calendar.YEAR ) %>" SELECTED><%= example.get( Calendar.YEAR ) %>
<option value="<%= example.get( Calendar.YEAR )+1 %>"><%= example.get( Calendar.YEAR )+1 %>
</select>
 <select name="hour<%= k %>">
<option value="-1">
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>"><%= i %><%
}%>
</select>:<select name="minute<%= k %>">
<option value="-1">
<%for ( int i = 0; i < 60; i += 10 ) { 
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
<%for ( int i = 0; i < 60; i += 10 ) {
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

ResultSet results = state.executeQuery( "SELECT * FROM available WHERE type = 1 AND ID = " + teacherID );

numberOfTimeSlots = 3;
while ( results.next() ) {
    numberOfTimeSlots++;
}

state.executeUpdate( "DELETE FROM available WHERE type = 1 AND ID = " + teacherID );

results = state.executeQuery( "SELECT * FROM conferencePeriod" );
Vector times = new Vector();
while ( results.next() ) {
    times.add( new TimeSlot( results.getTimestamp( 1 ), results.getTimestamp( 2 ) ) );
}

if ( request.getParameter( "timetype" ).equals( "all" ) ) {
    results = state.executeQuery( "SELECT * FROM available" );
    results.moveToInsertRow();
    for ( int i = 0; i < times.size(); i++ ) {
        results.updateInt( 1, teacherID );
	results.updateInt( 2, 1 );
	results.updateTimestamp( 3, new java.sql.Timestamp( ((TimeSlot)times.get( i )).getStart().getTime() ) );
	results.updateTimestamp( 4, new java.sql.Timestamp( ((TimeSlot)times.get( i )).getFinish().getTime() ) );
	results.insertRow();
    }
} else if ( request.getParameter( "timetype" ).equals( "custom" ) ) {

results = state.executeQuery( "SELECT * FROM available WHERE type = 1 AND ID = " + teacherID );

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

      if ( pm == 1 ) {
         if ( hour != 12 )
	    hour = ( hour + 12 ) % 24;
      }

      if ( topm == 1 ) {
         if ( tohour != 12 )
            tohour = ( tohour + 12 ) % 24;
      }

      cal.set( year, month, day, hour, minute, 0 );
      tocal.set( year, month, day, tohour, tominute, 0 );

      TimeSlot time = new TimeSlot( cal.getTime(), tocal.getTime() );
      if ( time.getStart().compareTo( time.getFinish() ) > 0 ) {
      	 errors = true;
      	 %><p><%= time.getStart() %> - <%= time.getFinish() %> ends before it begins.<%
      } else {
          boolean within = false;
	  for ( int j = 0; j < times.size(); j++ ) {
	      if ( time.within( (TimeSlot)times.get( j ) ) )
		  within = true;
      	  }
	  if ( within ) {
		results.moveToInsertRow();
		results.updateInt( 1, teacherID );
		results.updateInt( 2, 1 );
		results.updateTimestamp( 3, new java.sql.Timestamp( time.getStart().getTime() ) );
		results.updateTimestamp( 4, new java.sql.Timestamp( time.getFinish().getTime() ) );
		results.insertRow();
	  } else {
	    	errors = true;
		%><p><%= time.getStart() %> - <%= time.getFinish() %> is not within the timeframe of the conference.<%
      	  }
      }
    }    
}

results.close();

} else {
    blank = true;
}

if ( !errors && !blank && false ) {
   errors = true;
   %><br>You did not specify any times that you are available.<%
}

if (!errors) {
	state.execute("UPDATE teachers SET hasSetAvail = 1 WHERE teacherID = " + teacherID);
}
   
%>
<% if ( errors ) { %>
<p>Please use your brower's "Back" button to go back and correct the errors in your submission.

<% } else { %>
<jsp:forward page="/teacher/request2.jsp"/>
<% } %>
<% } %>
</body>
</html>
