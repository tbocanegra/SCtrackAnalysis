function [idelt] = nsec(mjd)
% C   This routine determine number of leap seconds or
% C   difference TAI - UTC_iers beginning 1972 January 1
if (mjd >= 41317.d0 && mjd < 41499.d0), idelt = 10; end; % 1972 JAN 1
if (mjd >= 41499.d0 && mjd < 41683.d0), idelt = 11; end; % 1972 JUL 1
if (mjd >= 41683.d0 && mjd < 42048.d0), idelt = 12; end; % 1973 JAN 1
if (mjd >= 42048.d0 && mjd < 42413.d0), idelt = 13; end; % 1974 JAN 1
if (mjd >= 42413.d0 && mjd < 42778.d0), idelt = 14; end; % 1975 JAN 1
if (mjd >= 42778.d0 && mjd < 43144.d0), idelt = 15; end; % 1976 JAN 1
if (mjd >= 43144.d0 && mjd < 43509.d0), idelt = 16; end; % 1977 JAN 1
if (mjd >= 43509.d0 && mjd < 43874.d0), idelt = 17; end; % 1978 JAN 1
if (mjd >= 43874.d0 && mjd < 44239.d0), idelt = 18; end; % 1979 JAN 1     
if (mjd >= 44239.d0 && mjd < 44786.d0), idelt = 19; end; % 1980 JAN 1
if (mjd >= 44786.d0 && mjd < 45151.d0), idelt = 20; end; % 1981 JUL 1
if (mjd >= 45151.d0 && mjd < 45516.d0), idelt = 21; end; % 1982 JUL 1
if (mjd >= 45516.d0 && mjd < 46247.d0), idelt = 22; end; % 1983 JUL 1
if (mjd >= 46247.d0 && mjd < 47161.d0), idelt = 23; end; % 1985 JUL 1
if (mjd >= 47161.d0 && mjd < 47892.d0), idelt = 24; end; % 1988 JAN 1
if (mjd >= 47892.d0 && mjd < 48257.d0), idelt = 25; end; % 1990 JAN 1
if (mjd >= 48257.d0 && mjd < 48804.d0), idelt = 26; end; % 1991 JAN 1
if (mjd >= 48804.d0 && mjd < 49169.d0), idelt = 27; end; % 1992 JUL 1
if (mjd >= 49169.d0 && mjd < 49534.d0), idelt = 28; end; % 1993 JUL 1
if (mjd >= 49534.d0 && mjd < 50083.d0), idelt = 29; end; % 1994 JUL 1
if (mjd >= 50083.d0 && mjd < 50630.d0), idelt = 30; end; % 1996 JAN 1
if (mjd >= 50630.d0 && mjd < 51179.d0), idelt = 31; end; % 1997 JUL 1
if (mjd >= 51179.d0 && mjd < 53736.d0), idelt = 32; end; % 1999 JAN 1
if (mjd >= 53736.d0 && mjd < 54832.d0), idelt = 33; end; % 2006 JAN 1
if (mjd >= 54832.d0 && mjd < 56109.d0), idelt = 34; end; % 2009 JAN 1
if (mjd >= 56109.d0),                   idelt = 35; end; % 2012 JUL 1
