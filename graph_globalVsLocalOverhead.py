import matplotlib.pyplot as plt
import sys

with open("globalVsLocalOverhead_1.txt", "r") as file:
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

fig1.savefig("graphs/glovVsLocal_numberOfFunctions.png", dpi=300)

plt.show()


fig2, ax2 = plt.subplots(figsize=(12, 7))

filter_nmb = 1
ax2.errorbar(parsed_data[1][0][::filter_nmb], parsed_data[1][1][::filter_nmb], fmt="-", label="Local hash-table", capsize=3, elinewidth=1, lw=1)
ax2.errorbar(parsed_data[1][0][::filter_nmb], parsed_data[1][2][::filter_nmb], fmt="--", label="Global hash-table", capsize=3, elinewidth=1, lw=1)
plt.title("Number of allocated words in relation to number of calls to memoized function\n", size="xx-large", weight="heavy")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of calls to memoized function", size="x-large")
plt.ylabel("Number of allocated words", size="x-large")
plt.legend(prop={'size':18})

fig2.savefig("graphs/glovVsLocal_numberOfCalls.png", dpi=300)

plt.show()

no_outliers = []
for i in range(len(parsed_data[1][2])):
	if i+1 < len(parsed_data[1][2]):
		if parsed_data[1][2][i+1] < parsed_data[1][2][i]:
			continue
	no_outliers.append((parsed_data[1][0][i], parsed_data[1][2][i]))

x_axis = list(zip(*no_outliers))[0]
y_axis = list(zip(*no_outliers))[1]

fig3, ax3 = plt.subplots(figsize=(12, 7))

ax3.errorbar(parsed_data[1][0][::filter_nmb], parsed_data[1][1][::filter_nmb], fmt="-", label="Local hash-table", capsize=3, elinewidth=1, lw=1)
ax3.errorbar(x_axis, y_axis, fmt="--", label="Global hash-table", capsize=3, elinewidth=1, lw=1)
plt.title("Number of allocated words in relation to number of calls to memoized function\n", size="xx-large", weight="heavy")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of calls to memoized function", size="x-large")
plt.ylabel("Number of allocated words", size="x-large")
plt.legend(prop={'size':18})

fig3.savefig("graphs/glovVsLocal_numberOfCalls_filtered.png", dpi=300)

plt.show()

cnt = 0
for i in range(len(parsed_data[1][1])):
	if parsed_data[1][2][i] < parsed_data[1][1][i]:
		cnt += 1

print("Local better:", len(parsed_data[1][1])-cnt, "Global better:", cnt)
