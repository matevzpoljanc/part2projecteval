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


plt.errorbar(parsed_data[0][0], parsed_data[0][1], fmt="-x", label="Local hash-table", capsize=3, elinewidth=0.8, lw=0.8)
plt.errorbar(parsed_data[0][0], parsed_data[0][2], fmt="-x", label="Global hash-table", capsize=3, elinewidth=0.8, lw=0.8)
plt.title("Number of allocated words in relation to number of memoized functions")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of memoized functions")
plt.ylabel("Number of allocated words")
plt.legend()
plt.show()

filter_nmb = 1
plt.errorbar(parsed_data[1][0][::filter_nmb], parsed_data[1][1][::filter_nmb], fmt="-", label="Local hash-table", capsize=3, elinewidth=0.8, lw=0.8)
plt.errorbar(parsed_data[1][0][::filter_nmb], parsed_data[1][2][::filter_nmb], fmt="-", label="Global hash-table", capsize=3, elinewidth=0.8, lw=0.8)
plt.title("Number of allocated words in relation to number of calls to memoized function")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of calls to memoized function")
plt.ylabel("Number of allocated words")
plt.legend()
plt.show()

no_outliers = []
for i in range(len(parsed_data[1][2])):
	if i+1 < len(parsed_data[1][2]):
		if parsed_data[1][2][i+1] < parsed_data[1][2][i]:
			continue
	no_outliers.append((parsed_data[1][0][i], parsed_data[1][2][i]))

x_axis = list(zip(*no_outliers))[0]
y_axis = list(zip(*no_outliers))[1]

plt.errorbar(parsed_data[1][0][::filter_nmb], parsed_data[1][1][::filter_nmb], fmt="-", label="Local hash-table", capsize=3, elinewidth=0.8, lw=0.8)
plt.errorbar(x_axis, y_axis, fmt="-", label="Global hash-table", capsize=3, elinewidth=0.8, lw=0.8)
plt.title("Number of allocated words in relation to number of calls to memoized function")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of calls to memoized function")
plt.ylabel("Number of allocated words")
plt.legend()
plt.show()

cnt = 0
for i in range(len(parsed_data[1][1])):
	if parsed_data[1][2][i] < parsed_data[1][1][i]:
		cnt += 1

print("Local better:", len(parsed_data[1][1])-cnt, "Global better:", cnt)
