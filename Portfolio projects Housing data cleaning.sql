Select * from PortfolioProjects.dbo.NashvilleHousing

-- Standardize date format

Select SaleDate, convert(Date, SaleDate)
from PortfolioProjects.dbo.NashvilleHousing
Update NashvilleHousing
Set SaleDate = Convert(Date,SaleDate)

Alter table NashvilleHousing
add SaleDateConverted Date;
Update NashvilleHousing
Set SaleDateConverted = Convert(Date,SaleDate)

Select SaleDateConverted, convert(Date, SaleDate)
from NashvilleHousing


-- Populate property address data

-- Check if there are null values

Select PropertyAddress
from NashvilleHousing
where PropertyAddress is null

Select *
from NashvilleHousing
where PropertyAddress is null

Select *
from NashvilleHousing
--where PropertyAddress is null
order by ParcelID

-- if parcel ID has not address then populate it with the same address

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b. [UniqueID]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL (a.PropertyAddress, b.PropertyAddress)
from NashvilleHousing a 
Join NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID] <> b. [UniqueID]
where a.PropertyAddress is null


-- Break down address (address, city, state)

Select PropertyAddress
from NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

Select
Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) as Address
from NashvilleHousing

Alter table NashvilleHousing
add PropertySplitAddress varchar(255);
Update NashvilleHousing
Set PropertySplitAddress = Substring(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

Alter table NashvilleHousing
add PropertySplitCity varchar(255);
Update NashvilleHousing
Set PropertySplitCity = Substring(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))

Select *
from NashvilleHousing

--split owner address

Select Owneraddress
from NashvilleHousing

Select 
PARSENAME (REPLACE (Owneraddress, ',', '.'), 3),
PARSENAME (REPLACE (Owneraddress, ',', '.'), 2),
PARSENAME (REPLACE (Owneraddress, ',', '.'), 1)
from NashvilleHousing


Alter table NashvilleHousing
add OwnerSplitAddress varchar(255);
Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME (REPLACE (Owneraddress, ',', '.'), 3)

Alter table NashvilleHousing
add OwnerSplitCity varchar(255);
Update NashvilleHousing
Set OwnerSplitCity = PARSENAME (REPLACE (Owneraddress, ',', '.'), 2)

Alter table NashvilleHousing
add OwnerSplitState varchar(255);
Update NashvilleHousing
Set OwnerSplitState = PARSENAME (REPLACE (Owneraddress, ',', '.'), 1)

Select *
From NashvilleHousing


-- Change Y and N from Yes and No in SoldAsVacant

Select Distinct (SoldAsVacant), count(SoldAsVacant)
from NashvilleHousing
group by SoldAsVacant
order by 2

-- change with case statement

Select SoldAsVacant,
Case when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end
from NashvilleHousing

update NashvilleHousing 
set SoldAsVacant = Case 
	when SoldAsVacant = 'Y' then 'Yes'
	when SoldAsVacant = 'N' then 'No'
	else SoldAsVacant
end

-- Remove duplicates
-- Cte and windows function to find them

with RowNumCTE as (
Select *,
	ROW_NUMBER() over (
	partition by ParcelID,
		PropertyAddress,
		SalePrice,
		SaleDate,
		LegalReference
		order by 
			UniqueID
			) row_num
from NashvilleHousing 
--order by ParcelID
)
Delete
from RowNumCTE
where row_num > 1

-- Delete unused columns

Select *
from NashvilleHousing

alter table NashvilleHousing
drop column Owneraddress, Taxdistrict, PropertyAddress

alter table NashvilleHousing
drop column SaleDate