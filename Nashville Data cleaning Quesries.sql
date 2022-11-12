select*from [Nashville Housing Data]

---convert to Standardize date format

select SaleDate from [Nashville Housing Data] 
alter table [Nashville Housing Data] 
alter column [SaleDate] date
          ---to check from excel data if the conversion id correct
select*from [Nashville Housing Data]         
where UniqueID=4513
          
		-----another way of conversion
		select [SaleDate], convert(date, [SaleDate])
        from [dbo].['Nashville Housing Data for Data$']

        update [dbo].['Nashville Housing Data for Data$']
        set [SaleDate]=convert(date, [SaleDate])


----Update the Property Address at Null..check if there is any patterrn in property address to fill null value
 
 select*from [Nashville Housing Data]

select* from [Nashville Housing Data] where PropertyAddress IS NULL
  Select propertyAddress, ParcelID from [Nashville Housing Data]
  where ParcelID='043 04 0 014.00'

            ---we can see that same parcel ID has addres for one record and not for other 
			   ---so we can replace the null with same property address, join the self table for same parcel Id but Diff. Unique ID

select a.propertyAddress, a.ParcelID, b.propertyAddress, b.ParcelID, ISNULL(a.propertyAddress,b.propertyAddress)
from [Nashville Housing Data] a
join [Nashville Housing Data] b
on a.ParcelID=b.ParcelID
and a.UniqueID<>b.UniqueID
where a.propertyAddress IS NULL
 
update a
set propertyAddress = ISNULL(a.propertyAddress,b.propertyAddress)
from [Nashville Housing Data] a
join [Nashville Housing Data] b
on a.ParcelID=b.ParcelID
and a.UniqueID<>b.UniqueID
where a.propertyAddress IS NULL

select*from [Nashville Housing Data]

select* from [Nashville Housing Data] where PropertyAddress IS NULL


----Breaking Address into individual column...analyse the address first and breake it into (Adddress, City, State)
Select*from [Nashville Housing Data]
  Select propertyAddress from [Nashville Housing Data]

  select
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
  from [Nashville Housing Data]

        ---Put the fount values af Address in new table

alter table [Nashville Housing Data]
add PropertyAddress1 nvarchar(255)

update [Nashville Housing Data]
set PropertyAddress1=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)


alter table [Nashville Housing Data]
add PropertyAddressCity1 nvarchar(255)

update [Nashville Housing Data]
set PropertyAddressCity1 =SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) 


----Change Y and N to Yes anf No in "Sold as Vacant" field

select Distinct(SoldAsVacant), count(SoldAsVacant) from [Nashville Housing Data]
group by SoldAsVacant
order by count(SoldAsVacant)


select SoldAsVacant,
case WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant end
from [Nashville Housing Data]

update [Nashville Housing Data]
set SoldAsVacant=case WHEN SoldAsVacant='Y' THEN 'Yes'
     WHEN SoldAsVacant='N' THEN 'No'
	 ELSE SoldAsVacant end

select SoldAsVacant from [Nashville Housing Data] where SoldAsVacant='N'

----Split Owner address into Address, City and State
select OwnerAddress from [Nashville Housing Data] 

select OwnerAddress, 
PARSENAME(REPLACE(Owneraddress, ',','.'), 3) ,
PARSENAME(REPLACE(Owneraddress, ',','.'), 2) ,
PARSENAME(REPLACE(Owneraddress, ',','.'), 1) 
from [Nashville Housing Data]

Alter Table [Nashville Housing Data] 
Add OwnerAddress1 nvarchar(255)

update [Nashville Housing Data] 
set OwnerAddress1=PARSENAME(REPLACE(Owneraddress, ',','.'), 3)


Alter Table [Nashville Housing Data] 
Add OwnerAddressCity nvarchar(50)

update [Nashville Housing Data] 
set OwnerAddressCity=PARSENAME(REPLACE(Owneraddress, ',','.'), 1)

Alter Table [Nashville Housing Data] 
Add OwnerAddressState nvarchar(50)

update [Nashville Housing Data] 
set OwnerAddressState=PARSENAME(REPLACE(Owneraddress, ',','.'), 1)

select OwnerAddressState from [Nashville Housing Data] 


------Remove Duplicates....Check Records with completely similar data...then remove duplicate data

select*from [Nashville Housing Data] 

WITH CTE_NashvilleHousingData  AS
(select*, ROW_NUMBER() OVER(
PARTITION BY ParcelID, PropertyAddress, saledate, saleprice, LegalReference
ORDER BY ParcelID)Index_Num
from [Nashville Housing Data ])
select*from CTE_NashvilleHousingData 
where Index_Num>1


----Code for Deleteting from CTE
-----DELETE FROM CTE_NashvilleHousingData WHERE Index_Num>1
