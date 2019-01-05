import scripts/datelib.ash;

int dateAsInt(string date) {
	//date as string formatted "yyyyMMdd" like today_to_string() returns
	int dateYear = format_date_time("yyyyMMdd", date, "yyyy").to_int() - 1;
	int dateDay = format_date_time("yyyyMMdd", date, "D").to_int() - 1;
	return dateYear * 365 + to_int(dateYear / 4) - to_int(dateYear / 100) + to_int(dateYear / 400) + dateDay;
}

string[int,string] Ascensions;
//Ascensions[DateStart,IndexStart,DateEnd,IndexEnd]

string[int]AscensionEnd;
string[int]AscensionStart;

string intAsDate(int dateInt)
{

	return floor((((dateInt)-(floor(dateInt / 365)/4)+(floor(dateInt / 365)/100)-(floor(dateInt / 365)/400)) / 365)+1) +""+ format_date_time("D",(((dateInt)-(floor(dateInt / 365)/4)+(floor(dateInt / 365)/100)-(floor(dateInt / 365)/400)) % 365 + 1),"MMdd");
}


void main(int HowManyAscensionsToFind)
{
	x = HowManyAscensionsToFind-1;
	string startDate = today_to_string();
	file_to_map("logascensions.txt",Ascensions);
	for i from my_ascensions() to (my_ascensions()-x)
	{
		if(Ascensions contains i)
		{
			print("Already Recored");
			continue;
		}
		string logDateString;
		string [int]logToCheck;
		boolean foundEnd = false;
		int logChecked = 0;
		string logEndDate;
		while(!foundEnd)
		{
			logDateString = intAsDate(dateAsInt(startDate)-logChecked);
			logToCheck = session_logs(my_name(), logDateString, 0);
			matcher logEnd = create_matcher("\\n\\[(\\d+)\\] Freeing King Ralph", logToCheck[0]);
			if(find(logEnd))
			{			
				print("End log date: "+logDateString);
				logEndDate = logDateString;
				foundEnd = true;
				AscensionEnd[i] = logEndDate;
			}
			logChecked++;
		}
		print("Found ascension End "+i+" of "+x+": "+my_name() +"_" +logEndDate+".txt");
		startDate = intAsDate(dateAsInt(logDateString)-1);
	}
	startDate = today_to_string();
	for i from my_ascensions() to (my_ascensions()-x)
	{
		if(Ascensions contains i)
		{
			print("Already Recored");
			continue;
		}
		string logDateString;
		string [int]logToCheck;
		boolean foundStart = false;
		int logChecked = 0;
		string logStartDate;
		while(!foundStart)
		{
			logDateString = intAsDate(dateAsInt(startDate)-logChecked);
			logToCheck = session_logs(my_name(), logDateString, 0);
			//[462] Freeing King Ralph
			matcher logStart = create_matcher("\\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\r\\n\\r\\nAscension #(\\d+)", logToCheck[0]);
			if(find(logStart))
			{			
				print("Start log date: "+logDateString);
				print(logStart.group(0));
				logStartDate = logDateString;
				foundStart = true;
				AscensionStart[i] = logStartDate;
			}
			logChecked++;
		
		}
		print("Found ascension End "+i+" of "+x+": "+my_name() +"_" +logStartDate+".txt");
		startDate = intAsDate(dateAsInt(logDateString)-1);
	}
	
	//Ascensions[DateStart,IndexStart,DateEnd,IndexEnd]
	foreach asc,date in AscensionStart
	{
		//print("Ascension Start ("+asc+") in log "+date);
		//print("Ascension End ("+asc+") in log "+AscensionEnd[asc]);
		Ascensions[asc,date] = AscensionEnd[asc];
	
	}
	map_to_file(Ascensions,"logascensions.txt");
}