select * from [DATA CLEANING]..Housingdata

-- standardize date Format 

select SaleDate, convert(date,saledate)
from [DATA CLEANING]..Housingdata

update [DATA CLEANING]..Housingdata
set SaleDate= convert(date,saledate)

 select SaleDate, convert(date,SaleDate) as saledateConv
 from [DATA CLEANING].dbo.Housingdata

 ALTER TABLE datacleaning..housingdata
 add saledateconv date;

 update [DATA CLEANING]..Housingdata
set SaleDate= convert(date,saledate)


 --Populate Property Address data

 select * 
 from [DATA CLEANING]..Housingdata a
 join [DATA CLEANING]..Housingdata b
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null 


 select a.ParcelID,a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.propertyaddress,b.PropertyAddress)
 from [DATA CLEANING]..Housingdata a
 join [DATA CLEANING]..Housingdata b
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null 


update a
set propertyaddress = ISNULL(a.propertyaddress,b.PropertyAddress)
 from [DATA CLEANING]..Housingdata a
 join [DATA CLEANING]..Housingdata b
     on a.ParcelID=b.ParcelID
	 and a.[UniqueID ]<> b.[UniqueID ]
where a.PropertyAddress is null


-- breaking out address into individual colums ( Address, city, state)


select PropertyAddress
from [DATA CLEANING]..Housingdata
--order by ParcelID


select 
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress) -1) as address,
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, len(propertyaddress)) as address

from [DATA CLEANING]..Housingdata

alter table [DATA CLEANING]..Housingdata
add propertySplitaddress nvarchar(255);

update [DATA CLEANING]..Housingdata
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

alter table [DATA CLEANING]..Housingdata
add propertySplitCity nvarchar(255);

 update [DATA CLEANING]..Housingdata
set propertySplitCity= SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress) +1, len(propertyaddress)) 


select owneraddress
from [DATA CLEANING]..Housingdata





select 
parsename(replace(owneraddress, ',','.'),3),
parsename(replace(owneraddress, ',','.'),2),
parsename(replace(owneraddress, ',','.'),1)
from [DATA CLEANING]..Housingdata

alter table [DATA CLEANING]..Housingdata
add ownerSplitAddress nvarchar(255);

update [DATA CLEANING]..Housingdata
set ownerSplitAddress = parsename(replace(owneraddress, ',','.'),3)

alter table [DATA CLEANING]..Housingdata
add ownerSplitcity nvarchar(255);

update [DATA CLEANING]..Housingdata
set ownerSplitcity = parsename(replace(owneraddress, ',','.'),2)

alter table [DATA CLEANING]..Housingdata
add ownerSplitstate nvarchar(255);

update [DATA CLEANING]..Housingdata
set ownerSplitstate = parsename(replace(owneraddress, ',','.'),1)

select * from [DATA CLEANING]..Housingdata

-- Changing Y and N to Yes and NO in "sold as vacant" field

select distinct SoldAsVacant, count(SoldAsVacant)
from [DATA CLEANING]..Housingdata
group by SoldAsVacant
order by 2

select SoldAsVacant,
case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end
from [DATA CLEANING]..Housingdata

update [DATA CLEANING]..Housingdata
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
     when SoldAsVacant = 'N' then 'No'
	 else SoldAsVacant
	 end


	 -- Remove Duplicates
	        -- step 1

select *,
    row_number () over (
	partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				   UniqueID
				   ) Row_num

from [DATA CLEANING]..Housingdata
order by ParcelID

           -- step 2 (CTE FUNCTION) -- looking at all duplicates

with RowNumCTE as (
select *,
    row_number () over (
	partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				   UniqueID
				   ) Row_num

from [DATA CLEANING]..Housingdata
)

select *
from RowNumCTE
where Row_num > 1
order by PropertyAddress


           -- step 3 deleting all duplicates

with RowNumCTE as (
select *,
    row_number () over (
	partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				   UniqueID
				   ) Row_num

from [DATA CLEANING]..Housingdata
)

delete
from RowNumCTE
where Row_num > 1

           -- step 4 VERIFICATION OF deleted duplicates

with RowNumCTE as (
select *,
    row_number () over (
	partition by ParcelID,
	             PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 order by
				   UniqueID
				   ) Row_num

from [DATA CLEANING]..Housingdata
)
select *
from RowNumCTE
where Row_num > 1
order by PropertyAddress



-- DELETING UNUSED COLUMNS

      --step 1 - DELETING COLUMNS


alter table [DATA CLEANING]..Housingdata
drop column OwnerAddress, TaxDistrict, PropertyAddress

     --step 2 - VERIFICATION

select * 
from [DATA CLEANING]..Housingdata
