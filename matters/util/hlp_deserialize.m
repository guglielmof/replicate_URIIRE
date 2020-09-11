%% hlp_deserialize
%
% Convert a serialized byte vector back into the corresponding MATLAB data structure.
%
%% Synopsis
%
% data = hlp_deserialize(bytes)
%
% *Parameters*
%
% * *|bytes|* - a representation of the original data as a byte stream
%
% *Returns*
%
% * |data structure|  -  some MATLAB data structure
%
%
%
%% Example of use
%
%   bytes = hlp_serialize(mydata);
%   ... e.g. transfer the 'bytes' array over the network ...
%   mydata = hlp_deserialize(bytes);
%
%                                Christian Kothe, Swartz Center for Computational Neuroscience, UCSD
%                                2010-04-02
%
%                                adapted from deserialize.m
%                                (C) 2010 Tim Hutt
%
%                                extended for including MATLAB 2013b data
%                                structures such as struct, tables, ordinal
%                                and categorical.
%                                (C) 2014 Nicola Ferro, Gianmaria Silvello

%% Information
% 
% * *Author*: <mailto:ferro@dei.unipd.it Nicola Ferro>,
% <mailto:silvello@dei.unipd.it Gianmaria Silvello>
% * *Version*: 1.00
% * *Since*: 1.00
% * *Requirements*: Matlab 2013b or higher
% * *Copyright:* (C) 2013-2014 <http://ims.dei.unipd.it/ Information 
% Management Systems> (IMS) research group, <http://www.dei.unipd.it/ 
% Department of Information Engineering> (DEI), <http://www.unipd.it/ 
% University of Padua>, Italy
% * *License:* <http://www.apache.org/licenses/LICENSE-2.0 Apache License, 
% Version 2.0>

% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
%     * Redistributions of source code must retain the above copyright
%       notice, this list of conditions and the following disclaimer.
%     * Redistributions in binary form must reproduce the above copyright
%       notice, this list of conditions and the following disclaimer in
%       the documentation and/or other materials provided with the distribution
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
% AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
% IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
% ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
% LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
% CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
% SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
% INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
% CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
% ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
% POSSIBILITY OF SUCH DAMAGE.

% Deserialize

function v = hlp_deserialize(m)
    % wrap dispatcher
    v = deserialize_value(uint8(m(:)), 1);
end

% dispatch
function [v,pos] = deserialize_value(m,pos)
switch m(pos)
    case {0,200}
        [v,pos] = deserialize_string(m,pos);
    case 128
        [v,pos] = deserialize_struct(m,pos);
    case {33,34,35,36,37,38,39}
        [v,pos] = deserialize_cell(m,pos);
    case {1,2,3,4,5,6,7,8,9,10}
        [v,pos] = deserialize_scalar(m,pos);
    case 133
        [v,pos] = deserialize_logical(m,pos);
    case {151,152,153}
        [v,pos] = deserialize_handle(m,pos);
    case {17,18,19,20,21,22,23,24,25,26}
        [v,pos] = deserialize_numeric_simple(m,pos);
    case 130
        [v,pos] = deserialize_sparse(m,pos);
    case 131
        [v,pos] = deserialize_complex(m,pos);
    case 132
        [v,pos] = deserialize_char(m,pos);
    case 134
        [v,pos] = deserialize_object(m,pos);
    % ### Start IMS - UNIPD Code ### 
    case {201, 202}
        [v, pos] = deserialize_categorical(m, pos);
    case 203
        [v, pos] = deserialize_ordinal(m, pos);
    case 210 % do not use 211 and 212: private ids for deserialization of tables
        [v, pos] = deserialize_table(m, pos);
    % ### End IMS - UNIPD Code ###     
    otherwise
        error('Unknown class');
end
end

% individual scalar
function [v,pos] = deserialize_scalar(m,pos)
classes = {'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64'};
sizes = [8,4,1,1,2,2,4,4,8,8];
sz = sizes(m(pos));
% Data.
v = typecast(m(pos+1:pos+sz),classes{m(pos)});

pos = pos + 1 + sz;
end

