SELECT * FROM sakila.nashvillehousing;





-- Standardize date format.--

SELECT SaleDate, STR_TO_DATE(SaleDate, '%M %d, %Y') as 'Date'
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD SaleDateConv Date;

UPDATE nashvillehousing	
SET SaleDateConv = STR_TO_DATE(SaleDate, '%M %d, %Y');

SELECT SaleDateConv
FROM nashvillehousing;





-- PROPERTY ADDRESS

SELECT * FROM nashvillehousing
-- WHERE PropertyAddress is null
order by ParcelID;


SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM nashvillehousing a
JOIN nashvillehousing b
on a.ParcelID = b.ParcelID
AND a.UniqueID != b.UniqueID
WHERE a.PropertyAddress is null;



-- UPDATE a
-- SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
-- FROM nashvillehousing a
-- JOIN nashvillehousing b
-- on a.ParcelID = b.ParcelID
-- AND a.UniqueID != b.UniqueID
-- WHERE a.PropertyAddress is null;






-- BREAKING ADDRESS INTO INDIVIDUAL COLUMNS (Address, city, state) 

SELECT
SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1) as Address,
SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress) ) as city
FROM nashvillehousing;


ALTER TABLE nashvillehousing
ADD SplitAddress nvarchar(255),
ADD SplitCity nvarchar(255);

UPDATE nashvillehousing
SET SplitAddress = SUBSTRING(PropertyAddress, 1, LOCATE(',', PropertyAddress) -1);

UPDATE nashvillehousing
SET SplitCity = SUBSTRING(PropertyAddress, LOCATE(',', PropertyAddress) +1, LENGTH(PropertyAddress) );

SELECT SUBSTRING_INDEX(OwnerAddress, ',', 1) ownerSplitStreet,
SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1) ownerSplitCity,
SUBSTRING_INDEX(OwnerAddress, ',', -1) ownerSplitState
FROM nashvillehousing;

ALTER TABLE nashvillehousing
ADD ownerSplitStreet nvarchar(255),
ADD ownerSplitCity nvarchar(255),
ADD ownerSplitState nvarchar(255);

UPDATE nashvillehousing
SET ownerSplitStreet = SUBSTRING_INDEX(OwnerAddress, ',', 1);

UPDATE nashvillehousing
SET ownerSplitCity = SUBSTRING_INDEX(SUBSTRING_INDEX(OwnerAddress, ',', 2), ',', -1);

UPDATE nashvillehousing
SET ownerSplitState = SUBSTRING_INDEX(OwnerAddress, ',', -1);





-- Change Y and N to Yes and No in "Sold as vacant" field

SELECT distinct(SoldAsVacant), count(SoldAsVacant)
FROM nashvillehousing
GROUP BY SoldAsVacant
ORDER BY 2;



SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END
FROM nashvillehousing;


UPDATE nashvillehousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	 WHEN SoldAsVacant = 'N' THEN 'No'
     ELSE SoldAsVacant
     END;






-- Remove Duplicates


WITH RowNumCTE AS (
SELECT *, 
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
                 SalePrice, 
                 SaleDate, 
                 LegalReference
                 ORDER BY 
					UniqueID
                    ) row_num
FROM nashvillehousing
-- ORDER BY ParcelID; 
)
SELECT * FROM RowNumCTE
WHERE row_num>1;
-- ORDER BY ParcelID;
                    




-- DELETE UNUSED COLUMNS

ALTER TABLE nashvillehousing
DROP COLUMN PropertyAddress, 
DROP COLUMN OwnerAddress, 
DROP COLUMN TaxDistrict,
DROP COLUMN SaleDate
