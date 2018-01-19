<%@ include file="/include/init.jsp" %>

<%
Statement state = null;

int numberOfTimeSlots = 0;

state = connect.createStatement( ResultSet.TYPE_SCROLL_INSENSITIVE, ResultSet.CONCUR_UPDATABLE );
%>

<%@ include file="/include/doctype.jsp" %>
<html>
<head>
<title>Set Conference Period</title>
<%@ include file="/include/meta.jsp" %>
</head>
<body>
<%@ include file="../include/admin_header.jsp" %>
<% if ( request.getParameter( "submitted" ) == null || !request.getParameter( "submitted" ).equals( "yes" ) ) { %>

<h2>Set Conference Period</h2>

<form action="/admin/setperiod.jsp" method="post">
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
<option value="-1"></option>
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
 <select name="hour<%= j %>">
<option value="-1"></option>
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.HOUR ) == i % 12 ) ? "SELECTED" : "" %>><%= i %></option><%
}%>
</select>:<select name="minute<%= j %>">
<option value="-1"></option>
<%for ( int i = 0; i < 60; i++ ) {
  %><option value="<%= i %>" <%= ( cal.get( Calendar.MINUTE ) == i ) ? "SELECTED" : "" %>><%= ( i < 10 ) ? "0"+i : ""+i %></option><%
}%>
</select> <select name="pm<%= j %>">
<option value="-1"></option>
<option value="0" <%= ( cal.get( Calendar.AM_PM ) == Calendar.AM ) ? "SELECTED" : "" %>>am</option>
<option value="1" <%= ( cal.get( Calendar.AM_PM ) == Calendar.PM ) ? "SELECTED" : "" %>>pm</option>
</select> - <select name="tohour<%= j %>">
<option value="-1"></option>
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>" <%= ( tocal.get( Calendar.HOUR ) == i % 12 ) ? "SELECTED" : "" %>><%= i %></option><%
}%>
</select>:<select name="tominute<%= j %>">
<option value="-1"></option>
<%for ( int i = 0; i < 60; i++ ) {
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
%><p><select name="month<%= k %>">
<option value="-1"></option>
<option value="1">January</option>
<option value="2">February</option>
<option value="3">March</option>
<option value="4">April</option>
<option value="5">May</option>
<option value="6">June</option>
<option value="7">July</option>
<option value="8">August</option>
<option value="9">September</option>
<option value="10">October</option>
<option value="11">November</option>
<option value="12">December</option>
</select> 
<select name="day<%= k %>">
<option value="-1"></option>
<%for ( int i = 1; i <= 31; i++ ) {
  %><option value="<%= i %>"><%= i %></option><%
}%>
 </select>
, <select name="year<%= k %>">
<option value="-1"></option>
<option value="<%= current.get( Calendar.YEAR )-1 %>"><%= current.get( Calendar.YEAR )-1 %></option>
<option value="<%= current.get( Calendar.YEAR ) %>"><%= current.get( Calendar.YEAR ) %></option>
<option value="<%= current.get( Calendar.YEAR )+1 %>"><%= current.get( Calendar.YEAR )+1 %></option>
</select>
 <select name="hour<%= k %>">
<option value="-1"></option>
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>"><%= i %></option><%
}%>
</select>:<select name="minute<%= k %>">
<option value="-1"></option>
<%for ( int i = 0; i < 60; i++ ) { 
  %><option value="<%= i %>"><%= ( i < 10 ) ? "0"+i : ""+i %></option><% }%>
</select> <select name="pm<%= k %>">
<option value="-1"></option>
<option value="0">am</option>
<option value="1">pm</option>
</select> - <select name="tohour<%= k %>">
<option value="-1"></option>
<%for ( int i = 1; i < 13; i++ ) {
  %><option value="<%= i %>"><%= i %></option><%
}%>
</select>:<select name="tominute<%= k %>">
<option value="-1"></option>
<%for ( int i = 0; i < 60; i++ ) {
  %><option value="<%= i %>"><%= ( i < 10 ) ? "0"+i : ""+i %></option><% }%>
</select> <select name="topm<%= k %>">
<option value="-1"></option>
<option value="0">am</option>
<option value="1">pm</option>
</select>
<%
}
%>

<p><input type="submit" value="Continue"/></p>
<input type="hidden" name="submitted" value="yes"/>
</form>

<% } else {

boolean errors = false;
boolean blank = false;

ResultSet results = state.executeQuery( "SELECT * FROM conferencePeriod" );

numberOfTimeSlots = 3;//The number of rows of combo boxes equals the number of rows in the SQL database plus 3.
while ( results.next() ) {
    numberOfTimeSlots++;
} 

state.executeUpdate( "TRUNCATE TABLE conferencePeriod" );

results = state.executeQuery( "SELECT * FROM conferencePeriod" );
for ( int i = 0; i < numberOfTimeSlots; i++ ) {
    	String month = request.getParameter( "month" + i );
    	if( month == null || month.equals( "-1" ) ) {
    		continue;
    	}
   	String day = request.getParameter( "day" + i );
   	String year = request.getParameter( "year" + i );
   	String hour = request.getParameter( "hour" + i );
   	String minute = request.getParameter( "minute" + i );
	String pm = ( request.getParameter( "pm" + i ).equals( "0" ) ) ? "AM" : "PM";
	String tohour = request.getParameter( "tohour" + i );
   	String tominute = request.getParameter( "tominute" + i );
	String topm = ( request.getParameter( "topm" + i ).equals( "0" ) ) ? "AM" : "PM";
	DateFormat myformat = new SimpleDateFormat( "yyyy.MM.dd@h:m:ssa" );
	java.util.Date d = null;
	java.util.Date tod = null;
	try {
		d = myformat.parse( year + "." + month + "." + day + "@" + hour + ":" + minute + ":" + "00" + pm );
                tod = myformat.parse( year + "." + month + "." + day + "@" + tohour + ":" + tominute + ":" + "00" + topm );
	} catch( ParseException e ) {
		session.setAttribute("errorMessage", "Some availability fields were not valid numbers.");
		throw e;
	}
      TimeSlot time = new TimeSlot( d, tod );
      if ( time.getStart().compareTo( time.getFinish() ) > 0 ) {
      	 errors = true;
      	 %><p><%= time.getStart() %> - <%= time.getFinish() %> ends before it begins.</p><%
      } else {
	results.moveToInsertRow();
	results.updateTimestamp( 1, new java.sql.Timestamp( time.getStart().getTime() ) );
	results.updateTimestamp( 2, new java.sql.Timestamp( time.getFinish().getTime() ) );
	results.insertRow();
      }
    
 
}

results.close();

if ( errors ) { %>
<p>Please use your brower's "Back" button to go back and correct the errors in your submission.</p>
<% } else { %>
<jsp:forward page="/admin/" />
<% }
} %>
</body>
</html>
