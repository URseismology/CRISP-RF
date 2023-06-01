function [Result] = Matlab_TauP(Mode,modelName,eventDepth,phaseNames,varargin)

% function Matlab_TauP
%
% Arguments
% ---------
% Mode          TauP operation to perform: 'Time' | 'Path' | 'Pierce'
% modelName     Name of Tau model to be used, which my be built-in, read-in
%               from a .taup file (see the 'modelPath' extended argument),
%               or passed-in as a TauModel object (see the 'TauModel'
%               extended argument)
% eventDepth    Depth of event in km
% phaseNames    Cell array of phase names, ex: {'P','S','P660s'}. An empty
%               cell array {} is implies the following suite of phases:
%               {'p','s','P','S','Pn','Sn','PcP','ScS','Pdiff','Sdiff', ...
%                'PKP','SKS','PKiKP','SKiKS','PKIKP','SKIKS'}
%
% Extended Argument Tuples
% ------------------------
% 'evt'         Event location, supply: [latitude longitude]
%                   ex: ... ,'evt',[11.3 -85.9], ...
% 'sta'         Station location, supply: [latitude longitude]
%                   ex: ... ,'sta',[11.3 -85.9], ...
% 'deg'         Event-station angular distance, supply: degrees
%                   ex: ... ,'deg',60, ...
% 'modelPath'   Path to .taup file associated with modelName, 
%               supply: character array containing path
%                   ex: ... ,'modelPath','/path/to/model/file/', ...
% 'TauModel'    TauModel object associated with modelName, 
%               supply: a valid TauModel object, such as one constructed
%               with Matlab_TauP_Create
%                   ex: ... ,'TauModel',myTauModel, ...
%
% Returns
% -------
% Essentially identical structure (array) as matTaup

% Import the TauP package
import edu.sc.seis.TauP.*

% Our arguments will always exist in pairs
if mod(length(varargin),2) == 0

    % Walk varargin for the event and station locations, as well as a
    % specified .taup model directory
    nstdargs = 4;
    for argument=1:2:nargin-nstdargs
        switch varargin{argument}
            case {'evt'}
                eventLocation = varargin{argument+1};
            case {'sta'}
                stationLocation = varargin{argument+1};
            case {'deg'}
                deltaDistance = varargin{argument+1};
            case {'modelPath'}
                modelPath = varargin{argument+1};
            case {'TauModel'}
                MyModel = varargin{argument+1};
            otherwise
                fprintf('\nWarning: unsupported argument %s ignored\n\n',varargin{argument});
        end
    end
    
    % Parse geographic reference
    if exist('deltaDistance','var')
        geographicReference.type = 'General';
        geographicReference.deltaDistance = deltaDistance;
        if exist('stationLocation','var') && exist('eventLocation','var')
            fprintf('\nWarning: redundant specification of evt / sta and deg; evt / sta ignored!\n\n');
        end
    elseif exist('stationLocation','var') && exist('eventLocation','var')
        geographicReference.type = 'Specific';
        geographicReference.stationLocation = stationLocation;
        geographicReference.eventLocation   = eventLocation;
    else
        fprintf('\nError: you must specificy one of evt / sta or deg!\n\n');
        Result = [];
        return
    end
    
    % Allow a zero-length phase specification to imply all phases
    if isempty(phaseNames)
        TauP_All_Phases = ...
            {'p','s','P','S','Pn','Sn','PcP','ScS', ...
            'Pdiff','Sdiff','PKP','SKS','PKiKP','SKiKS','PKIKP','SKIKS'};
        phaseNames = TauP_All_Phases;
    end

    % Assign a TauModel object for our supplied TauModel object, specified 
    % model file, or simply pass a string containing the name of what is 
    % assumed to be a standard model
    if exist('modelPath','var') && exist('MyModel','var')
        fprintf('Warning: both modelPath and TauModel options specified!\n');
        fprintf('         IGNORING THE FORMER!\n');
        clear modelPath
    else
        if exist('MyModel','var')
            if ~ strcmp(class(MyModel),'edu.sc.seis.TauP.TauModel')
                fprintf('Error: the supplied object is not a TauModel!\n');
                clear MyModel
            else
                if ~ MyModel.validate()
                    fprintf('Error: the supplied TauModel is *not* valid!\n');
                    clear MyModel
                else
                    if ~ strcmp(MyModel.getModelName(),modelName)
                        fprintf('Error: incorrect TauModel supplied for %s!\n',modelName);
                        clear MyModel
                    end
                end
            end
        elseif exist('modelPath','var')
            if ~ exist([modelPath '/' modelName '.taup'],'file')
                fprintf('Error: %s does not exist!\n',[modelPath '/' modelName '.taup']);
                clear MyModel
            else
                MyModel = TauModelLoader.load(modelName,modelPath);
            end
        else
            MyModel = modelName;
        end
    end

    if exist('MyModel','var')

        % Call the appropriate driver function
        if strcmp(Mode,'Time')
            Result = Matlab_TauP_Time(eventDepth,geographicReference,phaseNames,MyModel);
        elseif strcmp(Mode,'Pierce')
            Result = Matlab_TauP_Pierce(eventDepth,geographicReference,phaseNames,MyModel);
        elseif strcmp(Mode,'Path')
            Result = Matlab_TauP_Path(eventDepth,geographicReference,phaseNames,MyModel);
        else
            fprintf('\nError: unsupported mode %s\n\n',Mode);
            Result = [];
        end

    else
        
        Result = [];
        
    end
