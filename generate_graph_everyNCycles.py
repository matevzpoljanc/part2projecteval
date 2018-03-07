import matplotlib.pyplot as plt

with open("observeEverNCycles.txt", "r") as file:
	raw_data = file.read().split("\n")


parsed_data = []

for line in range(len(raw_data)):
	if line % 10 == 0:
		continue
	parsed_data.append(list(map(float,raw_data[line].split()[1::2])))

means = [el[0] * 10**6 for el in parsed_data]
st_dev = [el[1] * 10**6 for el in parsed_data]
cycles = list(range(1,10))

plt.errorbar(cycles, means[:len(cycles)], yerr=st_dev[:len(cycles)], fmt="x-", label="ReactiveCaml", capsize=3, elinewidth=0.8, lw=0.8)
plt.errorbar(cycles, means[len(cycles):], yerr=st_dev[len(cycles):], fmt="x-", label="Incremental", capsize=3, elinewidth=0.8, lw=0.8)
plt.title("Running time if result is observed after every n changes in x0")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of changes in x0")
plt.ylabel("Total running time (µs)")
plt.legend()

plt.show()

plt.plot(cycles, means[:len(cycles)], "x-", label="ReactiveCaml", lw=0.8)
plt.plot(cycles, means[len(cycles):],  "x-", label="Incremental", lw=0.8)
plt.title("Running time if result is observed after every n changes in x0")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of changes in x0")
plt.ylabel("Total running time (µs)")
plt.legend()

plt.show()