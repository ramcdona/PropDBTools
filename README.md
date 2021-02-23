# UIUC Propeller Database Tools

The [UIUC Propeller Data Site](https://m-selig.ae.illinois.edu/props/propDB.html)
is a tremendous resource maintained by
Prof. Michael Selig and students at UIUC.  A large number of propellers
suitable for application to radio-control aircraft and small UAV's have
been tested in the wind tunnel with the results reported in the data
site.

The complete site may be downloaded in
[one large file](https://m-selig.ae.illinois.edu/props/download/UIUC-propDB.zip)
These tools expect you to have downloaded this file and un-zipped it
to some suitable location.  These files expect to run from that
location.

While the UIUC propeller data (say CT and CP vs. J) is contained in simple
data files, the meta-data for each propeller (say diameter, pitch, and
what RPM's were tested) is not explicitly provided.  Instead, it is
implied by the names of the files containing the data.  Furthermore,
multiple file names must be considered jointly to determine what data
is available for a given propeller.

Although the data is presented in a largely consistent format, there
are inevetible special cases that break strict consistency.

This layout style makes it very easy for a user to scan the database
and to pull out the data they need about a particular propeller.
Unfortunately, this style makes it rather challenging for a computer
program to scan through and to work on the database as a whole.

These tools address that challenge.  propDataBase() scans all the
data file names in the database and parses the names into data fields
for each entry.  One of those entries can then be passed to parseProp()
or plotProp() as desired.


## Included Functions

* `PROPDB = propDataBase()`
   Parses DB meta-data into struct array PROPDB.
* `PROP = parseProp( DBENTRY )`
   Parses data from DBENTRY into struct PROP.
* `plotProp( DBENTRY )`
   Plots propeller data from DBENTRY.


## Example Use

To use these tools, first call `propDataBase()` to parse the meta-data
for all the site into a vector of structs.  Each entry in that vector
corresponds to a particular prop.  The other tools accept a single
database entry as their argument.

    propDB = propDataBase();

After parsing the complete meta-data, we pass entry 127 to `parseProp` to
parse the contents of the data files for that propeller into a structure.

    prop = parseProp( propDB(127) );

Finally, we can plot the data for any database entry with `plotProp`.

    plotProp( propDB(127) );


## License

This software is Copyright (c) Rob McDonald 2021 and is released under the terms specified in the [license](license.txt).

