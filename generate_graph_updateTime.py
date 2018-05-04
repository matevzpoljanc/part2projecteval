import matplotlib.pyplot as plt

with open("updateTime.txt", "r") as file:
	raw_data = file.read().split("\n")


parsed_data = []

for line in range(len(raw_data)):
	if line % 15 == 0:
		continue
	parsed_data.append(list(map(float,raw_data[line].split()[1::2])))

means = [el[0] * 10**3 for el in parsed_data]
st_dev = [el[1] * 10**3 for el in parsed_data]
nmb_nodes = [2**i for i in range(2,16)]


fig, ax = plt.subplots(figsize=(12, 7))

ax.set_xscale("log", nonposx='clip', basex=2)
ax.errorbar(nmb_nodes, means[len(nmb_nodes):], yerr=st_dev[len(nmb_nodes):], fmt="-x", label="ReactiveCaml", capsize=3, elinewidth=1, lw=1)
ax.errorbar(nmb_nodes, means[:len(nmb_nodes)], yerr=st_dev[:len(nmb_nodes)], fmt="--o", label="Incremental", capsize=3, elinewidth=1, lw=1)

plt.title("Update time in relation to the number of nodes in a Merkle tree\n", size="xx-large", weight="heavy")
plt.xlabel("Number of nodes in a tree", size="x-large")
plt.ylabel("Update time (ms)", size="x-large")
plt.legend(prop={'size':18})
plt.grid(True, linestyle='-.')

fig.savefig("graphs/updateTime.png", dpi=300)

# plt.show()