%% Add your names in a comment here at the beginning of the code!

% Sara and Sal

% Instructions: Follow through this code step by step, while also referring
% to the overall instructions and questions from the lab assignment sheet.

addpath('C:\Users\nuhin\git\ocean-co2-data-lab-rocks4jocks')

%% 1. Read in the monthly gridded CO2 data from the .csv file
% The data file is included in your repository as “LDEO_GriddedCO2_month_flux_2006c.csv”
% Your task is to write code to read this in to MATLAB
% Hint: you can again use the function “readtable”, and use your first data lab code as an example.

CO2data = readtable("LDEO_GriddedCO2_month_flux_2006c.csv");%<--

%% 2a. Create new 3-dimensional arrays to hold reshaped data
%Find each unique longitude, latitude, and month value that will define
%your 3-dimensional grid
longrid = unique(CO2data.LON); %finds all unique longitude values
 %<-- following the same approach, find all unique latitude values
 %<-- following the same approach, find all unique months

%Create empty 3-dimensional arrays of NaN values to hold your reshaped data
    %You can make these for any variables you want to extract - for this
    %lab you will need PCO2_SW (seawater pCO2) and SST (sea surface
    %temperature)
latgrid = unique(CO2data.LAT);%<--
monthgrid = unique(CO2data.MONTH);%<--

PCO2_SW = NaN(height(longrid), height(latgrid), height(monthgrid));
SST = NaN(height(longrid), height(latgrid), height(monthgrid));

%% 2b. Pull out the seawater pCO2 (PCO2_SW) and sea surface temperature (SST)
%data and reshape it into your new 3-dimensional arrays

for i = 1:height(CO2data)
    row  = find(longrid == CO2data.LON(i));
    col  = find(latgrid == CO2data.LAT(i));
    page = find(monthgrid == CO2data.MONTH(i));
    colSST = 9;
    colpCO2_SW = 4;
    PCO2_SW(row, col, page) = CO2data.PCO2_SW(i);
    SST(row, col , page) = CO2data.SST(i);
end%<--

%% 3a. Make a quick plot to check that your reshaped data looks reasonable
%Use the imagesc plotting function, which will show a different color for
%each grid cell in your map. Since you can't plot all months at once, you
%will have to pick one at a time to check - i.e. this example is just for
%January

imagesc(SST(:,:,1))


%% 3b. Now pretty global maps of one month of each of SST and pCO2 data.
%I have provided example code for plotting January sea surface temperature
%(though you may need to make modifications based on differences in how you
%set up or named your variables above).

