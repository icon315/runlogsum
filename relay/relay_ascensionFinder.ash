import scripts/datelib.ash;
import htmlform.ash

string[int,string] Ascensions;
//Ascensions[DateStart,IndexStart,DateEnd,IndexEnd]

string[int]AscensionEnd;
string[int]AscensionStart;
boolean rowStart = false;
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
LOV Extraterrestrial Chocolate,
LOV Eardigan,
LOV Epaulettes,
LOV Earrings,
worm-riding manual page,
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

void scripts()
{
	writeln("<script src=\"Chart.js\"></script>");	
	writeln("<script language=\"Javascript\" type=\"text/javascript\" src=\"sorttable.js\"></script>");
}
void row()
{
	if(!rowStart)
	{
		writeln("<tr>");
		rowStart = true;
	}
	else
	{
		writeln("</tr>");
		rowStart = false;
	}
}
void column(string contents, string style)
{
	writeln("<td style=\""+style+"\">"+contents+"</td>");
}
void column(string contents)
{
	column(contents,"");
}
void startTable(boolean[string] header)
{

	writeln("<table cellpadding=\"13\" cellspacing=\"0\" border=\"1px\" class=\"sortable\">");
	foreach i in header
		writeln("<th>"+i+"</th>");
}

void startTableNH()
{
	writeln("<table cellpadding=\"13\" cellspacing=\"0\" border=\"1px\" class=\"sortable\">");
}
void finishTable()
{
	writeln("</table>");
}

void printTrace(string mes)
{	
	//printTrace(get_stack_trace()[0].line+": "+mes);
}


string loadLogs(int ascension)
{

	string[int] sessionlogs;
	string cumlog;
	foreach asc,date,dateend in Ascensions
	{
		if(asc == ascension)
		{
			printTrace(date);
			printTrace(dateend);
			printTrace(datediff(date,dateend));
			sessionlogs = session_logs(my_name(),date,datediff(date,dateend));
			break;
		}
	}
	for i from 0 to sessionlogs.count()-1
	{
		printTrace(sessionlogs[i].length());
		cumlog += sessionlogs[i];
	}
	printTrace(cumlog.length());
	int ascStart = cumlog.index_of("Ascension #"+ascension+":");
	if(cumlog.index_of("Took choice 1089/30: Perform Service", ascStart) != -1)
		cumlog = cumlog.substring(ascStart,cumlog.index_of("Took choice 1089/30: Perform Service",ascStart));
	else if(cumlog.index_of("Freeing King Ralph", ascStart) != -1)
		cumlog = cumlog.substring(ascStart,cumlog.index_of("Freeing King Ralph",ascStart));
	else if(cumlog.index_of("Encounter: You Found It!", ascStart) != -1)
		cumlog = cumlog.substring(ascStart,cumlog.index_of("Encounter: You Found It!",ascStart));
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
			printTrace(date);
			printTrace(dateend);
			printTrace(datediff(date,dateend));
			sessionlogs = session_logs(my_name(),date,datediff(date,dateend));
			break;
		}
	}
	for i from 0 to sessionlogs.count()-1
	{
		printTrace(sessionlogs[i].length());
		cumlog += sessionlogs[i];
	}
	printTrace(cumlog.length());
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



