function field_out = set_boundary_values(field_in, boundary_value, varargin)
% SET_BOUNDARY_VALUES - Sets boundary points of a 2D field to specified values
%
% SYNTAX:
%   field_out = set_boundary_values(field_in, boundary_value)
%   field_out = set_boundary_values(field_in, boundary_value, 'BoundaryWidth', width)
%   field_out = set_boundary_values(field_in, boundary_value, 'Boundaries', boundaries)
%   field_out = set_boundary_values(field_in, boundary_value, 'BoundaryWidth', width, 'Boundaries', boundaries)
%
% INPUTS:
%   field_in        - 2D matrix representing the field data
%   boundary_value  - Value to set at boundaries (scalar) or structure with 
%                     fields: top, bottom, left, right for different values
%   
% OPTIONAL PARAMETERS (Name-Value pairs):
%   'BoundaryWidth' - Width of boundary region (default: 1)
%                     Can be scalar or 4-element vector [top, bottom, left, right]
%   
%   'Boundaries'    - Cell array specifying which boundaries to modify
%                     Options: 'top', 'bottom', 'left', 'right', 'all'
%                     Default: {'all'}
%
% OUTPUTS:
%   field_out      - 2D matrix with specified boundary values
%
% EXAMPLES:
%   % Set all boundaries to zero (equivalent to set_boundary_to_zero)
%   field_zero = set_boundary_values(field, 0);
%
%   % Set boundaries to different values
%   boundary_vals.top = 1.0;
%   boundary_vals.bottom = 0.5;
%   boundary_vals.left = 0.0;
%   boundary_vals.right = 2.0;
%   field_bc = set_boundary_values(field, boundary_vals);
%
%   % Set only top and bottom to specific value
%   field_bc = set_boundary_values(field, 1.5, 'Boundaries', {'top', 'bottom'});
%
%   % Set boundary conditions for combustion fields (typical use case)
%   field_bc = set_boundary_values(temperature_field, 300, 'BoundaryWidth', 2, 'Boundaries', {'left'});
%
% NOTES:
%   - Designed for CFD boundary condition applications
%   - Supports both uniform and non-uniform boundary values
%   - Compatible with combustion LES post-processing workflow
%   - Can be used for Dirichlet boundary conditions in field interpolation
%
% See also: set_boundary_to_zero, linear_interp_field, smoothen_fields
% Author: Satyam 
% Date: September 2025
% Part of MATLAB CFD Post-processing Suite

%% Input validation
if ~ismatrix(field_in) || ndims(field_in) ~= 2
    error('Input field must be a 2D matrix');
end

if ~isnumeric(field_in)
    error('Input field must be numeric');
end

[rows, cols] = size(field_in);

% Validate boundary_value
if ~(isnumeric(boundary_value) && isscalar(boundary_value)) && ~isstruct(boundary_value)
    error('boundary_value must be a numeric scalar or structure with boundary-specific values');
end

% Parse optional inputs
p = inputParser;
addParameter(p, 'BoundaryWidth', 1, @(x) isnumeric(x) && all(x > 0) && (isscalar(x) || length(x) == 4));
addParameter(p, 'Boundaries', {'all'}, @(x) iscell(x) || ischar(x) || isstring(x));
parse(p, varargin{:});

boundary_width = p.Results.BoundaryWidth;
boundaries = p.Results.Boundaries;

% Convert boundaries to cell array if needed
if ischar(boundaries) || isstring(boundaries)
    boundaries = {char(boundaries)};
end

% Handle 'all' boundary specification
if any(strcmpi(boundaries, 'all'))
    boundaries = {'top', 'bottom', 'left', 'right'};
end

%% Process boundary width parameter
if isscalar(boundary_width)
    width_top = boundary_width;
    width_bottom = boundary_width;
    width_left = boundary_width;
    width_right = boundary_width;
else
    width_top = boundary_width(1);
    width_bottom = boundary_width(2);
    width_left = boundary_width(3);
    width_right = boundary_width(4);
end

% Ensure widths don't exceed field dimensions
width_top = min(width_top, rows);
width_bottom = min(width_bottom, rows);
width_left = min(width_left, cols);
width_right = min(width_right, cols);

%% Determine boundary values for each side
if isstruct(boundary_value)
    % Different values for each boundary
    val_top = boundary_value.top;
    val_bottom = boundary_value.bottom;
    val_left = boundary_value.left;
    val_right = boundary_value.right;
else
    % Same value for all boundaries
    val_top = boundary_value;
    val_bottom = boundary_value;
    val_left = boundary_value;
    val_right = boundary_value;
end

%% Apply boundary modifications
field_out = field_in;

for i = 1:length(boundaries)
    boundary = lower(boundaries{i});
    
    switch boundary
        case 'top'
            if width_top > 0
                field_out(1:width_top, :) = val_top;
                fprintf('Set top boundary (%d rows) to %.3f\n', width_top, val_top);
            end
            
        case 'bottom'
            if width_bottom > 0
                field_out(end-width_bottom+1:end, :) = val_bottom;
                fprintf('Set bottom boundary (%d rows) to %.3f\n', width_bottom, val_bottom);
            end
            
        case 'left'
            if width_left > 0
                field_out(:, 1:width_left) = val_left;
                fprintf('Set left boundary (%d columns) to %.3f\n', width_left, val_left);
            end
            
        case 'right'
            if width_right > 0
                field_out(:, end-width_right+1:end) = val_right;
                fprintf('Set right boundary (%d columns) to %.3f\n', width_right, val_right);
            end
            
        otherwise
            warning('Unknown boundary specification: %s', boundary);
    end
end

%% Summary output for debugging
if nargout == 0
    fprintf('\nBoundary modification summary:\n');
    fprintf('Original field size: %d x %d\n', rows, cols);
    fprintf('Modified boundaries: %s\n', strjoin(boundaries, ', '));
    
    % Count modified points
    modified_points = sum(sum(field_in ~= field_out));
    total_points = rows * cols;
    fprintf('Points modified: %d (%.1f%%)\n', modified_points, 100*modified_points/total_points);
end

end