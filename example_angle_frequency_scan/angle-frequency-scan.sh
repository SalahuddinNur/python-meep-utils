#!/bin/bash
if [ -z $NP ] ; then NP=2 ; fi			 # number of processors
if [ -z $ext ] ; then ext=png ; fi             # number of processors

if [ -z "$model" ] ;   then model=HalfSpace ; fi
if [ -z "$simtime" ] ; then simtime=500f ; fi
if [ -z "$blend" ] ;   then blend=0 ; fi
if [ -z "$comment" ] ; then comment=x ; fi
if [ -z "$epsilon" ] ; then epsilon=1 ; fi
if [ -z "$padding" ] ; then padding=.5u ; fi



if [ -z "$skipsimulation" ]; then 
	## For normal optical simulations
    #for K in 0.1 0.3 ; do #`seq 0 2 9` `seq 12 6 60`; do    ## transverse wavenumber in 1/um 
    for K in 0.1 0.3 `seq 0 1 11` `seq 12 1 32`; do    ## transverse wavenumber in 1/um 
        mpirun -np $NP  ../../scatter.py resolution=30n  model=$model $Kcomponent=${K}e6 \
			blend=$blend comment=$comment  epsilon=$epsilon 
    done
	## For deep-UV gratings
    #for K in 0.1 0.3 `seq 0 2 9` `seq 12 6 60`; do    ## transverse wavenumber in 1/um
        #mpirun -np $NP  ../../scatter.py  "${@}" $Kcomponent=${K}e7
    #done
fi


## Resolve the angle of incidence from the magnitude of the wavevector and its transverse component and plot
rm last_simulation_name.dat
plotoptions=(*.dat  --xlabel     'Frequency'   \
        --paramname Kx  --paramlabel 'Angle $a$' --parameval "np.arcsin(param*c/2/np.pi/x)/np.pi*180" \
        --contours yes  --numcontours 50  --colormap gist_earth  --figsizex 4  --figsizey 3 --interp_aspect .5)

## (place small grey dot at each resolved point for better understanding which points were actually computed)
../../plot_multiline.py "${plotoptions[@]}" --ycol '|r|'    --ylabel 'Reflectance   $|r|$'  --ylim1 0 --ylim2 1 \
        --output ../${PWD##*/}_r.$ext 


## Clean up
if [ -z "$skipsimulation" ]; then 
    rm -r ${model}*/ ${model}*.dat
fi
