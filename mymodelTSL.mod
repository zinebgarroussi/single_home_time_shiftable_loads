param H ;
param nruns := 100;
set J := {1..H}; 
set I := {2..H}; 
param number_appliances;
set KK := {1..number_appliances}; 
set I_TLS := {1..number_appliances}; 

set DEST;


var tsl_binary {DEST,J}  binary >=0;
var tsl_power {DEST,J}  >=0;

var tsl_starting_time{DEST} integer >=0;
var tsl_SUM{J} >=0;



param minimum_st {DEST} >= 0;
param maximum_st {DEST} >= 0;
param prefered_st {DEST} >= 0;
param processing {DEST} >= 0;
param power_processing {DEST} >= 0;


param CHARGING_EFF;
param DISCHARGING_EFF;
param CHARGING_MAX;
param DISCHARGING_MAX;
param SOC_MAX;
param SOC_MIN;
param E_BATTERY;

param CONTRACTUAL_PEAK;
param my_alpha;


param PRICE {J} >= 0;
param base_load {J} >= 0;


param pv_production {J} >= 0;


# Decision variables 


var GRID_2_LOAD {J} >=0; 



# Battery
var B_CH {J}  binary; 
var B_DS {J}  binary;
var CHARGING_BATT {J} >=0;
var DISCHARGING {J} >=0;
var SOC {J} >=0;

# VARIABLES PV 
var PV_2_LOAD {J} >=0;
var PV_2_BATTERY {J} >=0;
var PV_2_GRID {J} >=0;


# Battery distribution

var BATTERY_2_LOAD {J} >=0;
var BATTERY_2_GRID {J} >=0;
var GRID_2_BATTERY {J} >=0;


var load_appliances {J} >=0;

var Total_Cost;

var DISCOMFORT_Cost;

var REVENUE_AMOUNT;

param PARAM1;
param PARAM2;


param FETOILE1;
param FETOILE2;


param FETOILE1m;
param FETOILE2m;


var B_HVAC {J} binary; 
var B_WS {J} binary; 
var POWER_HVAC {J} >=1.00;
var POWER_WS {J} >=1.00;
var temp_in {J};
var temp_hot {J};

param C_water;
param V_total;
param temp_cold;

param R; # thermal resistance of the building shell in (C/kW)
param C; #  Heat capacity of indoor air (kWh/C)
param temp_min;
param temp_max;

param temp_out {J};
param  hot_water_usage {J} >= 0;

##################################################################


var dis_vect_{DEST} >=0;
var dis_vect_a >=0;
var diss_hvac_m {J} >=0;
var diss_hvac_a >=0;


var zzz {DEST} binary; 
param epsi2=0.000000001;
var discomfort_level >=0;




var Total_Cost_v {J};

minimize my_fitness1: (Total_Cost - REVENUE_AMOUNT);

minimize my_fitness2: discomfort_level;


maximize my_fitness1m: (Total_Cost - REVENUE_AMOUNT); # 18000.00;  # 

maximize my_fitness2m: discomfort_level; 


var BBB{J} binary; 


minimize my_fitness: (((Total_Cost - REVENUE_AMOUNT - FETOILE1) / (FETOILE1m - FETOILE1)) * PARAM1) + (((discomfort_level  - FETOILE2)/(FETOILE2m-FETOILE2))* (1.00-PARAM1)); 




 s.t. Constraint0 : Total_Cost ==  ((sum {t in J} Total_Cost_v[t]));



#s.t. Constraint0 : Total_Cost ==  sum {t in J}  ((GRID_2_BATTERY[t] + GRID_2_LOAD[t])* PRICE[t]) ;



s.t. Constraint04__ : REVENUE_AMOUNT == (sum {t in J} (PV_2_GRID[t]*12.00));


#s.t. Constraint0ff_{t in J}:  (GRID_2_BATTERY[t]+GRID_2_LOAD[t]) <= 100.00;  # CONTRACTUAL_PEAK;

var CONDITION_COST {J} binary; 
param epsi=0.000000001;

s.t. Constraint1aq {t in J}: CONDITION_COST[t] = 0 ==> (GRID_2_BATTERY[t]+GRID_2_LOAD[t]) <= CONTRACTUAL_PEAK;
s.t. Constraint2aq {t in J}: CONDITION_COST[t] = 0 ==> Total_Cost_v[t]=((GRID_2_LOAD[t]+GRID_2_BATTERY[t])*PRICE[t]) ;

s.t. Constraint3aq {t in J}: CONDITION_COST[t] = 1 ==> (GRID_2_LOAD[t]+GRID_2_BATTERY[t]) >= (CONTRACTUAL_PEAK+ epsi);
s.t. Constraint4aq {t in J}: CONDITION_COST[t] = 1 ==> Total_Cost_v[t]=((GRID_2_LOAD[t]+GRID_2_BATTERY[t])*PRICE[t]*my_alpha) ;




s.t. Constraint12 {t in J}: B_CH[t]+B_DS[t]<=1.00;
s.t. Constraint13 {t in J}: CHARGING_BATT[t]>= 0.00;
s.t. Constraint14 {t in J}: DISCHARGING[t]>=0.00;
s.t. Constraint15 {t in J}: CHARGING_BATT[t]<=CHARGING_MAX*B_CH[t];
s.t. Constraint16 {t in J}: DISCHARGING[t]<=DISCHARGING_MAX*B_DS[t];



