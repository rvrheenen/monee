import sys
import numpy as np

MODE_COUNTS = "counts"
MODE_SIZES = "sizes"
MODE_STDDEV = "stddev"

# parameters
if len(sys.argv) != 4:
    print("error arguments")
    exit()
binsize, iterations = [int(x) for x in sys.argv[1:3]]
mode = sys.argv[3]

# prepare
organisms = [[] for x in range(int(iterations/binsize) +1)]

# handle input
while True:
    try:
        inp = [int(x) for x in input().split(",")[:4]] # Iteration,Organism,Size,Age,x,y,Agents
        organisms[(inp[0]//binsize)].append(inp[2])
    except EOFError:
        break

# print
if mode == MODE_COUNTS:
    for i in range(len(organisms)):
        orgs = organisms[i]
        print("{} {}".format(i * binsize, len(orgs)))

elif mode == MODE_SIZES:
    for i in range(len(organisms)):
        orgs = organisms[i]
        print("{} {}".format(i * binsize, sum(orgs) / len(orgs) if sum(orgs) != 0 else 0))

elif mode == MODE_STDDEV:
    for i in range(len(organisms)):
        orgs = organisms[i]
        print("{} {}".format(i * binsize, np.std(orgs) if len(orgs) > 0 else 0))

