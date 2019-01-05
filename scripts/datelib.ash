# DateLib v1.0
#    written by Heeheehee (#354981)
# Provides access to date-related functions:
#    : Moon phases
#    : Moon brightness
#    : Minimoon info
#    : Grimace darkness (for use with grimacite equips)
# Functions are overloaded for use with integer dates and no date (defaults to today).
# Sources used: 
#    : persistence/HolidayDatabase.java (Mafia's own source code!)
#    : http://kolmafia.us/showthread.php?1213-Convert-real-world-calendar-dates-into-KoL-calendar-dates&p=6743&viewfull=1#post6743
#          (several functions were taken from this post)
#

// Use dateform() to create this record from an integer like the one produced by today_to_string().
record date{
   int y;
   int m;
   int d;
};

date dateform(int date) {
   // formats the date.
   date f;
   f.y = date.substring(0,date.length()-4).to_int();
   f.m = date.substring(date.length()-4,date.length()-2).to_int();
   f.d = date.substring(date.length()-2,date.length()).to_int();
   // Doesn't check to see if these are valid, but it doesn't really matter anyway (unless month is invalid).
   // Uses substring() so it can accept variable-length years.
   return f;
}
date dateform(string a) {
   return dateform(a.to_int());
}

boolean isleapyear(int year) {
   return (year%400==0)||(!(year%100==0)&&(year%4==0));
}

int leapsbetween(int firstYear, int lastYear) {
   int count = max(firstyear, 4);
   int result = 0;
   if(count < max(lastYear, 4)) {
      while(count != max(lastYear, 4)) {
         if(isleapyear(count)) result += 1;
         count += 1;
      }
   }
   return result;
}

int daystillfirst(int month, int year) {
   int result;
   switch(month){
      case 1: return 0;
      case 2: return 31;
      case 3: 
         result = 60; break;
      case 4: 
         result = 91; break;
      case 5: 
         result = 121; break;
      case 6: 
         result = 152; break;
      case 7: 
         result = 182; break;
      case 8: 
         result = 213; break;
      case 9: 
         result = 244; break;
      case 10: 
         result = 274; break;
      case 11: 
         result = 305; break;
      case 12: 
         result = 335;
   }
   if(isleapyear(year)) result += 1;
   return result;
}

int datediff(date a, date b) {
   //returns x days from date a until date b.
   int years = b.y - a.y;
   int date1 = (a.y * 365) + leapsbetween(1, a.y) + daystillfirst(a.m, a.y) + a.d;
   int date2 = (b.y * 365) + leapsbetween(1, b.y) + daystillfirst(b.m, b.y) + b.d;
   return (date2 - date1);
}

int datediff(int a, int b) {
   return datediff(dateform(a), dateform(b));
}

int datediff(string a, string b) {
   return datediff(a.to_int(), b.to_int());
}

int datediff(date a) {
   return datediff(dateform(today_to_string()), a);
}

int datediff(int a) {
   return datediff(today_to_string().to_int(), a);
}

int datediff(string a) {
   return datediff(today_to_string(), a);
}

int moon_phase(date target) {
   return (datediff(dateform(20050817),target)%16); // This is moon_phase(), with a date specified.
}

int moon_phase(int a) {
   return moon_phase(dateform(a));
}

int moon_phase(string a) {
   return datediff(a.to_int());
}

