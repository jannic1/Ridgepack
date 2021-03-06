% ridgepack_JAMES_figure3 - Generates Figure 3 in JAMES Variational Ridging paper
% 
% This script generates Figure 3 from:
%
% Roberts, A.F., E.C. Hunke, S.M. Kamal, W.H. Lipscomb, C. Horvat, W. Maslowski (2018),
% Variational Method for Sea Ice Ridging in Earth System Models, Part I: Theory, 
% submitted to J. Adv. Model Earth Sy.
%
% Andrew Roberts, Naval Postgraduate School, April 2018 (afrobert@nps.edu)

% version check
[v d] = version;
if str2num(d(end-3:end))<2018
 warning('This script designed for MATLAB 2018a or more recent version')
end

clear
close all

% Create figure
figure(1);

% level ice and snow thickness
hfi=2.0; % level ice thickness
hfs=0.3; % snow thickness

% deformed ice and snow thickness
hdi=3.0; % ridged ice thickness
hds=0.3; % ridged snow thickness

% strain
epsilon=(hfi-hdi)/hdi;

% parameter settings of scheme
hc=ridgepack_astroconstants;
rho=hc.rhoi.const;  % density of ice (kg/m^3)
rhos=hc.rhos.const; % density of snow (kg/m^3)
rhow=hc.rhow.const; % density of seawater (kg/m^3)
g=hc.ghat.const; % acceleration due to gravity (m/s^2)

alphar=22; % angle of ridge
alphak=22; % angle of keel
%porosity=0.8; % porosity of ridge and keel complex
porosity=1.0; % porosity of ridge and keel complex

% geometric settings of figure
boxleftx=0.025;
boxrightx=0.775;
boxcenterx=(boxleftx+boxrightx)/2;
figLk=boxrightx-boxleftx;
levelextent=0.20;
sealeft=0;
searight=1;
aspectratio=2;
textbox=0.05;
textoffset=0.012;
arrowhead=0.005;
envelope=0.025;
scaleaxes=0.15;
cols=lines(10);
greycol=0.5*[1 1 1];
bluecol=cols(1,:);


% calculate freeboard and draft of level ice
hld=(rho*hfi+rhos*hfs)/rhow; % level draft
hlf=(hfi+hfs)-hld; % level freeboard

% calculate freeboard and draft of deformed ice 
hdd=(rho*hdi+rhos*hds)/rhow; % ridged draft
hdf=(hdi+hds)-hdd; % ridged freeboard

% check for bounds of level ice
if hld<0
 hld=0;
 hlf=0;
elseif hld>hdd/porosity | hlf>hdf/porosity
 error('There are no keels or ridges with this setting')
end

% calculate depth of keel relative to sea level
Hk=(2*hdd/porosity)-hld;

% calculate horizontal extent of keel structure 
Lk=2*(Hk-hld)/tan(alphak*pi/180);

% calculate height of ridge
Hr=hlf+sqrt((tan(alphar*pi/180))*(((hdf*Lk)/porosity)-hlf*Lk));

% calculate horizontal extent of ridge structure 
Lr=2*(Hr-hlf)/tan(alphar*pi/180);

% use this to determine the scale factor for the diagram
scalefactorx=figLk/Lk;
scalefactory=min(aspectratio*scalefactorx,1/(Hk+Hr));

% calculate level ice box and surface snow, centered slightly to left
ylbottom=max((1-(hfi+hfs)*scalefactory)/2,(Hk-hld)*scalefactory);
yltop=ylbottom+hfi*scalefactory;
ylsnow=yltop+hfs*scalefactory;
sealevely=ylbottom+hld*scalefactory;

% calculate deformed ice coordinates
ydbottom=sealevely-hdd*scalefactory/porosity;
ydtop=sealevely+(hdf-hds)*scalefactory/porosity;
ydsnow=ydtop+hds*scalefactory/porosity;

% calculate keel bottom
ykbottom=ylbottom-(Hk-hld)*scalefactory;

% calculate ridge top
yrtop=ylsnow+(Hr-hlf)*scalefactory;

extenty(1)=ydsnow-ydbottom;
extenty(2)=extenty(1)+0.05;
extenty(3)=yrtop-ykbottom;
totalextent=extenty(1)+extenty(2)+extenty(3);
posy(1)=1-extenty(1)/totalextent;
posy(2)=posy(1)-extenty(2)/totalextent;
posy(3)=posy(2)-extenty(3)/totalextent;


notation='abc';

