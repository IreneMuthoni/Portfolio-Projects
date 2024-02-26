SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing



---   Standardize Date Format   ---

ALTER TABLE PortfolioProject2..NashvilleHousing
ALTER COLUMN SaleDate Date;



---   Populate Property Address Column   ---

Select *
FROM PortfolioProject2..NashvilleHousing 
where PropertyAddress is null

--Houses with the same ParcelID have the same Property Address
Select a.[UniqueID ], a.ParcelID, a.PropertyAddress, b.[UniqueID ], b.ParcelID, b.PropertyAddress
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<> b.[UniqueID ]
--where a.PropertyAddress is null

--Here we populate the missing Property Address values in a with the Property Address values in b
Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject2..NashvilleHousing a
JOIN PortfolioProject2..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null



---   Breaking out Property Address into individual columns   ---

Select PropertyAddress
FROM PortfolioProject2..NashvilleHousing

--Splitting Property Address into PropertySplitAddress and PropertySplitCity
Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress)) as City
FROM PortfolioProject2..NashvilleHousing

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

UPDATE PortfolioProject2..NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)


ALTER TABLE PortfolioProject2..NashvilleHousing
ADD PropertySplitCity nvarchar(255)

UPDATE PortfolioProject2..NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM PortfolioProject2.dbo.NashvilleHousing



---   Breaking out OwnerAddress into individual columns   ---

Select OwnerAddress
FROM PortfolioProject2..NashvilleHousing


SELECT
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)
FROM PortfolioProject2..NashvilleHousing


ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerSplitAddress nvarchar(255)

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.'),3)


ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerSplitCity nvarchar(255)

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE PortfolioProject2..NashvilleHousing
ADD OwnerSplitState nvarchar(255)

UPDATE PortfolioProject2..NashvilleHousing
SET OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.'),1)


Select *
FROM PortfolioProject2..NashvilleHousing



---   Change Y and N to Yes and No in SoldAsVacant Field   ---

SELECT Distinct(SoldAsVacant), COUNT(SoldAsVacant) As Entries
FROM PortfolioProject2..NashvilleHousing
Group by SoldAsVacant
Order by Entries


Select SoldAsVacant, 
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End
FROM PortfolioProject2..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = 
CASE When SoldAsVacant = 'Y' Then 'Yes'
	 When SoldAsVacant = 'N' Then 'No'
	 Else SoldAsVacant
	 End



---   Remove Duplicates   ---

Select *
FROM PortfolioProject2..NashvilleHousing 


;With RowNumCTE AS(
Select *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference, OwnerName Order By ParcelID) as rownum
FROM PortfolioProject2..NashvilleHousing
)
Select *
FROM RowNumCTE
where rownum > 1


;With RowNumCTE AS(
Select *, ROW_NUMBER() OVER(PARTITION BY ParcelID, PropertyAddress, SalePrice, LegalReference, OwnerName Order By ParcelID) as rownum
FROM PortfolioProject2..NashvilleHousing
)
Delete
FROM RowNumCTE
where rownum > 1



---   Remove unused columns   ---
Select *
FROM PortfolioProject2..NashvilleHousing 

ALTER TABLE PortfolioProject2..NashvilleHousing
DROP COLUMN PropertyAddress, OwnerAddress, TaxDistrict



