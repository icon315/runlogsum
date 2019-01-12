import scripts/datelib.ash;

string[int,string] Ascensions;
//Ascensions[DateStart,IndexStart,DateEnd,IndexEnd]

string[int]AscensionEnd;
string[int]AscensionStart;

//Matchers
boolean[string] moonsigns = $strings[
Mongoose,
Wallaby,
Vole,
Platypus,
Opossum,
Marmot,
Wombat,
Blender,
Packrat,
];

boolean[string] paths = $strings[
Disguises Delimit,
Bees Hate You,
Way of the Surprising Fist,
Trendy,
Bugbear Invasion,
Zombie Slayer,
Class Act,
BIG!,
KOLHS,
Class Act II: A Class For Pigs,
Slow and Steady,
Heavy Rains,
Picky,
Actually Ed the Undying,
One Crazy Random Summer,
Community Service,
Avatar of West of Loathing,
The Source,
Nuclear Autumn,
Gelatinous Noob,
License to Adventure,
Live. Ascend. Repeat.,
Pocket Familiars,
G-Lover,
Disguises Delimit,
];

boolean[string] speclist = $strings[
LOV Enamorang,
DISINTEGRATE,
KGB TRANQUILIZER DART,
SPRING-LOADED FRONT BUMPER,
BREATHE OUT,
DIGITIZE,
DUPLICATE,
HUGS AND KISSES,
MACROMETEORITE,
SHATTERING PUNCH,
SNOKEBOMB,
TRANSCENDENT OLFACTION,
GALLAPAGOSIAN MATING CALL,
GINGERBREAD MOB HIT,
exploding cigar,
replica bat-oomerang,
use 1 Clara's bell,

];

//Blacklist, items which won't appear in log.
boolean[item] blackit = $items[
broken champagne bottle,
tinsel tights,
wad of used tape,
makeshift garbage shirt,
tinsel tights,

];


record logData
{
	int turn; //Tuncount
	string sType; //Adventure/Cook/eat
	record
	{
		skill sk;
		int times;
	} sSkill;
	familiar fam;
	string special;
	record
	{
		monster enc;
		int mox;
		int mys;
		int mus;
		int meat;
		item drop;
	}	iCombat;
	record
	{
		int comm;
		int turn;
	}	iComm;
	int[item] iCraft;
	boolean free;
};


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
			matcher logEndNormal = create_matcher("\\n\\[(\\d+)\\] Freeing King Ralph", logToCheck[0]);
			matcher logEndCS = create_matcher("\\nTook choice 1089/30: Perform Service", logToCheck[0]);
			matcher logEndEd = create_matcher("\\nEncounter: You Found It!", logToCheck[0]);
			if(find(logEndNormal) || find(logEndCS) || find(logEndEd))
			{
				print("End log date: "+logDateString);
				logEndDate = logDateString;
				foundEnd = true;
				AscensionEnd[i] = logEndDate;
			}
			logChecked++;
		}
		print("Found ascension End "+i+": "+my_name() +"_" +logEndDate+".txt");
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
			matcher logStart = create_matcher("\\n=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=\\r\\n\\r\\nAscension #"+i, logToCheck[0]);
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
		print("Found ascension End "+i+": "+my_name() +"_" +logStartDate+".txt");
		startDate = intAsDate(dateAsInt(logDateString)-1);
	}

	//Ascensions[DateStart,IndexStart,DateEnd,IndexEnd]
	foreach asc,date in AscensionStart
	{
		//print("Ascension Start ("+asc+") in log "+date);
		//print("Ascension End ("+asc+") in log "+AscensionEnd[asc]);
		Ascensions[asc,date] = AscensionEnd[asc];
		print(datediff(date,AscensionEnd[asc])+1);
	}
	map_to_file(Ascensions,"logascensions.txt");
}


string loadLogs(int ascension)
{

	string[int] sessionlogs;
	string cumlog;
	foreach asc,date,dateend in Ascensions
	{
		if(asc == ascension)
		{
			print(date);
			print(dateend);
			print(datediff(date,dateend));
			print(-(datediff(date,dateend) + 1));
			print(intAsDate(dateAsInt(dateend)-(datediff(date,dateend) + 1)));
			sessionlogs = session_logs(my_name(),dateend,-(datediff(date,dateend) + 1));
			break;
		}
	}
	for i from 0 to sessionlogs.count()-1
	{
		print(sessionlogs[i].length());
		cumlog += sessionlogs[i];
	}
	return cumlog;
}