else
    fprintf('\nError: invalid number of arguments\n\n');
    Result = [];
end

    function [ArrivalTimes] = Matlab_TauP_Time(eventDepth,geographicReference,phaseNames,MyModel)

        % Import the TauP package
        import edu.sc.seis.TauP.*

        % Create a TauP_Time object
        myTauP_Time = TauP_Time(MyModel);

        % Depending on geographic reference ...
        if strcmp(geographicReference.type,'General')
            % Accept the user's specification for event-station angular
            % distance
            eventDistance = geographicReference.deltaDistance;
        else
            % Calculate the event-station angular distance and azimuths
            eventDistance       = SphericalCoords.distance(eventLocation(1),eventLocation(2),stationLocation(1),stationLocation(2));
            eventAzimuth        = SphericalCoords.azimuth(eventLocation(1),eventLocation(2),stationLocation(1),stationLocation(2));
            eventBackAzimuth    = SphericalCoords.azimuth(stationLocation(1),stationLocation(2),eventLocation(1),eventLocation(2));
        end

        % Set the event depth correction and phase names
        myTauP_Time.setSourceDepth(eventDepth);
        myTauP_Time.setPhaseNames(phaseNames);

        % Calculate travel times for the specified event depth / phase /
        % angular distance triple
        myTauP_Time.calculate(eventDistance);

        % Walk the arrivals and store the results
        ArrivalTimes = [];
        for arrival=1:myTauP_Time.getNumArrivals()
            myArrival = myTauP_Time.getArrival(arrival - 1);
            ArrivalTimes(arrival).time      = myArrival.getTime();
            ArrivalTimes(arrival).distance  = myArrival.getDistDeg();
            ArrivalTimes(arrival).srcDepth  = myArrival.getSourceDepth();
            ArrivalTimes(arrival).rayParam  = myArrival.getRayParam();
            ArrivalTimes(arrival).phaseName = char(myArrival.getPuristName());
            if ~ strcmp(geographicReference.type,'General')
            	ArrivalTimes(arrival).azimuth   = eventAzimuth;
                ArrivalTimes(arrival).bAzimuth  = eventBackAzimuth;
            end
            clear myArrival
        end

        clear MyModel myTauP_Time
    end

    function [PiercePoints] = Matlab_TauP_Pierce(eventDepth,geographicReference,phaseNames,MyModel)

        % Load the TauP package
        import edu.sc.seis.TauP.*

        % Create a TauP_Pierce object
        myTauP_Pierce = TauP_Pierce(MyModel);

        % Depending on geographic reference ...
        if strcmp(geographicReference.type,'General')
            % Accept the user's specification for event-station angular
            % distance
            eventDistance = geographicReference.deltaDistance;
        else
            % Calculate the event-station angular distance and azimuths
            eventDistance       = SphericalCoords.distance(eventLocation(1),eventLocation(2),stationLocation(1),stationLocation(2));
            eventAzimuth        = SphericalCoords.azimuth(eventLocation(1),eventLocation(2),stationLocation(1),stationLocation(2));
            eventBackAzimuth    = SphericalCoords.azimuth(stationLocation(1),stationLocation(2),eventLocation(1),eventLocation(2));
        end
        
        % Set the event depth correction and phase names
        myTauP_Pierce.setSourceDepth(eventDepth);
        myTauP_Pierce.setPhaseNames(phaseNames);

        % Calculate discontinuity piercing points along the raypath for the
        % specified event depth / phase / angular distance triple
        myTauP_Pierce.calculate(eventDistance);

        % Walk the arrivals and store the results, converting
        % depth / angular distance tuples to latitude and longitude
        PiercePoints = [];
        for arrival=1:myTauP_Pierce.getNumArrivals()
            myArrival = myTauP_Pierce.getArrival(arrival - 1);
            PiercePoints(arrival).time      = myArrival.getTime();
            PiercePoints(arrival).distance  = myArrival.getDistDeg();
            PiercePoints(arrival).srcDepth  = myArrival.getSourceDepth();
            PiercePoints(arrival).rayParam  = myArrival.getRayParam();
            PiercePoints(arrival).phaseName = char(myArrival.getPuristName());
            myPiercePoints = myArrival.getPierce();
            for point=1:length(myPiercePoints)
                PiercePoints(arrival).pierce.p(point,1)         = myPiercePoints(point).p;
                PiercePoints(arrival).pierce.time(point,1)      = myPiercePoints(point).time;
                PiercePoints(arrival).pierce.distance(point,1)  = 180.0 * myPiercePoints(point).distRadian / pi;
                PiercePoints(arrival).pierce.depth(point,1)     = myPiercePoints(point).depth;
            end
            if ~ strcmp(geographicReference.type,'General')
                PiercePoints(arrival).azimuth   = eventAzimuth;
                PiercePoints(arrival).bAzimuth  = eventBackAzimuth;
                for point=1:length(myPiercePoints)
                    PiercePoints(arrival).pierce.latitude(point,1)  = ...
                        SphericalCoords.latFor(eventLocation(1),eventLocation(2), ...
                        180.0 * myPiercePoints(point).distRadian / pi,eventAzimuth);
                    PiercePoints(arrival).pierce.longitude(point,1) = ...
                        SphericalCoords.lonFor(eventLocation(1),eventLocation(2), ...
                        180.0 * myPiercePoints(point).distRadian / pi,eventAzimuth);
                end
            end
            clear myArrival
        end
        
        clear MyModel myTauP_Pierce
    end

    function [PathPoints] = Matlab_TauP_Path(eventDepth,geographicReference,phaseNames,MyModel)

        % Load the TauP package
        import edu.sc.seis.TauP.*

        % Create a TauP_Path object
        myTauP_Path = TauP_Path(MyModel);

        % Depending on geographic reference ...
        if strcmp(geographicReference.type,'General')
            % Accept the user's specification for event-station angular
            % distance
            eventDistance = geographicReference.deltaDistance;
        else
            % Calculate the event-station angular distance and azimuths
            eventDistance       = SphericalCoords.distance(eventLocation(1),eventLocation(2),stationLocation(1),stationLocation(2));
            eventAzimuth        = SphericalCoords.azimuth(eventLocation(1),eventLocation(2),stationLocation(1),stationLocation(2));
            eventBackAzimuth    = SphericalCoords.azimuth(stationLocation(1),stationLocation(2),eventLocation(1),eventLocation(2));
        end
        
        % Set the event depth correction and phase names
        myTauP_Path.setSourceDepth(eventDepth);
        myTauP_Path.setPhaseNames(phaseNames);

        % Calculate regularly spaced points along the raypat for the
        % specified event depth / phase / angular distance triple
        myTauP_Path.calculate(eventDistance);

        % Walk the arrivals and store the results, converting
        % depth / angular distance tuples to latitude and longitude
        PathPoints = [];
        for arrival=1:myTauP_Path.getNumArrivals()
            myArrival = myTauP_Path.getArrival(arrival - 1);
            PathPoints(arrival).time      = myArrival.getTime();
            PathPoints(arrival).distance  = myArrival.getDistDeg();
            PathPoints(arrival).srcDepth  = myArrival.getSourceDepth();
            PathPoints(arrival).rayParam  = myArrival.getRayParam();
            PathPoints(arrival).phaseName = char(myArrival.getPuristName());
            myPathPoints = myArrival.getPath();
            for point=1:length(myPathPoints)
                PathPoints(arrival).path.p(point,1)         = myPathPoints(point).p;
                PathPoints(arrival).path.time(point,1)      = myPathPoints(point).time;
                PathPoints(arrival).path.distance(point,1)  = 180.0 * myPathPoints(point).distRadian / pi;
                PathPoints(arrival).path.depth(point,1)     = myPathPoints(point).depth;
            end
            if ~ strcmp(geographicReference.type,'General')
                PathPoints(arrival).azimuth   = eventAzimuth;
                PathPoints(arrival).bAzimuth  = eventBackAzimuth;
                for point=1:length(myPathPoints)
                    PathPoints(arrival).path.latitude(point,1)  = ...
                        SphericalCoords.latFor(eventLocation(1),eventLocation(2), ...
                        180.0 * myPathPoints(point).distRadian / pi,eventAzimuth);
                    PathPoints(arrival).path.longitude(point,1) = ...
                        SphericalCoords.lonFor(eventLocation(1),eventLocation(2), ...
                        180.0 * myPathPoints(point).distRadian / pi,eventAzimuth);
                end
            end
            clear myArrival
        end

        clear MyModel myTauP_Path
    end

end
