/*


Cleaning data in sql queries

*/

SELECT *
FROM Cleaning_with_sql.DBO.Nashville_housing

--Standardize date format

SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM Cleaning_with_sql.DBO.Nashville_housing

ALTER TABLE Nashville_housing
ADD SaleDateConverted DATE;

UPDATE Nashville_housing
SET SaleDateConverted = CONVERT(DATE,SaleDate)


--Populate property address data

SELECT a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Cleaning_with_sql.DBO.Nashville_housing a
JOIN Cleaning_with_sql.DBO.Nashville_housing B
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM Cleaning_with_sql.DBO.Nashville_housing a
JOIN Cleaning_with_sql.DBO.Nashville_housing B
	ON a.ParcelID=b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


--Breaking out address into individual columns(Address,City,State)

SELECT PropertyAddress
FROM Cleaning_with_sql.DBO.Nashville_housing

SELECT 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) AS City
FROM Cleaning_with_sql.DBO.Nashville_housing

ALTER TABLE Nashville_housing
ADD Address nvarchar(255);

UPDATE Nashville_housing
SET Address = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) 

ALTER TABLE Nashville_housing
ADD City nvarchar(255);

UPDATE Nashville_housing
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))


SELECT *
FROM Cleaning_with_sql.DBO.Nashville_housing

SELECT OwnerAddress
FROM Cleaning_with_sql.DBO.Nashville_housing

SELECT 
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Cleaning_with_sql.DBO.Nashville_housing

ALTER TABLE Nashville_housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Nashville_housing
SET OwnerSplitAddress =PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_housing
ADD OwnerCity nvarchar(255);

UPDATE Nashville_housing
SET OwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_housing
ADD OwnerState nvarchar(255);

UPDATE Nashville_housing
SET OwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)


--Change Y and N to Yes and No

SELECT DISTINCT(SoldAsVacant),COUNT(SoldAsVacant)
FROM Cleaning_with_sql.DBO.Nashville_housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
,CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM Cleaning_with_sql.DBO.Nashville_housing



UPDATE Nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant='N' THEN 'No'
	ELSE SoldAsVacant
	END

--Remove Duplicates

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				ORDER BY
					UniqueID
					)row_num
FROM Cleaning_with_sql.DBO.Nashville_housing
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1


--Delete unused columns

SELECT *
FROM Cleaning_with_sql.DBO.Nashville_housing

ALTER TABLE Cleaning_with_sql.DBO.Nashville_housing
DROP COLUMN OwnerAddress,TaxDistrict,Propertyaddress

ALTER TABLE Cleaning_with_sql.DBO.Nashville_housing
DROP COLUMN Saledate





		