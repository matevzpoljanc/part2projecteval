import matplotlib.pyplot as plt

with open("reactiveCamlVsIncremental.txt", "r") as file:
	raw_data = file.read().split("\n")

# raw_data = """mean: 1.76e-06 stdev: 4.824e-11 max: 3e-06 min: 9.99999999973e-07
# mean: 2.63e-06 stdev: 5.53099999999e-11 max: 5.00000000001e-06 min: 1.99999999997e-06
# mean: 3.32e-06 stdev: 3.37599999999e-11 max: 6.00000000001e-06 min: 2e-06
# mean: 4.12e-06 stdev: 4.45599999998e-11 max: 6.00000000001e-06 min: 2.99999999998e-06
# mean: 4.8e-06 stdev: 4.8e-11 max: 6.00000000001e-06 min: 3.99999999998e-06
# mean: 6.45e-06 stdev: 3.54749999999e-10 max: 1.6e-05 min: 4.99999999998e-06
# mean: 6.41e-06 stdev: 1.2219e-10 max: 1.6e-05 min: 5.00000000001e-06
# mean: 7.11e-06 stdev: 3.979e-11 max: 8.00000000001e-06 min: 5.99999999998e-06
# mean: 7.89e-06 stdev: 3.979e-11 max: 9.00000000001e-06 min: 6.99999999998e-06
# mean: 8.67e-06 stdev: 1.1011e-10 max: 1.7e-05 min: 7.99999999995e-06"""

parsed_data = []
# print("\n".join(raw_data))

for line in range(len(raw_data)):
	if line % 11 == 0:
		continue
	parsed_data.append(list(map(float,raw_data[line].split()[1::2])))

means = [el[0] * 10**6 for el in parsed_data]
st_dev = [el[1] * 10**6 for el in parsed_data]
iterations = [100*i for i in range(1,11)]

plt.errorbar(iterations, means[:10], yerr=st_dev[:10], fmt="o-", label="ReactiveCaml")
plt.errorbar(iterations, means[10:20], yerr=st_dev[10:20], fmt="o-", label="Incremental")
plt.title("Running time in relation to number of changes in x0 with result observed on every data change")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of data changes")
plt.ylabel("Total running time (ms)")
plt.legend()
plt.show()

plt.plot(iterations, means[:10], "o-", label="ReactiveCaml")
plt.plot(iterations, means[20:], "o-", label="Incremental")
plt.title("Running time in relation to number of changes in x0 with result observed after all data changes")
plt.grid(True, linestyle='-.')
plt.xlabel("Number of data changes")
plt.ylabel("Total running time (ms)")
plt.legend()

plt.show()
# print(means)