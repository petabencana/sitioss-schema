Situational Intelligence Open Source Software (Siti OSS)
===========
**Open Source Situational Intelligence Framework**

### About
Siti OSS-schema is the PostgreSQL/PostGIS database schema for the Siti OSS Framework.  The schema contains the tables required for data input by [sitioss-reports](https://github.com/petabencana/sitioss-reports), [sitioss-reports-lambda](https://github.com/petabencana/sitioss-reports-lambda), [sitioss-reports-telegram](https://github.com/petabencana/sitioss-reports-telegram) and data output using [sitioss-server](https://github.com/petabencana/sitioss-server).

#### Reports
Input data sources for reporting are received into separate schemas, named by report types. Trigger functions in each data source's schema normalise the different report data and push it to the global sitioss.all_reports table (see Table below).

#### Risk Evaluation Matrix (REM)
Flood affected area polygon data provided by emergency services via the REM interface is stored in the sitioss.rem_status table. The geographic data for these areas is stored in the sitioss.local_areas table.

### Tables
#### Siti OSS Schema 
| Schema | Table Name | Description |
| ------ | ---------- | ----------- |
| sitioss | all_reports | Confirmed reports of flooding from all data sources |
| sitioss | instance_regions | Regions where CogniCity is currently deployed |
| sitioss | local_areas | Neighbourhood scale unit areas (In Indonesia, these are RWs.) |
| sitioss| rem_status | Flood state of local_areas as defined by the Risk Evaluation Matrix |
| sitioss| rem_status_log | Log changes to rem_status |
| detik | reports | Reports from Pasangmata citizen journalism app (provided by Detik.com) |
| detik | reports | Users with reports received from Pasangmata citizen journalism app (provided by Detik.com) |
| floodgauge | reports | Live reports of water depths from flood gauges in city |
| grasp | cards | Report cards issued to users via the Geosocial Rapid Assessment Platform (GRASP) |
| grasp | log | Log of activity regarding report cards issued to users via the Geosocial Rapid Assessment Platform (GRASP) |
| grasp | reports | Reports received from users via the Geosocial Rapid Assessment Platform (GRASP) |
| infrastructure | floodgates | Location of flood mitigation infrastructure in each city |
| infrastructure | floodgates | Location of flood mitigation infrastructure in each city |
| infrastructure | pumps | Location of flood mitigation infrastructure in each city |
| infrastructure | waterways | Location of waterways infrastructure in each city |
| public | sensor_data | Data from automated water level sensors in the city |
| public | sensor_metadata | Metadata of automated water level sensors in the city |
| public | spatial_ref_systems | Table created by PostGIS |
| qlue | reports | Reports from the government and citizen reporting application Qlue |
| twitter | invitees | Hashed representation of Twitter users that were automatically contacted by the platform |
| twitter | seen_tweet_id | Last Tweet processed by the cognicity-reports-powertrack module |

#### License for Sample Data
**Indonesia**
<dl>Jakarta's municipal boundaries are licensed under a <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/">Creative Commons Attribution-ShareAlike 4.0 International License</a>. <a rel="license" href="http://creativecommons.org/licenses/by-sa/4.0/"><img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by-sa/4.0/80x15.png" /></a></dl>

<dl>Hydrological Infrastructure Data (pumps, floodgates, waterways) is licensed under <a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/"><a rel="license" href="http://creativecommons.org/licenses/by-nc/4.0/">Creative Commons Attribution-NonCommercial 4.0 International License</a>. <img alt="Creative Commons Licence" style="border-width:0" src="https://i.creativecommons.org/l/by-nc/4.0/80x15.png"/></a>
</dl>
* Hydrological data are available from [Research Data Australia](https://researchdata.ands.org.au/petajakartaorg/552178) (Australian National Data Service), with DOIs held by the National Library of Australia.

### Dependencies
* [PostgreSQL](http://www.postgresql.org) version 9.6 or later, with
* [PostGIS](http://postgis.net) version 2.3 or later

### Installation
* The PostgreSQL database server must be running with a UTF-8 character set.

#### Installing the schema and data
This build `build/run.sh` script looks for the following environment variables:
- $PGHOST
- $PGUSER
- $PGDATABASE
- $COUNTRY (two letter country code for instance)
- $DATA (true | false - whether to load data)
- $FUNCTIONS (true | false - whether to load schema functions)
- $SCHEMA (true | false - whether to load schema definitions)

Country names should match the name specified in the `/data/` folder.

To install the database and load data for specified country run:
```sh
$ export COUNTRY=id
$ build/run.sh
```
This will create a database, build the empty schema and insert available data.

Note that if a password is set you'll need to use a ~/.pgpass file for the script to run. See more at the PostgreSQL [documentation](https://www.postgresql.org/docs/current/static/libpq-pgpass.html).


#### Use of RDS image
A blank database of the schema is also available as an [RDS](https://aws.amazon.com/rds/) PostgreSQL snapshot in the ap-southeast-1 (Singapore) region, ARN: arn:aws:rds:ap-southeast-1:917524458155:snapshot:cognicity-v3
To use:
* First copy the snapshot to the region (if not ap-southeast-1) where you want to start your instance.
* In the RDS snapshots page for the region where you you want to start your instance, select the copied snapshot and restore it.
* Modify the database, I recommend:
  - creating a new parameter group (from the postgres 9.6 original) that sets rds.force_ssl to 1.
  - setting a password (for user postgres).
  - for production environments, using a multi-AZ setup for redundancy and setting the size to 100 GB for better IOPS performance.

### Testing
Tests are run using NodeJS with Unit.js and Mocha to insert dummy values and perform integration testing on the database against the sample data sources.
To run tests:
```sh
$ npm install
$ npm test
```


#### Adding New City
Instructions to add a new city in sitioss-schema
* Install the database and load data for specified country run:
```sh
$ export COUNTRY=id
$ build/run.sh
```
This will create a database, build the empty schema and insert available data into postgres.

* prepare instance_region and local_area data for the city with same columns as schema.

* Add the cleaned up data into schema
```sh
$ shp2pgsql -I -d -s 4326 <FILENAME.SHP> <SCHEMA>.<TABLE> | psql -U postgres -d <DATABASE>
```
* select table>backup and add data into data.sql file in cognicity-schema repo

* add new instance in tests at index.js - change pkey, instance_region_code, report location and test.


### Contribution Guidelines
* Issues are tracked on Github

### Release
The release procedure is as follows:
- Update the CHANGELOG.md file with the newly released version and high-level overview of changes.
- Check that package.json contains the correct release version number.
- Check that package-lock.json contains the correct release version number.
- Check that schema/sitioss/sitioss.schema.functions.sql `cognicity.version()` function returns the correct release version number.
- Commit any changes and tag in git from the current head of master. The tag should be the same as the version specified in the package.json file and elsewhere - this is the release version.
- Pull changes into dev branch.
- Increment the version number in package.json, package-lock.json, and `sitioss.version()`.
- Commit these changes with the message 'Opened new version for development'.
- Further development is now on the updated version number until the release process begins  again.

### License
The schema is released under the GPLv3 License. See LICENSE.txt for details.
