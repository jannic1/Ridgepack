


rasmcases={'R1847_cice6_RBR_test00'};
quicknames={'CICE_6'};

pubdir='/Users/aroberts/science/publications/2018_RASM/Figures'


%springfall={'spring','fall'};
springfall={'spring'};
columns=5;

pub=false;

for j=1:length(springfall)

 Ridgepack_RASM_sea_ice_icesat_diff(rasmcases,char(springfall{j}),quicknames,columns,pub)

end


