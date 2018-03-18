function [GHPHI]=ridgepack_redistribution(ghphi,hgrid,phigrid,epsilondot,dt)

% RIDGEPACK_REDISTRIBUTION - Redistribution function Psi
%
% function [g]=ridgepack_redistribution(g,epsilondot,dt)
%
% Thid function calculate Psi in the sea ice mass conservation 
% equation for a bivariate thickness distribution that is a function
% of both thickness and macroporosity.
%
% INPUT:
%
% ghphi      - bivariate sea ice thickness distribution at time ti
% epsilondot - strain rate in an area A (/second)
% deltat     - timestep deltat = tf - ti (seconds)
%
%
% OUTPUT:
%
% GHPHI - bivariate sea ice thickness distribution at time tf
%
% Ridgepack Version 1.0.
% Andrew Roberts, Naval Postgraduate School, March 2018 (afrobert@nps.edu)

global debug;
if debug; disp(['Entering ',mfilename,'...']); end

% check there are sufficient inputs
if nargin~=3
 error('incorrect number of inputs')
end

% initialize ar and GHPHI
ar=zeros(size(ghphi));
GHPHI=zeros(size(ghphi));

% NOTES
Need a non-deformed initial distribution g(h) following the ice, and 
then the thickness distribution g(h,phi), of which the first category it the
minimum strain category, indicating how much of the ice is not deformed

% Calculate the zeta-hat plane. Please note that this function is dependent 
% on snow cover, but for the purpose of the paper that Ridgepack Version 1.0 
[HF,EPSILON,PHI,ALPHAHAT,VR,HK,HS,LK,LS]=ridgepack_zetahatplane;
HFs=zeros(size(HF));

% Only include thickness within the range of the chosen ridge (this
% can be adjusted for Earth System Model with variable thicknesses grid.)
VR(HK+HS>max(hgrid))=0;

% work per ridge shape M x N, where gin(1,:) is the concentration 
% of ice with zero porosity, and is therefore unridged
denominator=LK(:,:).*VR(:,:);
energyratio=sum(denominator(:))./denominator;

% probability of a ridge forming with strain and parent ice thickness HF
% with discrete distribution ghphi.
numerator=ghphi(:,1).*energyratio;
numerator(VR==0)=0;
probability=numerator./sum(numerator(:));

% calculate normlized ghphi
ghphinormal=ghphi./sum(ghphi(:));

% debug information 
if debug
 disp(['size of ghphi is ',num2str(size(ghphi))])
 disp(['size of ar is ',num2str(size(ar))])
 disp(['size of LK is ',num2str(size(LK))])
 disp(['size of LS is ',num2str(size(LS))])
 disp(['size of VR is ',num2str(size(VR))])
 disp(['size of HF is ',num2str(size(HF))])
 disp(['size of EPSILON is ',num2str(size(EPSILON))])
 disp(['size of energyratio is ',num2str(size(energyratio))])
 disp(['size of probability is ',num2str(size(probability))])
end

% only do calculations where there is ice
hidx=find(ghphi(:,1)>0);

% Integral transform:

% Calculate ar dependent on strain for the area change from non-porous ice
% where i represents the undeformed ice index, and j is the strain index.
for i=hidx'
 for j=1:length(EPSILON)

  if VR(i,j)>0

   % map PHI on EPSILON grid to phigrid used by GHPHI
   pidx=find(min(abs(PHI(i,j)-phigrid))==abs(PHI(i,j)-phigrid));

   % calculate step function for an indidividual ridge
   GRHPHI=ridgepack_grhphi(HF(i),HFs(i),EPSILON(j),PHI(i,j));
   
   % now determine total area based on strain and probability of occurrence
   ar(:,pidx)=probability(i,j)*(1+EPSILON(j))*GRHPHI(:) + ar(:,pidx);
  
  end

 end
end

% Now calculate the transform of porous ice
for j=2:length(phigrid)-1

 jdx=find(phigrid>phigrid(j));

 weight(j)=sum(ghphinormal(:,j));

 ar(:,j)=ar(:,j)-weight(j)*ghphi(:,j);

 ar(:,jdx)=weight(j).*ghphi(:,jdx) + ar(:,jdx);

end



% finish determining by determining gout       
%GHPHI(:,2:end)=ar(:,2:end)+ghphi(:,2:end);
%GHPHI(:,1)=ar(:,1);
GHPHI=ar;

if debug; disp(['...Leaving ',mfilename]); end


