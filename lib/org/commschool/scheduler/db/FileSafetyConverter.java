package org.commschool.scheduler.db;

public class FileSafetyConverter
{
	private static final int
	       HASH = 0,
	       FOR_SLASH = 1,
	       BACK_SLASH = 2,
	       COLON = 3,
	       STAR = 4,
	       QUESTION = 5,
	       QUOTE = 6,
	       GREATER = 7,
	       LESS = 8,
	       PIPE = 9;


	// removes {\, /, :, *, ?, ", <, >, |, #} by replacing them with a #X where X is a number
	public static String convertToSaveFormat(String s)
	{
		StringBuffer sb = new StringBuffer();

		for (int i = 0 ; i < s.length() ; i++)
		{
			char c = s.charAt(i);

			switch (c)
			{
				case '\\':
					sb.append("#" + BACK_SLASH);
					break;
				case '/':
					sb.append("#" + FOR_SLASH);
					break;
				case ':':
					sb.append("#" + COLON);
					break;
				case '*':
					sb.append("#" + STAR);
					break;
				case '?':
					sb.append("#" + QUESTION);
					break;
				case '"':
					sb.append("#" + QUOTE);
					break;
				case '<':
					sb.append("#" + LESS);
					break;
				case '>':
					sb.append("#" + GREATER);
					break;
				case '|':
					sb.append("#" + PIPE);
					break;
				case '#':
					sb.append("#" + HASH);
					break;
				default:
					sb.append(c);
			}
		}

		return sb.toString();
	}

	// I don't uses this, but no harm in it
	public static boolean isAllowable(char c)
	{
		return(c != '\\' && c != '/' && c != ':' && c != '*' && c != '?' && c != '"' && c != '<' && c != '>' && c != '|' && c != '#');
	}

	// puts them back
	public static String convertFromSaveFormat(String s)
	{
		StringBuffer sb = new StringBuffer();


		for(int i = 0 ; i < s.length() ; i++)
		{
			char c = s.charAt(i);

			if (c == '#')
			{
				i++;

				switch((int)(s.charAt(i) - '0'))
				{
					case BACK_SLASH:
						sb.append('\\');
						break;
					case FOR_SLASH:
						sb.append('/');
						break;
					case COLON:
						sb.append(':');
						break;
					case STAR:
						sb.append('*');
						break;
					case QUESTION:
						sb.append('?');
						break;
					case QUOTE:
						sb.append('"');
						break;
					case LESS:
						sb.append('<');
						break;
					case GREATER:
						sb.append('>');
						break;
					case PIPE:
						sb.append('|');
						break;
					case HASH:
						sb.append('#');
						break;
					default:
						System.err.println("FileName Corrupt!!! : " + s.charAt(i) + " ;;; " + s);
				}
			}
			else
			{
				sb.append(c);
			}
		}

		return sb.toString();
	}
}