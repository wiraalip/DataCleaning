SELECT *
FROM CovidAnalysis.dbo.nashville

--Standarize Format
SELECT SaleDate, CONVERT(date, SaleDate)
FROM CovidAnalysis.dbo.nashville

UPDATE nashville 
SET SaleDate = CONVERT(date, SaleDate)

ALTER TABLE nashville 
ADD SaleDateConverted DATE 

UPDATE nashville
SET SaleDateConverted = CONVERT(date, SaleDate)


--Remove Null in Property Address 
SELECT a.Parcelid, a.PropertyAddress, b.parcelid, b.propertyaddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CovidAnalysis.dbo.nashville a 
JOIN CovidAnalysis.dbo.nashville b 
	ON a.parcelid = b.parcelid AND a.uniqueID <> b.uniqueID
where a.propertyaddress is null 

UPDATE a 
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM CovidAnalysis.dbo.nashville a 
JOIN CovidAnalysis.dbo.nashville b 
	ON a.parcelid = b.parcelid AND a.uniqueID <> b.uniqueID
where a.propertyaddress is null 


--Separate the property address 
select propertyaddress, SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) AS Address, 
SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))
from CovidAnalysis.dbo.nashville

ALTER TABLE nashville 
ADD SeparateAddress Nvarchar(255)

UPDATE nashville
SET SeparateAddress =SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

ALTER TABLE nashville 
ADD SeparateCity Nvarchar(255)

UPDATE nashville 
SET SeparateCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))


-- Another way to separate (easy way)
SELECT owneraddress, PARSENAME(REPLACE(owneraddress, ',', '.'), 3), 
	   PARSENAME(REPLACE(owneraddress, ',', '.'), 2), 
	   PARSENAME(REPLACE(owneraddress, ',', '.'), 1)
FROM CovidAnalysis.dbo.nashville

ALTER TABLE nashville 
ADD SeparateOwnerAddress Nvarchar(255)

UPDATE nashville 
SET SeparateOwnerAddress = PARSENAME(REPLACE(owneraddress, ',', '.'), 3)

ALTER TABLE nashville 
ADD SeparateOwnerCity Nvarchar(255) 

UPDATE nashville 
SET SeparateOwnerCity = PARSENAME(REPLACE(owneraddress, ',', '.'), 2)

ALTER TABLE nashville 
ADD SeparateOwnerState Nvarchar(255)

UPDATE nashville 
SET SeparateOwnerState = PARSENAME(REPLACE(owneraddress, ',', '.'), 1)


--Change Y to Yes and N to No
SELECT DISTINCT(soldasvacant), COUNT(soldasvacant)
FROM CovidAnalysis.dbo.nashville
GROUP BY soldasvacant
ORDER BY 2 


SELECT soldasvacant, CASE WHEN soldasvacant = 'Y' THEN 'Yes' 
						  WHEN soldasvacant = 'N' THEN 'No'
						  ELSE soldasvacant
						  END
FROM CovidAnalysis.dbo.nashville

UPDATE nashville 
SET soldasvacant = CASE WHEN soldasvacant = 'Y' THEN 'Yes' 
						  WHEN soldasvacant = 'N' THEN 'No'
						  ELSE soldasvacant
						  END 


--Remove Duplicate 
with searchduplicate AS (
SELECT *, ROW_NUMBER() OVER (PARTITION BY 
										ParcelID,
										SaleDate,
										SalePrice, 
										LegalReference
							 ORDER BY ParcelID) AS row_num
FROM CovidAnalysis.dbo.nashville
)
DELETE
FROM searchduplicate 
WHERE row_num > 1 



--Delete Unuseful Columns 
SELECT *
FROM CovidAnalysis.dbo.nashville

ALTER TABLE nashville 
DROP COLUMN propertyaddress, owneraddress, Taxdistrict

ALTER TABLE nashville 
DROP COLUMN SaleDate