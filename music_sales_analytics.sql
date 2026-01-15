with metalsalesbase as (
  Select
  cast(Year(i.InvoiceDate) as varchar) as Salesyear,
  art.Name as ArtistName, 
  il.Quantity*il.UnitPrice as Linetotal 
  from Invoice i
  join InvoiceLine il on il.InvoiceId=i.InvoiceId
  join Track t on t.TrackId=il.TrackId
  join Album a on a.AlbumId=t.AlbumId
  join Artist art on art.ArtistId=a.ArtistId
  join Genre g on g.GenreId=t.GenreId
  where g.Name like '%Metal%' and t.Composer is not null and i.BillingCountry not in ('USA', 'Canada')
)

Select 
Case 
when grouping(Salesyear)=1 then 'All Years'
when grouping(ArtistName)=1 then concat(Salesyear, ' All')
else Salesyear
End as Year,
Case 
when grouping(Salesyear)=1 then 'All Artists'
when grouping(ArtistName)=1 then concat('All Artists in ', Salesyear)
else ArtistName
End as Artist_Name,
cast(sum(Linetotal) as decimal (10,0)) as Totalrevenue 
from metalsalesbase
group by rollup(Salesyear, ArtistName)
order by Salesyear
