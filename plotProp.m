function plotProp( dbentry )
% plotProp( DBENTRY ) plots propeller data from DBENTRY.
%
%   plotProp( DBENTRY ) plots propeller data from files in the UIUC
%   propeller database.  DBENTRY is a meta-data structure as parsed by
%   PROPDATABASE.
%
%   See also PROPDATABASE, PARSEPROP.

%   Rob McDonald
%   rob.a.mcdonald@gmail.com
%   17 February 2021 v. 1.0 -- Original version.
%


% Parse datat from data files
prop = parseProp( dbentry );


fignum = 1;
if( ~isempty( dbentry.rpmv ) )

    figadd = 1;

    figure( fignum );
    for irpm = 1:length( dbentry.rpmv )
        figure( fignum );
        plot( prop.J{irpm}, prop.CT{irpm}, prop.J{irpm}, prop.CP{irpm} )
        hold on
    end

    xlabel( 'J' )
    ylabel( 'C_T and C_P' )
    legend( string( dbentry.rpmv ) )
    ax = axis;
    ax(1) = 0;
    axis(ax);

    % Plot static performance data.
    if( ~isempty( dbentry.static ) )
        J0 = zeros( size( prop.CT_static ) );

        figure( fignum );
        ax=axis;
        plot( J0, prop.CT_static, 'o', J0, prop.CP_static, 'x' )
        axis(ax);
        legend( [string( dbentry.rpmv ); "CT_{static}"; "CP_{static}"])


        figure( fignum + 1 );
        plot( prop.RPM_static, prop.CT_static, prop.RPM_static, prop.CP_static )

        xlabel( 'RPM' )
        ylabel( 'C_T and C_P' )
        ax = axis;
        ax(3) = 0;
        axis(ax);

        figadd = figadd + 1;
    end

    figure( fignum )
    hold off

    fignum = fignum + figadd;
end

% Plot blade geometry data.
if( ~isempty( dbentry.geom ) )

    figure( fignum );
    plot( prop.r_R, prop.beta )

    xlabel( 'r/R' )
    ylabel( 'beta' )
    ax = axis;
    ax(1) = 0;
    axis(ax);

    fignum = fignum + 1;
    figure( fignum )
    plot( prop.r_R, prop.c_R )
    xlabel( 'r/R' )
    ylabel( 'c/R' )

    if( ~isempty( dbentry.thick ) )

        hold on
        plot( prop.r_R_thickness, prop.t_c )
        hold off
        % Amend ylabel
        ylabel( 'c/R and t/c' )
    end

    ax = axis;
    ax(1) = 0;
    axis(ax);

    fignum = fignum + 1;
end

if( ~isempty( dbentry.front ) )
    figure( fignum )
    imshow( prop.front );
    fignum = fignum + 1;
end

if( ~isempty( dbentry.side ) )
    figure( fignum )
    imshow( prop.side );
    fignum = fignum + 1;
end


end
