import pandas as pd
from sklearn.decomposition import PCA
from mpl_toolkits.mplot3d import Axes3D

import matplotlib.pyplot as plt

# Load the data
data = pd.read_csv('./merged_data.csv')

data = data.dropna().reset_index(drop=True)

country_to_continent = {
    "Afghanistan": "Asia", "Albania": "Europe", "Algeria": "Africa", "Andorra": "Europe", "Angola": "Africa",
    "Anguilla": "North America", "Antarctica": "Others", "Antigua and Barbuda": "North America", "Argentina": "South America",
    "Armenia": "Asia", "Aruba": "North America", "Australia": "Oceania", "Austria": "Europe", "Azerbaijan": "Asia",
    "Bahamas": "North America", "Bahrain": "Asia", "Bangladesh": "Asia", "Barbados": "North America", "Belarus": "Europe",
    "Belgium": "Europe", "Belize": "North America", "Benin": "Africa", "Bermuda": "North America", "Bhutan": "Asia",
    "Bonaire, Saint Eustatius and Saba": "North America", "Bosnia and Herzegovina": "Europe", "Botswana": "Africa",
    "Brazil": "South America", "British Virgin Islands": "North America", "Brunei Darussalam": "Asia", "Bulgaria": "Europe",
    "Burkina Faso": "Africa", "Burundi": "Africa", "Cambodia": "Asia", "Canada": "North America", "Cape Verde": "Africa",
    "Central African Republic": "Africa", "Chad": "Africa", "Chile": "South America", "China": "Asia", "Christmas Island": "Asia",
    "Colombia": "South America", "Comoros": "Africa", "Congo": "Africa", "Cook Islands": "Oceania", "Costa Rica": "North America",
    "Côte d'Ivoire": "Africa", "Croatia": "Europe", "Cuba": "North America", "Curaçao": "North America", "Cyprus": "Asia",
    "Czechia": "Europe", "North Korea": "Asia", "Democratic Republic of the Congo": "Africa", "Denmark": "Europe",
    "Djibouti": "Africa", "Dominica": "North America", "Dominican Republic": "North America", "Ecuador": "South America",
    "Egypt": "Africa", "El Salvador": "North America", "Equatorial Guinea": "Africa", "Eritrea": "Africa", "Estonia": "Europe",
    "Ethiopia": "Africa", "Faeroe Islands": "Europe", "Micronesia (Federated States of)": "Oceania", "Fiji": "Oceania",
    "Finland": "Europe", "France": "Europe", "French Polynesia": "Oceania", "Gabon": "Africa", "Gambia": "Africa",
    "Georgia": "Asia", "Germany": "Europe", "Ghana": "Africa", "Greece": "Europe", "Greenland": "North America",
    "Grenada": "North America", "Guatemala": "North America", "Guinea": "Africa", "Guinea-Bissau": "Africa", "Guyana": "South America",
    "Haiti": "North America", "Honduras": "North America", "Hong Kong": "Asia", "Hungary": "Europe", "Iceland": "Europe",
    "India": "Asia", "Indonesia": "Asia", "Iraq": "Asia", "Ireland": "Europe", "Iran": "Asia", "Israel": "Asia",
    "Italy": "Europe", "Jamaica": "North America", "Japan": "Asia", "Jordan": "Asia", "Kazakhstan": "Asia", "Kenya": "Africa",
    "Kiribati": "Oceania", "Kosovo": "Europe", "Kuwait": "Asia", "Kuwaiti Oil Fires": "Others", "Kyrgyzstan": "Asia",
    "Laos": "Asia", "Latvia": "Europe", "Lebanon": "Asia", "Lesotho": "Africa", "Liberia": "Africa", "Libya": "Africa",
    "Liechtenstein": "Europe", "Lithuania": "Europe", "Luxembourg": "Europe", "Macao": "Asia", "North Macedonia": "Europe",
    "Madagascar": "Africa", "Malawi": "Africa", "Malaysia": "Asia", "Maldives": "Asia", "Mali": "Africa", "Malta": "Europe",
    "Marshall Islands": "Oceania", "Mauritania": "Africa", "Mauritius": "Africa", "Mexico": "North America", "Mongolia": "Asia",
    "Montenegro": "Europe", "Montserrat": "North America", "Morocco": "Africa", "Mozambique": "Africa", "Myanmar": "Asia",
    "Namibia": "Africa", "Nauru": "Oceania", "Nepal": "Asia", "Netherlands": "Europe", "New Caledonia": "Oceania",
    "New Zealand": "Oceania", "Nicaragua": "North America", "Niger": "Africa", "Nigeria": "Africa", "Niue": "Oceania",
    "Norway": "Europe", "State of Palestine": "Asia", "Oman": "Asia", "Pacific Islands (Palau)": "Oceania", "Pakistan": "Asia",
    "Palau": "Oceania", "Panama": "North America", "Papua New Guinea": "Oceania", "Paraguay": "South America", "Peru": "South America",
    "Philippines": "Asia", "Bolivia": "South America", "Poland": "Europe", "Portugal": "Europe", "Qatar": "Asia",
    "Cameroon": "Africa", "South Korea": "Asia", "Moldova": "Europe", "South Sudan": "Africa", "Sudan": "Africa",
    "Romania": "Europe", "Russia": "Europe", "Rwanda": "Africa", "Ryukyu Islands": "Asia", "Saint Helena": "Africa",
    "Saint Lucia": "North America", "Sint Maarten (Dutch part)": "North America", "Samoa": "Oceania", "Sao Tome and Principe": "Africa",
    "Saudi Arabia": "Asia", "Senegal": "Africa", "Serbia": "Europe", "Seychelles": "Africa", "Sierra Leone": "Africa",
    "Singapore": "Asia", "Slovakia": "Europe", "Slovenia": "Europe", "Solomon Islands": "Oceania", "Somalia": "Africa",
    "South Africa": "Africa", "Spain": "Europe", "Sri Lanka": "Asia", "Saint Kitts and Nevis": "North America",
    "Saint Pierre and Miquelon": "North America", "Saint Vincent and the Grenadines": "North America", "Suriname": "South America",
    "Eswatini": "Africa", "Sweden": "Europe", "Switzerland": "Europe", "Syria": "Asia", "Taiwan": "Asia", "Tajikistan": "Asia",
    "Thailand": "Asia", "Timor-Leste": "Asia", "Togo": "Africa", "Tonga": "Oceania", "Trinidad and Tobago": "North America",
    "Tunisia": "Africa", "Türkiye": "Asia", "Turkmenistan": "Asia", "Turks and Caicos Islands": "North America", "Tuvalu": "Oceania",
    "Uganda": "Africa", "Ukraine": "Europe", "United Arab Emirates": "Asia", "United Kingdom": "Europe", "Tanzania": "Africa",
    "USA": "North America", "Uruguay": "South America", "Uzbekistan": "Asia", "Vanuatu": "Oceania", "Venezuela": "South America",
    "Viet Nam": "Asia", "Wallis and Futuna Islands": "Oceania", "Yemen": "Asia", "Zambia": "Africa", "Zimbabwe": "Africa",
    "International Shipping": "Others", "International Aviation": "Others", "Global": "Others"
}

