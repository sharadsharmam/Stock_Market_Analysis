use assignment; # using the schema assignment in which we have imported our tables.

# As the `Date` column in all the company's stock is in string format, we wil convert it into date type.
# %e is used when dates are in the form of 0,1,2,..30,31
# %M is used when months are in the form of 'January','February',...,'December'
# %Y is used when year is in 4 digit format like 2014, 2015 etc.

# We will now change the `Date` column into proper format for all the tables.
update bajaj_auto
set `Date` = str_to_date(`Date`,'%e-%M-%Y');

update eicher_motors
set `Date` = str_to_date(`Date`,'%e-%M-%Y');

update hero_motocorp
set `Date` = str_to_date(`Date`,'%e-%M-%Y');

update infosys
set `Date` = str_to_date(`Date`,'%e-%M-%Y');

update tcs
set `Date` = str_to_date(`Date`,'%e-%M-%Y');

update tvs_motors
set `Date` = str_to_date(`Date`,'%e-%M-%Y');

# We will need moving averages of previous 20 and 50 days.
# Therefore we will create a new table for each of the company and add Date, Close Price, moving avg of 20 days and moving avg of 50 days.
create table bajaj1 as
(select `Date`, `Close Price`,
avg(`Close Price`) over (order by `Date` ASC ROWS 20 PRECEDING) as `20 Day MA` ,
avg(`Close Price`) over (order by `Date` ASC ROWS 50 PRECEDING) as `50 Day MA`
from bajaj_auto);

create table eicher_motors1 as
(select `Date`, `Close Price`,
avg(`Close Price`) over (order by `Date` ASC ROWS 20 PRECEDING) as `20 Day MA` ,
avg(`Close Price`) over (order by `Date` ASC ROWS 50 PRECEDING) as `50 Day MA`
from eicher_motors);

create table hero_motocorp1 as
(select `Date`, `Close Price`,
avg(`Close Price`) over (order by `Date` ASC ROWS 20 PRECEDING) as `20 Day MA` ,
avg(`Close Price`) over (order by `Date` ASC ROWS 50 PRECEDING) as `50 Day MA`
from hero_motocorp);

create table infosys1 as
(select `Date`, `Close Price`,
avg(`Close Price`) over (order by `Date` ASC ROWS 20 PRECEDING) as `20 Day MA` ,
avg(`Close Price`) over (order by `Date` ASC ROWS 50 PRECEDING) as `50 Day MA`
from infosys);

create table tcs1 as
(select `Date`, `Close Price`,
avg(`Close Price`) over (order by `Date` ASC ROWS 20 PRECEDING) as `20 Day MA` ,
avg(`Close Price`) over (order by `Date` ASC ROWS 50 PRECEDING) as `50 Day MA`
from tcs);

create table tvs_motors1 as
(select `Date`, `Close Price`,
avg(`Close Price`) over (order by `Date` ASC ROWS 20 PRECEDING) as `20 Day MA` ,
avg(`Close Price`) over (order by `Date` ASC ROWS 50 PRECEDING) as `50 Day MA`
from tvs_motors);

# Creating a master table where we can find the close price of each company for each date.
create table master_table as (
select b.`Date`,
b.`Close Price` as `Bajaj`,
em.`Close Price` as `Eicher`,
hm.`Close Price` as `Hero`,
i.`Close Price` as `Infosys`,
tcs.`Close Price` as `TCS`,
tvs.`Close Price` as `TVS`
from bajaj1 b inner join eicher_motors1 em on b.`date` = em.`date`
inner join hero_motocorp1 hm on em.`date` = hm.`date`
inner join infosys1 i on hm.`date` = i.`date`
inner join tcs1 tcs on i.`date` = tcs.`date`
inner join tvs_motors1 tvs on tcs.`date` = tvs.`date`
);

# We will need to identify when to sell, buy or hold the stock of each company. Therefore we will create a new table for each company
#we will indicate the signal whether to buy, sell or hold.

#Creating a function which takes input 20 day avg and 50 day avg and returns whether to hold, buy or sell the stock.

# we will use a variable 'up' which will indicate whether the 20 day avg was upside or lower side of the 50 day avg the previous day.
set @up= (select case when `20 Day MA`<`50 Day MA` then 0
						when `20 Day MA`>`50 Day MA` then 1 end
from bajaj1 where `20 Day MA`!=`50 Day Ma` order by `Date` limit 1);

delimiter //
create function signal_func(small_ma float, large_ma float) returns varchar(10) deterministic
begin
	declare res varchar(10);

	if small_ma > large_ma and @up = 0 then set res = 'Buy', @up = 1;
	elseif small_ma < large_ma and @up = 1 then set res = 'Sell', @up = 0;
	else set res = 'Hold';
	end if;

	return res;
end; //
delimiter ;

# Creating the table with the signal to buy, hold or sell stock for each of the company.
create table `bajaj2` as (
select `Date`,`Close Price`, signal_func(`20 Day MA`, `50 Day MA`) as `Signal`
from bajaj1);

set @up= (select case when `20 Day MA`<`50 Day MA` then 0
						when `20 Day MA`>`50 Day MA` then 1 end
from eicher_motors1 where `20 Day MA`!=`50 Day Ma` order by `Date` limit 1);

create table `eicher_motors2` as (
select `Date`,`Close Price`, signal_func(`20 Day MA`, `50 Day MA`) as `Signal`
from eicher_motors1);

set @up= (select case when `20 Day MA`<`50 Day MA` then 0
						when `20 Day MA`>`50 Day MA` then 1 end
from hero_motocorp1 where `20 Day MA`!=`50 Day Ma` order by `Date` limit 1);

create table `hero_motocorp2` as (
select `Date`,`Close Price`, signal_func(`20 Day MA`, `50 Day MA`) as `Signal`
from hero_motocorp1);

set @up= (select case when `20 Day MA`<`50 Day MA` then 0
						when `20 Day MA`>`50 Day MA` then 1 end
from infosys1 where `20 Day MA`!=`50 Day Ma` order by `Date` limit 1);

create table `infosys2` as (
select `Date`,`Close Price`, signal_func(`20 Day MA`, `50 Day MA`) as `Signal`
from infosys1);

set @up= (select case when `20 Day MA`<`50 Day MA` then 0
						when `20 Day MA`>`50 Day MA` then 1 end
from tcs1 where `20 Day MA`!=`50 Day Ma` order by `Date` limit 1);

create table `tcs2` as (
select `Date`,`Close Price`, signal_func(`20 Day MA`, `50 Day MA`) as `Signal`
from tcs1);

set @up= (select case when `20 Day MA`<`50 Day MA` then 0
						when `20 Day MA`>`50 Day MA` then 1 end
from tvs_motors1 where `20 Day MA`!=`50 Day Ma` order by `Date` limit 1);

create table `tvs_motors2` as (
select `Date`,`Close Price`, signal_func(`20 Day MA`, `50 Day MA`) as `Signal`
from tvs_motors1);

# Creating a function which takes date as input and returns the signal for that date for bajaj stock.
delimiter //
create function give_signal(inp date) returns varchar(10) deterministic
begin
	return (select `Signal` from bajaj2 where `Date` = inp);
end; //
delimiter ;

select *