figure(1); clf
worldmap world
contourfm(latgrid, longrid, SST(:,:,1)','linecolor','none');
colorbar
geoshow('landareas.shp','FaceColor','black')
title('January Sea Surface Temperature (^oC)')

%Check that you can make a similar type of global map for another month
%and/or for pCO2 using this approach. Check the documentation and see
%whether you can modify features of this map such as the contouring
%interval, color of the contour lines, labels, etc.

figure(2); clf
worldmap world
contourfm(latgrid, longrid, PCO2_SW(:,:,1)','linecolor','none');
colorbar
geoshow('landareas.shp','FaceColor','black')
title('January pCO2 (µatm)')%<--

figure(3); clf
worldmap world
contourfm(latgrid, longrid, SST(:,:,2)','linecolor','none');
colorbar
geoshow('landareas.shp','FaceColor','black')
title('February Sea Surface Temperature (^oC)')%<--


%% 4. Calculate and plot a global map of annual mean pCO2

annualMeanPCO2 = mean(PCO2_SW, 3, 'omitnan');

figure(4); clf
worldmap world
contourfm(latgrid, longrid, annualMeanPCO2','linecolor','none');
colorbar
geoshow('landareas.shp','FaceColor','black')
title('Annual Mean Seawater pCO2 (µatm)')%<--


%% 5. Calculate and plot a global map of the difference between the annual mean seawater and atmosphere pCO2
%<--

annualmeanAtmospherePCO2 = 369.64; %% ppm

meanDifference = annualmeanAtmospherePCO2 - annualMeanPCO2;

figure(5); clf
worldmap world
contourfm(latgrid, longrid, meanDifference','Linecolor','none');
geoshow('landareas.shp','FaceColor','black')
title('Annual Difference in Mean Seawater and Atmosphere pCO2 (µatm)')
colormap(cmocean('balance'));
colorbar

%% 6. Calculate relative roles of temperature and of biology/physics in controlling seasonal cycle

tMean = repmat(mean(SST, 3, "omitnan"), [1, 1, 12]);

pCO2_atTmean = PCO2_SW .* exp(0.0423 * (tMean - SST));

pCO2_mean = repmat(mean(PCO2_SW, 3, "omitnan"), [1, 1, 12]);

pCO2_atTobsv = pCO2_mean .* exp(0.0423 * (SST - tMean));

pCO2_bio = max(pCO2_atTmean, [], 3) - min(pCO2_atTmean, [], 3);

pCO2_temp = max(pCO2_atTobsv, [], 3) - min(pCO2_atTobsv, [], 3);%<--

%% 7. Pull out and plot the seasonal cycle data from stations of interest
%Do for BATS, Station P, and Ross Sea (note that Ross Sea is along a
%section of 14 degrees longitude - I picked the middle point)

bats_lat_idx = 28;
bats_lon_idx = 60;

ross_lat_idx = 1;
ross_lon_idx = 36;

papa_lat_idx = 33;
papa_lon_idx = 44;%<--

% Pull out and reshape seasonal cycle data for BATS, Station P, and Ross Sea

bats_SST = squeeze(SST(bats_lon_idx, bats_lat_idx, :));
bats_pCO2 = squeeze(PCO2_SW(bats_lon_idx, bats_lat_idx, :));
bats_temp = squeeze(pCO2_atTobsv(bats_lon_idx, bats_lat_idx, :));
%tobsv represents the temperature effect corrected for the bio/physical
%effect
bats_bio = squeeze(pCO2_atTmean(bats_lon_idx, bats_lat_idx, :));
%Tmean represents the bio/physical effect corrected for temperature

figure(6); clf

months = 1:12;

subplot(3,1,1)
plot(months, bats_SST, '-o')
ylabel('SST (°C)')
title('Bermuda (BATS) Seasonal Cycle')

subplot(3,1,2)
plot(months, bats_pCO2, '-o', months, bats_temp, '-r', months, bats_bio, '-b')
ylabel('pCO2 (µatm)')
xlabel('Month')
legend('Observed', 'Temperature effect','Bio/physics effect')


papa_SST = squeeze(SST(papa_lon_idx, papa_lat_idx, :));
papa_pCO2 = squeeze(PCO2_SW(papa_lon_idx, papa_lat_idx, :));
papa_temp = squeeze(pCO2_atTobsv(papa_lon_idx, papa_lat_idx, :));
papa_bio = squeeze(pCO2_atTmean(papa_lon_idx, papa_lat_idx, :));

figure(7); clf

months = 1:12;

subplot(3,1,1)
plot(months, papa_SST, '-o')
ylabel('SST (°C)')
title('Ocean Station Papa Seasonal Cycle')

subplot(3,1,2)
plot(months, papa_pCO2, '-o', months, papa_temp, '-r', months, papa_bio, '-b')
ylabel('pCO2 (µatm)')
xlabel('Month')
legend('Observed', 'Temperature effect','Bio/physics effect')


ross_SST = squeeze(SST(ross_lon_idx, ross_lat_idx, :));
ross_pCO2 = squeeze(PCO2_SW(ross_lon_idx, ross_lat_idx, :));
ross_temp = squeeze(pCO2_atTobsv(ross_lon_idx, ross_lat_idx, :));
ross_bio = squeeze(pCO2_atTmean(ross_lon_idx, ross_lat_idx, :));

figure(8); clf

months = 1:12;

subplot(3,1,1)
plot(months, ross_SST, '-o')
ylabel('SST (°C)')
title('Ross Sea Seasonal Cycle')

subplot(3,1,2)
plot(months, ross_pCO2, '-o', months, ross_temp, '-r', months, ross_bio, '-b')
ylabel('pCO2 (µatm)')
xlabel('Month')
legend('Observed', 'Temperature effect','Bio/physics effect')
%<--

%% 8. Reproduce your own versions of the maps in figures 7-9 in Takahashi et al. 2002
% But please use better colormaps!!!
% Mark on thesese maps the locations of the three stations for which you plotted the
% seasonal cycle above

bats_lat = latgrid(bats_lat_idx);
bats_lon = longrid(bats_lon_idx);

ross_lat = latgrid(ross_lat_idx);
ross_lon = longrid(ross_lon_idx);

papa_lat = latgrid(papa_lat_idx);
papa_lon = longrid(papa_lon_idx);

figure(9); clf
worldmap world
contourfm(latgrid, longrid, pCO2_bio','Linecolor','none');
geoshow('landareas.shp','FaceColor','black')
title('Seasonal Biological Drawdown of Seawater pCO2 (µatm change)')
colormap(cmocean('algae'));
colorbar
plotm(bats_lat, bats_lon, 'o', 'MarkerSize',6, 'MarkerFaceColor','k')
plotm(ross_lat, ross_lon, 'o', 'MarkerSize',6, 'MarkerFaceColor','k')
plotm(papa_lat, papa_lon, 'o', 'MarkerSize',6, 'MarkerFaceColor','k')

textm(bats_lat, bats_lon, ' BATS')
textm(ross_lat, ross_lon, ' Ross Sea')
textm(papa_lat, papa_lon, ' Papa')

figure(10); clf
worldmap world
contourfm(latgrid, longrid, pCO2_temp','Linecolor','none');
geoshow('landareas.shp','FaceColor','black')
title('Seasonal Temperature Effect on Seawater pCO2 (µatm change)')
colormap(cmocean('matter'));
colorbar
plotm(bats_lat, bats_lon, 'o', 'MarkerSize',6, 'MarkerFaceColor','k')
plotm(ross_lat, ross_lon, 'o', 'MarkerSize',6, 'MarkerFaceColor','k')
plotm(papa_lat, papa_lon, 'o', 'MarkerSize',6, 'MarkerFaceColor','k')

textm(bats_lat, bats_lon, ' BATS')
textm(ross_lat, ross_lon, ' Ross Sea')
textm(papa_lat, papa_lon, ' Papa')

difference = pCO2_temp - pCO2_bio;

figure(11); clf
worldmap world
contourfm(latgrid, longrid, difference','Linecolor','none');
geoshow('landareas.shp','FaceColor','black')
title('Difference Between Temperature and Bio Effect on pCO2 (µatm)')
%colormap(cmocean(''))
clim([-200 200])
colorbar
plotm(bats_lat, bats_lon, 'o', 'MarkerSize',6, 'MarkerFaceColor','k')
plotm(ross_lat, ross_lon, 'o', 'MarkerSize',6, 'MarkerFaceColor','k')
plotm(papa_lat, papa_lon, 'o', 'MarkerSize',6, 'MarkerFaceColor','k')

textm(bats_lat, bats_lon, ' BATS')
textm(ross_lat, ross_lon, ' Ross Sea')
textm(papa_lat, papa_lon, ' Papa')
%<--
