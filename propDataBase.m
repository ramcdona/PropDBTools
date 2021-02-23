function propDB = propDataBase()
% PROPDB = propDataBase() parses DB meta-data into struct array PROPDB.
%
%   PROPDB = propDataBase() parses propeller database meta-data from
%   file names in the UIUC propeller database.
%
%   PROPDB is a vector of structs (one for each propeller) with the
%   following fields.
%
%   Numeric meta-data.  NAN for not applicable or not specified.
%     ident            % Identifier string used to group data files.
%     diam             % Diameter (in)
%     pitch            % Pitch (in)
%     deg              % Setting for ground-adjustable blades
%     nblade           % Number of blades for variable-blade props
%     tracpush         % Flag 1: Tractor, 2: Pusher flag
%     specimen         % Specimen for repeated cases
%     vnum             % Volume number
%     rpmv             % RPM vector for wind-on data
%
%   String meta-data.  Empty for not applicable or not specified.
%     model            % Size and model string as parsed
%     vname            % Volume name
%     mfg              % Manufacturer
%     fname            % Cell array of all data file names
%     typflag          % File type 0: Perf, 1: Static, 2: Geom, 3: Thick
%     perf             % Cell array of wind-on performance file names
%     static           % Static performance file name
%     geom             % Geometry file name
%     thick            % Thickness file name
%     front            % Front image file name
%     side             % Side image file name
%
%   The UIUC Propeller Data Site is a tremendous resource maintained by
%   Prof. Michael Selig and students at UIUC.  A large number of propellers
%   suitable for application to radio-control aircraft and small UAV's have
%   been tested in the wind tunnel with the results reported in the data
%   site.  https://m-selig.ae.illinois.edu/props/propDB.html
%
%   The complete site may be downloaded in one large file here:
%   https://m-selig.ae.illinois.edu/props/download/UIUC-propDB.zip
%   This program expects you to have downloaded this file and un-zipped it
%   to some suitable location.  This file expects to run from that
%   location.
%
%   While the propeller data (say CT and CP vs. J) is contained in simple
%   data files, the meta-data for each propeller (say diameter, pitch, and
%   what RPM's were tested) is not explicitly provided.  Instead, it is
%   implied by the names of the files containing the data.  Furthermore,
%   multiple file names must be considered jointly to determine what data
%   is available for a given propeller.
%
%   Although the data is presented in a largely consistent format, there
%   are inevetible special cases that break strict consistency.
%
%   This layout style makes it very easy for a user to scan the database
%   and to pull out the data they need about a particular propeller.
%   Unfortunately, this style makes it rather challenging for a computer
%   program to scan through and to work on the database as a whole.
%
%   This program addresses that challenge.  propDataBase() scans all the
%   data file names in the database and parses the names into data fields
%   for each entry.  One of those entries can then be passed to PARSEPROP
%   or PLOTPROP as desired.
%
%   See also PARSEPROP, PLOTPROP.

%   Rob McDonald
%   rob.a.mcdonald@gmail.com
%   17 February 2021 v. 1.0 -- Original version.
%


% Define some anonymous functions for indexing into temporary arrays
paren = @(x, varargin) x(varargin{:});
% curly = @(x, varargin) x{varargin{:}};

% Generate list of volumes
vols = dir( 'volume-*' );

nentry = 0;
nimage = 0;
% Loop over all volumes
for ivol = 1:length( vols )
    vname = vols( ivol ).name;
    cd( vname );
    cd( 'data' );

    % List all files in volume
    flist = dir( '*.txt' );
    % Strip out .txt from file names
    fnames{ivol} = erase( {flist.name}, '.txt' );

    nentry = nentry + length( fnames{ivol} );

    cd( '..' );
    if ( exist( 'prop_photos', 'dir' ) )
        cd( 'prop_photos' );

        % List all files in volume
        jflist = dir( '*.jpg' );
        pflist = dir( '*.png' );
        ifnames{ivol} = {jflist.name pflist.name};

        nimage = nimage + length( ifnames{ivol} );

        cd( '..' );
    else
        ifnames{ivol} = cell( 0, 0 );
    end

    cd( '..' );
end
vname = [];


% Numeric data extracted from file names.  NAN for not applicable or not specified.
typflag = nan( nentry, 1 );  % File type 0: Normal, 1: Static, 2: Geom, 3: Thick
rpm = typflag;               % RPM for Normal data
nblade = typflag;            % Number of blades for cases with variable blade numbers
specimen = typflag;          % Specimen for repeated cases
deg = typflag;               % Angle for variable angle cases
diam = typflag;              % Prop Diameter (in)
pitch = typflag;             % Prop Pitch (in)
tracpush = typflag;          % Flag 1: Tractor, 2: Pusher flag
vnum = typflag;              % Volume number

% String data extracted from file names.
vname = cell( nentry, 1);    % Volume name (subdirectory)
fname = vname;               % File name
mfg = vname;                 % Manufacturer
sz = vname;                  % Size descriptor
model = vname;               % Model name for prop size not given as DxP or D
testid = vname;              % Test number/person ID

ientry = 1;
for ivol = 1:length( vols )

    for inam = 1:length( fnames{ivol} )

        strs = strsplit( fnames{ivol}{inam}, '_' );

        vname{ientry} = vols( ivol ).name;
        fname{ientry} = fnames{ivol}{inam};

        mfg{ientry} = strs{1};

        vdat = strsplit( vname{ientry}, '-' );
        vnum(ientry) = str2num( vdat{2} );

        if ( length( strs ) > 2 )

            sz{ientry} = strs{2};

            dp = strsplit( sz{ientry}, 'x' );
            d = str2num( dp{1} );
            p = nan;

            if( isempty( d ) )
                model{ientry} = dp{1};
                d = nan;
                if( length( dp{1} ) < 5 && contains( dp{1}, 'p' ) )
                    ds = strsplit( dp{1}, 'p' );
                    d = str2num( ds{1} );
                    specimen(ientry) = str2num( ds{2} );
                    tracpush(ientry) = 2;
                elseif( length( dp{1} ) < 5 && contains( dp{1}, 't' ) )
                    ds = strsplit( dp{1}, 't' );
                    d = str2num( ds{1} );
                    specimen(ientry) = str2num( ds{2} );
                    tracpush(ientry) = 1;
                end
            else
                if ( length( dp ) > 1 )
                    p = str2num( dp{2} );
                end
            end

            if ( strcmp( mfg{ientry}, 'ancf' ) )
                % Half-inch increments were specified without a decimal.
                % For example, d=12.5 listed as 125.
                if ( d > 60 )
                    d = d / 10;
                end
                if ( p > 30 )
                    p = p / 10;
                end
            elseif ( d > 30 ) % Detect cases with dimensions in mm.  Convert to inch.
                d = d / 25.4;
                p = p / 25.4;
            end
            diam(ientry) = d;
            pitch(ientry) = p;

            % Attempt to detect entry type
            typ = strs{3};

            % Tracker for additional fields
            iadd = 0;

            if ( contains( typ, 'deg' ) )
                deg(ientry) = str2num( erase( typ, 'deg' ) );
                iadd = iadd + 1;
                typ = strs{3+iadd};
            end

            % Needs to come after deg.
            if ( length( typ ) == 2 && contains( typ, 'b' ) )
                nblade(ientry) = str2num( erase( typ, 'b' ) );
                iadd = iadd + 1;
                typ = strs{3+iadd};
            end

            if ( contains( typ, 'spec' ) )
                specimen(ientry) = str2num( erase( typ, 'spec' ) );
                iadd = iadd + 1;
                typ = strs{3+iadd};
            end

            % Check type
            if( strcmp( typ, 'geom' ) )
                typflag(ientry) = 2;
            elseif( strcmp( typ, 'static' ) )
                typflag(ientry) = 1;
                testid{ientry} = strs{4+iadd};
            else % Normal case.
                typflag(ientry) = 0;
                testid{ientry} = strs{3+iadd};
                rpm(ientry) = str2num( strs{4+iadd} );
            end

        else % Handle case where geom and thick are specified without type.
            typ = strs{2};
            if( strcmp( typ, 'geom' ) )
                typflag(ientry) = 2;
            elseif( strcmp( typ, 'thick' ) )
                typflag(ientry) = 3;
            end
        end

        ientry = ientry + 1;
    end
end


itypflag = nan( nimage, 1 );  % File type 0: Normal, 1: Static, 2: Geom, 3: Thick
irpm = itypflag;               % RPM for Normal data
inblade = itypflag;            % Number of blades for cases with variable blade numbers
ispecimen = itypflag;          % Specimen for repeated cases
ideg = itypflag;               % Angle for variable angle cases
idiam = itypflag;              % Prop Diameter (in)
ipitch = itypflag;             % Prop Pitch (in)
itracpush = itypflag;          % Flag 1: Tractor, 2: Pusher flag
ivnum = itypflag;              % Volume number

% String data extracted from file names.
ivname = cell( nimage, 1);    % Volume name (subdirectory)
ifname = ivname;               % File name
imfg = ivname;                 % Manufacturer
isz = ivname;                  % Size descriptor
imodel = ivname;               % Model name for prop size not given as DxP or D
itestid = ivname;              % Test number/person ID

viewdir = cell( nimage, 1 );  % View direction string
ityp = nan( nimage, 1 );      % Image view flag 0: front, 1: side

ientry = 1;
for ivol = 1:length( vols )

    for inam = 1:length( ifnames{ivol} )

        strs = strsplit( ifnames{ivol}{inam}, '-' );

        prefix = strs{1};
        viewdir{ientry} = strs{2};

        if ( contains( viewdir{ientry}, 'front' ) )
            ityp(ientry) = 0;
        else
            ityp(ientry) = 1;
        end

        strs = strsplit( prefix, '-' );

        ivname{ientry} = vols( ivol ).name;
        ifname{ientry} = ifnames{ivol}{inam};

        imfg{ientry} = strs{1};

        vdat = strsplit( vname{ientry}, '-' );
        ivnum(ientry) = str2num( vdat{2} );

        if ( length( strs ) > 2 )

            isz{ientry} = strs{2};

            dp = strsplit( sz{ientry}, 'x' );
            d = str2num( dp{1} );
            p = nan;

            if( isempty( d ) )
                imodel{ientry} = dp{1};
                d = nan;
                if( length( dp{1} ) < 5 && contains( dp{1}, 'p' ) )
                    ds = strsplit( dp{1}, 'p' );
                    d = str2num( ds{1} );
                    ispecimen(ientry) = str2num( ds{2} );
                    itracpush(ientry) = 2;
                elseif( length( dp{1} ) < 5 && contains( dp{1}, 't' ) )
                    ds = strsplit( dp{1}, 't' );
                    d = str2num( ds{1} );
                    ispecimen(ientry) = str2num( ds{2} );
                    itracpush(ientry) = 1;
                end
            else
                if ( length( dp ) > 1 )
                    p = str2num( dp{2} );
                end
            end

            if ( strcmp( mfg{ientry}, 'ancf' ) )
                % Half-inch increments were specified without a decimal.
                % For example, d=12.5 listed as 125.
                if ( d > 60 )
                    d = d / 10;
                end
                if ( p > 30 )
                    p = p / 10;
                end
            elseif ( d > 30 ) % Detect cases with dimensions in mm.  Convert to inch.
                d = d / 25.4;
                p = p / 25.4;
            end
            idiam(ientry) = d;
            ipitch(ientry) = p;

            % Attempt to detect entry type
            addfield = strs{3};

            % Tracker for additional fields
            iadd = 0;

            if ( contains( addfield, 'deg' ) )
                ideg(ientry) = str2num( erase( addfield, 'deg' ) );
            end

            % Needs to come after deg.
            if ( length( addfield ) == 2 && contains( addfield, 'b' ) )
                inblade(ientry) = str2num( erase( addfield, 'b' ) );
            end

            if ( contains( addfield, 'spec' ) )
                ispecimen(ientry) = str2num( erase( addfield, 'spec' ) );
            end

        else

        end

        ientry = ientry + 1;
    end
end


% Set up identifier that will cluster prop data files together
% rpm and file type are not in identifier
ident = cell( nentry, 1 );
for ientry = 1:nentry
    id = mfg{ientry};

    if ( isfinite( diam(ientry) ) )
        id = [id '_' num2str( diam( ientry ) ) ];
    end

    if ( isfinite( pitch(ientry) ) )
        id = [id 'x' num2str( pitch( ientry ) ) ];
    end

    if ( isfinite( deg(ientry) ) )
        id = [id '_' num2str( deg( ientry ) ) 'deg' ];
    end

    if ( isfinite( nblade(ientry) ) )
        id = [id '_' num2str( nblade( ientry ) ) 'b' ];
    end

    if ( isfinite( tracpush(ientry) ) )
        if ( tracpush(ientry) == 1 )
            id = [id '_t'];
        else
            id = [id '_p'];
        end
    end

    if ( isfinite( specimen( ientry ) ) )

        id = [id '_spec' num2str( specimen( ientry ) ) ];

    end

    ident{ientry} = id;

end


% Set up identifier that will cluster prop image files together
% rpm and file type are not in identifier
iident = cell( nimage, 1 );
for ientry = 1:nimage
    id = imfg{ientry};

    if ( isfinite( idiam(ientry) ) )
        id = [id '_' num2str( idiam( ientry ) ) ];
    end

    if ( isfinite( ipitch(ientry) ) )
        id = [id 'x' num2str( ipitch( ientry ) ) ];
    end

    if ( isfinite( ideg(ientry) ) )
        id = [id '_' num2str( ideg( ientry ) ) 'deg' ];
    end

    if ( isfinite( inblade(ientry) ) )
        id = [id '_' num2str( inblade( ientry ) ) 'b' ];
    end

    if ( isfinite( itracpush(ientry) ) )
        if ( itracpush(ientry) == 1 )
            id = [id '_t'];
        else
            id = [id '_p'];
        end
    end

    if ( isfinite( ispecimen( ientry ) ) )

        id = [id '_spec' num2str( ispecimen( ientry ) ) ];

    end

    iident{ientry} = id;

end



% Group by identifier
[uident, ia, ic] = unique( ident );

nprop = length( uident );


% Build struct with fields
propDB = struct( 'ident', uident,...
                       'diam', num2cell( diam( ia ) ),...
                       'pitch', num2cell( pitch( ia ) ),...
                       'deg', num2cell( deg( ia ) ),...
                       'nblade', num2cell( nblade( ia ) ),...
                       'tracpush', num2cell( tracpush( ia ) ),...
                       'specimen', num2cell( specimen( ia ) ),...
                       'vnum', num2cell( vnum( ia ) ),...
                       'model', num2cell( model( ia ) ),...
                       'vname', num2cell( vname( ia ) ),...
                       'mfg', num2cell( mfg( ia ) ) );

for iprop = 1:nprop
    id = propDB(iprop).ident;

    indexes = find( strcmp( ident, id ) );
    typs = typflag( indexes );

    rpms = rpm( indexes );
    rpmv = paren( rpms, typs == 0 );

    files = fname( indexes );

    pfile = files( typs == 0 );
    sfile = files( typs == 1 );
    gfile = files( typs == 2 );
    tfile = files( typs == 3 );

    % Index to original vector positions.
    % propDB(iprop).indexes = indexes;

    propDB(iprop).fname = files;
    propDB(iprop).typflag = typs;
    propDB(iprop).rpmv = rpmv;
    propDB(iprop).perf = pfile;
    propDB(iprop).static = sfile;
    propDB(iprop).geom = gfile;
    propDB(iprop).thick = tfile;

    iindex = find( strcmp( iident, id ) );
    ityps = ityp( iindex );

    ifiles = ifname( iindex );

    iffile = ifiles( ityps == 0 );
    isfile = ifiles( ityps == 1 );

    propDB(iprop).front = iffile;
    propDB(iprop).side = isfile;

end

end
