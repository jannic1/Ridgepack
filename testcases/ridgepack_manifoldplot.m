function ridgepack_manifoldplot

% function ridgepack_manifoldplot
%
% This function generates a cross-section of the potential energy density 
% manifold on alpha-hat space, as presented in Figure 11 of the paper submitted
% to JAMES. 
% 
% Ridgepack Version 1.0
% Andrew Roberts, Naval Postgraduate School, March 2018 (afrobert@nps.edu)

% clear all variables and graphics
clear
figure(1)
clf

% set Latex intepreter for graphics
set(0,'DefaultTextInterpreter','Latex')

% set constants
[rhoi,rhos,rhow,delrho,g,eincr,hincr,minthick,maxthick]=ridgepack_constants;

% set thickness of paranet ice and snow
hfii=[0.5 2.0]; % thickness of initial ice
hfsi=[0.0 0.0]; % thickness of snow on the initial ice

% create strain and phi coordinates
[hgrid,epsiloni,phii]=ridgepack_gridinit;
[epsilon,phi]=meshgrid(epsiloni,phii);

% ALPHAHAT color contours (degrees)
AKS=[0:2:30];

% set colormap and line colors
cols=lines(7);
cmap=ridgepack_colormap(AKS,0,'bluered',true);
cmap=flipud(cmap);
colormap(cmap);

% initiate dynamic limits on vertical plot extent
minpe=10^11;
maxpe=0;

% generate manifolds
for i=1:length(hfii)

 [vr,ALPHAHAT,HK,HS,LK,LS]=ridgepack_energetics(hfii(i),hfsi(i),epsilon,phi); 

 % set dynamic vertical limits 
 minpe=min(minpe, min(vr(:)));
 maxpe=max(maxpe, max(vr(:)));

 % set color scale
 [zindex,truecol]=ridgepack_colorindex(ALPHAHAT,AKS,0);

 % plot surface
 surface(epsilon,phi,vr,truecol,'FaceAlpha',0.85,'EdgeColor','k')

 % remove grid on the surface
 shading flat

 % hold for further additions to figure
 hold on

 % Dashed line for lower leaf lines, full strength for top leaf
 if i==length(hfii)
  linestyle='-';
 else
  linestyle=':';
 end

 % find contour values of observed keel depth (Melling and Riedel, 1996)
 hfd=(rhoi*hfii(i)+rhos*hfsi(i))/rhow; 
 contval=16*sqrt(hfd);
 ssk=NaN*zeros(size(phii));
 vrk=NaN*zeros(size(phii));
 for j=1:length(phii);
   ix=find(abs(HK(j,:)-contval)==min(abs(HK(j,:)-contval)));
   ssk(j)=epsilon(j,ix);
   vrk(j)=vr(j,ix);
   if ix==1
    break
   end
 end
 phk=phii(~isnan(vrk));
 ssk=ssk(~isnan(vrk));
 vrk=vrk(~isnan(vrk));
 line(ssk,phk,vrk,'Color',cols(5,:),'LineStyle',linestyle)

 % annotate max observed keel on top leaf
 if i==length(hfii)
  text(ssk(end),phk(end)-0.02,vrk(end)*1.2,...
            '$H_K=16\sqrt{h_{F_d}}\qquad$',...
            'Color',cols(5,:),...
            'Fontsize',8,...
            'Rotation',-18.5,...
            'VerticalAlignment','top',...
            'HorizontalAlignment','right',...
            'Interpreter','Latex')
 end

 % find contour values of observed sail height (Tucker et al. 1984)
 contval=5.24*sqrt(hfii(i));
 sss=NaN*zeros(size(phii));
 vrs=NaN*zeros(size(phii));
 for j=1:length(phii);
   ix=find(abs(HS(j,:)-contval)==min(abs(HS(j,:)-contval)));
   sss(j)=epsilon(j,ix);
   vrs(j)=vr(j,ix);
   if ix==1
    break
   end
 end
 phs=phii(~isnan(vrs));
 sss=sss(~isnan(vrs));
 vrs=vrs(~isnan(vrs));
 line(sss,phs,vrs,'Color','w','LineStyle',linestyle)

 % annotate max observed sail on top leaf
 if i==length(hfii)
  text(sss(end),phs(end),vrs(end),'$H_S=5.24\sqrt{h_{F}}\qquad$',...
            'Color','w',...
            'Fontsize',8,...
            'Rotation',-18.5,...
            'VerticalAlignment','bottom',...
            'HorizontalAlignment','right',...
            'Interpreter','Latex')
 end

 % finish with annotations to here
 drawnow

 % calculate zeta-hat trajectory
 [EPSILON,PHI,ALPHAHAT,VR]=ridgepack_trajectory(hfii(i),hfsi(i));

 % only plot up to a min strain of -0.98
 idx=find(EPSILON>=-0.98);
 EPSILON=EPSILON(idx);
 PHI=PHI(idx);
 VR=VR(idx);

 % plot ridging path
 plot3(EPSILON,PHI,VR,'r','LineStyle',linestyle)

 % Notation of mean path
 if i==length(hfii)
  text(EPSILON(end)+0.025,PHI(end),VR(end)*1.5,...
           ['$\hat{\zeta}$'],...
            'Color','r',...
            'Fontsize',10,...
            'Rotation',10,...
            'Margin',0.5,...
            'VerticalAlignment','bottom',...
            'HorizontalAlignment','center',...
            'Interpreter','Latex')
 end

 % arrow head of mean path
 text(EPSILON(end)+0.006,PHI(end)-0.0045,VR(end)*1.05,...
                 ['$\bigtriangleup$'],...
                 'Color','r',...
                 'Fontsize',7,...
                 'Rotation',10,...
                 'VerticalAlignment','baseline',...
                 'HorizontalAlignment','center',...
                 'Interpreter','Latex')

 % plot the thickness of each leaf
 idx=find(abs(phii(:)-0.4)==min(abs(phii(:)-0.4)));
 text(epsilon(idx,1),phi(idx,1),vr(idx,1),...
                 ['$h_{F}\!=\!',num2str(hfii(i),'%1.1f'),'$m'],...
                 'Color','k',...
                 'Fontsize',12,...
                 'Rotation',30,...
                 'VerticalAlignment','bottom',...
                 'HorizontalAlignment','left',...
                 'Interpreter','Latex')

 % plot points along path to correspond with other figures
 if i==length(hfii)
  colplo={[0.5 0 1.0],[0.5 0 0.5],[0.75 0.25 0.25],[1 0.25 0]};
  erplor=[0,-0.2,-0.4,-0.6];
  for m=1:length(erplor)
   idx=find(abs(EPSILON(:)-erplor(m))==min(abs(EPSILON(:)-erplor(m))));
   plot3(EPSILON(idx),PHI(idx),1.1*VR(idx),'o','MarkerFaceColor','w',...
         'Color',colplo{m},'MarkerSize',4)
   plot3(EPSILON(idx),PHI(idx),1.1*VR(idx),'+',...
         'Color',colplo{m},'MarkerSize',4)
  end
 end
 

