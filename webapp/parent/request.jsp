<%@ include file="/include/init.jsp" %>

<%
Statement state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );

int numberOfTimeSlots;
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Request Conferences for <%= studentName %></title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="/include/parent_header.jsp" %>
<% if ( request.getParameter( "submitted" ) == null || !request.getParameter( "submitted" ).equals( "yes" ) ) { %>
<h2>Set Available Meeting Times (Step 1)</h2>
<form action="/parent/request.jsp" method="post">
<%
ResultSet results = state.executeQuery( "SELECT * FROM conferencePeriod" );
%>
<p>Conferences will take place at the following times; be sure you specify that
you are available within at least one of these time periods:</p>
<ul><%
DateFormat tdf = DateFormat.getTimeInstance();
DateFormat ddf = DateFormat.getDateInstance();

Calendar firstDate = null;
Calendar lastDate = null;
while ( results.next() ) { 
    Calendar startTime = Calendar.getInstance();
    Calendar stopTime = Calendar.getInstance();
    startTime.setTime(results.getTimestamp(1));
    stopTime.setTime(results.getTimestamp(2));
    if ((firstDate == null) || (firstDate.after(startTime))) firstDate = startTime;
    if ((lastDate == null) || (lastDate.before(stopTime))) lastDate = stopTime;
    %><li><%= ddf.format(startTime.getTime()) + " " + tdf.format(startTime.getTime()) %> - <%= tdf.format(stopTime.getTime()) %></li>
<% } %></ul>

<%
results.first();
Calendar example = Calendar.getInstance();
example.setTime( results.getTimestamp( 1 ) );
%>

<p>Please enter the times that you will be available for conferences.
<!-- (Month, Date, Year, Begin Time - Stop Time) --></p>
<!-- <small>NOTE: In order to make your time more effective <a href="available.jsp" target="_new">click here</a> to look at the availability information for each of the teachers you would like to see, and enter your time accordingly.</small> -->
<p><input type="radio" name="timetype" value="all">I will be available for the entire conference period.<br />
<input type="radio" name="timetype" value="none">I will not be attending any conferences.<br />
<input type="radio" name="timetype" value="custom" checked="checked">I will select a custom set of times below:
<%

results = state.executeQuery( "SELECT * FROM available WHERE type = 0 AND ID = " + studentID );
Calendar current = Calendar.getInstance();

Calendar cal = Calendar.getInstance();
Calendar tocal = Calendar.getInstance();

int j = 0;
for ( j = 0; results.next(); j++ ) {
cal.setTime( results.getTimestamp( 3 ) );
tocal.setTime( results.getTimestamp( 4 ) );
int hour = cal.get( Calendar.HOUR );
if ( hour == 0 )
    hour = 12;
int tohour = tocal.get( Calendar.HOUR );
if ( tohour == 0 )
    tohour = 12;
%>
<p>
<select name="date<%= j %>">
<option value="-1"></option>
<% Calendar date = (Calendar)firstDate.clone();
date.clear(Calendar.MILLISECOND);
date.clear(Calendar.SECOND);
date.clear(Calendar.MINUTE);
date.clear(Calendar.HOUR);
date.clear(Calendar.AM_PM);
for (; date.before(lastDate); date.add(Calendar.DATE, 1)) { %>
<option value="<%= date.getTime().getTime() %>" <%=(
(cal.get(Calendar.MONTH) == date.get(Calendar.MONTH)) && (cal.get(Calendar.DAY_OF_MONTH) == date.get(Calendar.DAY_OF_MONTH))
) ? " selected=\"selected\"" : "" %>><%= ddf.format(date.getTime()) %></option>
<% } %>
</select>
<% /* %>
<select name="month<%= j %>">
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
<select name="day<%= j %>">
<option value="-1">
<%for ( int i = 1; i <= 31; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.DAY_OF_MONTH ) == i ) ? "SELECTED" : "" %>><%= i %></option><%
}%>
</select>
, <select name="year<%= j %>">
<option value="-1"></option>
<option value="<%= current.get( Calendar.YEAR )-1 %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR )-1 ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR )-1 %></option>
<option value="<%= current.get( Calendar.YEAR ) %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR ) ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR ) %></option>
<option value="<%= current.get( Calendar.YEAR )+1 %>" <%= ( cal.get( Calendar.YEAR ) == current.get( Calendar.YEAR )+1 ) ? "SELECTED" : "" %>><%= current.get( Calendar.YEAR )+1 %></option>
</select>
<% */ %>
 <select name="hour<%= j %>">
<option value="-1"></option>
<%for ( int i = 0; i < 12; i++ ) {
  %><option value="<%= i %>" <%= ( hour == i % 12 ) ? "SELECTED" : "" %>><%= (i == 0) ? 12 : i %></option><%
}%>
</select>:<select name="minute<%= j %>">
<option value="-1"></option>
<%for ( int i = 0; i < 60; i += 10 ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.MINUTE ) == i ) ? "SELECTED" : "" %>><%= ( i < 10 ) ? "0"+i : ""+i %></option><%
}%>
</select> <select name="pm<%= j %>">
<option value="-1"></option>
<option value="0" <%= ( cal.get( Calendar.AM_PM ) == Calendar.AM ) ? "SELECTED" : "" %>>am</option>
<option value="1" <%= ( cal.get( Calendar.AM_PM ) == Calendar.PM ) ? "SELECTED" : "" %>>pm</option>
</select> - <select name="tohour<%= j %>">
<option value="-1"></option>
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>" <%= ( tohour == i % 12 ) ? "SELECTED" : "" %>><%= i %></option><%
}%>
</select>:<select name="tominute<%= j %>">
<option value="-1"></option>
<%for ( int i = 0; i < 60; i += 10 ) {
  %><option value="<%= i %>" <%= ( tocal.get( Calendar.MINUTE ) == i ) ? "SELECTED" : "" %>><%= ( i < 10 ) ? "0"+i : ""+i %></option><%
}%>
</select> <select name="topm<%= j %>">
<option value="-1">
<option value="0" <%= ( tocal.get( Calendar.AM_PM ) == Calendar.AM ) ? "SELECTED" : "" %>>am</option>
<option value="1" <%= ( tocal.get( Calendar.AM_PM ) == Calendar.PM ) ? "SELECTED" : "" %>>pm</option>
</select>
<%
}