for setting=1:3

 % start axis
 if setting==1 | setting==2
  axes('Position',[1/3 posy(setting) 1/3 extenty(setting)/totalextent],...
      'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1],...
      'Xlim',[0 1],'Ylim',[ydbottom ydsnow],...
      'Box','off','Visible','off','Clipping','off')
 elseif setting==3
  axes('Position',[1/3 posy(setting) 1/3 extenty(setting)/totalextent],...
      'DataAspectRatio',[1 1 1],'PlotBoxAspectRatio',[1 1 1],...
      'Xlim',[0 1],'Ylim',[ykbottom yrtop],...
      'Box','off','Visible','off','Clipping','off')
 end

 % add "a)", "b)", and "c)"
 ymin=get(gca,'Ylim');
 text(-0.20,sum(ymin)/2,[notation(setting),')'],...
       'Interpreter','tex',...
       'FontName','Helvetica')

 %set(gca,'FontSize',7)
 labelsize=get(gca,'FontSize')-3;


 if setting==3
  rectangle('Position',[boxleftx,ylbottom,figLk,ylsnow-ylbottom],...
           'EdgeColor',0.5*[1 1 1],...
           'LineStyle','-');
 end

 % plot level ice to the right of ridged ice
 rectangle('Position',[boxrightx,ylbottom,levelextent,ylsnow-ylbottom],...
           'EdgeColor',0.5*[1 1 1],...
           'LineStyle','-');
 if setting==1
  handle=rectangle('Position',[boxrightx,yltop,levelextent,ylsnow-yltop],...
           'EdgeColor',0.5*[1 1 1],...
           'FaceColor',bluecol,...
           'LineStyle',':');
  uistack(handle,'bottom')
 %elseif setting==2 
 % handle=rectangle('Position',[boxrightx,sealevely,levelextent,ylsnow-sealevely],...
 %           'EdgeColor','none',...
 %           'FaceColor',0.85*[1 1 1],...
 %           'LineStyle','none');
 % uistack(handle,'bottom')
 end


 if setting==3

 % plot keel left
  x=[boxleftx boxcenterx];
  y=[ylbottom ykbottom];
  line(x,y,'Color',0.5*[1 1 1],'LineStyle','-');

 % overlay top of box with white except to indicate angle
  line([boxleftx+0.07 boxrightx],[ylbottom ylbottom],...
           'Color',0.99999*[1 1 1],...
           'LineStyle','-');

 % plot keel right
  x=[boxrightx boxcenterx];
  y=[ylbottom ykbottom];
  line(x,y,'Color',0.5*[1 1 1],'LineStyle','-');

 % plot ridge left
  x1=[boxcenterx-scalefactorx*Lr/2 boxcenterx];
  y1=[ylsnow yrtop];
  line(x1,y1,'Color',0.5*[1 1 1],'LineStyle','-');

  x2=[boxcenterx+scalefactorx*Lr/2 boxcenterx];
  y2=[ylsnow yrtop];

 % overlay bottom of box with white except to indicate angle
  line([x1(1)+0.07 x2(1)],[ylsnow ylsnow],'Color',0.85*[1 1 1],'LineStyle','-');

 % plot ridge right
  line(x2,y2,'Color',0.5*[1 1 1],'LineStyle','-');

 % fill in ridge and freeboard
  x=[boxleftx, boxleftx, boxcenterx-scalefactorx*Lr/2, boxcenterx,...
     boxcenterx+scalefactorx*Lr/2, boxrightx, boxrightx, boxleftx];
  y=[sealevely, ylsnow, ylsnow, yrtop, ylsnow, ylsnow, sealevely, sealevely];
  patch(x,y,0.85*[1 1 1])

 end


 % plot sea level line across figure
 x=[sealeft searight]; 
 y=[sealevely sealevely];
 line(x,y,'Color',bluecol,'LineStyle','-.');
 text(boxcenterx,sealevely-textoffset/2,...
           {'sea level'},...
           'Interpreter','Latex',...
           'VerticalAlignment','top',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize+2,...
           'Color',bluecol,...
           'EdgeColor','none')


 % plot deformed ice box and surface snow, centered 
 if setting==1 
  handle=rectangle('Position',[boxleftx,ydbottom,figLk,ydsnow-ydbottom],...
           'EdgeColor',0.5*[1 1 1],...
	   'LineWidth',0.4,...
           'LineStyle','-');
  handle=rectangle('Position',[boxleftx,ydtop,figLk,ydsnow-ydtop],...
           'EdgeColor',0.5*[1 1 1],...
           'FaceColor',bluecol,...
           'LineStyle',':');
  uistack(handle,'bottom')
 elseif setting==2 
  handle=rectangle('Position',[boxleftx,ydbottom,figLk,ydsnow-ydbottom],...
           'EdgeColor',0.5*[1 1 1],...
	   'LineWidth',0.4,...
           'LineStyle','-');
  handle=rectangle('Position',[boxleftx,sealevely,figLk,ydsnow-sealevely],...
           'EdgeColor','none',...
           'FaceColor',0.85*[1 1 1],...
           'LineStyle','none');
  uistack(handle,'bottom')
 elseif setting==3
  % handle=rectangle('Position',[boxleftx,ydbottom,figLk,ydsnow-ydbottom],...
  %           'EdgeColor',0.90*[1 1 1],...
  %	   'LineWidth',0.4,...
  %           'LineStyle','-');
  % uistack(handle,'bottom')
 end

 if setting==1

 % annotations of deformed ice metrics on left hand side
  x=[sealeft sealeft];
  y=[sealevely ydsnow];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ydsnow ydsnow],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ydtop ydtop],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)-textoffset,(ydtop+ydsnow)/2,...
           '$h_{R_s}$',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','right',...
           'EdgeColor','none')

  y=[ydbottom sealevely];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ydbottom ydbottom],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ydtop ydtop],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)-textoffset,sum(y)/2,...
           '$h_{R}$',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','right',...
           'EdgeColor','none')

 % annotations of level ice metrics on right hand side
  x=[searight searight];
  y=[sealevely ylsnow];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ylsnow ylsnow],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[yltop yltop],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)+textoffset,sum(y)/2,...
           '$h_{F_s}$',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'EdgeColor','none')

  y=[ylbottom sealevely];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ylbottom ylbottom],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[yltop yltop],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)+textoffset,sum(y)/2,...
           '$h_{F}$',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'EdgeColor','none')

 elseif setting==2

 % annotations of deformed ice metrics on left hand side
  x=[sealeft sealeft];
  y=[sealevely ydsnow];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ydsnow ydsnow],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[sealevely sealevely],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)-textoffset,sum(y)/2,...
           '$h_{R_f}$',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','right',...
           'EdgeColor','none')

  y=[ydbottom sealevely];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ydbottom ydbottom],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[sealevely sealevely],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)-textoffset,sum(y)/2,...
           '$h_{R_d}$',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','right',...
           'EdgeColor','none')

 end

 if setting==2 | setting==3

 % annotations of level ice metrics on right hand side
  x=[searight searight];
  y=[sealevely ylsnow];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ylsnow ylsnow],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[sealevely sealevely],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)+arrowhead+textoffset,sum(y)/2,...
           '$h_{F_f}$',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'EdgeColor','none')

  y=[ylbottom sealevely];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[ylbottom ylbottom],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[sealevely sealevely],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)+arrowhead+textoffset,sum(y)/2,...
           '$h_{F_d}$',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'EdgeColor','none')

 end

 if setting==3

 % annotate level ice and snow
  text(boxrightx+levelextent/2,(ylbottom+sealevely)/2,...
           {'\makebox[1in][c]{Floe}','\makebox[1in][c]{draft}'},...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize+2,...
           'EdgeColor','none')

  text(boxrightx+levelextent/2,ylsnow,...
           {'\makebox[1in][c]{Floe}'},...
           'Interpreter','Latex',...
           'VerticalAlignment','top',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize,...
           'EdgeColor','none')

  text(boxrightx+levelextent/2,sealevely-0.5*textoffset,...
           {'\makebox[1in][c]{freeboard}'},...
           'Interpreter','Latex',...
           'VerticalAlignment','bottom',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize,...
           'EdgeColor','none')

 % annotations of ridge height and keel depth
  x=[sealeft sealeft];
  y=[sealevely-Hk*scalefactory sealevely];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[y(1) y(1)],...
            'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[sealevely sealevely],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)-textoffset,sum(y)/2,...
           '$H_K$',...
           'Interpreter','Latex',...
           'HorizontalAlignment','right',...
           'VerticalAlignment','middle',...
           'EdgeColor','none')

  y=[sealevely sealevely+Hr*scalefactory];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[y(2) y(2)],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1)-arrowhead x(1)+arrowhead],[sealevely sealevely],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(x(1)-textoffset,sum(y)/2,textbox,...
           '$H_S$',...
           'Interpreter','Latex',...
           'HorizontalAlignment','right',...
           'VerticalAlignment','middle',...
           'EdgeColor','none')

 % annotation of ridge width
  x=[boxcenterx-scalefactorx*Lr/2 boxcenterx+scalefactorx*Lr/2];
  y=[sealevely+Hr*scalefactory+envelope sealevely+Hr*scalefactory+envelope];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1) x(1)],[y(1)-arrowhead y(1)+arrowhead],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(2) x(2)],[y(1)-arrowhead y(1)+arrowhead],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(sum(x)/2,y(1),...
           '$L_S$',...
           'Interpreter','Latex',...
           'VerticalAlignment','bottom',...
           'HorizontalAlignment','center',...
           'EdgeColor','none')

 % annotation of alphak
  radius=(scalefactorx*Lr/2)*0.35;
  theta=-[0:1:atan2d(ylbottom-ykbottom,(boxrightx-boxleftx)/2)];
  x=boxleftx+radius*cosd(theta);
  y=ylbottom+radius*sind(theta);
  line(x,y,'Color','k');

  text(boxleftx+0.06,ylbottom-0.06*tan(alphak*pi/180),...
           '$\alpha_K$',...
           'VerticalAlignment','middle',...
	   'LineWidth',0.4,...
           'Interpreter','Latex',...
           'Fontsize',labelsize+1,...
           'EdgeColor','none');

 % annotation of alphar
  radius=(scalefactorx*Lr/2)*0.35;
  theta=[0:1:atan2d(ylbottom-ykbottom,(boxrightx-boxleftx)/2)];
  x=(boxcenterx-(scalefactorx*Lr/2))+radius*cosd(theta);
  y=ylsnow+radius*sind(theta);
  line(x,y,'Color','k')

  text(x1(1)+0.05,ylsnow+0.05*tan(alphar*pi/180),...
           '$\alpha_S$',...
           'VerticalAlignment','middle',...
	   'LineWidth',0.4,...
           'Interpreter','Latex',...
           'Fontsize',labelsize+1,...
           'EdgeColor','none');

 % add ridge line
  x=[boxcenterx boxrightx];
  y=[(yrtop+ylsnow)/2 (yrtop+ylsnow)/2];
  handle=text(x(1),y(1)+1.75*textoffset,...
           'Sail',...
           'Interpreter','Latex',...
           'VerticalAlignment','top',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize+2,...
           'Color','r',...
           'BackgroundColor','none',...
           'EdgeColor','none');
  uistack(handle,'top')

 % add keel line
  x=[boxcenterx boxrightx];
  y=[(ykbottom+ylbottom)/2 (ykbottom+ylbottom)/2];
  text(x(1),y(1),...
           'Keel',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize+4,...
           'Color','r',...
           'BackgroundColor','none',...
           'EdgeColor','none');

 % annotate deformed ice and snow
  text((boxrightx+boxleftx)/2,(ydbottom+sealevely)/2,...
           {'\makebox[4in][c]{Ridging ice draft with}',...
            '\makebox[4in][c]{volume ${2 V_{R_d}}$}'},...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
           'Interpreter','Latex',...
           'Fontsize',labelsize+2,...
           'EdgeColor','none');

  text((boxrightx+boxleftx)/2,sealevely,...
           {'Freeboard volume ${2 V_{R_f}}$'},...
           'VerticalAlignment','bottom',...
           'HorizontalAlignment','center',...
           'Interpreter','Latex',...
           'Fontsize',labelsize+2,...
           'EdgeColor','none')

 % add axes and aspect ratio annotation 
  x=[boxrightx+2*envelope-2*arrowhead ...
     boxrightx+2*envelope ... 
     boxrightx+2*envelope+2*arrowhead ...
     boxrightx+2*envelope ... 
     boxrightx+2*envelope ...
     boxrightx+2*envelope+scaleaxes ...
     boxrightx+2*envelope+scaleaxes-4*arrowhead ...
     boxrightx+2*envelope+scaleaxes ...
     boxrightx+2*envelope+scaleaxes-4*arrowhead];

  y=[ylbottom-5*envelope-4*arrowhead ...
     ylbottom-5*envelope ...
     ylbottom-5*envelope-4*arrowhead ...
     ylbottom-5*envelope ...
     ylbottom-5*envelope-scaleaxes ...
     ylbottom-5*envelope-scaleaxes ...
     ylbottom-5*envelope-scaleaxes+2*arrowhead  ...
     ylbottom-5*envelope-scaleaxes ...
     ylbottom-5*envelope-scaleaxes-2*arrowhead];

  line(x,y,'Color',greycol)
  
  text(x(2)-textoffset,(y(end-1)+y(1))/2,...
           '$\hat{z}$',...
           'Color',greycol,...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','right',...
           'Interpreter','Latex',...
           'Fontsize',labelsize+3,...
           'EdgeColor','none')

  text((x(2)+x(end-3))/2,y(end-1),...
           '$\hat{x}$',...
           'Color',greycol,...
           'VerticalAlignment','top',...
           'HorizontalAlignment','center',...
           'Interpreter','Latex',...
           'Fontsize',labelsize+3,...
           'EdgeColor','none')

  text((x(2)+x(end-1))/2,(y(end-1)+y(2))/2,...
           {'$\hat{x}$:$\hat{z}$','1:2'},...
           'Color',greycol,...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
           'Interpreter','Latex',...
           'Fontsize',labelsize+3,...
           'EdgeColor','none')

 elseif setting==2

 % annotate level ice and snow
  text(boxrightx+levelextent/2,(ylbottom+sealevely)/2,...
           {'\makebox[1in][c]{Floe}','\makebox[1in][c]{draft}'},...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize+2,...
           'EdgeColor','none')

  text(boxrightx+levelextent/2,ylsnow,...
           {'\makebox[1in][c]{Floe}'},...
           'Interpreter','Latex',...
           'VerticalAlignment','top',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize,...
           'EdgeColor','none')

  text(boxrightx+levelextent/2,sealevely-0.5*textoffset,...
           {'\makebox[1in][c]{freeboard}'},...
           'Interpreter','Latex',...
           'VerticalAlignment','bottom',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize,...
           'EdgeColor','none')

 % annotate deformed ice and snow
  text((boxrightx+boxleftx)/2,(ydbottom+sealevely)/2,...
           {'\makebox[4in][c]{Ridging ice draft with}',...
            '\makebox[4in][c]{volume ${2 V_{R_d}}(1-\phi_R)$}'},...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
           'Interpreter','Latex',...
           'Fontsize',labelsize+2,...
           'EdgeColor','none')

  text((boxrightx+boxleftx)/2,sealevely,...
           {'Freeboard volume ${2 V_{R_f}}(1-\phi_R)$'},...
           'VerticalAlignment','bottom',...
           'HorizontalAlignment','center',...
           'Interpreter','Latex',...
           'Fontsize',labelsize+2,...
           'EdgeColor','none')

 % annotations of keel width
  x=[boxleftx boxrightx];
  y=[ydsnow+envelope ydsnow+envelope];
  line(x,y,'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(1) x(1)],[y(1)-arrowhead y(1)+arrowhead],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  line([x(2) x(2)],[y(1)-arrowhead y(1)+arrowhead],...
           'Color',0.0*[1 1 1],'LineStyle','-');
  text(sum(x)/2,y(1),...
           '$L_K$',...
           'Interpreter','Latex',...
           'VerticalAlignment','bottom',...
           'HorizontalAlignment','center',...
           'EdgeColor','none')


 elseif setting==1

 % annotate level ice and snow
  text(boxrightx+levelextent/2,(ylbottom+yltop)/2,...
           {'\makebox[1in][c]{Floe}','\makebox[1in][c]{ice}'},...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize+2,...
           'EdgeColor','none')

  text(boxrightx+levelextent/2,(yltop+ylsnow)/2,...
           'Snow',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
	   'Color',0.99999*[1 1 1],...
           'Fontsize',labelsize,...
           'EdgeColor','none')

 % annotate deformed ice and snow
  text((boxrightx+boxleftx)/2,(ydbottom+ydtop)/2,...
           {'Ridging ice'},...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
           'Fontsize',labelsize+2,...
           'EdgeColor','none')

  text((boxrightx+boxleftx)/2,(ydtop+ydsnow)/2,...
           'Snow on deforming ice',...
           'Interpreter','Latex',...
           'VerticalAlignment','middle',...
           'HorizontalAlignment','center',...
	   'Color',0.99999*[1 1 1],...
           'Fontsize',labelsize,...
           'EdgeColor','none')

 end

end % for setting=1:3

% determine directory for read/write
dir=fileparts(which(mfilename));
outdir=[dir(1:strfind(dir,'scripts')-1),'output'];
[status,msg]=mkdir(outdir);
cd(outdir);

% determine filename
x=strfind(mfilename,'_');
thisfilename=mfilename;
graphicsout=thisfilename(x(end)+1:end);

% output
disp(['Writing graphics output ',graphicsout,' to:',char(13),' ',pwd])

% print figure
ridgepack_fprint('epsc',graphicsout,1,2)
ridgepack_fprint('png',graphicsout,1,2)