s.t. Constraint18 {t in J}:  pv_production[t] == (PV_2_LOAD[t] + PV_2_BATTERY[t] + PV_2_GRID[t]);

s.t. Constraint20 {t in J}: ( GRID_2_LOAD[t]+ BATTERY_2_LOAD[t] + PV_2_LOAD[t]) == (tsl_SUM[t] + base_load[t]); 

#s.t. Constraint20 {t in J}: ( GRID_2_LOAD[t]+ BATTERY_2_LOAD[t] + PV_2_LOAD[t]) == (tsl_SUM[t] + base_load[t] + POWER_HVAC[t]*B_HVAC[t] + POWER_WS[t]*B_WS[t]); 

s.t. Constraint22 {t in J}:  (GRID_2_BATTERY[t] + PV_2_BATTERY[t] ) ==  CHARGING_BATT[t];
s.t. Constraint23 {t in J}:  BATTERY_2_LOAD[t] ==  DISCHARGING[t];



s.t. Constraint26: SOC[1] == 0.20;
s.t. Constraint27: SOC[H]== 0.20;


s.t. Constraint33 {t in I}: SOC[t]==( SOC[t-1]+((CHARGING_BATT[t-1]*CHARGING_EFF)/E_BATTERY)+((-DISCHARGING[t-1])/ (E_BATTERY*DISCHARGING_EFF)));

s.t. Constraint34 {t in I}: SOC[t]>=SOC_MIN;
s.t. Constraint35 {t in I}: SOC[t]<=SOC_MAX; 

# APPLIANCES


s.t. Constraint50 {j in DEST}: sum { t in J :  t>= minimum_st[j] and t<=maximum_st[j]-processing[j]+1}  tsl_binary[j,t]==1;

s.t. Constraint51 {j in DEST, t in J :  t < minimum_st[j] or t > maximum_st[j]-processing[j]+1}:  tsl_binary[j,t]==0;



  
#s.t. Constraint5M0 {i in DEST}: tsl_starting_time[i] == prefered_st[i];


s.t. Constraint52 {j in DEST, t in J}:  tsl_power[j,t] == (sum { d in J : d <= t and d <= processing[j] } (tsl_binary[j,t-d+1]*power_processing[j]));




s.t. Constraint53 {j in DEST} :  tsl_starting_time[j] == sum { t in I} (t * tsl_binary[j,t]);


s.t. Constraint54 {t in J} : tsl_SUM[t] ==  sum{ j in DEST} tsl_power[j,t]  ;



#############################################################

s.t. Constraint1_ap1 {i in DEST}: zzz[i]=1 ==>   tsl_starting_time[i] <= prefered_st[i] - epsi2 ;

s.t. Constraint1_ap2 {i in DEST}: zzz[i]=1 ==> dis_vect_[i] = ((prefered_st[i]- tsl_starting_time[i])*(1/(prefered_st[i]-minimum_st[i])));

s.t. Constraint1_ap3 {i in DEST}: zzz[i]=0 ==>   tsl_starting_time[i]  >=  prefered_st[i]; 
s.t. Constraint1_ap4 {i in DEST}: zzz[i]=0 ==> dis_vect_[i] = ((tsl_starting_time[i] - prefered_st[i])*(1/(maximum_st[i]-prefered_st[i])));

s.t. Constraint1_ap5 : dis_vect_a == (100* ((sum {i in DEST} dis_vect_[i])* 1/number_appliances));


s.t. Constraintdis :  discomfort_level == (dis_vect_a);


#######################################################################################""


#s.t. Constraint38W: temp_hot[1] == 70.00;

#s.t. Constraint39W {t in I}: temp_hot[t] == temp_hot[t-1] +  (hot_water_usage[t-1]*( temp_cold - temp_hot[t-1]))/V_total+(POWER_WS[t-1]*B_WS[t-1])/(V_total*C_water);


##s.t. Constraint399W {t in I}: temp_hot[t]==70.00;

#s.t. Constraint399MW {t in I}: temp_hot[t]<=80.00;
#s.t. Constraint3999W {t in I}: temp_hot[t]>=60.00;

#s.t. Constraint399MWH {t in I}: POWER_WS[t]<=5.00;
#s.t. Constraint3999WH {t in I}: POWER_WS[t]>=1.00;

#######################################

#s.t. Constraint24H : temp_in[1] == 19.00;

#s.t. Constraint25H {t in I}:  temp_in[t] == temp_in[t-1]*exp(-1/(R*C)) + R*(1-exp(-1/(R*C)))*POWER_HVAC[t-1]*B_HVAC[t-1]+ (1-exp(-1/R*C))*temp_out[t-1];


##s.t. Constraint255H {t in I}: temp_in[t] == 19.00;

#s.t. Constraint255MH {t in J}: temp_in[t] <= 24.00;
#s.t. Constraint2555H {t in J}:  temp_in[t]>= 15.00;


#s.t. Constraint255MHA {t in I}: POWER_HVAC[t] <=5.00;
#s.t. Constraint2555HA {t in I}: POWER_HVAC[t]>= 1.00;