end


% set the dynamic limits
xlim([-1 0])
ylim([0 1])
zlim([minpe maxpe])

% plot the colorbar
ridgepack_colorbar(AKS,'{\widehat{\alpha}_R}^{\circ}');

% set the viewing angle
view(45,30)

% fiddle to get the grid to plot
grid 
grid off
grid on

% set log scale for z-axis 
set(gca,'ZScale','log','ZMinorTick','off','Box','on','TickLabelInterpreter','Latex')

% set tick marks
set(gca,'Xtick',[-1:0.1:0])
set(gca,'Ytick',[0:0.1:1])

% changes the position
set(gca,'Position',[0.1 0.08 0.7 0.9])

% axis labels (fiddle with positions to overcome MATLAB bug)
zpos=(10.^(log10(minpe)-0.075*(log10(maxpe)-log10(minpe))));
xlabel('Strain, $\epsilon_{R_I}$','Interpreter','Latex','HorizontalAlignment','center',...
       'Position',[-0.5 -0.086 zpos],'fontsize',12,'Rotation',-24)
ylabel('Porosity, $\phi_R$','Interpreter','Latex','HorizontalAlignment','center',...
       'Position',[0.086 0.5 zpos],'fontsize',12,'Rotation',24)
zlabel('Potential Energy Density, $\mathcal{V}_R$ (J m$^{-2}$)',...
       'Interpreter','Latex','fontsize',12)

% determine directory for read/write of zeta-hat plane data
writedir=[fileparts(which('ridgepack')),'/figures'];
cd(writedir)

% plot figures
ridgepack_fprint('png','ridgepack_manifoldplot',1,2)
ridgepack_fprint('epsc','ridgepack_manifoldplot',1,2)