% standard string
function [v,pos] = deserialize_string(m,pos)
if m(pos) == 0
    % horizontal string: tag
    pos = pos + 1;
    % length (uint32)
    nbytes = double(typecast(m(pos:pos+3),'uint32'));
    pos = pos + 4;
    % data (chars)
    v = char(m(pos:pos+nbytes-1))';
    pos = pos + nbytes;
else
    % proper empty string: tag
    [v,pos] = deal('',pos+1);
end
end

% general char array
function [v,pos] = deserialize_char(m,pos)
pos = pos + 1;
% Number of dims
ndms = double(m(pos));
pos = pos + 1;
% Dimensions
dms = double(typecast(m(pos:pos+ndms*4-1),'uint32')');
pos = pos + ndms*4;
nbytes = prod(dms);
% Data.
v = char(m(pos:pos+nbytes-1));
pos = pos + nbytes;
v = reshape(v,[dms 1 1]);
end

% general logical array
function [v,pos] = deserialize_logical(m,pos)
pos = pos + 1;
% Number of dims
ndms = double(m(pos));
pos = pos + 1;
% Dimensions
dms = double(typecast(m(pos:pos+ndms*4-1),'uint32')');
pos = pos + ndms*4;
nbytes = prod(dms);
% Data.
v = logical(m(pos:pos+nbytes-1));
pos = pos + nbytes;
v = reshape(v,[dms 1 1]);
end

% simple numerical matrix
function [v,pos] = deserialize_numeric_simple(m,pos)
classes = {'double','single','int8','uint8','int16','uint16','int32','uint32','int64','uint64'};
sizes = [8,4,1,1,2,2,4,4,8,8];
cls = classes{m(pos)-16};
sz = sizes(m(pos)-16);
pos = pos + 1;
% Number of dims
ndms = double(m(pos));
pos = pos + 1;
% Dimensions
dms = double(typecast(m(pos:pos+ndms*4-1),'uint32')');
pos = pos + ndms*4;
nbytes = prod(dms) * sz;
% Data.
v = typecast(m(pos:pos+nbytes-1),cls);
pos = pos + nbytes;
v = reshape(v,[dms 1 1]);
end

% complex matrix
function [v,pos] = deserialize_complex(m,pos)
pos = pos + 1;
[re,pos] = deserialize_numeric_simple(m,pos);
[im,pos] = deserialize_numeric_simple(m,pos);
v = complex(re,im);
end

% sparse matrix
function [v,pos] = deserialize_sparse(m,pos)
pos = pos + 1;
% matrix dims
u = double(typecast(m(pos:pos+7),'uint64'));
pos = pos + 8;
v = double(typecast(m(pos:pos+7),'uint64'));
pos = pos + 8;
% index vectors
[i,pos] = deserialize_numeric_simple(m,pos);
[j,pos] = deserialize_numeric_simple(m,pos);
if m(pos)
    % real
    pos = pos+1;
    [s,pos] = deserialize_numeric_simple(m,pos);
else
    % complex
    pos = pos+1;
    [re,pos] = deserialize_numeric_simple(m,pos);
    [im,pos] = deserialize_numeric_simple(m,pos);
    s = complex(re,im);
end
v = sparse(i,j,s,u,v);
end

% struct array
function [v,pos] = deserialize_struct(m,pos)
pos = pos + 1;
% Number of field names.
nfields = double(typecast(m(pos:pos+3),'uint32'));
pos = pos + 4;
% Field name lengths
fnLengths = double(typecast(m(pos:pos+nfields*4-1),'uint32'));
pos = pos + nfields*4;
% Field name char data
fnChars = char(m(pos:pos+sum(fnLengths)-1)).';
pos = pos + length(fnChars);
% Number of dims
ndms = double(typecast(m(pos:pos+3),'uint32'));
pos = pos + 4;
% Dimensions
dms = typecast(m(pos:pos+ndms*4-1),'uint32')';
pos = pos + ndms*4;
% Field names.
fieldNames = cell(length(fnLengths),1);
splits = [0; cumsum(double(fnLengths))];
for k=1:length(splits)-1
    fieldNames{k} = fnChars(splits(k)+1:splits(k+1)); end
% Content.
v = reshape(struct(),[dms 1 1]);
if m(pos)
    % using struct2cell
    pos = pos + 1;
    [contents,pos] = deserialize_cell(m,pos);
    v = cell2struct(contents,fieldNames,1);
else
    % using per-field cell arrays
    pos = pos + 1;
    for ff = 1:nfields
        [contents,pos] = deserialize_cell(m,pos);
        [v.(fieldNames{ff})] = deal(contents{:});
    end
end
end

% cell array
function [v,pos] = deserialize_cell(m,pos)
kind = m(pos);
pos = pos + 1;
switch kind
    case 33 % arbitrary/heterogenous cell array
        % Number of dims
        ndms = double(m(pos));
        pos = pos + 1;
        % Dimensions
        dms = double(typecast(m(pos:pos+ndms*4-1),'uint32')');
        pos = pos + ndms*4;
        % Contents
        v = cell([dms,1,1]);
        for ii = 1:numel(v)
            [v{ii},pos] = deserialize_value(m,pos); end
    case 34 % cell scalars
        [content,pos] = deserialize_value(m,pos);
        v = cell(size(content));
        for k=1:numel(v)
            v{k} = content(k); end
    case 35 % mixed-real cell scalars
        [content,pos] = deserialize_value(m,pos);
        v = cell(size(content));
        for k=1:numel(v)
            v{k} = content(k); end
        [reality,pos] = deserialize_value(m,pos);
        v(reality) = real(v(reality));
    case 36 % cell array with horizontal or empty strings
        [chars,pos] = deserialize_string(m,pos);
        [lengths,pos] = deserialize_numeric_simple(m,pos);
        [empty,pos] = deserialize_logical(m,pos);
        v = cell(size(lengths));
        splits = [0 cumsum(double(lengths(:)))'];
        for k=1:length(lengths)
            v{k} = chars(splits(k)+1:splits(k+1)); end
        [v{empty}] = deal('');
    case 37 % empty,known type
        tag = m(pos);
        pos = pos + 1;
        switch tag
            case 1   % double - []
                prot = [];
            case 33  % cell - {}
                prot = {};
            case 128 % struct - struct()
                prot = struct();
            otherwise
                error('Unsupported type tag.');
        end
        % Number of dims
        ndms = double(m(pos));
        pos = pos + 1;
        % Dimensions
        dms = typecast(m(pos:pos+ndms*4-1),'uint32')';
        pos = pos + ndms*4;
        % Create content
        v = repmat({prot},dms);
    case 38 % empty, prototype available
        % Prototype.
        [prot,pos] = deserialize_value(m,pos);
        % Number of dims
        ndms = double(m(pos));
        pos = pos + 1;
        % Dimensions
        dms = typecast(m(pos:pos+ndms*4-1),'uint32')';
        pos = pos + ndms*4;
        % Create content
        v = repmat({prot},dms);
    case 39 % boolean flags
        [content,pos] = deserialize_logical(m,pos);
        v = cell(size(content));
        for k=1:numel(v)
            v{k} = content(k); end
    otherwise
        error('Unsupported cell array type.');
end
end

% ### Start IMS - UNIPD Code ###

% categorical array
function [v, pos] = deserialize_categorical(m, pos)
    switch m(pos)
        % not a matrix
        case 201
            v = categorical(deserialize_cell(m, pos + 1));
        case 202
            % get the number of columns
            columns = double(typecast(m(pos + 1 : pos + 8),'uint64'));
            % update position 
            pos = pos + 8;
            % get length cell
            cellLength = double(typecast(m(pos + 1 : pos + 8),'uint64'));
            % update position
            pos = pos + 8;
            % deserialize categorical
            v = categorical(deserialize_cell(m(pos + 1 : pos + cellLength), 1));
            % update the position to the new array
            pos = pos + cellLength;
            
            for i = 2 : columns
                % get length cell
                cellLength = double(typecast(m(pos + 1 : pos + 8),'uint64'));
                % update position
                pos = pos + 8;
                v = [v categorical(deserialize_cell(m(pos + 1 : pos + cellLength), 1))];
                if i < columns
                    % update the position to the new array
                    pos = pos + cellLength;
                end
            end
    end
    
end

% ordinal array
function [v, pos] = deserialize_ordinal(m, pos)
    % take the array from the position after the one indicating the length
    % of the level array to the end of the array given by m(pos + 1) + 2
    
    %get levels length
    levelsLength = double(typecast(m(pos + 1 : pos + 8),'uint64'));
    % update position
    pos = pos + 8;
    % getLevels
    levels = deserialize_cell(m(pos + 1 : pos + levelsLength), 1);
    tmp = deserialize_categorical(m, pos + levelsLength + 1);
    v = categorical(tmp, levels, levels, 'Ordinal', true);
end

% table
function [v, pos] = deserialize_table(m, pos)
    % get the length of the Properties of the table
    lengthProperties = double(typecast(m(pos + 1 : pos + 8),'uint64'));
    % update position after length deserialization
    pos = pos + 8;
    % get the properties of the table
    properties = hlp_deserialize(m(pos + 1 : pos + lengthProperties));
    % the number of rows of the table
    numRows = double(typecast(m(pos + lengthProperties + 1 : pos + lengthProperties + 8),'uint64'));
    % update position after rows length deserialization
    pos = pos + lengthProperties + 8;
    % the number of columns of the table
    numColumns = double(typecast(m(pos + 1 : pos + 8),'uint64')); 
    % update position after column length deserialization
    pos = pos + 8;
    % if we have an empty table
    if numColumns == 0
        % initialize an empty table
        v = table();
        % set the properties
        v.Properties = properties;
        pos = pos + 1;
    else
        % deserialize total length value
        totalLength = double(typecast(m(pos + 1 : pos + 8),'uint64')); 
        % update position after column length deserialization
        pos = pos + 8;
        % get the total length of the table to be deserialized
        totalLength = pos + totalLength;
        % initialize the current position
        currentPos = pos + 1;
        % initialize the cell array that will be used for the output table
        v_data = cell(1, numColumns);
        % keep an index for the while loop, it indicates the number of the 
        % column under being processed
        i = 1;
        % stay in the loop until you reach the end of the array
        while currentPos < totalLength
            % get the deserialization type for the first column
            columnType = m(currentPos);
            % get the length of the first column
            columnLength = double(typecast(m(currentPos + 1 : currentPos + 8),'uint64'));
            % update the current position 
            currentPos = currentPos + 8;
            % get the absolute int indicating the end of the column in the
            % array
            endColumnInt = currentPos + columnLength;
            % decide how to process each column
            switch columnType
                case 211 % process the column cell by cell
                    currentColumnPos = currentPos;
                    column = cell(numRows, 1);
                    j = 1;
                    while currentColumnPos < endColumnInt
                        % get the total length of the serialized cell
                        cellLength = double(typecast(m(currentColumnPos + 1 : currentColumnPos + 8),'uint64')); 
                        % update the current position 
                        currentColumnPos = currentColumnPos + 8;
                        % get the first cell of the column
                        cellColumn = hlp_deserialize(m(currentColumnPos + 1 : currentColumnPos + cellLength));
                        % update the current position 
                        currentColumnPos = currentColumnPos + cellLength;
                        % update the end column
                        column(j, :) = {cellColumn};
                        % update column index
                        j = j + 1;
                    end
                case 212 % process the column in one shot
                    % get the column
                    column = hlp_deserialize(m(currentPos + 1 : currentPos + columnLength));
                otherwise
                    error('Column type: %s is unsupported. Valid column type are: 211 and 212', ...
                     columnType);
            end
            
            % put the column in the table as a cell
            v_data(i) = {column};
            % update the column index
            i = i + 1;
            % go to the first value after the serialization of this column
            currentPos = currentPos + 1 + columnLength;
        end
        
        % create the end table
        v = table(v_data{:});
        % update table properties
        v.Properties = properties;
        % update pos
        pos = currentPos;
        % check if the number of rows is correct 
        % this step could be skipped
        if (size(v, 1) ~= numRows)
            error('InvalidSizeException in deserializing table: The expected number of rows is %d, but the actual number of rows is %d', ... 
                numRows, size(v, 1));
        end
        
    end
end

% ### End IMS - UNIPD Code ###

% Original code

% object
function [v,pos] = deserialize_object(m,pos)
pos = pos + 1;
% Get class name.
[cls,pos] = deserialize_string(m,pos);
% Get contents
[conts,pos] = deserialize_value(m,pos); 
% construct object
try
    % try to use the loadobj function
    v = eval([cls '.loadobj(conts)']);
catch
    try
        % pass the struct directly to the constructor
        v = eval([cls '(conts)']);
    catch
        try
            % try to set the fields manually
            v = feval(cls);
            for fn=fieldnames(conts)'
                try
                    set(v,fn{1},conts.(fn{1})); 
                catch
                    % Note: if this happens, your deserialized object might not be fully identical
                    % to the original (if you are lucky, it didn't matter, through). Consider 
                    % relaxing the access rights to this property or add support for loadobj from
                    % a struct.
                    warn_once('hlp_deserialize:restricted_access','No permission to set property %s in object of type %s.',fn{1},cls);
                end
            end
        catch
            v = conts;
            v.hlp_deserialize_failed = ['could not construct class: ' cls];
        end
    end
end
end

% function handle
function [v,pos] = deserialize_handle(m,pos)
% Tag
kind = m(pos);
pos = pos + 1;
switch kind
    case 151 % simple function
        persistent db_simple; %#ok<TLEV> % database of simple functions (indexed by name)
        % Name
        [name,pos] = deserialize_string(m,pos);
        try
            % look up from table
            v = db_simple.(name);
        catch
            % otherwise generate & fill table
            v = str2func(name);
            db_simple.(name) = v;
        end
    case 152 % anonymous function
        % Function code
        [code,pos] = deserialize_string(m,pos);
        % Workspace
        [wspace,pos] = deserialize_struct(m,pos);
        % Construct
        v = restore_function(code,wspace);
    case 153 % scoped or nested function
        persistent db_nested; %#ok<TLEV> % database of nested functions (indexed by name)
        % Parents
        [parentage,pos] = deserialize_cell(m,pos);
        try
            key = sprintf('%s_',parentage{:});
            % look up from table
            v = db_nested.(key);
        catch
            % recursively look up from parents, assuming that these support the arg system
            v = parentage{end};
            for k=length(parentage)-1:-1:1
                % Note: if you get an error here, you are trying to deserialize a function handle
                % to a nested function. This is not natively supported by MATLAB and can only be made
                % to work if your function's parent implements some mechanism to return such a handle.
                % The below call assumes that your function uses the BCILAB arg system to do this.
                v = arg_report('handle',v,parentage{k});
            end
            db_nested.(key) = v;
        end
end
end

% helper for deserialize_handle
function f = restore_function(decl__,workspace__)
% create workspace
for fn__=fieldnames(workspace__)'
    % we use underscore names here to not run into conflicts with names defined in the workspace
    eval([fn__{1} ' = workspace__.(fn__{1}) ;']); 
end
clear workspace__ fn__;
% evaluate declaration
f = eval(decl__);
end

% emit a specific warning only once (per MATLAB session)
function warn_once(varargin)
persistent displayed_warnings;
% determine the message content
if length(varargin) > 1 && any(varargin{1}==':') && ~any(varargin{1}==' ') && ischar(varargin{2})
    message_content = [varargin{1} sprintf(varargin{2:end})];
else
    message_content = sprintf(varargin{1:end});
end
% generate a hash of of the message content
str = java.lang.String(message_content);
message_id = sprintf('x%.0f',str.hashCode()+2^31);
% and check if it had been displayed before
if ~isfield(displayed_warnings,message_id)
    % emit the warning
    warning(varargin{:});
    % remember to not display the warning again
    displayed_warnings.(message_id) = true;
end
end