int hamburglarLight(int ronaldPhase, int grimacePhase, int hamburglarPosition) {
   hamburglarPosition = (hamburglarPosition+4)%11;
   switch ( hamburglarPosition ) {
      case 0:
         if ( grimacePhase > 0 && grimacePhase < 5 )
            return -1;
         return 1;
      case 1:
         if ( grimacePhase < 4 )
            return 1;
         return -1;
      case 2:
         if ( grimacePhase > 3 )
            return 1;
         return 0;
      case 4:
         if ( grimacePhase > 0 && grimacePhase < 5 )
            return 1;
         return 0;
      case 5:
         if ( ronaldPhase > 3 )
            return 1;
         return 0;
      case 7:
         if ( ronaldPhase > 0 && ronaldPhase < 5 )
            return 1;
         return 0;
      case 8:
         if ( ronaldPhase > 0 && ronaldPhase < 5 )
            return -1;
         return 1;
      case 9:
         if ( ronaldPhase < 4 )
            return 1;
         return -1;
      case 10:
         int totalEffect = 0;
         if ( ronaldPhase > 3 )
            totalEffect+=1;
         if ( grimacePhase > 0 && grimacePhase < 5 )
            totalEffect+=1;
         return totalEffect;
   }
   return 0;
}

int minimoon(date target) {
   // position 0 is dark, left of Ronald.
   int m = (datediff(dateform(20100521),target)* 2 % 11 + 11 ) % 11;
   if(m<0) m+=11;
   return m;
}

int minimoon(int a) {
   return minimoon(dateform(a));
}

int minimoon(string a) {
   return minimoon(a.to_int());
}

int minimoon() {
   return minimoon(today_to_string());
}

int moon_light(date target) {
   int mm = (datediff(dateform(20060503),target)* 2 % 11 + 11 ) % 11;
   int grimacePhase = moon_phase(target) / 2;
   int ronaldPhase = moon_phase(target) % 8;
   int ronaldLight = ronaldPhase;
   if(ronaldPhase > 4) ronaldLight = 8 - ronaldPhase;
   int grimaceLight = grimacePhase;
   if(grimaceLight > 4) grimaceLight = 8 - grimacePhase;
   // Function to determine what's lit, and what isn't.
   return hamburglarLight(ronaldPhase,grimacePhase,mm)+ronaldLight+grimaceLight;
}

int moon_light(int a) {
   return moon_light(dateform(a));
}

int moon_light(string a) {
   return moon_light(a.to_int());
}

int hamburglarDarkness(int ronaldPhase, int grimacePhase, int hamburglarPosition) {
   hamburglarPosition = (hamburglarPosition + 4)%11;
   switch ( hamburglarPosition ) {
      case 0:
         if ( grimacePhase > 0 && grimacePhase < 5 )
            return 1;
         return -1;
      case 1:
         if ( grimacePhase < 4 )
            return -1;
         return 1;
      case 2:
         if ( grimacePhase > 3 )
            return 0;
         return 1;
      case 4:
         if ( grimacePhase > 0 && grimacePhase < 5 )
            return 0;
         return 1;
      case 5:
         if ( ronaldPhase > 3 )
            return 0;
         return 1;
      case 7:
         if ( ronaldPhase > 0 && ronaldPhase < 5 )
            return 0;
         return 1;
      case 8:
         if ( ronaldPhase > 0 && ronaldPhase < 5 )
            return 1;
         return 0;
      case 9:
         if ( ronaldPhase < 4 )
            return 0;
         return 1;
      case 10:
         if ( ronaldPhase > 3 )
            return 0;
         if ( grimacePhase > 0 && grimacePhase < 5 )
            return 0;
         return 1;
   }
   return 0;
}

int grimacite_darkness(date target) {
   int mm = (datediff(dateform(20060503),target)* 2 % 11 + 11 ) % 11;
   int grimacePhase = moon_phase(target) / 2;
   int ronaldPhase = moon_phase(target) % 8;
   int ronaldLight = ronaldPhase;
   if(ronaldPhase > 4) ronaldLight = 8 - ronaldPhase;
   int grimaceLight = grimacePhase;
   if(grimaceLight > 4) grimaceLight = 8 - grimacePhase;
   return 4 - grimaceLight + hamburglarDarkness(ronaldPhase, grimacePhase, mm);
}

int grimacite_darkness(int a) {
   return grimacite_darkness(dateform(a));
}

int grimacite_darkness(string a) {
   return grimacite_darkness(a.to_int());
}

int grimacite_darkness() {
   return grimacite_darkness(dateform(today_to_string()));
}