string[int] loadLogsArray(int ascension)
{

	string[int] sessionlogs;
	string cumlog;
	foreach asc,date,dateend in Ascensions
	{
		if(asc == ascension)
		{
			print(date);
			print(dateend);
			print(datediff(date,dateend));
			print(-(datediff(date,dateend) + 1));
			print(intAsDate(dateAsInt(dateend)-(datediff(date,dateend) + 1)));
			sessionlogs = session_logs(my_name(),dateend,-(datediff(date,dateend) + 1));
			break;
		}
	}
	for i from 0 to sessionlogs.count()-1
	{
		print(sessionlogs[i].length());
		cumlog += sessionlogs[i];
	}
	print(cumlog.length());
	return cumlog.split_string("\\n");
}

int beatenUpCount(string log)
{
	int beatenUpInt;
	matcher beatenUp = create_matcher("\\nYou lose an effect: Beaten Up",log);
	while(find(beatenUp))
	{
		beatenUpInt++;
	}
	return beatenUpInt;
}



int[item,string] getConsumablesUsed(string log)
{
	int[item,string] consList;
	matcher cons = create_matcher("(eat|drink|chew) (\\d+?) (.+?)\n",log);
		while (find(cons))
		{
			consList[cons.group(3).to_item(),cons.group(2)] = cons.group(1).to_int();

		}

	return consList;
}

int[skill] getCombatSkillsUsed(string log)
{
	int[skill] skillsList;
	matcher skills = create_matcher("casts (.+?)!\n",log);
	while (find(skills))
	{
		skill name = to_skill(skills.group(1));
		skillsList[name] += 1;
	}
	return skillsList;
}

int[skill] getSkillsUsed(string log)
{
	int[skill] skillsList;
	matcher skills = create_matcher("cast (\\d+?) (.+?)\n",log);
	while (find(skills))
	{
		int amount = to_int(skills.group(1));
		skill name = to_skill(skills.group(2));
		skillsList[name] += amount;
	}
	return skillsList;
}

int[item] getPulls(string log)
{
	int[item] pullList;
	matcher pulls = create_matcher("pull: (\\d+) (.+?)\n",log);
	while (find(pulls))
	{
		pullList[pulls.group(2).to_item()] += pulls.group(1).to_int();
	}
	return pullList;
}


int[int] serviceTurns(string log)
{
	int[int] serviceArray;
	matcher service = create_matcher("Took choice 1089/(\\d+\): Perform Service \\((\\d+\) Adventures\\)",log);
	while(service.find())
	{
		//0- All
		//1- Choice Taken
		//2- Adventures Taken
		serviceArray[service.group(1).to_int()] = service.group(2).to_int();
	}
	return serviceArray;

}

