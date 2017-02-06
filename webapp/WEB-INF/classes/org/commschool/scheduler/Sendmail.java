package org.commschool.scheduler;

import java.net.*;
import java.io.*;

public class Sendmail {
  
  public static boolean DEBUG = true;
  public static boolean TESTING = false;
  
  public static boolean send( String server, String from, String to, String data ) {
    try {
      Socket s = null;
      BufferedReader in = null;
      PrintWriter out = null;
      
      if ( !TESTING ) {
        s = new Socket( server, 25 );
        in = new BufferedReader( new InputStreamReader( s.getInputStream() ) );
        out = new PrintWriter( new OutputStreamWriter( s.getOutputStream() ) );
      }
      
      if ( !TESTING && !readln( in ).startsWith( "220" ) )
        return false;
      
      println( out, "MAIL FROM: <" + from + ">" );
      
      if ( !TESTING && !readln( in ).startsWith( "250" ) )
        return false;
      
      println( out, "RCPT TO: <" + to + ">" );
      
      if ( !TESTING && !readln( in ).startsWith( "250" ) )
        return false;
      
      println( out, "DATA" );
      
      if ( !TESTING && !readln( in ).startsWith( "354" ) )
        return false;
      
      println( out, "X-Mailer: Commonwealth Scheduler Sendmail module" );
      println( out, data );
      println( out, "." );
      
      if ( !TESTING && !readln( in ).startsWith( "250" ) )
        return false;
      
      println( out, "QUIT" );
      
      if ( !TESTING && !readln( in ).startsWith( "221" ) )
        return false;
      
      if ( !TESTING ) {
        in.close();
        out.close();
        s.close();
      }
      
      return true;
    } catch ( Exception e ) {
      System.out.println( e + "" );
      e.printStackTrace();
      return false;
    }
  }
  
  public static void println( PrintWriter out, String s ) throws IOException {
    if ( !TESTING ) {
      out.println( s );
      out.flush();
    }
    if ( DEBUG )
      System.out.println( "C: " + s );
  }
  
  public static String readln( BufferedReader in ) throws IOException {
    if ( TESTING ) {
      System.out.println( "S: We're in testing mode, no data read." );
      return null;
    } else if ( DEBUG ) {
      String s = in.readLine();
      System.out.println( "S: " + s );
      return s;
    } else { 
      return in.readLine();
    }
  }
}