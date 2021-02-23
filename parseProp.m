function prop = parseProp( dbentry )
% PROP = parseProp( DBENTRY ) parses data from DBENTRY into struct PROP.
%
%   parseProp( DBENTRY ) parses propeller data from files in the UIUC
%   propeller database.  DBENTRY is a meta-data structure as parsed by
%   PROPDATABASE.
%
%   PROP is a struct with the following fields.
%
%   Numeric data.  Empty for not applicable or not specified.
%     RPM              % Vector of RPM values for wind-on data.
%     CT               % Cell array of vectors of CT for wind-on data.
%     CP               % Cell array of vectors of CP for wind-on data.
%     J                % Cell array of vectors of J for wind-on data.
%     RPM_static       % Vector of RPM values for wind-on data.
%     CT_static        % Vector of CT values for wind-on data.
%     CP_static        % Vector of CP values for wind-on data.
%     r_R              % Vector of r/R values for blade geometry.
%     c_R              % Vector of c/R values for blade geometry.
%     beta             % Vector of beta values for blade geometry.
%     r_R_thickness    % Vector of r/R values for thickness vector.
%     t_c              % Vector of t/c values for blade geometry.
%   Image data.  Empty for not applicable or not specified.
%     front            % Image data for front view of prop.
%     side             % Image data for side view of prop.
%

%   See also PROPDATABASE, PLOTPROP.

%   Rob McDonald
%   rob.a.mcdonald@gmail.com
%   17 February 2021 v. 1.0 -- Original version.
%


% Initialize all fields to empty.
prop.RPM = [];
prop.CT = [];
prop.CP = [];
prop.J = [];
prop.RPM_static = [];
prop.CT_static = [];
prop.CP_static = [];
prop.r_R = [];
prop.c_R = [];
prop.beta = [];
prop.r_R_thickness = [];
prop.t_c = [];
prop.front = [];
prop.side = [];

if( ~isempty( dbentry.rpmv ) )

    nrpm = length( dbentry.rpmv );

    prop.RPM = dbentry.rpmv;
    prop.CT = cell( nrpm, 1 );
    prop.CP = cell( nrpm, 1 );
    prop.J = cell( nrpm, 1 );

    for irpm = 1:length( dbentry.rpmv )
        imdat = imdata( char( strcat('./', dbentry.vname, '/data/', dbentry.perf{irpm}, '.txt') ) );

        prop.CT{irpm} = imdat.CT;
        prop.CP{irpm} = imdat.CP;
        prop.J{irpm} = imdat.J;
    end
end

if( ~isempty( dbentry.static ) )
    imdat = imdata( char( strcat('./', dbentry.vname, '/data/', dbentry.static, '.txt') ) );

    prop.RPM_static = imdat.RPM;
    prop.CT_static = imdat.CT;
    prop.CP_static = imdat.CP;
end

if( ~isempty( dbentry.geom ) )
    imdat = imdata( char( strcat('./', dbentry.vname, '/data/', dbentry.geom, '.txt') ) );

    prop.r_R = imdat.r_R;
    prop.c_R = imdat.c_R;
    prop.beta = imdat.beta;
end

if( ~isempty( dbentry.thick ) )
    imdat = imdata( char( strcat('./', dbentry.vname, '/data/', dbentry.thick, '.txt') ) );

    prop.r_R_thickness = imdat.r_R;
    prop.t_c = imdat.t_c;
end

if( ~isempty( dbentry.front ) )
    if( contains( dbentry.front, '.png' ) )
        itype = 'PNG';
    else
        itype = 'JPEG';
    end
    img = imread( char( strcat('./', dbentry.vname, '/prop_photos/', dbentry.front) ), itype );
    prop.front = img;
end

if( ~isempty( dbentry.side ) )
    if( contains( dbentry.side, '.png' ) )
        itype = 'PNG';
    else
        itype = 'JPEG';
    end
    img = imread( char( strcat('./', dbentry.vname, '/prop_photos/', dbentry.side) ), itype );
    prop.side = img;
end


end


function str = imdata( fname )
% str = imdata( FILENAME ) loads data from FILENAME into struct str.
%
%   imdata( FILENAME ) is a simple wrapper around importdata( FILENAME )
%   that places columns of data into named fields of a struct instead
%   of leaving them in a matrix.
%
%   See also IMPORTDATA.

%   Rob McDonald
%   rob.a.mcdonald@gmail.com
%   17 February 2021 v. 1.0 -- Original version.
%

% Check if file exists
if ( exist( fname, 'file' ) )

    % Use importdata to detect format and read data in
    imdat = importdata( fname );

    % Convert matrix data in imdat to named fields in str
    for icol = 1:length( imdat.colheaders )
        fname = imdat.colheaders{icol};
        fname = matlab.lang.makeValidName( fname );
        str.(fname) = imdat.data( :, icol );
    end

else
    warning( ['File ' fname ' not found'] );
    str = [];
end

end
