import sys
import numpy as np


def make_number(x):
    try:
        return int(x)
    except ValueError:
        try:
            return float(x)
        except:
            return x

MODE_COUNTS = "counts"
# MODE_SIZES = "sizes"
# MODE_STDDEV = "stddev"

# parameters
if len(sys.argv) != 4:
    print("error arguments")
    exit()
binsize, iterations = [int(x) for x in sys.argv[1:3]]
mode = sys.argv[3]

# prepare
steals = [0 for x in range(int(iterations/binsize) +1)]

# handle input
while True:
    try:
        inp = [make_number(x) for x in input().split()] # iterations thisId thisScore otherId otherScore amountstolen amountafter

        steals[(inp[0]//binsize)] += 1
    except EOFError:
        break

# print
if mode == MODE_COUNTS:
    for i in range(len(steals)):
        # orgs = steals[i]
        print("{} {}".format(i * binsize, steals[i] ))

# elif mode == MODE_SIZES:
#     for i in range(len(steals)):
#         orgs = steals[i]
#         print("{} {}".format(i * binsize, sum(orgs) / len(orgs) if sum(orgs) != 0 else 0))

# elif mode == MODE_STDDEV:
#     for i in range(len(steals)):
#         orgs = steals[i]
#         print("{} {}".format(i * binsize, np.std(orgs) if len(orgs) > 0 else 0))

