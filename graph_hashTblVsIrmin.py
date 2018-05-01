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
fig, ax = plt.subplots()

ax.set_yscale("log", nonposy='clip', basey=2)
ax.errorbar(parsed_data[0], parsed_data[1], fmt="-x", label="In-memory Irmin", capsize=3, elinewidth=0.8, lw=0.8)
ax.errorbar(parsed_data[0], parsed_data[2], fmt="-x", label="Global hash-table", capsize=3, elinewidth=0.8, lw=0.8)

plt.title("Number of live words in relation to length of an argument list")
plt.grid(True, linestyle='-.')
plt.xlabel("Length of an list")
plt.ylabel("Number of live words")
plt.legend()
plt.show()