function varargout = flySorterTraining(varargin)
% FLYSORTERTRAINING MATLAB code for flySorterTraining.fig
%      FLYSORTERTRAINING, by itself, creates a new FLYSORTERTRAINING or raises the existing
%      singleton*.
%
%      H = FLYSORTERTRAINING returns the handle to a new FLYSORTERTRAINING or the handle to
%      the existing singleton*.
%
%      FLYSORTERTRAINING('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in FLYSORTERTRAINING.M with the given input arguments.
%
%      FLYSORTERTRAINING('Property','Value',...) creates a new FLYSORTERTRAINING or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before flySorterTraining_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to flySorterTraining_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help flySorterTraining

% Last Modified by GUIDE v2.5 25-Jul-2014 13:46:58

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @flySorterTraining_OpeningFcn, ...
                   'gui_OutputFcn',  @flySorterTraining_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before flySorterTraining is made visible.
function flySorterTraining_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to flySorterTraining (see VARARGIN)

% Choose default command line output for flySorterTraining
handles.output = hObject;
handles.impl = FlySorterTrainingImpl(handles.flySorterTrainingFigure);
guidata(hObject, handles);

% UIWAIT makes flySorterTraining wait for user response (see UIRESUME)
% uiwait(handles.flySorterTrainingFigure);


% --- Outputs from this function are returned to the command line.
function varargout = flySorterTraining_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


% --- Executes on button press in jabbaPathPushButton.
function jabbaPathPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to jabbaPathPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.setJabbaPathWithGui();


% --- Executes on button press in poolEnableCheckbox.
function poolEnableCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to poolEnableCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of poolEnableCheckbox
handles.impl.onPoolEnableChange()


% --- Executes on selection change in numberOfCoresPopup.
function numberOfCoresPopup_Callback(hObject, eventdata, handles)
% hObject    handle to numberOfCoresPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns numberOfCoresPopup contents as cell array
%        contents{get(hObject,'Value')} returns selected item from numberOfCoresPopup
handles.impl.setNumberOfPoolCores()


% --- Executes during object creation, after setting all properties.
function numberOfCoresPopup_CreateFcn(hObject, eventdata, handles)
% hObject    handle to numberOfCoresPopup (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in generateClassifiersPushButton.
function generateClassifiersPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to generateClassifiersPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.generateClassifierFiles()


% --- Executes on button press in generateJsonConfigPushButton.
function generateJsonConfigPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to generateJsonConfigPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.generateJsonConfigFiles()


% --- Executes on button press in userClassifierClearPushButton.
function userClassifierClearPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to userClassifierClearPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.clearUserClassifierTraining()


% --- Executes on button press in userClassifierRunPushButton.
function userClassifierRunPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to userClassifierRunPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.runUserClassifierTraining()


% --- Executes on button press in orientationRunPushButton.
function orientationRunPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to orientationRunPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.runOrientationTraining();


% --- Executes on button press in orientationClearPushButton.
function orientationClearPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to orientationClearPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.clearOrientationTraining();


% --- Executes on button press in clearPreProcessingPushButton.
function clearPreProcessingPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearPreProcessingPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.clearPreProcessing();


% --- Executes on button press in runPreProcessingPushButton.
function runPreProcessingPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to runPreProcessingPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.runPreProcessing();


% --- Executes on button press in selectDataPushButton.
function selectDataPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectDataPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.selectTrainingData();


% --- Executes on button press in clearTrainingDataPushButton.
function clearTrainingDataPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to clearTrainingDataPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.clearTraingingData()


% --- Executes when user attempts to close flySorterTrainingFigure.
function flySorterTrainingFigure_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to flySorterTrainingFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% Hint: delete(hObject) closes the figure
delete(hObject);



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function jabbaPathEditText_Callback(hObject, eventdata, handles)
% hObject    handle to jabbaPathEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of jabbaPathEditText as text
%        str2double(get(hObject,'String')) returns contents of jabbaPathEditText as a double


% --- Executes during object creation, after setting all properties.
function jabbaPathEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to jabbaPathEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in filePreProcessingPushButton.
function filePreProcessingPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to filePreProcessingPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in fileOrientationTrainingPushButton.
function fileOrientationTrainingPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to fileOrientationTrainingPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in orientationHintCheckbox.
function orientationHintCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to orientationHintCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of orientationHintCheckbox
handles.impl.onOutFileNameChange();


% --- Executes on button press in orientationHintFilePushButton.
function orientationHintFilePushButton_Callback(hObject, eventdata, handles)
% hObject    handle to orientationHintFilePushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton32.
function pushbutton32_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton32 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


function filePrefixEditText_Callback(hObject, eventdata, handles)
% hObject    handle to filePrefixEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of filePrefixEditText as text
%        str2double(get(hObject,'String')) returns contents of filePrefixEditText as a double
handles.impl.onOutFileNameChange();


% --- Executes during object creation, after setting all properties.
function filePrefixEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to filePrefixEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in filePrefixCheckbox.
function filePrefixCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to filePrefixCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of filePrefixCheckbox
handles.impl.onOutFileNameChange();


% --- Executes on button press in autoIncrementCheckbox.
function autoIncrementCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to autoIncrementCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of autoIncrementCheckbox
handles.impl.onOutFileNameChange();


% --- Executes on button press in addDatetimeCheckbox.
function addDatetimeCheckbox_Callback(hObject, eventdata, handles)
% hObject    handle to addDatetimeCheckbox (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of addDatetimeCheckbox
handles.impl.onOutFileNameChange();


function workingDirEditText_Callback(hObject, eventdata, handles)
% hObject    handle to workingDirEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of workingDirEditText as text
%        str2double(get(hObject,'String')) returns contents of workingDirEditText as a double


% --- Executes during object creation, after setting all properties.
function workingDirEditText_CreateFcn(hObject, eventdata, handles)
% hObject    handle to workingDirEditText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in workingDirPushButton.
function workingDirPushButton_Callback(hObject, eventdata, handles)
% hObject    handle to workingDirPushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.setWorkingDirWithGui();


% --- Executes during object deletion, before destroying properties.
function flySorterTrainingFigure_DeleteFcn(hObject, eventdata, handles)
% hObject    handle to flySorterTrainingFigure (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

handles.impl.delete()  % delete before figure is detroyed - as we need
                       % data from graphics objects to save state.


% --- Executes on button press in nowDatetimePushButton.
function nowDatetimePushButton_Callback(hObject, eventdata, handles)
% hObject    handle to nowDatetimePushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.setDatetimeToNow();


% --- Executes on button press in selectDateTimePushButton.
function selectDateTimePushButton_Callback(hObject, eventdata, handles)
% hObject    handle to selectDateTimePushButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles.impl.setDatetimeWithGui();
