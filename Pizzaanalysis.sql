--- Database architecture---

drop table if exists Receipt, Ingredient, Pizza, PizzaType, #tempingredients, #temptypes
 
create table PizzaType 
(PizzaTypeId int identity primary key not null, 
PizzaTypeName varchar(100) not null check (Pizzatypename != ''))
create table Pizza 
(PizzaId int not null identity primary key, 
Pizzaname varchar(100), 
Price decimal(5,2), 
Pizzatypeid int foreign key references Pizzatype(Pizzatypeid), 
check (Price > 0))
create table Ingredient 
(Ingredientid int identity primary key not null, 
IngredientName varchar(100) not null)
create table Receipt 
(PizzaId int not null foreign key references Pizza(PizzaId), 
Ingredientid int not null foreign key references Ingredient (Ingredientid), 
primary key(Pizzaid, Ingredientid))
 
 --- ETL and DML ---

declare @pizzatypesxml xml
set @pizzatypesxml = '<pizzatypes>
<pizzatype>
<name>classic</name>
</pizzatype>
<pizzatype>
<name>vegetarian</name>
</pizzatype>
<pizzatype>
<name>gluten free</name>
</pizzatype>
<pizzatype>
<name>kids special</name>
</pizzatype>
<pizzatype>
<name>extra spicy</name>
</pizzatype>
<pizzatype>
<name>deep dish</name>
</pizzatype>
</pizzatypes>'
 
 
Select 
pizzatyped.value('name[1]', 'nvarchar(50)') as pizzatypes
into #temptypes
from @pizzatypesxml.nodes('/pizzatypes/pizzatype') as t(pizzatyped)
 
insert into #temptypes (pizzatypes)
Select distinct Pizzatype from pizzaimport
 
insert into PizzaType(PizzaTypename)
Select distinct pizzatypes from #temptypes
 
 
insert into Pizza (Pizzaname, Price, PizzaTypeId)
Select Pizza, Price, Pizzatype.PizzaTypeId from pizzaimport
join PizzaType on Pizzatype.PizzaTypeName=pizzaimport.Pizzatype

with Parsedingredients as ( 
Select Pizzaid, value as ingredientName from pizzaimport
join Pizza p on p.Pizzaname=pizzaimport.Pizza
cross apply string_split(ingredients, '/')
 
)

insert into Ingredient (IngredientName)
Select distinct ingredientName from Parsedingredients
where IngredientName not in (select IngredientName from Ingredient)
 
insert into Receipt (PizzaId, Ingredientid)
Select t.PizzaId, i.IngredientId from #tempingredients t
join Ingredient i on i.IngredientName=t.ingredient

update Pizzatype set Pizzatypename = lower(Pizzatypename)
 
--- Reporting ---
 
go
create or alter view ingredientname
as
Select  IngredientName, count(distinct PizzaId)  as countofpizzas from Ingredient
join Receipt on Receipt.Ingredientid=Ingredient.Ingredientid
group by Ingredientname
 
go
 
create or alter function returnpizza (@ingredientname nvarchar(100))
returns table
as
 
return (Select p.PizzaId, p.Pizzaname, p.Price, pt.PizzaTypeName from Pizza p
join Receipt r on r.PizzaId=p.PizzaId
join Ingredient i on i.Ingredientid=r.Ingredientid
join PizzaType pt on pt.PizzaTypeId=p.Pizzatypeid
where i.IngredientName=@ingredientname)
 
go
Select * from dbo.returnpizza ('Parmesan');
 
go

with originaltable as (
Select PizzatypeName, Pizzaname, Price, STRING_AGG(IngredientName, '/') as ingredients, 
rank() over (partition by PizzatypeName order by Price desc) as Pricerank from Pizza p
join Pizzatype pt on pt.PizzaTypeId=p.Pizzatypeid
join Receipt r on r.PizzaId=p.PizzaId
join Ingredient i on i.Ingredientid=r.Ingredientid
group by Pizzaname, Price, PizzatypeName
 )
Select * from originaltable
where Pricerank > 3
order by PizzatypeName asc
