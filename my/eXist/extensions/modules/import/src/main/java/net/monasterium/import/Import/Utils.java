package net.monasterium.Import;

import java.io.File;
import java.util.Calendar;
import java.util.Date;

public class Utils 
{
	static public boolean deleteDirectory(File path) 
	{
		if(path.exists()) 
		{
			File[] files = path.listFiles();
			for(int i=0; i<files.length; i++) 
			{
				if(files[i].isDirectory()) 
				{
					deleteDirectory(files[i]);
				}
				else 
				{
					files[i].delete();
				}
			}
		}
		return(path.delete());
	}

	static public String getDatedName(String str)
	{
		String date = null;
		String DATE_FORMAT = "yyyy-MM-dd";
		String HOUR_FORMAT = "HHmmss";
		java.text.SimpleDateFormat sdf = new java.text.SimpleDateFormat(DATE_FORMAT);
		java.text.SimpleDateFormat shf = new java.text.SimpleDateFormat(HOUR_FORMAT);
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(new Date());
		date = sdf.format(calendar.getTime()) + "T" + shf.format(calendar.getTime());
		return str + date;
	}
}
