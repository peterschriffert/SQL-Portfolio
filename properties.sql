---Database structure---


drop table if exists Apartmentservice
drop table if exists service
drop table if exists apartment
drop table if exists resident
drop table if exists building
drop table if exists Junction
drop table if exists #temp

Create table building (BuildingId int identity primary key, BuildingName nvarchar(50) not null)
Create table resident (ResidentId varchar(10) primary key, Name nvarchar(50) not null, Email nvarchar(50) not null, Birthyear int not null)
Create table apartment (ApartmentId int primary key not null, BuildingId int not null foreign key references building(BuildingId), 
ResidentId varchar(10) foreign key references resident(ResidentId), Floor int not null, Size int not null, Unitprice int not null)
create table service (serviceid int identity primary key, servicename nvarchar(50))
create table Apartmentservice (apartmentid int foreign key references apartment(apartmentid), serviceid int foreign key references service(serviceid), primary key(apartmentid, serviceid))

---Data ingestion---

insert into building (Buildingname) Select distinct building_name from apartments
insert into resident (ResidentId, Name, Email, Birthyear) 
select distinct personid, name, email, birth_year from apartments
insert into apartment (apartmentid, Buildingid, Residentid, Floor, size, Unitprice)
Select a.apartment_number, b.buildingid, a.personid, a.floor, a.square_meters, a.price_per_sqm from apartments a 
join building b on b.BuildingName=a.building_name
Select apartment_number, services, ltrim(rtrim(value)) as services1 into junction from Apartments
cross apply string_split(services, ',')
insert into Service (servicename)
Select distinct services1 as service from junction
insert into Apartmentservice (apartmentid, serviceid)
Select j.apartment_number, s.serviceid from Junction j join service s on j.services1=s.servicename 

alter table resident add constraint agecnstr check(year(getdate())-Birthyear > 18)
go




declare @newapps xml
set @newapps = '<Apartments>
<Apartment>
<BuildingName>Pine Ridge</BuildingName>
<ApartmentNumber>310</ApartmentNumber>
<Floor>5</Floor>
<Size>146</Size>
<UnitPrice>28</UnitPrice>
</Apartment>
<Apartment>
<BuildingName>Pine Ridge</BuildingName>
<ApartmentNumber>311</ApartmentNumber>
<Floor>5</Floor>
<Size>129</Size>
<UnitPrice>12</UnitPrice>
</Apartment>
<Apartment>
<BuildingName>Pine Ridge</BuildingName>
<ApartmentNumber>312</ApartmentNumber>
<Floor>3</Floor>
<Size>104</Size>
<UnitPrice>26</UnitPrice>
</Apartment>
<Apartment>
<BuildingName>Pine Ridge</BuildingName>
<ApartmentNumber>303</ApartmentNumber>
<Floor>3</Floor>
<Size>149</Size>
<UnitPrice>22</UnitPrice>
</Apartment>
<Apartment>
<BuildingName>Pine Ridge</BuildingName>
<ApartmentNumber>304</ApartmentNumber>
<Floor>1</Floor>
<Size>128</Size>
<UnitPrice>17</UnitPrice>
</Apartment>
<Apartment>
<BuildingName>River View</BuildingName>
<ApartmentNumber>305</ApartmentNumber>
<Floor>5</Floor>
<Size>104</Size>
<UnitPrice>28</UnitPrice>
</Apartment>
<Apartment>
<BuildingName>River View</BuildingName>
<ApartmentNumber>306</ApartmentNumber>
<Floor>2</Floor>
<Size>102</Size>
<UnitPrice>28</UnitPrice>
</Apartment>
<Apartment>
<BuildingName>River View</BuildingName>
<ApartmentNumber>307</ApartmentNumber>
<Floor>3</Floor>
<Size>136</Size>
<UnitPrice>26</UnitPrice>
</Apartment>
<Apartment>
<BuildingName>River View</BuildingName>
<ApartmentNumber>308</ApartmentNumber>
<Floor>3</Floor>
<Size>119</Size>
<UnitPrice>13</UnitPrice>
</Apartment>
<Apartment>
<BuildingName>River View</BuildingName>
<ApartmentNumber>309</ApartmentNumber>
<Floor>1</Floor>
<Size>138</Size>
<UnitPrice>18</UnitPrice>
</Apartment>
</Apartments>'


Select 
Apartment.value('BuildingName[1]', 'nvarchar(50)') as Buildingname,
Apartment.value('ApartmentNumber[1]', 'int') as number,
Apartment.value('Floor[1]', 'int') as floor,
Apartment.value('Size[1]', 'int') as size,
Apartment.value('UnitPrice[1]', 'int') as unitprice
into #temp
from @newapps.nodes('Apartments/Apartment') as T(Apartment)

insert into building (buildingname)
select distinct buildingname from #temp

insert into apartment (Apartmentid, buildingid, floor, size, unitprice)
select t.number, b.buildingid, t.floor, t.size, t.unitprice from #temp t
join building b on b.BuildingName=t.Buildingname

---Functions and Views---

go
create or alter function aplevelfee (@unitprice int, @squaremeter int)
returns decimal(10,2)
AS
begin
return @unitprice*@squaremeter*1.1
end 
go
Select count(*) as countofapartments, sum(dbo.aplevelfee(a.unitprice, a.[Size])) as total from apartment a
group by BuildingId
order by count(*) desc 
go
create or alter view vwBuildingApts as 
Select Buildingid, count(*) as countofapartments, sum(dbo.aplevelfee(a.unitprice, a.[Size])) as total from apartment a
group by BuildingId
go





