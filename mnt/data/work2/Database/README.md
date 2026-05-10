## Database Setup
1. Ensure MongoDB Compass is running on your machine.
2. Install dependencies: `pip install -r reqs.txt`
3. Initialize the database through the python file

##  Import Data
1. Enter mongodb://localhost:27017/ in browser address bar.
2. Compass will open up and show the SE-Marketplace database that you created during the setup.
3. Click on the name of any collection (Users, Artisans, Reviews, Products, Categories, Orders) and then the green + icon and click on "Import JSON or CSV file".
4. Select the respective JSON file in the sample_data folder for the respective collection (artisans.json for Artisans collection and so on for all 6).
