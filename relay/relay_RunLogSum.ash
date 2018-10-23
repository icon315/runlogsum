script "relay_RunLogSum.ash";
notify icon315;

import "htmlform.ash";
/*
Original code by ckb:

https://sourceforge.net/projects/ckbrunlogsum/
svn checkout https://svn.code.sf.net/p/ckbrunlogsum/code/

*/
string[int] sessionlogs;
string sessionlogsstring;
string[int] sessionlogscount;

void loadLogs(int getdays)
{
	sessionlogs = session_logs(getdays);
	for days from getdays downto 1
	{
		sessionlogsstring += sessionlogs[days-1];
	}

	sessionlogscount = sessionlogsstring.split_string("Beginning New Ascension");

}

void RunLogSum(int ascensionNumber ) {

	//static {
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

		boolean[item] blackit = $items[
		broken champagne bottle,
		tinsel tights,
		wad of used tape,
		makeshift garbage shirt,
		tinsel tights,
		chewing gum on a string,

		];

	//}

	//cli_execute("cls");

	set_property("logAcquiredItems",true);
	set_property("logBattleAction",true);
	set_property("logDecoratedResponses",true);
	set_property("logFamiliarActions",true);
	set_property("logGainMessages",true);
	set_property("logMonsterHealth",true);
	set_property("logPreferenceChange",false);
	set_property("logStatGains",true);
	set_property("logStatusEffects",true);



	string runlog = "";
	//for ii from my_daycount() downto 1 { runlog += session_logs(my_daycount())[ii-1]; }
	//runlog += session_logs(1)[0];
	print(sessionlogscount);
	print(sessionlogscount.count());
	print(sessionlogscount.count()-(my_ascensions()-ascensionNumber));
	runlog = sessionlogscount[sessionlogscount.count()-(my_ascensions()-ascensionNumber)];
	writeln(substring(runlog,index_of(runlog,":")+1,index_of(runlog,"Uncategorized")).replace_string("\n", "</br>"));
	//runlog = substring(runlog,index_of(runlog,"Beginning New Ascension"));
	if (contains_text(runlog,"Freeing King Ralph")) { runlog = substring(runlog,0,index_of(runlog,"Freeing King Ralph")+18); }
	if (contains_text(runlog,"Took choice 1089/30: Perform Service")) { runlog = substring(runlog,0,index_of(runlog,"Took choice 1089/30: Perform Service")+36); }
	if (contains_text(runlog,"Encounter: You Found It!")) { runlog = substring(runlog,0,index_of(runlog,"Encounter: You Found It!")+24); }
	string ffn = my_name()+"-runlog_"+to_string(ascensionNumber+2,"%04d")+".txt";

	int[string,string,string,string,string,string,string,string,string,string,string] rlx;
	rlx["0000","Turn","Location","Encounter","Familiar","Mus","Myst","Mox","Meat","Special","Items"]=0;
	//#,idx ,trn ,loc ,enc ,fam ,mus ,mys ,mox ,meat,spc ,itl

	//matcher mrl = create_matcher("\\[(\\d+)\\] (.+?)\n(?:Encounter: (.+?)\n)?([\\w\\W\\n]+?)(?=\\[)",runlog);
	//matcher: 1:turn 2:loc3:Enc 4:other
	matcher mrl = create_matcher("\\[(\\d+)\\] (.+?)\n([\\w\\W\\n]+?)(?=\\[)",runlog);
	//matcher: 1:turn 2:loc3:other

	int[skill] castlist;
	string[int] loclist;
	int[string,string,string] banishlist;
	familiar fam = $familiar[none];

	writeln("<script src=\"Chart.js\"></script>");

	writeln("<script language=\"Javascript\" type=\"text/javascript\" src=\"sorttable.js\"></script>");
	writeln("<canvas id=\"AscensionData\" width=\"1300px\" height=\"700px\"></canvas>");
	writeln("<canvas id=\"SkillsData\" width=\"1300px\" height=\"700px\"></canvas>");

	write("<table cellpadding=\"13\" cellspacing=\"0\" border=\"1px\" class=\"sortable\">");
	write("<tr><td style=\"max-width: 5px;background-color: #EFEFEF\"><a>Turn</a></td><td>Location</td><td style=\"background-color: #EFEFEF\"><a>Encounter</a></td><td>Familiar</td><td style=\"background-color: #EFEFEF\"><a>Mus</a></td><td>Myst</td><td style=\"background-color: #EFEFEF\"><a>Mox</a></td><td>Meat</td><td style=\"background-color: #EFEFEF\"><a>Special</a></td><td>Items</td></tr>");

	matcher mrlcs = create_matcher("Took choice 1089/(\\d+\): Perform Service \\((\\d+\) Adventures\\)",runlog);

	while (find(mrlcs)) {


	write("<tr><td>");
	write(to_string("Total Turns ("+group(mrlcs,2)+")"));
	write("</td><td>");
	write(to_string("Community Service"));
	write("</td><td>");
	switch(group(mrlcs,1).to_int())
	{
		case 1:
		{
			write("Donate Blood (HP)");
			break;
		}
		case 2:
		{
			write("Feed The Children (Muscle)");
			break;
		}
		case 3:
		{
			write("Build Playground Mazes (Mysticality)");
			break;
		}
		case 4:
		{
			write("Feed Conspirators (Moxie)");
			break;
		}
		case 5:
		{
			write("Breed More Collies (Familiar Weight)");
			break;
		}
		case 6:
		{
			write("Reduce Gazelle Population (Melee Damage)");
			break;
		}
		case 7:
		{
			write("Make Sausage (Spell Damage)");
			break;
		}
		case 8:
		{
			write("Be a Living Statue (-combat)");
			break;
		}
		case 9:
		{
			write("Make Margaritas (Item Drops and Booze Drops)");
			break;
		}
		case 10:
		{
			write("Clean Steam Tunnels (Hot Protection)");
			break;
		}
		case 11:
		{
			write("Coil Wire (Always 60)");
			break;
		}

	}
	write("</td><td></td><td></td><td></td><td></td><td></td><td></td><td></td></tr>");

	}

	while (find(mrl)) {
		int trn = to_int(group(mrl,1));
		string loc = group(mrl,2);
		string txt = group(mrl,3);

		if (loc!="") { loc = substring(loc,0,length(loc)-1); }



		matcher mtt;

		mtt = create_matcher("\nfamiliar (.+?) \\(\\d+ lbs\\)",txt);
		while (find(mtt)) { fam = to_familiar(group(mtt,1)); }

		string enc = "";
		mtt = create_matcher("Encounter: (.+?)\n",txt);
		if (find(mtt)) { enc = group(mtt,1); }

		if (enc!="") { enc = substring(enc,0,length(enc)-1); }
		//print(enc);
		//print(char_at(enc,length(enc)-2));
		//print("---");

		int mus = 0;
		int mys = 0;
		int mox = 0;
		int met = 0;

		mtt = create_matcher("You gain ([0-9,]+) (Beefiness|Fortitude|Muscleboundness|Strengthliness|Strongness)",txt);
		while (find(mtt)) { mus += to_int(group(mtt,1)); }
		mtt = create_matcher("You gain ([0-9,]+) (Enchantedness|Magicalness|Mysteriousness|Wizardliness)",txt);
		while (find(mtt)) { mys += to_int(group(mtt,1)); }
		mtt = create_matcher("You gain ([0-9,]+) (Cheek|Chutzpah|Roguishness|Sarcasm|Smarm)",txt);
		while (find(mtt)) { mox += to_int(group(mtt,1)); }
		mtt = create_matcher("You gain ([0-9,]+) Meat",txt);
		while (find(mtt)) { met += to_int(group(mtt,1)); }

		string itl = "";
		mtt = create_matcher("You acquire an item: (.+?)\n",txt);
		//mtt = create_matcher("You acquire an item: (.+?)(?: \\(\\d+\\))?\n",txt);
		while (find(mtt)) {
			string ss = group(mtt,1);
			//ckb: hack for reports of multiple drops
			foreach nn in $strings[(1), (2), (3), (4), (5)] { ss = replace_string(ss,nn,""); }
			item it = to_item(ss);
			if (!(blackit contains it)) { itl += it+"|"; }
		}

		string spc = "";
		foreach ss in speclist {
			if (contains_text(txt,ss)) {
			spc += ss;
			banishlist[spc,enc,loc] ++;
			}
		}

		if (contains_text(loc,"An Overgrown Shrine")) {
			loclist[trn] = "An Overgrown Shrine";
		} else if (contains_text(loc,"The Typical Tavern Cellar")) {
			loclist[trn] = "The Typical Tavern Cellar";
		} else if (contains_text(loc,"The Lower Chambers")) {
			loclist[trn] = "The Lower Chambers";
		} else if (contains_text(loc,"Tower Level")) {
			loclist[trn] = "NS Tower";
		} else if (contains_text(loc,"The Daily Dungeon")) {
			loclist[trn] = "The Daily Dungeon";
		} else {
			loclist[trn] = loc;
		}

		//rlx[to_string(count(rlx))+"_"+to_string(trn),loc,enc,to_string(fam),to_string(mus),to_string(mys),to_string(mox),to_string(met),spc,itl] = count(rlx);
		rlx[to_string(count(rlx),"%04d"),to_string(trn),loc,enc,to_string(fam),to_string(mus),to_string(mys),to_string(mox),to_string(met),spc,itl] = count(rlx);

		mtt = create_matcher("cast (\\d+?) (.+?)\n",txt);
		while (find(mtt)) {
			int ncc = to_int(group(mtt,1));
			skill skl = to_skill(group(mtt,2));
			castlist[skl] += ncc;
		}
		mtt = create_matcher("casts (.+?)!\n",txt);
		while (find(mtt)) {
			skill skl = to_skill(group(mtt,1));
			castlist[skl] += 1;
		}

		mtt = create_matcher("(eat|drink|chew) (\\d+?) (.+?)\n",txt);
		while (find(mtt)) {
			mus = 0;
			mys = 0;
			mox = 0;
			met = 0;
			enc = "";
			spc = "";
			itl = "";
			loc = group(mtt);
			loc = replace_string(loc,"\n","");
			if (loc!="") { loc = substring(loc,0,length(loc)-1); }
			rlx[to_string(count(rlx),"%04d"),to_string(trn),loc,enc,to_string(fam),to_string(mus),to_string(mys),to_string(mox),to_string(met),spc,itl] = count(rlx);
		}

		mtt = create_matcher("You gain a Level!",txt);
		while (find(mtt)) {
			//print(trn+"	"+group(mtt));
		}
		if(spc.last_index_of("!") != -1)
			spc = spc.substring(0,spc.last_index_of("!"));
		while(itl.last_index_of("|") != -1)
			itl = itl.replace_string("|",", ");
		if (loc.index_of("eat") == 0 || loc.index_of("drink") == 0 || loc.index_of("eat") == 0)
			continue;
		write("<tr>");
		write("<td>");
		write(to_string(trn));
		write("</td>");
		write("<td>");
		write(to_string(loc));
		write("</td>");
		write("<td>");
		write(to_string(enc));
		write("</td>");
		write("<td>");
		write(to_string(fam));
		write("</td>");
		write("<td>");
		write(to_string(mus));
		write("</td>");
		write("<td>");
		write(to_string(mys));
		write("</td>");
		write("<td>");
		write(to_string(mox));
		write("</td>");
		write("<td>");
		write(to_string(met));
		write("</td>");
		write("<td>");
		write(to_string(spc));
		write("</td>");
		write("<td>");
		write(to_string(itl));
		write("</td>");
		write("</tr>");

		//if (trn>55) { break; }
	}
	map_to_file(banishlist,"TESTINGBEE.txt");
	write("</table>");
	write("<<h1>Banishes and Limited Skills</h1><table cellpadding=\"3\" cellspacing=\"0\" border=\"1px\" class=\"sortable\">");
	write("<tr><td>Item/Skill Name</td><td>Monster</td><td>Location</td><td># of Times</td></tr>");
	foreach itm,mons,loc,times in banishlist{ write("<tr><td>"+itm+"</td><td>"+mons+"</td><td>"+loc+"</td><td>"+times+"</td></tr>"); }
	write("</table>");

	write("<h1>Consumables Table</h1><table cellpadding=\"3\" cellspacing=\"0\" border=\"1px\" class=\"sortable\">");
	write("<tr><td>Organ</td><td>Amount</td><td>Type</td></tr>");
	foreach indx,tc,ll in rlx {		
		matcher consm = create_matcher("(eat|drink|chew) (\\d+?) (.+)",ll);
		print(ll);
		if(find(consm))
		{
			print("found");
			write("<tr><td>"+consm.group(1)+"</td><td>"+consm.group(2)+"</td><td>"+consm.group(3)+"</td></tr>");
		}
		else
			print("didn't find more");
	}
	write("</table>");
	
	int[string] loccount;
	foreach tt,ll in loclist {if (ll.index_of("eat") == 0 || ll.index_of("drink") == 0 || ll.index_of("eat") == 0|| ll.index_of("Cook") == 0) continue; loccount[ll] += 1;}


	//Location - Labels
	string varDataLC = "'";
	foreach ll,nn in loccount {varDataLC = varDataLC+(ll.replace_string("'",""))+"','";}
	varDataLC = varDataLC.substring(0,varDataLC.length()-1);

	//Location - Turn Count
	string varDataTC = "";
	foreach ll,nn in loccount { varDataTC = varDataTC+(nn+1)+",";}
	varDataTC = varDataTC.substring(0,varDataTC.length()-1);


	//Skills - Labels
	string varDataSK = "'";
	foreach sk,ii in castlist {varDataSK = varDataSK+(sk.replace_string("'",""))+"','";}
	varDataSK = varDataSK.substring(0,varDataSK.length()-1);


	//Skills - Count
	string varDataSKCT = "";
	foreach sk,ii in castlist { varDataSKCT = varDataSKCT+(ii+1)+",";}
	varDataSKCT = varDataSKCT.substring(0,varDataSKCT.length()-1);



	//Skills - MP Cost

	string varDataSKCTMP = "";
	foreach sk,ii in castlist { varDataSKCTMP = varDataSKCTMP+((ii+1)* sk.mp_cost())+",";}
	varDataSKCTMP = varDataSKCTMP.substring(0,varDataSKCTMP.length()-1);


	writeln("<script>var ctx = document.getElementById(\"AscensionData\"); var AscensionData = new Chart(ctx, { type: 'bar',data: {labels: ["+varDataLC+"],datasets: [{label: 'Current Ascension',data: ["+varDataTC+"], backgroundColor: [ ");


	string[int] coloRs;
foreach colorCode in $strings["#3366CC", "#DC3912", "#FF9900", "#109618", "#990099", "#3B3EAC", "#0099C6", "#DD4477", "#66AA00", "#B82E2E", "#316395", "#994499", "#22AA99", "#AAAA11", "#6633CC", "#E67300", "#8B0707", "#329262", "#5574A6", "#3B3EAC"]
	{
		coloRs[count(coloRs)] = colorCode;
	}
	int chooseColor = 0;
	foreach i in loccount { if(chooseColor > 19) chooseColor=0;write(coloRs[chooseColor]+","); chooseColor++;}
	write("],borderColor: 'rgba(255, 255, 255, 1)',borderWidth: 5 }] }, options: { responsive: false,legend: {display: false}, scales: { xAxes: [{categoryPercentage:1.0 ,barPercentage:1.0 ,ticks: { fontSize:10, maxRotation: 90,minRotation: 90}}]}, title: { display: true, fontSize:20, text: 'Ascension Data' } }});</script>");

	writeln("<script>var ctx = document.getElementById(\"SkillsData\"); var SkillsData = new Chart(ctx, { type: 'bar', ");

	write("data: { labels: ["+varDataSK+"], datasets: [{ label: '# Times skills Casted', data: ["+varDataSKCT+"], backgroundColor: '#3366CC',borderColor: 'rgba(255, 255, 255, 1)',borderWidth: 5},{ ");

	write(" label: 'Total MP Cost (Predicted)',hidden: true, data: ["+varDataSKCTMP+"], backgroundColor: '#DC3912',borderColor: 'rgba(255, 255, 255, 1)',borderWidth: 5 }] }, ");

	write("options: { responsive: false, scales: { xAxes: [{categoryPercentage:1.0 ,barPercentage:1.0 ,ticks: { fontSize:10, maxRotation: 90,minRotation: 90}}]}, title: { display: true, fontSize:20, text: 'Skills Data' } }});</script>");


	//print("");

//	print("Skill casting");
	//foreach sk,ii in castlist { print(ii+"	"+sk); }


	//cli_execute("mirror");
	//cli_execute("cls");

	map_to_file(rlx,ffn);
	print("RunLog summary saved to: "+ffn,"blue");

}

void main(){
	//Load 90 logs
	loadLogs(90);
	write_page();
	writeln("<link rel='stylesheet' type='text/css' href='http://images.kingdomofloathing.com/styles.css' />");
	writeln("<center><h3>Choose ascension to load:<br/>");
	writeln("<form name='relayform' method='POST' action=''>");
	for i from my_ascensions() downto (my_ascensions()-20)
	{
		writeln("<input class=\"button\" type=\"submit\" name=\"ascension\" value='"+(i == my_ascensions() ? "Current Ascension" : (i+1))+"'/>");
	}
	writeln("</form></center><hr/>");
	fields = form_fields();
	success = count(fields) > 0;
	switch(fields['ascension'])
	{
		case "":
		{
			break;
		}
		case "Current Ascension":
		{
			RunLogSum(my_ascensions()-1);
			break;
		}
		case fields['ascension']:
		{
			RunLogSum(fields['ascension'].to_int()-2);
			break;
		}
		default:
		{
			break;
		}
	}
}