void RunLogParse(int ascension, string startlog, string endlog)
{

	if(!user_confirm("Do you want to parse ascension #"+ascension+". It is "+datediff(startlog,endlog)+" days long"))
		abort("Done.");
	string ascensionLogs = loadLogs(ascension);
	string pathmatch = "(";
	foreach i in paths { pathmatch += i+"|"; }
	pathmatch = pathmatch.substring(0,pathmatch.last_index_of("|")) + ")";
	print (pathmatch);
	string classmatch = "(";
	foreach i in $classes[] { classmatch += i+"|"; }
	classmatch = classmatch.substring(0,classmatch.last_index_of("|")) + ")";
	print (classmatch);
	string moonmatch = "(";
	foreach i in moonsigns { moonmatch += i+"|"; }
	moonmatch = moonmatch.substring(0,moonmatch.last_index_of("|")) + ")";
	print (moonmatch);
	matcher runType = create_matcher("Ascension #(\\d+\):\\r\\n(Casual|Softcore|Hardcore) "+pathmatch+" "+classmatch+"\\r\\n"+moonmatch,ascensionLogs);
	if(runType.find())
	{
		print(ascension);
		print(runType.group(1).to_int());
		//0-Line 1-Asc # 2- SC/HC/C 3-Path 4-Class 5-Moon Sign
		if(runType.group(1).to_int() != ascension-1)
			abort("Not correct log");
	}
	string[int] runLog = loadLogsArray(ascension);
	print(runLog.count());
	int startIndex = -1;
	int endIndex;
	int currentTurn = 0;
	int logCount = 0;
	string previousEncounter;
//  0000	Turn	Location	Encounter	Familiar	Mus	Myst	Mox	Meat	Special	Items	0
	int[string,string,string,string,string] runLogArray;
	string loc,fam,mus,mys,mox,met,spc,itl;
	
	foreach i in runLog
	{
		boolean log = false;
		string line = runLog[i];
		string enc;
		//Skip til you find beginning of ascension - 1 day ascensions will probably break this
		matcher ascensionInt = create_matcher("Ascension #(\\d+\):",line);
		boolean found = ascensionInt.find();
		if(!found && startIndex == -1)
		{
			continue;
		}
		else if(found)
			startIndex = i;
		//Abort when end is found
		//End of CS - "Took choice 1089/30: Perform Service"
		if(line.index_of("Took choice 1089/30: Perform Service") != -1 || line.index_of("Freeing King Ralph") != -1 || line.index_of("Encounter: You Found It!") != -1 )
		{			
			print(currentTurn);
			print(i);
			print(line);
			print("Done with log");
			break;
		}
		
		
		
		/*
		
			Begin parsing turns;
		
		*/
		
		//Community Service Service "Took choice 1089/11: Perform Service (60 Adventures)"
		matcher serviceLog = create_matcher("Took choice 1089/(\\d+\): Perform Service \\((\\d+\) Adventures\\)",line);
		if (find(serviceLog))
		{
			switch(serviceLog.group(1).to_int())
			{
				case 1:
				{
					enc = "Donate Blood (HP)";
					break;
				}
				case 2:
				{
					enc = "Feed The Children (Muscle)";
					break;
				}
				case 3:
				{
					enc = "Build Playground Mazes (Mysticality)";
					break;
				}
				case 4:
				{
					enc = "Feed Conspirators (Moxie)";
					break;
				}
				case 5:
				{
					enc = "Breed More Collies (Familiar Weight)";
					break;
				}
				case 6:
				{
					enc = "Reduce Gazelle Population (Melee Damage)";
					break;
				}
				case 7:
				{
					enc = "Make Sausage (Spell Damage)";
					break;
				}
				case 8:
				{
					enc = "Be a Living Statue (-combat)";
					break;
				}
				case 9:
				{
					enc = "Make Margaritas (Item Drops and Booze Drops)";
					break;
				}
				case 10:
				{
					enc = "Clean Steam Tunnels (Hot Protection)";
					break;
				}
				case 11:
				{
					enc = "Coil Wire (Always 60)";
					break;
				}

			}
			if((currentTurn+serviceLog.group(2).to_int()) < currentTurn)
				abort("Something went wrong current turncount is less than previous");
			currentTurn += serviceLog.group(2).to_int();
			//print("["+currentTurn+"] " +line);
			loc = "Community Service";
			logCount++;
		}
		matcher adven = create_matcher("\\[(\\d+)\\](.+?)$", line);
		if(adven.find())
		{
			if(adven.group(1).to_int() < currentTurn)
				abort("Something went wrong current turncount is less than previous");
			currentTurn = adven.group(1).to_int();
			loc = adven.group(2).to_string();
			print(adven.group(1));
			print(adven.group(1).url_encode());
		}
		//Encounter "Encounter: Apathetic Tyrannosaurus"
		matcher encounter = create_matcher("Encounter: (.+?)$",line);
		if(encounter.find())
		{
			//print("["+currentTurn+"] " +encounter.group(1));
			enc = encounter.group(1);
			if(enc.contains_text("Sweet Synthesis"))
				loc = "Skill";
			print(encounter.group(1));
			print(encounter.group(1).url_encode());
			log = true;
			logCount++;
		}
		//Familiar "familiar XO Skeleton (25 lbs)"
		matcher familarmatch = create_matcher("familiar (.+) \\((\\d+) lbs\\)",line);
		if(familarmatch.find())
		{
		//	print("["+currentTurn+"] Switched familiars:" +familarmatch.group(1)+" weight: "+familarmatch.group(2));
			familarmatch.group(1);
			fam = familarmatch.group(1);
		}
//  0000	Turn	Location	Encounter	Familiar	Mus	Myst	Mox	Meat	Special	Items	0
		if(log)
		{
			write("+++++++++++++++++++"+to_string(logCount,"%04d")+" - "+to_string(currentTurn)+" - "+loc+" - "+enc+" - "+fam+" - "+to_string(mus)+" - "+to_string(mys)+" - "+to_string(mox)+" - "+to_string(met)+" - "+spc+" - "+itl);
			//runLogArray[to_string(logCount,"%04d"),to_string(currentTurn),loc,enc,fam,to_string(mus),to_string(mys),to_string(mox),to_string(met),spc,itl] = logCount;
			runLogArray[to_string(logCount,"%04d"),to_string(currentTurn),loc,enc,fam] = logCount;
		}
		
		/*
			Parsing special skills
		*/
	}
	
	map_to_file(runLogArray,my_name()+"testing.txt");
	
}

void main(int Ascensions2)
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

	findAscensions(Ascensions2);
	foreach asc,startdate,enddate in Ascensions
	{
		print(asc);
		print(startdate);
		print(enddate);
		RunLogParse(asc,startdate,enddate);
	}
}
