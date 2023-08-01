-- Data Cleaning in SQL
SELECT *
FROM [ProjectPortfolio-3].[dbo].[Housingdata] 

-- Standardized data format
SELECT SaleDate_Converted--, Convert(date, SaleDate)
FROM [ProjectPortfolio-3].[dbo].[Housingdata]

Update [ProjectPortfolio-3].[dbo].[Housingdata]
SET SaleDate = Convert(date, SaleDate)

ALTER TABLE [ProjectPortfolio-3].[dbo].[Housingdata]
ADD SaleDate_Converted Date

Update [ProjectPortfolio-3].[dbo].[Housingdata]
SET SaleDate_Converted = Convert(date, SaleDate)

-- Populate Property Address Data
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [ProjectPortfolio-3].[dbo].[Housingdata] a
JOIN [ProjectPortfolio-3].[dbo].[Housingdata] b
On a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

UPDATE a
SET a.PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
FROM [ProjectPortfolio-3].[dbo].[Housingdata] a
JOIN [ProjectPortfolio-3].[dbo].[Housingdata] b
On a.ParcelID = b.ParcelID
and a.[UniqueID ] <> b.[UniqueID ]
Where a.PropertyAddress is null

-- Breaking out Property Address into individual columns(Address, City, State)
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS City
FROM [ProjectPortfolio-3].[dbo].[Housingdata]

ALTER TABLE [ProjectPortfolio-3].[dbo].[Housingdata] --Altering table to add new column Address
ADD PropertySplitAddress nvarchar(255)
Update [ProjectPortfolio-3].[dbo].[Housingdata]
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE [ProjectPortfolio-3].[dbo].[Housingdata] --Altering table to add new column City
ADD PropertySplitCity nvarchar(255)
Update [ProjectPortfolio-3].[dbo].[Housingdata]
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM [ProjectPortfolio-3].[dbo].[Housingdata]

-- Breaking out Owner Address into individual columns(Address, City, State)
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) AS OwnerSplitAddress,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) AS OwnerSplitCity,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) AS OwnerSplitState
FROM [ProjectPortfolio-3].[dbo].[Housingdata]

ALTER TABLE [ProjectPortfolio-3].[dbo].[Housingdata] --Altering table to add new column OwnerSplitAddress
ADD OwnerSplitAddress nvarchar(255)
Update [ProjectPortfolio-3].[dbo].[Housingdata]
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE [ProjectPortfolio-3].[dbo].[Housingdata] --Altering table to add new column OwnerSplitCity
ADD OwnerSplitCity nvarchar(255)
Update [ProjectPortfolio-3].[dbo].[Housingdata]
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE [ProjectPortfolio-3].[dbo].[Housingdata] --Altering table to add new column OwnerSplitState
ADD OwnerSplitState nvarchar(255)
Update [ProjectPortfolio-3].[dbo].[Housingdata]
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

-- Change Y and N to Yes and No in 'Sold as Vacant' field

SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) -- To see distint values in SoldAsVacant column and how many entering are there for each distinct value
FROM [ProjectPortfolio-3].[dbo].[Housingdata]
GROUP BY SoldAsVacant
Order by 2

SELECT SoldAsVacant, 
CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM [ProjectPortfolio-3].[dbo].[Housingdata]

UPDATE Housingdata
SET SoldAsVacant = CASE
    WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-- Remove Duplicates
                             --(By using CTE and window functions)
							 -- Some of the ways to remove duplicates are "Rank, Order Rank, Row Number"

With RowNumCTE
AS (
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
FROM [ProjectPortfolio-3].[dbo].[Housingdata]
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--SELECT *
--FROM RowNumCTE
--WHERE row_num > 1

-- Delete Unused Columns

SELECT * 
FROM [ProjectPortfolio-3].[dbo].[Housingdata]

ALTER TABLE [ProjectPortfolio-3].[dbo].[Housingdata]
DROP COLUMN OwnerAddress, SaleDate , PropertyAddress