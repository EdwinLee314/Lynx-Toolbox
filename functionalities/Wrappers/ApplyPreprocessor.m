% ApplyPreprocessor - Apply a Preprocessor to the data before training
%   Using this wrapper, you can fine-tune the parameters of a preprocessor.
%   For example, you can apply a PCA to the data:
%
%   add_wrapper(id, @ApplyPreprocessor, @PrincipalComponentAnalysis);
%
%   Then you can optimize the number of principal components to keep:
%
%   add_wrapper(id, @ParameterSweep, {'varianceToPreserve'}, {0.1:0.9});
%
% See also Wrapper, Preprocessor

% License to use and modify this code is granted freely without warranty to all, as long as the original author is
% referenced and attributed as such. The original author maintains the right to be solely associated with this work.
%
% Programmed and Copyright by Simone Scardapane:
% simone.scardapane@uniroma1.it

classdef ApplyPreprocessor <  Wrapper
    
    properties
    end
    
    methods
        
        function obj = ApplyPreprocessor(wrappedAlgo, varargin)
            obj = obj@Wrapper(wrappedAlgo, varargin{1});
            if(~isa(obj.parameters.preprocessor(), 'Preprocessor'))
                error('Lynx:Runtime:InvalidParameter', 'The first parameter of ApplyPreprocessor must be a valid preprocessor');
            end
            obj.parameters.preprocessor = obj.parameters.preprocessor(varargin{2:end});
        end
        
        function p = initParameters(~, p)
            p.addRequired('preprocessor');
        end

        function obj = train(obj, Xtr, Ytr)
            d = Dataset.generateAnonymousDataset(obj.getCurrentTask(), Xtr, Ytr);
            [~, d, obj.parameters.preprocessor] = evalc('obj.parameters.preprocessor.process(d)'); % Silence the preprocessor
            obj.wrappedAlgo = obj.wrappedAlgo.train(d.X, d.Y);
        end
        
        function [labels, scores] = test_custom(obj, Xts)
            d = Dataset.generateAnonymousDataset(obj.getCurrentTask(), Xts, ones(size(Xts, 1), 1));
            [~, d] = evalc('obj.parameters.preprocessor.processAsBefore(d)'); % Silence the preprocessor
            [labels, scores] = obj.wrappedAlgo.test(d.X);
        end
        
        function b = hasCustomTesting(obj)
            b = true;
        end
        
        function value = getParameter(obj, param)
            try
                value = obj.parameters.preprocessor.getParameter(param);
            catch
                value = obj.wrappedAlgo.getParameter(param);
            end
        end
        
        function obj = setParameter(obj, param, value)
            try
                obj.parameters.preprocessor = obj.parameters.preprocessor.setParameter(param, value);
            catch
                obj.wrappedAlgo = obj.wrappedAlgo.setParameter(param, value);
            end
        end
        
        function tp = getParameters(obj)
            warning('off', 'catstruct:DuplicatesFound');
            tp = catstruct(obj.parameters.preprocessor.parameters, obj.getParameters@Wrapper());
        end
        
    end
    
    methods(Static)
        function info = getDescription()
            info = 'Apply a Preprocessor to the data before training and testing';
        end
        
        function pNames = getParametersNames()
            pNames = {'preprocessor', 'varargin'}; 
        end
        
        function pInfo = getParametersDescription()
            pInfo = {'Preprocessor to apply', 'Parameters for the preprocessor'};
        end
        
        function pRange = getParametersRange()
            pRange = {'An object of class Preprocessor', 'Variable, depends on the Preprocessor'};
        end
    end
    
end
