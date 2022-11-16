select*from [dbo].['Nashville Housing Data for Data$']

sp_rename ['Nashville Housing Data for Data$'], 'Nashville_Housing_Data'

select*from Nashville_Housing_Data

------------TO VIEW THE DETAILS ABOUT TABLE

sp_help Nashville_Housing_Data


------------CHANGING DATATYPES TO PROPER FORMAT

alter table Nashville_Housing_Data
alter column uniqueid int

alter table Nashville_Housing_Data
alter column saledate date
------------OR
update Nashville_Housing_Data
set saledate=CAST(saledate as date)

alter table Nashville_Housing_Data
alter column bedrooms int

alter table Nashville_Housing_Data
alter column fullbath int

alter table Nashville_Housing_Data
alter column halfbath int

------------CREATING UNIQUE CLUSTRED INDEX ON 'UNIQUE ID' COLUMN

create unique clustered index UCIX_UniqueID_Nashville
on Nashville_Housing_Data (UniqueID)

------------CHECKING FOR NULL VALUES AND FILLING NULL WIHT PROPER VALUES
select*from Nashville_Housing_Data
where PropertyAddress is null

select uniqueid, parcelid, propertyaddress from Nashville_Housing_Data
where ParcelID in ('052 01 0 296.00','093 08 0 054.00','092 13 0 322.00')
order by 2

/*   From the above observation we can see that same parcel id has got value in one PropertyAddress row and not for other 
     but both rows has different UniqueID   */
	 
------------POPULATING THE 'PropertyAddress' WHERE IT HAS GOT NULL VALUE


select n1.[UniqueID ], n1.parcelid, n1.propertyaddress,n2.[UniqueID ], n2.parcelid, n2.propertyaddress, isnull(n1.propertyaddress,n2.propertyaddress) Populated_PropertyAddress
from Nashville_Housing_Data n1
join Nashville_Housing_Data n2
on n1.[UniqueID ]<>n2.[UniqueID ] and n1.ParcelID=n2.ParcelID
--where n1.ParcelID in ('052 01 0 296.00','093 08 0 054.00','092 13 0 322.00')
order by 2

begin transaction
update n1
set propertyaddress=  isnull(n1.propertyaddress,n2.propertyaddress) 
from Nashville_Housing_Data n1
join Nashville_Housing_Data n2
on n1.[UniqueID ]<>n2.[UniqueID ] and n1.ParcelID=n2.ParcelID

--select [UniqueID ], parcelid, propertyaddress from Nashville_Housing_Data
--where ParcelID in ('052 01 0 296.00','093 08 0 054.00','092 13 0 322.00')
--order by 2

commit transaction

------------FOMATING THE PROPER NAMING CONVENTION AT COLUMN 'SoldAsVacant'

select SoldAsVacant, case when  SoldAsVacant='N' then 'No' 
                          when SoldAsVacant='Y' then 'Yes' 
						  else SoldAsVacant end
from Nashville_Housing_Data
--where SoldAsVacant in ('N','Y')

begin transaction
update Nashville_Housing_Data
set SoldAsVacant=case when  SoldAsVacant='N' then 'No' 
                          when SoldAsVacant='Y' then 'Yes' 
						  else SoldAsVacant end

--select SoldAsVacant from Nashville_Housing_Data
--where SoldAsVacant in ('N','Y')
commit transaction

------------BREAKING THE 'PropertyAddress' INTO TWO SEPARATE COLUMNS OF ADDRESS AND CITY

select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1)-1) PropertyAddress1,
                        SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1)+1, LEN(PropertyAddress)) PropertyAddress_City
from Nashville_Housing_Data

alter table  Nashville_Housing_Data
add PropertyAddress1 nvarchar(100)

alter table Nashville_Housing_Data
add PropertyAddress_City nvarchar(50)

begin transaction 
update Nashville_Housing_Data
set PropertyAddress1=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress, 1)-1)

update Nashville_Housing_Data
set PropertyAddress_City=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress, 1)+1, LEN(PropertyAddress))

--select PropertyAddress,PropertyAddress1,PropertyAddress_City from Nashville_Housing_Data
commit transaction

------------BREAKING THE 'OwnerAddress' INTO THREE SEPARATE COLUMNS OF ADDRESS, CITY AND STATE

select OwnerAddress, PARSENAME(REPLACE(OwnerAddress,',', '.'),3) OwnerAddress1, 
                     PARSENAME(REPLACE(OwnerAddress,',', '.'),2) Owner_City,
					 PARSENAME(REPLACE(OwnerAddress,',', '.'),1) Owner_State
from Nashville_Housing_Data

alter table Nashville_Housing_Data 
add OwnerAddress1 nvarchar(100)
 
begin transaction
update Nashville_Housing_Data 
set OwnerAddress1=PARSENAME(REPLACE(OwnerAddress,',', '.'),3)

--select OwnerAddress, OwnerAddress1 from Nashville_Housing_Data
commit transaction

alter table Nashville_Housing_Data 
add Owner_City nvarchar(50)

begin transaction
update Nashville_Housing_Data 
set Owner_City=PARSENAME(REPLACE(OwnerAddress,',', '.'),2)

--select OwnerAddress, OwnerAddress1,Owner_City from Nashville_Housing_Data
commit transaction


alter table Nashville_Housing_Data 
add Owner_State nvarchar(10)

begin transaction
update Nashville_Housing_Data 
set Owner_State=PARSENAME(REPLACE(OwnerAddress,',', '.'),1)

--select OwnerAddress, OwnerAddress1,Owner_City, Owner_State from Nashville_Housing_Data
commit transaction

------------CHECKING FOR THE DUPLICATE RECORDS
with cte as
(
select *, ROW_NUMBER() over(partition by  parcelid, landuse, propertyaddress, saledate, saleprice, legalreference, ownername, 
                                         owneraddress, acreage, taxdistrict, landvalue,buildingvalue,totalvalue order by uniqueid) RowNum 
from Nashville_Housing_Data
)
select*from cte
where RowNum>1

select*from Nashville_Housing_Data
where ParcelID='164 07 0A 192.00'

------------DELETING THE DUPLICATE RECORDS
with cte as
(
select *, ROW_NUMBER() over(partition by  parcelid, landuse, propertyaddress, saledate, saleprice, legalreference, ownername, 
                                         owneraddress, acreage, taxdistrict, landvalue,buildingvalue,totalvalue order by uniqueid) RowNum 
from Nashville_Housing_Data
)
--DELETE from cte
--where RowNum>1