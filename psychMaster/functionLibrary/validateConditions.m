function [ conditionInfo ] = validateConditions( conditionInfo )
%validateConditions Ensures that conditionInfo has required fields
%   This function checks to see if all required fields are set in each
%   condition.  If not it sets things to a default value 


%list of required fields and default values:
fieldListCommon = {...
'iti',2;...
'nReps',1;...
'type','generic';...
'giveFeedback',false;...
'giveAudioFeedback',false;...
'intervalBeep', false;...
'label',[],...
};  

fieldList2afc = {...
'nullCondition',[];...
'isNullCorrect',false;...
'responseDuration',3;...
};

fieldListSimpleResponse = {...
'responseDuration',3;...
 };


nCond  = length(conditionInfo);


%check each condition. 
for iCond = 1:nCond,

    
    checkFields(iCond,fieldListCommon)
    
    
    %validate 2afc specific fields
    if strcmp(lower(conditionInfo(iCond).type),'2afc')
        
        checkFields(iCond,fieldList2afc)
        
    end
    
    %validate simpleResponse specific fields
    if strcmp(lower(conditionInfo(iCond).type),'simpleresponse')
        
        checkFields(iCond,fieldListSimpleResponse)
        
    end
    
    
end





%Nested function to check the structure. NOTE: Nested functions have access
%to the whole function workspace. 
function checkFields(iCond,fieldList)

nField = size(fieldList,1);
    for iField = 1:nField,
        
        if ~isfield(conditionInfo(iCond),fieldList{iField,1})
            disp(['Condition structure is missing field: "' fieldList{iField,1} '"'...
                ' setting to default value: "' num2str(fieldList{iField,2}) '"']);
           conditionInfo(iCond).(fieldList{iField,1}) = fieldList{iField,2};
        elseif isempty(conditionInfo(iCond).(fieldList{iField,1}))
            conditionInfo(iCond).(fieldList{iField,1}) = fieldList{iField,2};
        end
    end
end

end



