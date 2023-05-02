classdef CodeFromGUI1 < matlab.apps.AppBase

    % Properties that correspond to app components
    properties (Access = public)
        UIFigure                        matlab.ui.Figure
        CalculateSoC                    matlab.ui.control.Button
        ProducedHeatFieldW              matlab.ui.control.NumericEditField
        HeatWLabel                      matlab.ui.control.Label
        ProducedHeatField               matlab.ui.control.NumericEditField
        HeatJLabel                      matlab.ui.control.Label
        CalculateProducedHeatButton     matlab.ui.control.Button
        RecoveredWhVMaxField            matlab.ui.control.NumericEditField
        RecoveredWhEditFieldLabel_4     matlab.ui.control.Label
        RecoveredWhVolField             matlab.ui.control.NumericEditField
        RecoveredWhEditFieldLabel_3     matlab.ui.control.Label
        CellResistancemOEditField       matlab.ui.control.NumericEditField
        CellResistancemOEditFieldLabel  matlab.ui.control.Label
        StabilisedVoltagesButton        matlab.ui.control.Button
        PeakPowerVolField               matlab.ui.control.NumericEditField
        PeakpowerfromVolWLabel          matlab.ui.control.Label
        AvgPowerVolField                matlab.ui.control.NumericEditField
        AvgpowerfromVolWLabel           matlab.ui.control.Label
        EnergyVolField                  matlab.ui.control.NumericEditField
        EnergyusedfromVolWhLabel        matlab.ui.control.Label
        AhMaxVWhField                   matlab.ui.control.NumericEditField
        AhMaxVWhLabel                   matlab.ui.control.Label
        MaxVField                       matlab.ui.control.NumericEditField
        MaxVEditFieldLabel              matlab.ui.control.Label
        MaxAField                       matlab.ui.control.NumericEditField
        MaxAEditFieldLabel              matlab.ui.control.Label
        AhField                         matlab.ui.control.NumericEditField
        AhEditFieldLabel                matlab.ui.control.Label
        PeakPowerVmaxField              matlab.ui.control.NumericEditField
        PeakpowerfromVmaxWEditFieldLabel  matlab.ui.control.Label
        AvgPowerVmaxField               matlab.ui.control.NumericEditField
        AvgpowerfromVmaxWLabel          matlab.ui.control.Label
        EnergyVmaxField                 matlab.ui.control.NumericEditField
        EnergyusedfromVmaxWhEditFieldLabel  matlab.ui.control.Label
        FilePath                        matlab.ui.control.EditField
        Label                           matlab.ui.control.Label
        TimeField                       matlab.ui.control.NumericEditField
        TimesLabel                      matlab.ui.control.Label
        ChoosefolderButton              matlab.ui.control.Button
        Slider_2                        matlab.ui.control.Slider
        Slider_2Label                   matlab.ui.control.Label
        Slider                          matlab.ui.control.Slider
        SliderLabel                     matlab.ui.control.Label
        AxesVoltages                    matlab.ui.control.UIAxes
        AxesChosenData                  matlab.ui.control.UIAxes
        AxesFullData                    matlab.ui.control.UIAxes
    end

    
    properties (Access = private)
        filenamesToRead = ["_TEL_HVBMS_CURR.txt", "_TEL_HVBMS_MAXCVOLT.txt", "_TEL_HVBMS_MINCVOLT.txt", "_TEL_HVBMS_VOLT.txt"]% Files with what endings that need to be read, in that order
        sFolderPath%='/home/jacek/Dokumenty/Matlab/Testy LEM MotoPark/lem_logi_motopark_30102020/20201030_092123662678_decoded' % Initial value set for quick testing on my PC only
        val % contains values read from sensors and converted to double, in order of filenamesToRead
        times % time of each datapoint, converted to miliseconds
        %accumulator configuration:
        SERIES = 102;
        PARALLEL = 6;
    end
    
    methods (Access = private)
        
        function updatePlotsAndCalculations(app)
            %Calculate based on max and min cell voltages from BMS
            plot(app.AxesFullData, app.times, app.val(:,1), 'k')
            hold(app.AxesFullData, 'on')
            plot(app.AxesFullData, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1))
            hold(app.AxesFullData, 'off')
            app.TimeField.Value=(app.times(app.Slider_2.Value)-app.times(app.Slider.Value))/1000;
            plot(app.AxesChosenData, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1))
            hold(app.AxesChosenData, 'on')
            plot(app.AxesChosenData, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1).*app.val(app.Slider.Value:app.Slider_2.Value,4)/1000)
            hold(app.AxesChosenData, 'off')

            cla(app.AxesVoltages, 'reset')
            %yyaxis(app.AxesVoltages,'left')
            plot(app.AxesVoltages, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,2:3))
            
            %In some of our telemetries the total voltage sensor was
            %missing, so those values won't be calculated if it is in fact
            %reading zero
            %if app.val(1, 4)
                hold(app.AxesVoltages, 'on')
                plot(app.AxesVoltages, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,4)/app.SERIES)
                hold(app.AxesVoltages, 'off')
                [wv, pv, rv]=calculateEnergy(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1), app.val(app.Slider.Value:app.Slider_2.Value,4));
                app.EnergyVolField.Value=wv;
                app.PeakPowerVolField.Value=pv;
                app.RecoveredWhVolField.Value=app.SERIES*rv;
                app.AvgPowerVolField.Value=app.EnergyVolField.Value/app.TimeField.Value*3600;
            %end
            %calculate energies
            [app.AhField.Value, app.MaxAField.Value]=calculateCurrent(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1));
            app.MaxVField.Value=max(app.val(app.Slider.Value:app.Slider_2.Value, 2));
            app.AhMaxVWhField.Value=app.AhField.Value*app.MaxVField.Value*app.SERIES;
            [wm, pm, rm]=calculateEnergy(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1), app.val(app.Slider.Value:app.Slider_2.Value,2));
            app.EnergyVmaxField.Value=app.SERIES*wm;
            app.PeakPowerVmaxField.Value=app.SERIES*pm;
            app.RecoveredWhVMaxField.Value=app.SERIES*rm;
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

        % Button pushed function: StabilisedVoltagesButton
        function StabilisedVoltagesButtonPushed(app, event)
            %This button will try to show voltages, but offset by the
            %voltage lost on the internal resistance. Was an experiment to
            %see what is the real internal resistance
            %yyaxis(app.AxesVoltages,'left')
            %redraw the plot to clear previous stabilised values
            cla(app.AxesVoltages, 'reset')
            plot(app.AxesVoltages, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,2:3))
            hold(app.AxesVoltages, 'on')
            plot(app.AxesVoltages, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,4)/app.SERIES)

            %akuResistance=app.CellResistancemOEditField.Value/1000*17;
            plot(app.AxesVoltages, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,4)/app.SERIES+app.val(app.Slider.Value:app.Slider_2.Value,1)*app.CellResistancemOEditField.Value/1000/app.PARALLEL);

            [calculatedTimes, medianSVolt, ampLimit] = calculateSafePwrLimit(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,4), app.val(app.Slider.Value:app.Slider_2.Value,1), app.CellResistancemOEditField.Value/1000, app.SERIES, app.PARALLEL);
            plot(app.AxesVoltages, calculatedTimes, medianSVolt)
            hold(app.AxesVoltages, 'off')

            %display amp limit
            hold(app.AxesChosenData, 'on')
            plot(app.AxesChosenData, calculatedTimes, ampLimit)
            hold(app.AxesChosenData, 'off')
        end

        % Button pushed function: CalculateProducedHeatButton
        function CalculateProducedHeatButtonPushed(app, event)
            %This will calculate heat W=P*t=I²R*t
            akuResistance = app.CellResistancemOEditField.Value/1000*app.SERIES/app.PARALLEL;
            producedHeat = calculateHeat(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,1), akuResistance);
            app.ProducedHeatField.Value = producedHeat/3600;
            app.ProducedHeatFieldW.Value = producedHeat/app.TimeField.Value;
        end

        % Button pushed function: CalculateSoC
        function CalculateSoCButtonPushed(app, event)
            %This button will show SoC calculated using 2 methods
            cla(app.AxesVoltages, 'reset')
            plot(app.AxesVoltages, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,2:3))
            hold(app.AxesVoltages, 'on')
            plot(app.AxesVoltages, app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,4)/app.SERIES)
            
            %calculate SoCs
            [calculatedTimes, soc] = calculateSoC(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,4), app.val(app.Slider.Value:app.Slider_2.Value,1), app.CellResistancemOEditField.Value/1000, app.SERIES, app.PARALLEL);
            [calculatedTimesEnergy, socEnergy] = calculateSoCEnergy(app.times(app.Slider.Value:app.Slider_2.Value), app.val(app.Slider.Value:app.Slider_2.Value,4), app.val(app.Slider.Value:app.Slider_2.Value,1), app.CellResistancemOEditField.Value/1000, app.SERIES, app.PARALLEL);
            yyaxis(app.AxesVoltages,'right')
            plot(app.AxesVoltages, calculatedTimes, soc)
            plot(app.AxesVoltages, calculatedTimesEnergy, socEnergy)
            hold(app.AxesVoltages, 'off')
        end
    end

    % Component initialization
    methods (Access = private)

        % Create UIFigure and components
        function createComponents(app)

            % Create UIFigure and hide until all components are created
            app.UIFigure = uifigure('Visible', 'off');
            app.UIFigure.Position = [100 100 1000 720];
            app.UIFigure.Name = 'MATLAB App';
            app.UIFigure.Pointer = 'crosshair';

            % Create AxesFullData
            app.AxesFullData = uiaxes(app.UIFigure);
            title(app.AxesFullData, 'Current - all data points')
            xlabel(app.AxesFullData, 'Time [ms]')
            ylabel(app.AxesFullData, '[A]')
            zlabel(app.AxesFullData, 'Z')
            app.AxesFullData.Position = [501 511 500 210];

            % Create AxesChosenData
            app.AxesChosenData = uiaxes(app.UIFigure);
            title(app.AxesChosenData, 'Current + Power')
            xlabel(app.AxesChosenData, 'Time [ms]')
            ylabel(app.AxesChosenData, '[A] or [kW]')
            zlabel(app.AxesChosenData, 'Z')
            app.AxesChosenData.Position = [501 1 500 400];

            % Create AxesVoltages
            app.AxesVoltages = uiaxes(app.UIFigure);
            title(app.AxesVoltages, 'Voltages')
            xlabel(app.AxesVoltages, 'Time [ms]')
            ylabel(app.AxesVoltages, '[V]')
            zlabel(app.AxesVoltages, 'Z')
            app.AxesVoltages.Position = [1 1 500 400];

            % Create SliderLabel
            app.SliderLabel = uilabel(app.UIFigure);
            app.SliderLabel.HorizontalAlignment = 'right';
            app.SliderLabel.Position = [501 489 25 22];
            app.SliderLabel.Text = '';

            % Create Slider
            app.Slider = uislider(app.UIFigure);
            app.Slider.ValueChangedFcn = createCallbackFcn(app, @SliderValueChanged, true);
            app.Slider.Position = [547 498 438 3];

            % Create Slider_2Label
            app.Slider_2Label = uilabel(app.UIFigure);
            app.Slider_2Label.HorizontalAlignment = 'right';
            app.Slider_2Label.Position = [501 439 25 22];
            app.Slider_2Label.Text = '';

            % Create Slider_2
            app.Slider_2 = uislider(app.UIFigure);
            app.Slider_2.ValueChangedFcn = createCallbackFcn(app, @Slider_2ValueChanged, true);
            app.Slider_2.Position = [547 448 439 3];

            % Create ChoosefolderButton
            app.ChoosefolderButton = uibutton(app.UIFigure, 'push');
            app.ChoosefolderButton.ButtonPushedFcn = createCallbackFcn(app, @ChoosefolderButtonPushed, true);
            app.ChoosefolderButton.Position = [22 682 97 25];
            app.ChoosefolderButton.Text = 'Choose folder';

            % Create TimesLabel
            app.TimesLabel = uilabel(app.UIFigure);
            app.TimesLabel.BackgroundColor = [1 1 1];
            app.TimesLabel.HorizontalAlignment = 'right';
            app.TimesLabel.FontColor = [0 0.4471 0.7412];
            app.TimesLabel.Position = [8 649 50 22];
            app.TimesLabel.Text = 'Time [s]';

            % Create TimeField
            app.TimeField = uieditfield(app.UIFigure, 'numeric');
            app.TimeField.Editable = 'off';
            app.TimeField.FontColor = [0 0.4471 0.7412];
            app.TimeField.Position = [61 649 48 22];

            % Create Label
            app.Label = uilabel(app.UIFigure);
            app.Label.HorizontalAlignment = 'right';
            app.Label.Position = [127 684 25 22];
            app.Label.Text = '';

            % Create FilePath
            app.FilePath = uieditfield(app.UIFigure, 'text');
            app.FilePath.Editable = 'off';
            app.FilePath.Position = [126 684 360 22];

            % Create EnergyusedfromVmaxWhEditFieldLabel
            app.EnergyusedfromVmaxWhEditFieldLabel = uilabel(app.UIFigure);
            app.EnergyusedfromVmaxWhEditFieldLabel.HorizontalAlignment = 'right';
            app.EnergyusedfromVmaxWhEditFieldLabel.FontColor = [0.9294 0.6941 0.1255];
            app.EnergyusedfromVmaxWhEditFieldLabel.Position = [12 558 161 23];
            app.EnergyusedfromVmaxWhEditFieldLabel.Text = 'Energy used from Vmax [Wh]';

            % Create EnergyVmaxField
            app.EnergyVmaxField = uieditfield(app.UIFigure, 'numeric');
            app.EnergyVmaxField.ValueDisplayFormat = '%7.2f';
            app.EnergyVmaxField.Editable = 'off';
            app.EnergyVmaxField.FontColor = [0.9294 0.6941 0.1255];
            app.EnergyVmaxField.Position = [181 559 110 22];

            % Create AvgpowerfromVmaxWLabel
            app.AvgpowerfromVmaxWLabel = uilabel(app.UIFigure);
            app.AvgpowerfromVmaxWLabel.HorizontalAlignment = 'right';
            app.AvgpowerfromVmaxWLabel.FontColor = [0.502 0.502 0.502];
            app.AvgpowerfromVmaxWLabel.Position = [12 528 146 22];
            app.AvgpowerfromVmaxWLabel.Text = 'Avg power from Vmax [W]';

            % Create AvgPowerVmaxField
            app.AvgPowerVmaxField = uieditfield(app.UIFigure, 'numeric');
            app.AvgPowerVmaxField.ValueDisplayFormat = '%7.2f';
            app.AvgPowerVmaxField.Editable = 'off';
            app.AvgPowerVmaxField.FontColor = [0.502 0.502 0.502];
            app.AvgPowerVmaxField.Position = [182 528 109 22];

            % Create PeakpowerfromVmaxWEditFieldLabel
            app.PeakpowerfromVmaxWEditFieldLabel = uilabel(app.UIFigure);
            app.PeakpowerfromVmaxWEditFieldLabel.HorizontalAlignment = 'right';
            app.PeakpowerfromVmaxWEditFieldLabel.FontColor = [1 0 0];
            app.PeakpowerfromVmaxWEditFieldLabel.Position = [11 498 151 22];
            app.PeakpowerfromVmaxWEditFieldLabel.Text = 'Peak power from Vmax [W]';

            % Create PeakPowerVmaxField
            app.PeakPowerVmaxField = uieditfield(app.UIFigure, 'numeric');
            app.PeakPowerVmaxField.ValueDisplayFormat = '%7.2f';
            app.PeakPowerVmaxField.Editable = 'off';
            app.PeakPowerVmaxField.FontColor = [1 0 0];
            app.PeakPowerVmaxField.Position = [181 498 110 22];

            % Create AhEditFieldLabel
            app.AhEditFieldLabel = uilabel(app.UIFigure);
            app.AhEditFieldLabel.HorizontalAlignment = 'right';
            app.AhEditFieldLabel.FontColor = [0.9294 0.6941 0.1255];
            app.AhEditFieldLabel.Position = [11 619 29 22];
            app.AhEditFieldLabel.Text = '[Ah]';

            % Create AhField
            app.AhField = uieditfield(app.UIFigure, 'numeric');
            app.AhField.Editable = 'off';
            app.AhField.FontColor = [0.9294 0.6941 0.1255];
            app.AhField.Position = [111 619 70 22];

            % Create MaxAEditFieldLabel
            app.MaxAEditFieldLabel = uilabel(app.UIFigure);
            app.MaxAEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxAEditFieldLabel.FontColor = [1 0 0];
            app.MaxAEditFieldLabel.Position = [191 619 47 22];
            app.MaxAEditFieldLabel.Text = 'Max [A]';

            % Create MaxAField
            app.MaxAField = uieditfield(app.UIFigure, 'numeric');
            app.MaxAField.Editable = 'off';
            app.MaxAField.FontColor = [1 0 0];
            app.MaxAField.Position = [253 619 38 22];

            % Create MaxVEditFieldLabel
            app.MaxVEditFieldLabel = uilabel(app.UIFigure);
            app.MaxVEditFieldLabel.HorizontalAlignment = 'right';
            app.MaxVEditFieldLabel.FontColor = [1 0 0];
            app.MaxVEditFieldLabel.Position = [191 589 47 22];
            app.MaxVEditFieldLabel.Text = 'Max [V]';

            % Create MaxVField
            app.MaxVField = uieditfield(app.UIFigure, 'numeric');
            app.MaxVField.Editable = 'off';
            app.MaxVField.FontColor = [1 0 0];
            app.MaxVField.Position = [253 589 38 22];

            % Create AhMaxVWhLabel
            app.AhMaxVWhLabel = uilabel(app.UIFigure);
            app.AhMaxVWhLabel.HorizontalAlignment = 'right';
            app.AhMaxVWhLabel.FontColor = [1 0.4118 0.1608];
            app.AhMaxVWhLabel.Position = [11 589 93 22];
            app.AhMaxVWhLabel.Text = '[Ah*Max[V]=Wh]';

            % Create AhMaxVWhField
            app.AhMaxVWhField = uieditfield(app.UIFigure, 'numeric');
            app.AhMaxVWhField.Editable = 'off';
            app.AhMaxVWhField.FontColor = [1 0.4118 0.1608];
            app.AhMaxVWhField.Position = [111 589 69 22];

            % Create EnergyusedfromVolWhLabel
            app.EnergyusedfromVolWhLabel = uilabel(app.UIFigure);
            app.EnergyusedfromVolWhLabel.HorizontalAlignment = 'right';
            app.EnergyusedfromVolWhLabel.FontColor = [0.9294 0.6941 0.1255];
            app.EnergyusedfromVolWhLabel.Position = [11 467 150 23];
            app.EnergyusedfromVolWhLabel.Text = 'Energy used from Vol [Wh]';

            % Create EnergyVolField
            app.EnergyVolField = uieditfield(app.UIFigure, 'numeric');
            app.EnergyVolField.ValueDisplayFormat = '%7.2f';
            app.EnergyVolField.Editable = 'off';
            app.EnergyVolField.FontColor = [0.9294 0.6941 0.1255];
            app.EnergyVolField.Position = [181 468 109 22];

            % Create AvgpowerfromVolWLabel
            app.AvgpowerfromVolWLabel = uilabel(app.UIFigure);
            app.AvgpowerfromVolWLabel.HorizontalAlignment = 'right';
            app.AvgpowerfromVolWLabel.FontColor = [0.502 0.502 0.502];
            app.AvgpowerfromVolWLabel.Position = [11 438 133 22];
            app.AvgpowerfromVolWLabel.Text = 'Avg power from Vol [W]';

            % Create AvgPowerVolField
            app.AvgPowerVolField = uieditfield(app.UIFigure, 'numeric');
            app.AvgPowerVolField.ValueDisplayFormat = '%7.2f';
            app.AvgPowerVolField.Editable = 'off';
            app.AvgPowerVolField.FontColor = [0.502 0.502 0.502];
            app.AvgPowerVolField.Position = [181 438 110 22];

            % Create PeakpowerfromVolWLabel
            app.PeakpowerfromVolWLabel = uilabel(app.UIFigure);
            app.PeakpowerfromVolWLabel.HorizontalAlignment = 'right';
            app.PeakpowerfromVolWLabel.FontColor = [1 0 0];
            app.PeakpowerfromVolWLabel.Position = [11 409 139 22];
            app.PeakpowerfromVolWLabel.Text = 'Peak power from Vol [W]';

            % Create PeakPowerVolField
            app.PeakPowerVolField = uieditfield(app.UIFigure, 'numeric');
            app.PeakPowerVolField.ValueDisplayFormat = '%7.2f';
            app.PeakPowerVolField.Editable = 'off';
            app.PeakPowerVolField.FontColor = [1 0 0];
            app.PeakPowerVolField.Position = [181 409 110 22];

            % Create StabilisedVoltagesButton
            app.StabilisedVoltagesButton = uibutton(app.UIFigure, 'push');
            app.StabilisedVoltagesButton.ButtonPushedFcn = createCallbackFcn(app, @StabilisedVoltagesButtonPushed, true);
            app.StabilisedVoltagesButton.FontColor = [0.502 0.502 0.502];
            app.StabilisedVoltagesButton.Position = [321 646 118 25];
            app.StabilisedVoltagesButton.Text = 'Stabilised Voltages';

            % Create CellResistancemOEditFieldLabel
            app.CellResistancemOEditFieldLabel = uilabel(app.UIFigure);
            app.CellResistancemOEditFieldLabel.HorizontalAlignment = 'right';
            app.CellResistancemOEditFieldLabel.FontColor = [0.502 0.502 0.502];
            app.CellResistancemOEditFieldLabel.Position = [118 649 108 22];
            app.CellResistancemOEditFieldLabel.Text = 'Cell Resistance mO';

            % Create CellResistancemOEditField
            app.CellResistancemOEditField = uieditfield(app.UIFigure, 'numeric');
            app.CellResistancemOEditField.FontColor = [0.502 0.502 0.502];
            app.CellResistancemOEditField.Position = [241 649 50 22];
            app.CellResistancemOEditField.Value = 16;

            % Create RecoveredWhEditFieldLabel_3
            app.RecoveredWhEditFieldLabel_3 = uilabel(app.UIFigure);
            app.RecoveredWhEditFieldLabel_3.HorizontalAlignment = 'right';
            app.RecoveredWhEditFieldLabel_3.FontColor = [0.4667 0.6745 0.1882];
            app.RecoveredWhEditFieldLabel_3.Position = [321 469 91 22];
            app.RecoveredWhEditFieldLabel_3.Text = 'Recovered [Wh]';

            % Create RecoveredWhVolField
            app.RecoveredWhVolField = uieditfield(app.UIFigure, 'numeric');
            app.RecoveredWhVolField.ValueDisplayFormat = '%7.2f';
            app.RecoveredWhVolField.Editable = 'off';
            app.RecoveredWhVolField.FontColor = [0.4667 0.6745 0.1882];
            app.RecoveredWhVolField.Position = [425 469 56 22];

            % Create RecoveredWhEditFieldLabel_4
            app.RecoveredWhEditFieldLabel_4 = uilabel(app.UIFigure);
            app.RecoveredWhEditFieldLabel_4.HorizontalAlignment = 'right';
            app.RecoveredWhEditFieldLabel_4.FontColor = [0.4667 0.6745 0.1882];
            app.RecoveredWhEditFieldLabel_4.Position = [321 559 91 22];
            app.RecoveredWhEditFieldLabel_4.Text = 'Recovered [Wh]';

            % Create RecoveredWhVMaxField
            app.RecoveredWhVMaxField = uieditfield(app.UIFigure, 'numeric');
            app.RecoveredWhVMaxField.ValueDisplayFormat = '%7.2f';
            app.RecoveredWhVMaxField.Editable = 'off';
            app.RecoveredWhVMaxField.FontColor = [0.4667 0.6745 0.1882];
            app.RecoveredWhVMaxField.Position = [425 559 56 22];

            % Create CalculateProducedHeatButton
            app.CalculateProducedHeatButton = uibutton(app.UIFigure, 'push');
            app.CalculateProducedHeatButton.ButtonPushedFcn = createCallbackFcn(app, @CalculateProducedHeatButtonPushed, true);
            app.CalculateProducedHeatButton.FontColor = [0.502 0.502 0.502];
            app.CalculateProducedHeatButton.Position = [330 618 100 25];
            app.CalculateProducedHeatButton.Text = 'Calculate Heat';

            % Create HeatJLabel
            app.HeatJLabel = uilabel(app.UIFigure);
            app.HeatJLabel.FontColor = [0.4941 0.1843 0.5569];
            app.HeatJLabel.Position = [326 528 60 22];
            app.HeatJLabel.Text = 'Heat [Wh]';

            % Create ProducedHeatField
            app.ProducedHeatField = uieditfield(app.UIFigure, 'numeric');
            app.ProducedHeatField.ValueDisplayFormat = '%7.2f';
            app.ProducedHeatField.Editable = 'off';
            app.ProducedHeatField.FontColor = [0.4941 0.1843 0.5569];
            app.ProducedHeatField.Position = [425 528 56 22];

            % Create HeatWLabel
            app.HeatWLabel = uilabel(app.UIFigure);
            app.HeatWLabel.FontColor = [0.4941 0.1843 0.5569];
            app.HeatWLabel.Position = [326 500 53 22];
            app.HeatWLabel.Text = 'Heat [W]';

            % Create ProducedHeatFieldW
            app.ProducedHeatFieldW = uieditfield(app.UIFigure, 'numeric');
            app.ProducedHeatFieldW.ValueDisplayFormat = '%7.2f';
            app.ProducedHeatFieldW.Editable = 'off';
            app.ProducedHeatFieldW.FontColor = [0.4941 0.1843 0.5569];
            app.ProducedHeatFieldW.Position = [425 500 54 22];

            % Create CalculateSoC
            app.CalculateSoC = uibutton(app.UIFigure, 'push');
            app.CalculateSoC.ButtonPushedFcn = createCallbackFcn(app, @CalculateSoCButtonPushed, true);
            app.CalculateSoC.FontColor = [0.502 0.502 0.502];
            app.CalculateSoC.Position = [330 588 100 25];
            app.CalculateSoC.Text = 'Calculate SoC';

            % Show the figure after all components are created
            app.UIFigure.Visible = 'on';
        end
    end

    % App creation and deletion
    methods (Access = public)

        % Construct app
        function app = CodeFromGUI1

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