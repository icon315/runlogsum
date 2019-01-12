import scripts/datelib.ash;

string[int,string] Ascensions;

string[int]AscensionEnd;
string[int]AscensionStart;


void printTrace(string mes)
{	
	print(get_stack_trace()[0].line+": "+mes);
}

int dateAsInt(string date) {
	//date as string formatted "yyyyMMdd" like today_to_string() returns
	int dateYear = format_date_time("yyyyMMdd", date, "yyyy").to_int() - 1;
	int dateDay = format_date_time("yyyyMMdd", date, "D").to_int() - 1;
	return dateYear * 365 + to_int(dateYear / 4) - to_int(dateYear / 100) + to_int(dateYear / 400) + dateDay;
}


string intAsDate(int dateInt)
{

	return floor((((dateInt)-(floor(dateInt / 365)/4)+(floor(dateInt / 365)/100)-(floor(dateInt / 365)/400)) / 365)+1) +""+ format_date_time("D",(((dateInt)-(floor(dateInt / 365)/4)+(floor(dateInt / 365)/100)-(floor(dateInt / 365)/400)) % 365 + 1),"MMdd");
}

void findAscensions(int x)
{
	x--;
	boolean aftercore = true;
	if(get_property("questL13Final") != "finished")
		aftercore = false;
	string startDate = today_to_string();
	file_to_map("logascensions.txt",Ascensions);
	for i from my_ascensions()+1 to (my_ascensions()-x)
	{
		if(Ascensions contains i)
		{
			printTrace("Already Recored");
			continue;
		}
		string logDateString;
		string [int]logToCheck;
		boolean foundEnd = false;
		int logChecked = 0;
		string logEndDate;
		if(!aftercore && i == my_ascensions()+1)
		{
			logDateString = intAsDate(dateAsInt(startDate)-logChecked);
			printTrace("End log date: "+logDateString);
			logEndDate = logDateString;
			foundEnd = true;
			AscensionEnd[i] = today_to_string();		
		}
		while(!foundEnd)
		{
			logDateString = intAsDate(dateAsInt(startDate)-logChecked);
			logToCheck = session_logs(my_name(), logDateString, 0);
			matcher logEndNormal = create_matcher("\\n\\[(\\d+)\\] Freeing King Ralph", logToCheck[0]);
			matcher logEndCS = create_matcher("\\nTook choice 1089/30: Perform Service", logToCheck[0]);
			matcher logEndEd = create_matcher("\\nEncounter: You Found It!", logToCheck[0]);
			if(find(logEndNormal) || find(logEndCS) || find(logEndEd))
			{
				printTrace("End log date: "+logDateString);
				logEndDate = logDateString;
				foundEnd = true;
				AscensionEnd[i] = logEndDate;
			}
			logChecked++;
		}
		printTrace("Found ascension End "+i+": "+my_name() +"_" +logEndDate+".txt");
		startDate = intAsDate(dateAsInt(logDateString)-1);
	}
	startDate = today_to_string();
	for i from my_ascensions()+1 to (my_ascensions()-x)
	{
		if(Ascensions contains i)
		{
			printTrace("Already Recored");
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
			matcher logStart = create_matcher("\\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\r\\n\\r\\nAscension #(\\d+\)", logToCheck[0]);
			if(find(logStart))
			{
				printTrace("Start log date: "+logDateString);
				printTrace(logStart.group(0));
				logStartDate = logDateString;
				foundStart = true;
				AscensionStart[i] = logStartDate;
			}
			logChecked++;

		}
		printTrace("Found ascension End "+i+": "+my_name() +"_" +logStartDate+".txt");
		startDate = intAsDate(dateAsInt(logDateString)-1);
	}

	//Ascensions[DateStart,IndexStart,DateEnd,IndexEnd]
	foreach asc,date in AscensionStart
	{
		//printTrace("Ascension Start ("+asc+") in log "+date);
		//printTrace("Ascension End ("+asc+") in log "+AscensionEnd[asc]);
		Ascensions[asc,date] = AscensionEnd[asc];
	}
	map_to_file(Ascensions,"logascensions.txt");
}


void main(int How_Many_Ascensions_To_Find)
{

	set_property("logAcquiredItems",true);
	set_property("logBattleAction",true);
	set_property("logDecoratedResponses",true);
	set_property("logFamiliarActions",true);
	set_property("logGainMessages",true);
	set_property("logMonsterHealth",true);
	set_property("logPreferenceChange",false);
	set_property("logStatGains",true);
	set_property("logStatusEffects",true);

	findAscensions(How_Many_Ascensions_To_Find);
}