# Separate labels and features
labels = data.iloc[:, 1]

features = data.iloc[:, 2:]

# Perform PCA
pca = PCA(n_components=3)
principal_components = pca.fit_transform(features)

# Print out variance per component
print("Explained variance ratio per principal component:")
print(pca.explained_variance_ratio_)

# Create a DataFrame with the principal components
pca_df = pd.DataFrame(data=principal_components, columns=['PC1', 'PC2', 'PC3'])

# Map countries to continents
continents = labels.map(country_to_continent)

# Add continent information to the PCA DataFrame
pca_df['Continent'] = continents

# 3D Visualization with continents
fig = plt.figure()
ax = fig.add_subplot(111, projection='3d')
scatter = ax.scatter(
    pca_df['PC1'], pca_df['PC2'], pca_df['PC3'],
    c=pca_df['Continent'].astype('category').cat.codes, cmap='tab10'
)

# Add country names for every 10th row
for i in range(0, len(pca_df), 10):
    ax.text(pca_df['PC1'][i], pca_df['PC2'][i], pca_df['PC3'][i], labels[i])

# Print out the name of the country if PC2 is above 0.5
for i in range(len(pca_df)):
    if pca_df['PC2'][i] > 0.5:
        ax.text(pca_df['PC1'][i], pca_df['PC2'][i], pca_df['PC3'][i], labels[i])

# Map integer codes to continent names
unique_continents = pca_df['Continent'].astype('category').cat.categories
legend_labels = [unique_continents[int(code)] for code in range(len(unique_continents))]

# Add legend with continent names
handles, _ = scatter.legend_elements()
legend = ax.legend(handles, legend_labels, title="Continents")
ax.add_artist(legend)

# Labels and title
ax.set_xlabel('Principal Component 1')
ax.set_ylabel('Principal Component 2')
ax.set_zlabel('Principal Component 3')
ax.set_title('3D PCA of merged_data.csv')

plt.show()