numberOfTimeSlots = j+3;

for ( int k = j; k < j + 3; k++ ) {
// display 3 blank timeslots.
%><p>
<select name="date<%= k %>">
<option value="-1"></option>
<% Calendar date = (Calendar)firstDate.clone();
date.clear(Calendar.MILLISECOND);
date.clear(Calendar.SECOND);
date.clear(Calendar.MINUTE);
date.clear(Calendar.HOUR);
date.clear(Calendar.AM_PM);
for (; date.before(lastDate); date.add(Calendar.DATE, 1)) { %>
<option value="<%= date.getTime().getTime() %>"><%= ddf.format(date.getTime()) %></option>
<% } %>
</select>
<% /* %>
<select name="month<%= k %>">
<option value="-1"></option>
<option value="1" <%= ( example.get( Calendar.MONTH ) == Calendar.JANUARY ) ? "SELECTED" : "" %>>January</option>
<option value="2" <%= ( example.get( Calendar.MONTH ) == Calendar.FEBRUARY ) ? "SELECTED" : "" %>>February</option>
<option value="3" <%= ( example.get( Calendar.MONTH ) == Calendar.MARCH ) ? "SELECTED" : "" %>>March</option>
<option value="4" <%= ( example.get( Calendar.MONTH ) == Calendar.APRIL ) ? "SELECTED" : "" %>>April</option>
<option value="5" <%= ( example.get( Calendar.MONTH ) == Calendar.MAY ) ? "SELECTED" : "" %>>May</option>
<option value="6" <%= ( example.get( Calendar.MONTH ) == Calendar.JUNE ) ? "SELECTED" : "" %>>June</option>
<option value="7" <%= ( example.get( Calendar.MONTH ) == Calendar.JULY ) ? "SELECTED" : "" %>>July</option>
<option value="8" <%= ( example.get( Calendar.MONTH ) == Calendar.AUGUST ) ? "SELECTED" : "" %>>August</option>
<option value="9" <%= ( example.get( Calendar.MONTH ) == Calendar.SEPTEMBER ) ? "SELECTED" : "" %>>September</option>
<option value="10" <%= ( example.get( Calendar.MONTH ) == Calendar.OCTOBER ) ? "SELECTED" : "" %>>October</option>
<option value="11" <%= ( example.get( Calendar.MONTH ) == Calendar.NOVEMBER ) ? "SELECTED" : "" %>>November</option>
<option value="12" <%= ( example.get( Calendar.MONTH ) == Calendar.DECEMBER ) ? "SELECTED" : "" %>>December</option>
</select>
<select name="day<%= k %>"><option value="-1"></option>
<%for ( int i = 1; i <= 31; i++ ) {
  %><option value="<%= i %>" <%= ( example.get( Calendar.DAY_OF_MONTH ) == i ) ? "SELECTED" : "" %>><%= i %><%
}%>
 </select>
, <select name="year<%= k %>">
<option value="<%= example.get( Calendar.YEAR )-1 %>"><%= example.get( Calendar.YEAR )-1 %></option>
<option value="<%= example.get( Calendar.YEAR ) %>" SELECTED><%= example.get( Calendar.YEAR ) %></option>
<option value="<%= example.get( Calendar.YEAR )+1 %>"><%= example.get( Calendar.YEAR )+1 %></option>
</select>
<% */ %>
 <select name="hour<%= k %>">
<option value="-1"></option>
<%for ( int i = 0; i < 12; i++ ) {
  %><option value="<%= i %>"><%= (i == 0) ? 12 : i %></option><%
}%>
</select>:<select name="minute<%= k %>">
<option value="-1"></option>
<%for ( int i = 0; i < 60; i += 10 ) { 
  %><option value="<%= i %>"><%= ( i < 10 ) ? "0"+i : ""+i %></option><% }%>
</select> <select name="pm<%= k %>">
<option value="-1"></option>
<option value="0">am</option>
<option value="1">pm</option>
</select> - <select name="tohour<%= k %>">
<option value="-1"></option>
<%for ( int i = 0; i < 12; i++ ) {
  %><option value="<%= i %>"><%= (i == 0) ? 12 : i %></option><%
}%>
</select>:<select name="tominute<%= k %>">
<option value="-1"></option>
<%for ( int i = 0; i < 60; i += 10 ) {
  %><option value="<%= i %>"><%= ( i < 10 ) ? "0"+i : ""+i %></option><% }%>
</select> <select name="topm<%= k %>">
<option value="-1"></option>
<option value="0">am</option>
<option value="1">pm</option>
</select>
<% } %>

