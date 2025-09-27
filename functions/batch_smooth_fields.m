% Batch processing function for convenience
function batch_smooth_fields(varargin)
% BATCH_SMOOTH_FIELDS - Convenience wrapper for f_smoothen_fields with boundary ignoring support
%
% SYNTAX:
%   batch_smooth_fields('DataDir', data_dir, 'SaveOutput', true, 'Fields', field_list)
%   batch_smooth_fields('DataDir', data_dir, 'Fields', field_list, 'IgnoreBoundaries', {'left', 'right'})
%
% INPUTS (All Name-Value pairs):
%   'DataDir'          - Path to directory containing field .mat files (string, required)
%   'SaveOutput'       - Save smoothed fields (logical, default: false)
%   'Fields'           - Cell array of field configurations (cell, default: {})
%   'PlotResults'      - Generate comparison plots (logical, default: false)
%   'PlotSurf'         - Generate surface plots (logical, default: false)
%   'SaveFigs'         - Save generated figures (logical, default: false)
%   'IgnoreBoundaries' - Boundaries to ignore during smoothing (cell array or string)
%                        Options: 'left', 'right', 'top', 'bottom', 'all'
%                        Default: {} (no boundaries ignored)
%   'BoundaryWidth'    - Width of boundary region to ignore (scalar or 4-element vector)
%                        Default: 1
%
% EXAMPLES:
%   % Basic usage
%   batch_smooth_fields('DataDir', data_dir, 'SaveOutput', true, 'Fields', field_list);
%
%   % With boundary ignoring
%   batch_smooth_fields('DataDir', data_dir, 'Fields', field_list, 'PlotResults', true, ...
%                      'IgnoreBoundaries', {'left', 'right'}, 'BoundaryWidth', 2);
%
% See also: f_smoothen_fields

    % Parse all arguments using inputParser
    p = inputParser;
    
    % All parameters are name-value pairs
    addParameter(p, 'DataDir', '', @ischar);
    addParameter(p, 'SaveOutput', false, @islogical);
    addParameter(p, 'Fields', {}, @iscell);
    addParameter(p, 'PlotResults', false, @islogical);
    addParameter(p, 'PlotSurf', false, @islogical);
    addParameter(p, 'SaveFigs', false, @islogical);
    addParameter(p, 'IgnoreBoundaries', {}, @(x) iscell(x) || ischar(x) || isstring(x));
    addParameter(p, 'BoundaryWidth', 1, @(x) isnumeric(x) && all(x > 0) && (isscalar(x) || length(x) == 4));
    
    parse(p, varargin{:});
    
    % Extract parsed values
    data_dir = p.Results.DataDir;
    save_flag = p.Results.SaveOutput;
    field_list = p.Results.Fields;
    plot_results_flag = p.Results.PlotResults;
    plot_surf_flag = p.Results.PlotSurf;
    save_figs = p.Results.SaveFigs;
    ignore_boundaries = p.Results.IgnoreBoundaries;
    boundary_width = p.Results.BoundaryWidth;
    
    % Validate required parameters
    if isempty(data_dir)
        error('DataDir must be specified!');
    end
    
    % Validate data directory
    if ~exist(data_dir, 'dir')
        error('Data directory %s not found!', data_dir);
    end
    
    % Call the main smoothing function
    f_smoothen_fields('DataDir', data_dir, 'Fields', field_list, ...
                   'SaveOutput', save_flag, 'PlotResults', plot_results_flag, ...
                   'PlotSurf', plot_surf_flag, 'SaveFigs', save_figs, ...
                   'IgnoreBoundaries', ignore_boundaries, 'BoundaryWidth', boundary_width);
end