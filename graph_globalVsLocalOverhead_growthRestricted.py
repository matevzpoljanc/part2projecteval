import matplotlib.pyplot as plt
import sys

with open("globalVsLocalOverhead.txt", "r") as file:
	raw_data = file.read().split("\n")

parsed_data = [([], [], []), ([], [], [])]
test = -1
for line in range(len(raw_data)):
	if raw_data[line].startswith("Test"):
		test += 1
		continue

	elif raw_data[line].startswith("Number"):
		# print(raw_data[line])
		parsed_data[test][0].append(int(raw_data[line].split()[-1]))
		parsed_data[test][1].append(int(raw_data[line+1].split()[-1]))
		parsed_data[test][2].append(int(raw_data[line+2].split()[-1]))

	else:
		continue

# print(parsed_data[0])
fig1, ax1 = plt.subplots(figsize=(12, 7))

ax1.errorbar(parsed_data[0][0], parsed_data[0][1], fmt="-x", label="Local hash-table", capsize=3, elinewidth=1, lw=1)
ax1.errorbar(parsed_data[0][0], parsed_data[0][2], fmt="--o", label="Global hash-table", capsize=3, elinewidth=1, lw=1)
plt.title("Number of allocated words in relation to number of memoized functions\n", size="xx-large", weight="heavy")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of memoized functions", size="x-large")
plt.ylabel("Number of allocated words", size="x-large")
plt.legend(prop={'size':18})

fig1.savefig("graphs/glovVsLocal_numberOfFunctions_noGrowth.png", dpi=300)

plt.show()