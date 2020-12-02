classdef EnvironmentManager < handle
    properties (Access=private)
        env struct = struct('name', [], 'path', [])
        nameArr cell = {}
        locationHistory cell = {}
    end
    
    methods
        function obj = EnvironmentManager(pathToData)
            pathToData = strrep(pathToData, '>', filesep);
            
            assert(exist(pathToData, 'file') == 2,...
                'Error: %s does not exist.', pathToData);
            
            rawEnvData = textscan(fopen(pathToData, 'r'), '%s');
            rawEnvData = rawEnvData{1};
            
            assert(strcmp(rawEnvData{1}, 'EnvironmentManager>paths'),...
                'Error: %s is not a valid header.', rawEnvData{1});
            
            rawEnvData(1) = [];
            
            obj.nameArr = cell(1, length(rawEnvData));
            obj.locationHistory{1} = 'home';
            
            for i = 1:length(rawEnvData)
                currentLine = strsplit(rawEnvData{i}, ':');
                
                assert(~any(strcmp(currentLine{1}, obj.nameArr)),...
                    'Error: %s is a repeated path name.', currentLine{1});
                
                obj.env(i).name = currentLine{1};
                obj.nameArr{i} = currentLine{1};
                
                obj.env(i).path = [cd, filesep,...
                    strrep(currentLine{2}, '>', filesep)];
                
                if obj.env(i).path(end) ~= filesep
                    obj.env(i).path = [obj.env(i).path, filesep];
                end
            end
            
            obj.env(strcmp('home', obj.nameArr)).path = [cd, filesep];
            obj.env(strcmp('back', obj.nameArr)).path =...
                obj.env(strcmp('home', obj.nameArr)).path;
            
            addpath(obj.env(strcmp('home', obj.nameArr)).path);
        end
        
        function outStr = ToPath(obj, pathname, additions)
            arguments
                obj
                pathname
            end
            arguments (Repeating)
                additions
            end
            
            sFlag = any(strcmp('-s', additions));
            additions(strcmp('-s', additions)) = [];
            
            outStr = obj.env(strcmp(pathname, obj.nameArr)).path;
            
            for i = 1:length(additions)
                outStr = [outStr, additions{i}, filesep];
            end
            
            if sFlag
                outStr(end) = [];
            end
        end
        
        function GoTo(obj, pathname)
            assert(any(strcmp(pathname, [obj.nameArr, 'back'])),...
                'Error: %s is not a valid destination.', pathname);
            
            cd(obj.env(strcmp(pathname, obj.nameArr)).path);
            
            if strcmp(pathname, 'back')
                obj.BumpBack();
            else
                obj.AddBack(pathname);
            end
        end
        
        function CloseProcedure(obj)
            rmpath(obj.env(strcmp('home', obj.nameArr)).path);
        end
    end
    
    methods (Access=private)
        function BumpBack(obj)
            obj.locationHistory(end) = [];
            
            if isempty(obj.locationHistory)
                obj.locationHistory{1} = 'home';
            end
            
            obj.env(strcmp('back', obj.nameArr)).path =...
                obj.env(strcmp(obj.locationHistory{end}, obj.nameArr)).path;
        end
        
        function AddBack(obj, pathname)
            obj.locationHistory{end + 1} = pathname;
            obj.env(strcmp('back', obj.nameArr)).path =...
                obj.env(strcmp(obj.locationHistory{end - 1},...
                obj.nameArr)).path;
        end
    end
    
    methods (Static)
        function Usage()
            fprintf(['obj = EnvironmentManager(''EnvironmentManager_',...
                'ExampleFile.txt'');\n']);
            fprintf(['%% Generate this file using EnvironmentManager.',...
                'GenerateExample();\n']);
            fprintf('%% The format must match in your version\n\n');
            fprintf('obj.GoTo(''art'');\n');
            fprintf('%% Changes current directory to .\\bin\\art\\\n');
            fprintf('obj.GoTo(''back'');\n');
            fprintf('%% Changes current directory to .\\\n');
            fprintf('obj.GoTo(''script'');\n');
            fprintf('obj.GoTo(''home'');\n');
            fprintf('%% Changes current directory to .\\\n\n');
            fprintf(['absPath = obj.ToPath(''script'', ''scriptName.m''',...
                ');\n']);
            fprintf(['%% Stores the absolute path of the file ',...
                'scriptName.m in .\\bin\\scripts\\']);
        end
        
        function GenerateExample()
            fid = fopen('EnvironmentManager_ExampleFile.txt', 'w');
            
            fprintf(fid, 'EnvironmentManager>paths\n');
            fprintf(fid, 'home: \n');
            fprintf(fid, 'back: \n');
            fprintf(fid, 'art:bin>art\n');
            fprintf(fid, 'script:bin>scripts\n');
            fprintf(fid, 'setup:bin>setup');
            
            fclose(fid);
        end
    end
end