import matplotlib.pyplot as plt
import sys

with open("irminFs.txt", "r") as file:
	raw_data = file.read().split("\n")

parsed_data = ([], [], [])
index = 2
for line in range(len(raw_data)):
	if raw_data[line].startswith("u"):
		parsed_data[0].append(index)
		index += 1
		parsed_data[1].append(int(raw_data[line].split()[-1]))
		parsed_data[2].append(int(raw_data[line].split()[-1])*2)

	else:
		continue
		# print(raw_data[line])
		# parsed_data[0].append(int(raw_data[line].split()[-1]))
		# parsed_data[1].append(int(raw_data[line + 1].split()[-1]))
		# parsed_data[2].append(int(raw_data[line + 2].split()[-1]))

print(parsed_data)
# print(parsed_data[0])
fig, ax = plt.subplots(figsize=(12, 7))

ax.set_yscale("log", nonposy='clip', basey=2)
ax.errorbar(parsed_data[0], parsed_data[1], fmt="-x", label="Sharing file-system location", capsize=6, elinewidth=0.8, lw=0.8)
ax.errorbar(parsed_data[0], parsed_data[2], fmt="--o", label="Separate file-system locations", capsize=6, elinewidth=0.8, lw=0.8)

plt.title("Memory used for storage of results in relation to number of nodes in a graph\n", size="xx-large", weight="heavy")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of nodes in a graph", size="x-large")
plt.ylabel("Memory used (Bytes)", size="x-large")
plt.legend(prop={'size':18})

fig.savefig("graphs/irminFs.png", dpi=300)