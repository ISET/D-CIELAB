function [lmsContrast,bgLMS]=RGB2ConeContrast(display,stimRGB,bgRGB,sensor)%% function RGB2ConeContrast(display,stimRGB,[bgRGB],[sensor])%%    Compute the vector of cone contrasts (yes, real contrasts)%    when using stimRGB and backRGB.  The structures (display,%    backRGB, and stimRGB) define the characteristics of the%    display, background and contrast stimulus.  The sensor%    default to the Stockman sensors. % %  Inputs:%   %    display:  ISET compatible display structure%    stimRGB:  vector, RGB value of stimulus to be shown on display, can be%              in forms of 3 numbers / XW formats (N-by-3 matrix) / RGB%              formats (M-by-N-by-3 matrix)%    backRGB:  (optional) vector, background RGB value, default [.5 .5 .5]%    sensor :  (optional) A matrix of sensor wavelength sensitivities%                  shoulde contain two fields .wavelength and .data%                  Default:  Stockman sensors.%%  Outputs:%%   lmsContrast:  The vector of cone contrasts under these conditions%   bgLMS      :  The lms values of the background%%  Example:%    display = displayCreate('LCD-Apple');%    lmsContrast = RGB2ConeContrast(display, [0.3 0.4 0.5]');%%  See also:%    coneContrast2RGB %%  History:%   ( BW ) Sep, 1998 : write first version of this function%   ( WAP) Nov, 1998 : swapped location of parameters in argument list%   ( RFD) Apr, 2010 : allow an rgb2lms matrix as input%   ( HJ ) Aug, 2013 : change i/o structure, compute rgb2lms from isetbio%% Check inputsif nargin < 1, error('Display structure required'); endif nargin < 2, error('Stimulus RGB values required'); endif nargin < 3, bgRGB = [0.5 0.5 0.5]'; end%  Convert input to XW formatstimRGBFormat = ndims(stimRGB);if stimRGBFormat == 2 && length(stimRGB) == 3    stimRGBFormat = 1;endswitch stimRGBFormat    case 1 % 3 numbers, convert to 3-by-1 column vector        stimRGB = stimRGB(:);    case 2 % XW format, convert to 3-by-N matrix        assert(size(stimRGB, 2) == 3, 'Unknown stimContrast format');        stimRGB = stimRGB';    case 3 % M-by-N-by-3, convert to 3-by-M*N matrix        assert(size(stimRGB, 3) == 3, 'Unknown stimContrast format');        [row, col, ~] = size(stimRGB);        stimRGB  = RGB2XWFormat(stimRGB)';    otherwise        error('Unknown stimContrast format');end% Convert background RGB to column vectorbgRGB   = bgRGB(:);%  Convert background to 0~1if max(bgRGB) > 1    bgRGB = bgRGB / 255; % Assume it's 8 bit    assert(all(bgRGB >=0) && all(bgRGB <= 1));end%  Convert stimulus to 0~1if max(stimRGB) > 1    stimRGB = stimRGB / 255; % Assume it's 8 bit    assert(all(stimRGB >=0) && all(stimRGB <= 1));end%% Compute rgb2lms conversino matrixif nargin < 4 || isempty(sensor) % Sensor not specified, use stockman    [~, rgb2lms] = humanConeIsolating(display);else % Use another sensor model    wave    = sensor.wavelength;    spd     = displayGet(display,'spd',wave);    rgb2lms = sensor.data'*spd;end%% Compute stimulus contrast%  Compute background LMSbgLMS = rgb2lms * bgRGB;%  Compute stimulus LMSstimLMS = rgb2lms * stimRGB;%  Compute contrastlmsContrast = stimLMS ./ repmat(bgLMS,[1 size(stimLMS, 2)]) - 1;%  Convert to proper formatswitch stimRGBFormat    case 1 % should by 3-by-1 now, do nothing    case 2 % convert to XW format, namely, N-by-3        lmsContrast = lmsContrast';    case 3 % convert to M-by-N-by-3        lmsContrast = XW2RGBFormat(lmsContrast', row, col);    otherwise        error('How could you get here');endend