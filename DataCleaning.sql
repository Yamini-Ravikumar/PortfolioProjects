-- selecting all data from the table 

SELECT 
    *
FROM
    housingdata;

-- populate property address data

SELECT 
    *
FROM
    housingdata
WHERE
    PropertyAddress IS NULL;


SELECT 
    a.ParcelID,
    a.PropertyAddress,
    b.ParcelID,
    b.PropertyAddress,
    COALESCE(a.PropertyAddress, b.PropertyAddress)
FROM
    housingdata a
        JOIN
    housingdata b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID
WHERE
    a.PropertyAddress IS NULL;


UPDATE housingdata a
        JOIN
    housingdata b ON a.ParcelID = b.ParcelID
        AND a.UniqueID != b.UniqueID 
SET 
    a.PropertyAddress = IFNULL(a.PropertyAddress, b.PropertyAddress)
WHERE
    a.PropertyAddress IS NULL;


-- Breaking out Address into individual columns (Address, City) using PropertyAddress column
 
SELECT 
    PropertyAddress
FROM
    housingdata;

SELECT 
    SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress)) AS Address
FROM
    housingdata;

-- updating the table with split address values 
alter table housingdata
add PropertySplitAddress nvarchar(255);

UPDATE housingdata 
SET 
    PropertySplitAddress = SUBSTRING(PropertyAddress,
        1,
        LOCATE(',', PropertyAddress) - 1);

alter table housingdata
add PropertySplitCity nvarchar(255);

UPDATE housingdata 
SET 
    PropertySplitCity = SUBSTRING(PropertyAddress,
        LOCATE(',', PropertyAddress) + 1,
        LENGTH(PropertyAddress));



-- Breaking out Address into individual columns (Address, City, State) using OwnerAddress column
SELECT 
    OwnerAddress
FROM
    housingdata;

SELECT 
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1),
            ',',
            - 1) AS address1,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1) AS address2,
    SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),
            ',',
            - 1) AS address3
FROM
    housingdata;


alter table housingdata
add OwnerSplitAddress nvarchar(255);
UPDATE housingdata 
SET 
    OwnerSplitAddress = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 1),
            ',',
            - 1);

alter table housingdata
add OwnerSplitCity nvarchar(255);
UPDATE housingdata 
SET 
    OwnerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2),
            ',',
            - 1);

alter table housingdata
add OwnerSplitState nvarchar(255);
UPDATE housingdata 
SET 
    OwnerSplitState = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 3),
            ',',
            - 1);



SELECT DISTINCT
    (SoldAsVacant), COUNT(SoldAsVacant)
FROM
    housingdata
GROUP BY SoldAsVacant
ORDER BY 2;

SELECT 
    SoldAsVacant,
    CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
    END
FROM
    housingdata;

UPDATE housingdata 
SET 
    SoldAsVacant = CASE
        WHEN SoldAsVacant = 'Y' THEN 'Yes'
        WHEN SoldAsVacant = 'N' THEN 'No'
        ELSE SoldAsVacant
    END;
    

-- Removing Duplicates
with RowNumCTE as(
select *,
row_number() over(
partition by ParcelID, 
PropertyAddress, 
SalePrice, SaleDate, 
LegalReference order by UniqueID ) as row_num
from housingdata)
select * from RowNumCTE 
where row_num > 1
order by PropertyAddress;

with RowNumCTE as(
select *,
row_number() over(
partition by ParcelID, 
PropertyAddress, 
SalePrice, SaleDate, 
LegalReference order by UniqueID ) as row_num
from housingdata)
delete from housingdata using  housingdata join RowNumCTE 
on housingdata.UniqueID = RowNumCTE.UniqueID 
where RowNumCTE.row_num > 1;


-- Delete unused columns

SELECT 
    *
FROM
    housingdata;


alter table housingdata 
drop column OwnerAddress, drop column PropertyAddress, drop column TaxDistrict;



