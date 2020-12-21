classdef GUI1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                  matlab.ui.Figure
        SliderLabel               matlab.ui.control.Label
        Slider                    matlab.ui.control.Slider
        Slider_2Label             matlab.ui.control.Label
        Slider_2                  matlab.ui.control.Slider
        ChoosefolderButton        matlab.ui.control.Button
        TimesLabel                matlab.ui.control.Label
        TimeField                 matlab.ui.control.NumericEditField
        Label                     matlab.ui.control.Label
        FilePath                  matlab.ui.control.EditField
        EnergyusedfromVmaxWhEditFieldLabel  matlab.ui.control.Label
        EnergyVmaxField           matlab.ui.control.NumericEditField
        AvgpowerfromVmaxWLabel    matlab.ui.control.Label
        AvgPowerVmaxField         matlab.ui.control.NumericEditField
        PeakpowerfromVmaxWEditFieldLabel  matlab.ui.control.Label
        PeakPowerVmaxField        matlab.ui.control.NumericEditField
        AhEditFieldLabel          matlab.ui.control.Label
        AhField                   matlab.ui.control.NumericEditField
        MaxAEditFieldLabel        matlab.ui.control.Label
        MaxAField                 matlab.ui.control.NumericEditField
        MaxVEditFieldLabel        matlab.ui.control.Label
        MaxVField                 matlab.ui.control.NumericEditField
        AhMaxVWhEditFieldLabel    matlab.ui.control.Label
        AhMaxVWhField             matlab.ui.control.NumericEditField
        EnergyusedfromVolWhLabel  matlab.ui.control.Label
        EnergyVolField            matlab.ui.control.NumericEditField
        AvgpowerfromVolWLabel     matlab.ui.control.Label
        AvgPowerVolField          matlab.ui.control.NumericEditField
        PeakpowerfromVolWLabel    matlab.ui.control.Label
        PeakPowerVolField         matlab.ui.control.NumericEditField
        AxesFullData              matlab.ui.control.UIAxes
        AxesChosenData            matlab.ui.control.UIAxes
        AxesVoltages              matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        filenamesToRead = ["_TEL_HVBMS_CURR.txt", "_TEL_HVBMS_MAXCVOLT.txt", "_TEL_HVBMS_MINCVOLT.txt", "_TEL_HVBMS_VOLT.txt"]% Files with what endings that need to be read, in that order
        sFolderPath%='/home/jacek/Dokumenty/Matlab/Testy LEM MotoPark/lem_logi_motopark_30102020/20201030_092123662678_decoded' % Initial value set for quick testing on my PC only
        val % contains values read from sensors and converted to double, in order of filenamesToRead
        times % time of each datapoint, converted to miliseconds
    end
    
    methods (Access = private)
        
        function updatePlotsAndCalculations(app)
            plot(app.AxesFullData, app.times, app.val(:,1), 'k')
            hold(app.AxesFullData, 'on')
            plot(app.AxesFullData, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1))
            hold(app.AxesFullData, 'off')
            app.TimeField.Value=(app.times(app.Slider_2.Value)-app.times(app.Slider.Value))/1000;
            plot(app.AxesChosenData, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1))
            plot(app.AxesVoltages, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,2:3))
            
            if app.val(1, 4)
                hold(app.AxesVoltages, 'on')
                plot(app.AxesVoltages, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,4)/102)
                hold(app.AxesVoltages, 'off')
                [wv, pv]=calculateEnergy(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1), app.val(app.Slider.Value:app.Slider_2.Value,4));
                app.EnergyVolField.Value=wv;
                app.PeakPowerVolField.Value=pv;
                app.AvgPowerVolField.Value=app.EnergyVolField.Value/app.TimeField.Value*3600;
            end
            %calculate energies
            [app.AhField.Value, app.MaxAField.Value]=calculateCurrent(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1));
            app.MaxVField.Value=max(app.val(app.Slider.Value:app.Slider_2.Value, 2));
            app.AhMaxVWhField.Value=app.AhField.Value*app.MaxVField.Value*102;
            [wm, pm]=calculateEnergy(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1), app.val(app.Slider.Value:app.Slider_2.Value,2));
            app.EnergyVmaxField.Value=102*wm;
            app.PeakPowerVmaxField.Value=102*pm;
            app.AvgPowerVmaxField.Value=app.EnergyVmaxField.Value/app.TimeField.Value*3600;
        end
    end
    

    % Callbacks that handle component events
    methods (Access = private)

        % Code that executes after component creation
        function startupFcn(app)
            clear
            clc
        end

        % Button pushed function: ChoosefolderButton
        function ChoosefolderButtonPushed(app, event)
            if(exist(app.sFolderPath,'file'))
                app.sFolderPath=uigetdir(app.sFolderPath);
            else
                app.sFolderPath=uigetdir();
            end
            app.FilePath.Value=app.sFolderPath;
            app.ChoosefolderButton.BackgroundColor=[1, 0, 0]; %change to red until it hasn't finished reading files
            drawnow;
            [oTimestamps, app.times, app.val] = readSensorsInFolder(app.filenamesToRead, app.sFolderPath);
            app.ChoosefolderButton.BackgroundColor=[1, 1, 1];
            drawnow;
            app.Slider.Limits = [1,length(oTimestamps)];
            app.Slider_2.Limits = [1,length(oTimestamps)];
            app.Slider.Value = 1;
            app.Slider_2.Value = length(oTimestamps);
            %calculate energies and update plots
            updatePlotsAndCalculations(app)
        end

        % Value changed function: Slider_2
        function Slider_2ValueChanged(app, event)
            app.Slider_2.Value = round(app.Slider_2.Value);
            if app.Slider_2.Value < app.Slider.Value
                app.Slider.Value = app.Slider_2.Value - 3;
            end
            updatePlotsAndCalculations(app)
        end

        % Value changed function: Slider
        function SliderValueChanged(app, event)
            app.Slider.Value = round(app.Slider.Value);
            if app.Slider_2.Value < app.Slider.Value
                app.Slider_2.Value = app.Slider.Value + 3;
            end
            updatePlotsAndCalculations(app)
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 610 505];
            app.UIFigure.Name = 'MATLAB App';

            % Create SliderLabel
            app.SliderLabel = uilabel(app.UIFigure);
            app.SliderLabel.HorizontalAlignment = 'right';
            app.SliderLabel.Position = [311 284 25 22];
            app.SliderLabel.Text = '';

            % Create Slider
            app.Slider = uislider(app.UIFigure);
            app.Slider.ValueChangedFcn = createCallbackFcn(app, @SliderValueChanged, true);
            app.Slider.Position = [357 293 238 3];

            % Create Slider_2Label
            app.Slider_2Label = uilabel(app.UIFigure);
            app.Slider_2Label.HorizontalAlignment = 'right';
            app.Slider_2Label.Position = [311 240 25 22];
            app.Slider_2Label.Text = '';

            % Create Slider_2
            app.Slider_2 = uislider(app.UIFigure);
            app.Slider_2.ValueChangedFcn = createCallbackFcn(app, @Slider_2ValueChanged, true);
            app.Slider_2.Position = [357 249 239 3];

            % Create ChoosefolderButton
            app.ChoosefolderButton = uibutton(app.UIFigure, 'push');
            app.ChoosefolderButton.ButtonPushedFcn = createCallbackFcn(app, @ChoosefolderButtonPushed, true);
            app.ChoosefolderButton.Position = [22 467 97 25];
            app.ChoosefolderButton.Text = 'Choose folder';

            % Create TimesLabel
            app.TimesLabel = uilabel(app.UIFigure);
            app.TimesLabel.BackgroundColor = [1 1 1];
            app.TimesLabel.HorizontalAlignment = 'right';
            app.TimesLabel.Position = [8 434 50 22];
            app.TimesLabel.Text = 'Time [s]';

            % Create TimeField
            app.TimeField = uieditfield(app.UIFigure, 'numeric');
            app.TimeField.Editable = 'off';
            app.TimeField.Position = [61 434 48 22];

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [127 469 25 22];
            app.Label.Text = '';

            % Create FilePath
            app.FilePath = uieditfield(app.UIFigure, 'text');
            app.FilePath.Editable = 'off';
            app.FilePath.Position = [126 469 168 22];

            % Create EnergyusedfromVmaxWhEditFieldLabel
            app.EnergyusedfromVmaxWhEditFieldLabel = uilabel(app.UIFigure);
            app.EnergyusedfromVmaxWhEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergyusedfromVmaxWhEditFieldLabel.Position = [11 343 161 23];
            app.EnergyusedfromVmaxWhEditFieldLabel.Text = 'Energy used from Vmax [Wh]';

            % Create EnergyVmaxField
            app.EnergyVmaxField = uieditfield(app.UIFigure, 'numeric');
            app.EnergyVmaxField.ValueDisplayFormat = '%7.2f';
            app.EnergyVmaxField.Editable = 'off';
            app.EnergyVmaxField.Position = [180 344 110 22];

            % Create AvgpowerfromVmaxWLabel
            app.AvgpowerfromVmaxWLabel = uilabel(app.UIFigure);
            app.AvgpowerfromVmaxWLabel.HorizontalAlignment = 'right';
            app.AvgpowerfromVmaxWLabel.Position = [12 315 146 22];
            app.AvgpowerfromVmaxWLabel.Text = 'Avg power from Vmax [W]';

            % Create AvgPowerVmaxField
            app.AvgPowerVmaxField = uieditfield(app.UIFigure, 'numeric');
            app.AvgPowerVmaxField.ValueDisplayFormat = '%7.2f';
            app.AvgPowerVmaxField.Editable = 'off';
            app.AvgPowerVmaxField.Position = [182 315 109 22];

            % Create PeakpowerfromVmaxWEditFieldLabel
            app.PeakpowerfromVmaxWEditFieldLabel = uilabel(app.UIFigure);
            app.PeakpowerfromVmaxWEditFieldLabel.HorizontalAlignment = 'right';
            app.PeakpowerfromVmaxWEditFieldLabel.Position = [11 284 151 22];
            app.PeakpowerfromVmaxWEditFieldLabel.Text = 'Peak power from Vmax [W]';

            % Create PeakPowerVmaxField
            app.PeakPowerVmaxField = uieditfield(app.UIFigure, 'numeric');
            app.PeakPowerVmaxField.ValueDisplayFormat = '%7.2f';
            app.PeakPowerVmaxField.Editable = 'off';
            app.PeakPowerVmaxField.Position = [181 284 110 22];

            % Create AhEditFieldLabel
            app.AhEditFieldLabel = uilabel(app.UIFigure);
            app.AhEditFieldLabel.HorizontalAlignment = 'right';
            app.AhEditFieldLabel.Position = [1 404 29 22];
            app.AhEditFieldLabel.Text = '[Ah]';

            % Create AhField
            app.AhField = uieditfield(app.UIFigure, 'numeric');
            app.AhField.Editable = 'off';
            app.AhField.Position = [111 404 70 22];

            % Create MaxAEditFieldLabel
            app.MaxAEditFieldLabel = uilabel(app.UIFigure);
            app.MaxAEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxAEditFieldLabel.Position = [179 404 47 22];
            app.MaxAEditFieldLabel.Text = 'Max [A]';

            % Create MaxAField
            app.MaxAField = uieditfield(app.UIFigure, 'numeric');
            app.MaxAField.Editable = 'off';
            app.MaxAField.Position = [241 404 50 22];

            % Create MaxVEditFieldLabel
            app.MaxVEditFieldLabel = uilabel(app.UIFigure);
            app.MaxVEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxVEditFieldLabel.Position = [180 374 47 22];
            app.MaxVEditFieldLabel.Text = 'Max [V]';

            % Create MaxVField
            app.MaxVField = uieditfield(app.UIFigure, 'numeric');
            app.MaxVField.Editable = 'off';
            app.MaxVField.Position = [242 374 49 22];

            % Create AhMaxVWhEditFieldLabel
            app.AhMaxVWhEditFieldLabel = uilabel(app.UIFigure);
            app.AhMaxVWhEditFieldLabel.HorizontalAlignment = 'right';
            app.AhMaxVWhEditFieldLabel.Position = [1 374 89 22];
            app.AhMaxVWhEditFieldLabel.Text = '[Ah*MaxV=Wh]';

            % Create AhMaxVWhField
            app.AhMaxVWhField = uieditfield(app.UIFigure, 'numeric');
            app.AhMaxVWhField.Editable = 'off';
            app.AhMaxVWhField.Position = [111 374 69 22];

            % Create EnergyusedfromVolWhLabel
            app.EnergyusedfromVolWhLabel = uilabel(app.UIFigure);
            app.EnergyusedfromVolWhLabel.HorizontalAlignment = 'right';
            app.EnergyusedfromVolWhLabel.Position = [11 253 150 23];
            app.EnergyusedfromVolWhLabel.Text = 'Energy used from Vol [Wh]';

            % Create EnergyVolField
            app.EnergyVolField = uieditfield(app.UIFigure, 'numeric');
            app.EnergyVolField.ValueDisplayFormat = '%7.2f';
            app.EnergyVolField.Editable = 'off';
            app.EnergyVolField.Position = [181 254 109 22];

            % Create AvgpowerfromVolWLabel
            app.AvgpowerfromVolWLabel = uilabel(app.UIFigure);
            app.AvgpowerfromVolWLabel.HorizontalAlignment = 'right';
            app.AvgpowerfromVolWLabel.Position = [11 224 133 22];
            app.AvgpowerfromVolWLabel.Text = 'Avg power from Vol [W]';

            % Create AvgPowerVolField
            app.AvgPowerVolField = uieditfield(app.UIFigure, 'numeric');
            app.AvgPowerVolField.ValueDisplayFormat = '%7.2f';
            app.AvgPowerVolField.Editable = 'off';
            app.AvgPowerVolField.Position = [181 224 110 22];

            % Create PeakpowerfromVolWLabel
            app.PeakpowerfromVolWLabel = uilabel(app.UIFigure);
            app.PeakpowerfromVolWLabel.HorizontalAlignment = 'right';
            app.PeakpowerfromVolWLabel.Position = [11 194 139 22];
            app.PeakpowerfromVolWLabel.Text = 'Peak power from Vol [W]';

            % Create PeakPowerVolField
            app.PeakPowerVolField = uieditfield(app.UIFigure, 'numeric');
            app.PeakPowerVolField.ValueDisplayFormat = '%7.2f';
            app.PeakPowerVolField.Editable = 'off';
            app.PeakPowerVolField.Position = [181 194 110 22];

            % Create AxesFullData
            app.AxesFullData = uiaxes(app.UIFigure);
            title(app.AxesFullData, 'Current - all data points')
            xlabel(app.AxesFullData, 'Time [ms]')
            ylabel(app.AxesFullData, '[A]')
            zlabel(app.AxesFullData, 'Z')
            app.AxesFullData.Position = [311 321 300 185];

            % Create AxesChosenData
            app.AxesChosenData = uiaxes(app.UIFigure);
            title(app.AxesChosenData, 'Current')
            xlabel(app.AxesChosenData, 'Time [ms]')
            ylabel(app.AxesChosenData, '[A]')
            zlabel(app.AxesChosenData, 'Z')
            app.AxesChosenData.Position = [311 1 300 185];

            % Create AxesVoltages
            app.AxesVoltages = uiaxes(app.UIFigure);
            title(app.AxesVoltages, 'Voltages')
            xlabel(app.AxesVoltages, 'Time [ms]')
            ylabel(app.AxesVoltages, '[V]')
            zlabel(app.AxesVoltages, 'Z')
            app.AxesVoltages.Position = [1 1 300 185];

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = GUI1

            % Create UIFigure and components
            createComponents(app)

            % Register the app with App Designer
            registerApp(app, app.UIFigure)

            % Execute the startup function
            runStartupFcn(app, @startupFcn)

            if nargout == 0
                clear app
            end
        end

        % Code that executes before app deletion
        function delete(app)

            % Delete UIFigure when app is deleted
            delete(app.UIFigure)
        end
    end
end
