
package org.commschool.scheduler;

import java.io.*;

public class TextDataReader extends PushbackReader
{
  public TextDataReader(Reader reader)
  {
    super(reader);
  }

  public String readString() throws IOException
  {
    StringBuffer buffer = new StringBuffer();
    boolean isStart = true;
    while (true)
    {
      int x = read();
      if (x == -1)
        break;
      if (Character.isSpaceChar((char)x)
          || Character.isWhitespace((char)x))
      {
        if (!isStart)
        {
          unread(x);
          break;
        }
      } else {
        isStart = false;
        buffer.append((char)x);
      }
    }
    return buffer.toString();
  }

  public int readInt() throws IOException
  {
    String s = readString();
    try
    {
      return Integer.parseInt(s);
    } catch (NumberFormatException e)
    {
      throw new IOException("Integer expected: " + s);
    }
  }

  public float readFloat() throws IOException
  {
    String s = readString();
    try
    {
      return Float.parseFloat(s);
    } catch (NumberFormatException e)
    {
      throw new IOException("Float expected: " + s);
    }
  }
}
