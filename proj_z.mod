reset;

param MAX_TIME = 600;

set t = 0..MAX_TIME;
set spawn = 0..MAX_TIME by 15;
set nospawn = t diff spawn;
set qspawn = 0..MAX_TIME by 40;
set noqspawn = t diff qspawn;

var b{i in t} integer; # bases
var w{i in t} integer; # workers

var s{i in t} integer; # total free supply
var m{i in t}; # total money

var bu{i in t} integer; # upgraded bases
var tech{i in t} binary; # is there a spawning pool

var d{i in t} integer; # overlords

var income{i in t}; # income

var bs{i in t} integer; # bases started
var ws{i in t} integer; # workers started

var bus{i in t} integer; # bases starting to upgrade
var techs{i in t} binary; # spawning pool starting

var ds{i in t} integer; # Overlords started

var larv{i in t} integer; # Number of Larva
var larvh{i in t} integer;
var larvq{i in t} integer;

param WORKER_BUILD = 17;
param BASE_BUILD = 100;
param SD_BUILD = 25;
param RAX_BUILD = 65;
param OC_BUILD = 50;

param WORKER_COST = 50;
param BASE_COST = 350;
param SD_COST = 100;
param RAX_COST = 250;
param OC_COST = 150;

param WORKER_SUPP = -1;
param BASE_SUPP = 2;
param SD_SUPP = 8;

param BASE_MAX_WORKER = 24;

# param OC_COLLECT_RATE = 3;
param WORKER_COLLECT_RATE = 34/60;

maximize net_gains: m[MAX_TIME];

subject to init_base {i in 0..BASE_BUILD-1}: b[i] = 1;
subject to init_worker {i in 0..WORKER_BUILD-1}: w[i] = 6;
subject to init_money: m[0] = 0; # we spend our first 50 on our first worker.
subject to init_upg {i in 0..OC_BUILD-1}: bu[i] = 0;
subject to init_tech {i in 0..RAX_BUILD-1}: tech[i] = 0;
subject to init_depots {i in 0..SD_BUILD-1}: d[i] = 1;
subject to init_larv: larv[0] = 2;

subject to hspawn {i in spawn}: larvh[i] = b[i];
subject to no_hspawn {i in nospawn}: larvh[i] = 0;

subject to queen_spawn {i in qspawn}: larvq[i] = 4*bu[i];
subject to no_qspawn {i in noqspawn}: larvq[i] = 0;

subject to init_constructing_bases: bs[0] = 0;
subject to init_constructing_work: ws[0] = 1; # most efficient!
subject to init_constructing_upbase: bus[0] = 0;
subject to init_constructing_rax: techs[0] = 0;
subject to init_constructing_depots: ds[0] = 0;
subject to upgrade_base {i in OC_BUILD..MAX_TIME}: bu[i] = bu[i-1] + bus[i-OC_BUILD];

subject to larv_amt {i in 1..MAX_TIME}: larv[i] = larv[i-1] + larvh[i] + larvq[i] - ws[i] - ds[i];

subject to income_equality {i in t}: income[i] <= w[i]*WORKER_COLLECT_RATE;
subject to base_max_income {i in t}: income[i] <= BASE_MAX_WORKER*b[i]*WORKER_COLLECT_RATE;

subject to supply_constraint {i in t}: s[i] = WORKER_SUPP*(w[i]+ws[i]) - 2*(bu[i] + bus[i]) + BASE_SUPP*b[i] + SD_SUPP*d[i];
subject to max_supply {i in t}: WORKER_SUPP*(w[i]+ws[i]) <= 200;

subject to build_base {i in BASE_BUILD..MAX_TIME}: b[i] = b[i-1] + bs[i-BASE_BUILD];
subject to build_worker {i in WORKER_BUILD..MAX_TIME}: w[i] = w[i-1] + ws[i-WORKER_BUILD];
subject to build_supply {i in SD_BUILD..MAX_TIME}: d[i] = d[i-1] + ds[i-SD_BUILD];
subject to build_rax {i in RAX_BUILD..MAX_TIME}: tech[i] = tech[i-1] + techs[i-RAX_BUILD];

subject to money {i in 1..MAX_TIME}: m[i] =  m[i-1] + income[i] - ws[i]*WORKER_COST - bs[i]*BASE_COST - ds[i]*SD_COST - techs[i]*RAX_COST - bus[i]*OC_COST;

subject to upgrade {i in t}: bu[i] + bus[i] <= b[i];
subject to tech_req {i in t}: bu[i] <= 100*tech[i];

subject to pos_b{i in t}: b[i] >= 0;
subject to pos_w{i in t}: w[i] >= 0;

subject to pos_s{i in t}: s[i] >= 0;
subject to pos_m{i in t}: m[i] >= 0;

subject to pos_bu{i in t}: bu[i] >= 0;
subject to pos_tech{i in t}: tech[i] >= 0;

subject to pos_d{i in t}: d[i] >= 0;

subject to pos_bs{i in t}: bs[i] >= 0;
subject to pos_ws{i in t}: ws[i] >= 0;

subject to pos_bus{i in t}: bus[i] >=0;
subject to pos_techs{i in t}: techs[i] >= 0;

subject to pos_ds{i in t}: ds[i] >= 0;
