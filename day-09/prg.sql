drop table if exists numbers;
drop table if exists preamble;
drop table if exists sums;
drop table if exists fail;
drop table if exists range;
.mode csv

create table numbers
(
    n numeric,
    i INTEGER PRIMARY KEY
);
create table preamble as
select 25 as size;
.import 'input' numbers

create table fail as
select n as f
from numbers x,
     preamble
where x.i > size
  and not exists(
        select 1
        from numbers a,
             numbers b
        where a.i < x.i
          and a.i >= x.i - size
          and b.i < x.i
          and b.i >= x.i - size
          and a.n + b.n = x.n
    );

select *
from fail;

create table sums as
select i,
       (select sum(n)
        from numbers y
        where y.i < x.i) as s
from numbers x;

create table range as
select sa.i as low, b.i as high
from numbers b,
     sums sa,
     sums sb,
     fail
where  b.i = sb.i
  and sa.i < b.i
  and b.n + sb.s - sa.s = f;

select min(n) + max(n)
from numbers,
     range
where i >= low
  and i <= high;
