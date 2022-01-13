
--Entire Dataset to verify that import was done correctly
SELECT 
*
FROM
Portfolio_Project.dbo.Housing_Data

--Verify Unique ID length. 
SELECT 
UniqueID
FROM 
Portfolio_Project.dbo.Housing_Data
WHERE LEN(UniqueID) = 1
--User IDs start from 0 (single digits)




--Standardize date format...... For some reason, the update did not replace the column, therefore a new column was created and the original was dropped
SELECT
SaleDate, CAST(SaleDate AS date) AS Sales_Date
FROM 
Portfolio_Project.dbo.Housing_Data

UPDATE Housing_Data
SET SaleDate = CAST(SaleDate AS date)

ALTER TABLE Housing_Data
ADD Sales_Date date;
UPDATE Housing_Data
SET Sales_Date = CAST(SaleDate AS date)

ALTER TABLE
Housing_Data
DROP COLUMN SaleDate


--Populate nulls in property values: Using Parcel ID as a reference and Unique ID to distinguish, we can populate NULLS where the ID is the same
--Must join the table to itself to make that connection between data coloumns. Parcel IDs can match but Unique IDs must be different.
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Portfolio_Project.dbo.Housing_Data a
JOIN Portfolio_Project.dbo.Housing_Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is NULL

UPDATE a 
SET 
PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM
Portfolio_Project.dbo.Housing_Data a
JOIN Portfolio_Project.dbo.Housing_Data b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress is NULL
--Run above query once update is over. If no Nulls return then the table has been successfully updated.



 
--Seperate Address , City and State to Individual Columns
SELECT 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Street, -- -1 to eliminate the ','
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS City -- -1 to eliminate the ','
FROM
Portfolio_Project.dbo.Housing_Data

ALTER TABLE
Portfolio_Project.dbo.Housing_Data
ADD Street Nvarchar(255)

UPDATE Portfolio_Project.dbo.Housing_Data
SET Street = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) 

ALTER TABLE Portfolio_project.dbo.Housing_Data
ADD City Nvarchar (255)

UPDATE Portfolio_Project.dbo.Housing_Data
SET City = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT *
FROM Portfolio_Project.dbo.Housing_Data

ALTER TABLE --Drop Original Coloumn from cleaned dataset
Portfolio_Project.dbo.Housing_Data
DROP COLUMN PropertyAddress

--Now to do Owner Address
SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM Portfolio_Project.dbo.Housing_Data

ALTER TABLE
Portfolio_Project.dbo.Housing_Data
ADD Owner_Split_Address Nvarchar(255)

ALTER TABLE
Portfolio_Project.dbo.Housing_Data
ADD Owner_Split_City Nvarchar(255)

ALTER TABLE
Portfolio_Project.dbo.Housing_Data
ADD Owner_Split_State Nvarchar(255)

UPDATE Portfolio_Project.dbo.Housing_Data
SET Owner_Split_Address = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
 
UPDATE Portfolio_Project.dbo.Housing_Data
SET Owner_Split_City = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

UPDATE Portfolio_Project.dbo.Housing_Data
SET Owner_Split_State = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)





--Make Sold as Vacant Consistent in format
--Options were found to be 'Yes', 'No', 'Y', 'N. This format was simplified to only two options 
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant) AS CountVacant
FROM 
Portfolio_Project.dbo.Housing_Data
GROUP BY 
SoldAsVacant 
ORDER BY
CountVacant -- 'Yes' and 'no' appear to be more common. Therefore the data will be formatted to suit that


SELECT SoldAsVacant,
CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM
Portfolio_Project.dbo.Housing_Data

UPDATE Portfolio_Project.dbo.Housing_Data
SET SoldAsVacant = CASE
	WHEN SoldAsVacant = 'Y' THEN 'Yes'
	WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END



SELECT *
FROM Portfolio_Project.dbo.Housing_Data

--Drop Some more unnecessary columns
ALTER TABLE
Portfolio_Project.dbo.Housing_Data
DROP COLUMN OwnerAddress, TaxDistrict 