<p><input type="submit" value="Continue"/></p>
<input type="hidden" name="submitted" value="yes"/>
</form>

<% } else {

boolean errors = false;
boolean blank = false;

ResultSet results = state.executeQuery( "SELECT * FROM available WHERE type = 0 AND ID = " + studentID );

numberOfTimeSlots = 3;
while ( results.next() ) {
    numberOfTimeSlots++;
}

state.executeUpdate( "DELETE FROM available WHERE type = 0 AND ID = " + studentID );

results = state.executeQuery( "SELECT * FROM conferencePeriod" );
Vector times = new Vector();
while ( results.next() ) {
    times.add( new TimeSlot( results.getTimestamp( 1 ), results.getTimestamp( 2 ) ) );
}

if ( request.getParameter( "timetype" ).equals( "all" ) ) {
    results = state.executeQuery( "SELECT * FROM available" );
    results.moveToInsertRow();
    for ( int i = 0; i < times.size(); i++ ) {
        results.updateInt( 1, studentID );
	results.updateInt( 2, 0 );
	results.updateTimestamp( 3, new java.sql.Timestamp( ((TimeSlot)times.get( i )).getStart().getTime() ) );
	results.updateTimestamp( 4, new java.sql.Timestamp( ((TimeSlot)times.get( i )).getFinish().getTime() ) );
	results.insertRow();
    }
} else if ( request.getParameter( "timetype" ).equals( "none" ) ) {
	results = state.executeQuery( "SELECT * FROM students WHERE studentID = " + studentID );
	if (results.first()) {
		results.updateInt(5, 2);
		results.updateRow();
	}
} else if ( request.getParameter( "timetype" ).equals( "custom" ) ) {

results = state.executeQuery( "SELECT * FROM available WHERE type = 0 AND ID = " + studentID );

for ( int i = 0; i < numberOfTimeSlots; i++ ) {
    long date = -1;
    int hour = -1;
    int minute = -1;
    int pm = -1;
    int tohour = -1;
    int tominute = -1;
    int topm = -1;

    try {
	date = Long.parseLong(request.getParameter("date" + i));
   	hour = Integer.parseInt( request.getParameter( "hour" + i ) );
   	minute = Integer.parseInt( request.getParameter( "minute" + i ) );
	pm = Integer.parseInt( request.getParameter( "pm" + i ) );
   	tohour = Integer.parseInt( request.getParameter( "tohour" + i ) );
   	tominute = Integer.parseInt( request.getParameter( "tominute" + i ) );
	topm = Integer.parseInt( request.getParameter( "topm" + i ) );
    } catch ( NumberFormatException e ) {
		throw new Exception("Availability parameter is not a valid number.", e);
	}

    if ( !( date == -1 || hour == -1 || minute == -1 || pm == -1 || tohour == -1 || tominute == -1 || topm == -1 ) ) {
      Calendar cal = Calendar.getInstance();
      Calendar tocal = Calendar.getInstance();

/*      if ( pm == 1 ) {
         if ( hour != 12 )
	    hour = ( hour + 12 ) % 24;
      }

      if ( topm == 1 ) {
         if ( tohour != 12 )
            tohour = ( tohour + 12 ) % 24;
      } 
*/
      if (hour == 12) pm = 1 - pm;
	  if (tohour == 12) topm = 1 - topm;

      cal.setTimeInMillis(date);
      cal.set(Calendar.HOUR, hour);
      cal.set(Calendar.MINUTE, minute);
      cal.set(Calendar.AM_PM, pm);
      tocal.setTimeInMillis(date);
      tocal.set(Calendar.HOUR, tohour);
      tocal.set(Calendar.MINUTE, tominute);
      tocal.set(Calendar.AM_PM, topm);

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
		results.updateInt( 1, studentID );
		results.updateInt( 2, 0 );
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
   %><p>You did not specify any times that you are available.</p><%
}

if (!errors) {
	state.execute("UPDATE students SET hasSetAvail = 1 WHERE studentID = " + studentID);
}
   
%>
<% if ( errors ) { %>
<p>Please use your brower's "Back" button to go back and correct the errors in your submission.</p>
<% } else if ( blank ) { %>
<jsp:forward page="request3.jsp"/>
<% } else { %>
<jsp:forward page="request2.jsp"/>
<% } %>
<% } %>
</body>
</html>
