from __future__ import print_function, division
import numpy as np
import matplotlib as mpl
mpl.use('TkAgg')
import matplotlib.pyplot as plt
import sys

## states
state = [
    "CT",
    "NY",
    "NJ",
    "PA",
    "MD",
    "DC",
    "VA",
    "GA",
    "FL",
    "MI",
    "OH",
    "IN",
    "KY",
    "AL",
    "MS",
    "WI",
    "MN",
    "IL",
    "IA",
    "MO",
    "AR",
    "LA",
    "ND",
    "SD",
    "NE",
    "OK",
    "TX",
    "MT",
    "CO",
    "NM",
    "UT",
    "NV",
    "AZ",
    "CA",
    "Chihuahua",
    "Sopnora",
    "Tamaulipas",
    "Baja California"
]

state_colours = [mpl.colors.rgb2hex(mpl.cm.viridis(i)) for i in np.linspace(0,1,len(state))]

## lineages / strains / clades (they're not monophyletic)
wnv_strain = ["NY99", "SW03", "WN02"]
wnv_strain_colours = ["#CBB742", "#7EB876", "#4988C5"]

## hosts
# use the tab20c scale - https://matplotlib.org/examples/color/colormaps_reference.html
cols = [mpl.colors.rgb2hex(mpl.cm.tab20c(i)) for i in range(0,20)]
host =         ["Bird-crow", "Bird-other", "Human", "Mosquito-Aedes", "Mosquito-Culex", "Mosquito-Culiseta", "Mosquito-other", "Horse", "Squirrel", "Unknown"]
host_colours = [cols[0],     cols[1],      cols[4],  cols[8],          cols[9],          cols[10],           cols[11],         cols[12], cols[13],  "#DDDDDD"]

with open(sys.argv[1], "w") as fh:
    fh.write("## STATES ##\n")
    for pair in zip(state, state_colours):
        fh.write("{}\t{}\t{}\n".format("state", pair[0], pair[1]))
    fh.write("## LINEAGES ##\n")
    for pair in zip(wnv_strain, wnv_strain_colours):
        fh.write("{}\t{}\t{}\n".format("wnv_strain", pair[0], pair[1]))
    fh.write("## HOSTS ##\n")
    for pair in zip(host, host_colours):
        fh.write("{}\t{}\t{}\n".format("host", pair[0], pair[1]))
    fh.write("## COUNTRIES ##\n")
    fh.write("country\tUSA\t#511ea8\n")
    fh.write("country\tMexico\t#dc2f24\n")
    fh.write("## END ##\n")
