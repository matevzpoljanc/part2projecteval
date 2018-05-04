import matplotlib.pyplot as plt
import sys

with open("hashTblVsIrmin.txt", "r") as file:
	raw_data = file.read().split("\n")

parsed_data = ([], [], [])
for line in range(len(raw_data)):
	if not raw_data[line].startswith("Length"):
		continue

	else:
		# print(raw_data[line])
		parsed_data[0].append(int(raw_data[line].split()[-1]))
		parsed_data[1].append(int(raw_data[line + 1].split()[-1]))
		parsed_data[2].append(int(raw_data[line + 2].split()[-1]))
		# parsed_data[test][0].append(int(raw_data[line].split()[-1]))
		# parsed_data[test][1].append(int(raw_data[line+1].split()[-1]))
		# parsed_data[test][2].append(int(raw_data[line+2].split()[-1]))

# print(parsed_data[0])
fig, ax = plt.subplots(figsize=(12, 7))

ax.set_yscale("log", nonposy='clip', basey=2)
ax.errorbar(parsed_data[0], parsed_data[1], fmt="-x", label="In-memory Irmin", capsize=6, elinewidth=1, lw=1)
ax.errorbar(parsed_data[0], parsed_data[2], fmt="--o", label="Global hash-table", capsize=6, elinewidth=1, lw=1)

plt.title("Number of live words in relation to length of an argument list\n", size="xx-large", weight="heavy")
plt.grid(True, linestyle='-.')
plt.xlabel("Length of an list", size="x-large")
plt.ylabel("Number of live words", size="x-large")
plt.legend(prop={'size':18})

fig.savefig("graphs/hashTblVsIrmin.png", dpi=300)

# plt.show()