int[string,string] getConsumables(string log)
{
	int[string,string] consList;
	matcher cons = create_matcher("(eat|drink|chew) (\\d+?) (.+?)\n",log);
	while (find(cons))
	{
		print(cons.group(3));
		print(cons.end());
		consList[cons.group(3),cons.group(1)] += cons.group(2).to_int();

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

int[skill] getSkills(string log)
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
	matcher pulls = create_matcher("\npull: (\\d+) (.+?)\n",log);
	while (pulls.find())
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

void RunPullsParse(int ascension)
{
	int[item] pullLog = getPulls(loadLogs(ascension));
	startTable($strings[Item,Amount]);
	foreach i in pullLog
	{
		row();
		column(i);
		column(pullLog[i]);
		row();
	
	}
	finishTable();
}

void RunSkillsParse(int ascension)
{
	int[skill] skillLog = getSkills(loadLogs(ascension));
	startTable($strings[Skill,Total MP,Estimated MP Cost]);
	foreach i in skillLog
	{
		row();
		column(i);
		column(skillLog[i]);
		column((mp_cost(i))*(skillLog[i]));
		row();
	
	}
	finishTable();

}
void RunConsumablesParse(int ascension)
{
	int[string,string] consLog = getConsumables(loadLogs(ascension));
	startTable($strings[Type,Item,Amount]);
	foreach x,y,z in consLog
	{
		row();
		column(y);
		column(x);
		column(z);
		row();
	
	}
	finishTable();

}

void RunLogParse(int ascension, string startlog, string endlog)
{
	string[int] runLog = loadLogsArray(ascension);
	int[string] locationList;
	printTrace(runLog.count());
	int startIndex = -1;
	int endIndex;
	int currentTurn = 0;
	int logCount = 0;
	string previousEncounter;
//  0000	Turn	Location	Encounter	Familiar	Mus	Myst	Mox	Meat	Special	Items	0
	int[string,string,string,string,string,string,string,string,string,string,string] runLogArray;
	string loc,fam,spc,itm;
	int mus,mys,mox,meat;
	logData thisEncounter;
	string pathmatch = "(";
	foreach i in paths { pathmatch += i+"|"; }
	pathmatch = pathmatch.substring(0,pathmatch.last_index_of("|")) + ")";
	print (pathmatch);
	string classmatch = "(";
	foreach i in $classes[] { classmatch += i+"|"; }
	classmatch = classmatch.substring(0,classmatch.last_index_of("|")) + ")";
	print (classmatch);
	string moonmatch = "^(";
	foreach i in moonsigns { moonmatch += i+"|"; }
	moonmatch = moonmatch.substring(0,moonmatch.last_index_of("|")) + ")";
	print (moonmatch);
	
	foreach i in runLog
	{
		boolean log = false;
		string line = runLog[i];
		string enc;
		/*
			Ascension Matching
		*/
		matcher runType = create_matcher("^(Casual|Softcore|Hardcore) "+pathmatch+" "+classmatch,line);
		matcher moonmatchMatcher = create_matcher(moonmatch, line);	
		matcher ascensionInt = create_matcher("Ascension #(\\d+\):",line);
		//Skip til you find beginning of ascension - 1 day ascensions will probably break this
		boolean found = ascensionInt.find();
		if(!found && startIndex == -1)
		{
			continue;
		}
		else if(found)
		{			
			writeln("<h3><br/>"+ascensionInt.group(0));
			startIndex = i;
		}
		if(runType.find())
		{
			writeln(runType.group(0));
		}
		if(moonmatchMatcher.find())
		{
			writeln("<br/>"+moonmatchMatcher.group(0)+"</h3>");
			startTable($strings[Turn,Location,Encounter,Familiar,Stat Gains,Meat Gain, Special, Item Drops]);
		}
		//Abort when end is found
		//End of CS - "Took choice 1089/30: Perform Service"
		if(line.index_of("Took choice 1089/30: Perform Service") != -1 || line.index_of("Freeing King Ralph") != -1 || line.index_of("Encounter: You Found It!") != -1 )
		{			
			printTrace(currentTurn);
			printTrace(i);
			printTrace(line);
			printTrace("Done with log");
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
			//printTrace("["+currentTurn+"] " +line);
			loc = "Community Service";
			locationList[enc] = serviceLog.group(2).to_int();
			log = true;
			logCount++;
		}
		//You acquire an item: x (y)
		matcher acquire = create_matcher("^You acquire an item: (.+?)$", line);
		if(acquire.find())
		{
			matcher multiple =  create_matcher("(.+?) \\((\\d+)\\)", acquire.group(1));
			if(multiple.find())
			{
				printTrace("=======================================================================");
				printTrace(multiple.group(1));
				printTrace(multiple.group(2));
				if(speclist contains multiple.group(1))
				{
					spc +=  " - "+multiple.group(1)+" ("+multiple.group(2)+")";
					printTrace(spc);
				}
				else
					itm += " - "+multiple.group(1)+" ("+multiple.group(2)+")";
			}
			else
			{
				printTrace(acquire.group(1));
				if(speclist contains acquire.group(1))
				{
					spc +=  " - "+acquire.group(1);
					printTrace(spc);
				}
				else
					itm += " - "+acquire.group(1);
			}
		}
		
		
		matcher adven = create_matcher("^\\[(\\d+)\\](.+?)$", line);
		if(adven.find())
		{
			if(adven.group(1).to_int() < currentTurn)
				abort("Something went wrong current turncount is less than previous");
			if(currentTurn < adven.group(1).to_int())
				locationList[adven.group(2)]++;
			//[2] Cook 1 scrumptious reagent + 1 glass of goat's milk
			matcher crafting = create_matcher("(Cook|Mix)(.+?)$;",adven.group(2));
			if(crafting.find())
			{
				
				loc = crafting.group(1);
			}
			else
				loc = adven.group(2).to_string();
			currentTurn = adven.group(1).to_int();
			printTrace(loc);
		}
		//Encounter "Encounter: Apathetic Tyrannosaurus"
		matcher encounter = create_matcher("^Encounter: (.+?)$",line);
		if(encounter.find())
		{
			//printTrace("["+currentTurn+"] " +encounter.group(1));
			enc = encounter.group(1);
			if(enc.contains_text("Sweet Synthesis"))
				loc = "Skill";
			printTrace(encounter.group(1));
			printTrace(encounter.group(1).url_encode());
			logCount++;
			//Encounter: Starship Partnership :: In your Quarters
			matcher timeSpinner = create_matcher("Starship (.+)",enc);
			matcher bastille = create_matcher("(Bastille Battalion( \\(turn #[\\d+]\\))?|Cheese Seeking Behavior|Castle vs. Castle)",enc);
			if(!timeSpinner.find() && !bastille.find())
				log = true;
		}
		//Familiar "familiar XO Skeleton (25 lbs)"
		matcher familarmatch = create_matcher("^familiar (.+) \\((\\d+) lbs\\)",line);
		if(familarmatch.find())
		{
		//	printTrace("["+currentTurn+"] Switched familiars:" +familarmatch.group(1)+" weight: "+familarmatch.group(2));
			familarmatch.group(1);
			fam = familarmatch.group(1);
		}
		
		
		//Stat gains
		matcher stats = create_matcher("You gain ([0-9,]+) (Beefiness|Fortitude|Muscleboundness|Strengthliness|Strongness)",line);
		if (find(stats)) 
		{ 
			mus += to_int(stats.group(1)); 
			printTrace(stats.group(0)); 
			
		}
		stats = create_matcher("You gain ([0-9,]+) (Enchantedness|Magicalness|Mysteriousness|Wizardliness)",line);
		if (find(stats))
		{ 
			mys += to_int(stats.group(1)); 
			printTrace(stats.group(1)); 
			printTrace(stats.group(0)); 
		}
		stats = create_matcher("You gain ([0-9,]+) (Cheek|Chutzpah|Roguishness|Sarcasm|Smarm)",line);
		if (find(stats))
		{
			mox += to_int(stats.group(1));
			printTrace(stats.group(0)); 
		}
		stats = create_matcher("You gain ([0-9,]+) Meat",line);
		if (find(stats))
		{ 
			meat += to_int(stats.group(1)); 
			printTrace(stats.group(0)); 
		}
		
		
		
//  0000	Turn	Location	Encounter	Familiar	Mus	Myst	Mox	Meat	Special	Items	0
		if(log)
		{
			row();
			//runLogArray[to_string(logCount,"%04d"),to_string(currentTurn),loc,enc,fam,to_string(mus),to_string(mys),to_string(mox),to_string(met),spc,itl] = logCount;
			column(currentTurn);
			column(loc);
			column(enc);
			column(fam);
			column("("+mus+","+mys+","+mox+")");
			column(meat);
			column(spc.length() == 0 ? "" : spc.substring(2, spc.length()));
			column(itm.length() == 0 ? "" : itm.substring(2, itm.length()));
			row();
			runLogArray[to_string(logCount,"%04d"),to_string(currentTurn),loc,enc,fam,mus.to_string(),mys.to_string(),mox.to_string(),meat.to_string(),(itm.length() == 0 ? "" : itm.substring(2, itm.length())), (spc.length() == 0 ? "" : spc.substring(2, spc.length()))] = logCount;
			mus = 0;
			mys = 0;
			mox = 0;
			meat = 0;
			itm="";
			spc="";
		}
		
		/*
			Parsing special skills
		*/
	}
	
	foreach i in locationList
		print(i+": "+locationList[i]);
	finishTable();
	map_to_file(runLogArray,my_name()+"testing.txt");
	
}

void main()
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

	file_to_map("logascensions.txt",Ascensions);
	write_page();
	if(Ascensions.count() == 0)
	{	
		writeln("Please run ascensionFinder.ash");
	}
	boolean[string] options;
	write_box("Options:");
	write_box("Choose ascension to load:");
	
	int temp = write_select(0, "ascension", "");
	
	foreach asc, startDate,endDate in Ascensions
		write_option("#"+asc+" Logs: "+startDate+" => "+endDate, asc);
	finish_select();
	//Ascensions[0," "] = " ";
	writeln("<br/>");
	finish_box();
	write_check(false, "charts", "Show Charts");	
	writeln("<br/>");
	finish_box();
	writeln("<h2>Which charts to load?</h2>");
	write_radio("logs", "tables", "All Logs", "logs");	
	write_radio("skills", "tables", "Skills", "skills");	
	write_radio("consumables", "tables", "Consumables", "consumables");	
	write_radio("pulls", "tables", "Pulls", "pulls");	
	fields = form_fields();
	//success = count(fields) > 0;
	if(write_button("load", "Load")) {
		writeln("<br/>Loaded...");
		
		switch(fields['ascension'])
		{
			case "":
			{
				break;
			}
			case fields['ascension']:
			{
				if( fields['charts'] == "on")
				{
					//doCharts();
				}
				
				if( fields['tables'] == "logs")
				{
					printTrace("running logs");
					foreach asc,startdate,enddate in Ascensions
					{
						if(asc == fields['ascension'].to_int())
						{
							RunLogParse(asc,startdate,enddate);
						}
					}
					
				}
				else if( fields['tables'] == "skills")
				{
					printTrace("running skills");
					foreach asc,startdate,enddate in Ascensions
					{
						if(asc == fields['ascension'].to_int())
						{
							RunSkillsParse(asc);
						}
					}
					
				}
				else if( fields['tables'] == "pulls")
				{
					printTrace("running pulls");
					foreach asc,startdate,enddate in Ascensions
					{
						if(asc == fields['ascension'].to_int())
						{
							RunPullsParse(asc);
						}
					}
					
				}
				else if( fields['tables'] == "consumables")
				{
					printTrace("running consumables");
					foreach asc,startdate,enddate in Ascensions
					{
						if(asc == fields['ascension'].to_int())
						{
							RunConsumablesParse(asc);
						}
					}
					
				}
				break;
			}
			default:
			{
				break;
			}
		}
	}
	foreach i, j in fields{
		printTrace(i);
		printTrace(j);
	}
    finish_page(); 
}

