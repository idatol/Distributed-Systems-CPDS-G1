# Part 3 – Performance experiments

This file lists the commands used for the Part 3 experiments, in the order they were run.

Every experiment uses the test module:

```erlang
opty:start(Clients, Entries, Reads, Writes, Time).
```

| Argument | Meaning |
|---|---|
| `Clients` | Number of concurrent clients |
| `Entries` | Number of entries in the store |
| `Reads` | Read operations per transaction |
| `Writes` | Write operations per transaction |
| `Time` | Duration of the run, in seconds |

When a run finishes, each client prints its total number of transactions, the number that committed, and its success rate.

## 0. Setup

Start the Erlang shell from this folder and compile all the modules:

```bash
cd Lab2-opty/opty-source-files
erl
```

```erlang
c(entry), c(store), c(handler), c(validator), c(server), c(client), c(opty).
```

> If a run crashes halfway, the server name `s` stays registered and the next
> call fails with `badarg`. Run `unregister(s).` or restart the shell.

## 1. Baseline

The baseline is a configuration with few conflicts. Each experiment below changes **one** parameter and keeps the rest at these values:

| Clients | Entries | Reads | Writes | Time |
|---|---|---|---|---|
| 4 | 1000 | 5 | 5 | 5 |

```erlang
opty:start(4, 1000, 5, 5, 5).
```

## 2. Experiment (i): number of clients

```erlang
opty:start(1, 1000, 5, 5, 5).
opty:start(2, 1000, 5, 5, 5).
opty:start(4, 1000, 5, 5, 5).
opty:start(8, 1000, 5, 5, 5).
opty:start(16, 1000, 5, 5, 5).
```

### Results
1 -> 1: Transactions TOTAL:251824, OK:251824, -> 100.0 % 

2 -> 2: Transactions TOTAL:161220, OK:159279, -> 98.79605508001488 % 
    1: Transactions TOTAL:161299, OK:159435, -> 98.84438217223914 % 

4 -> 4: Transactions TOTAL:84610, OK:81161, -> 95.92364968679826 % 
    1: Transactions TOTAL:84601, OK:81179, -> 95.95513055401237 % 
    2: Transactions TOTAL:84527, OK:81076, -> 95.91728086883481 % 
    3: Transactions TOTAL:84632, OK:81195, -> 95.93888836373948 % 

8 -> 3: Transactions TOTAL:51358, OK:46391, -> 90.32867323493906 % 
    8: Transactions TOTAL:51384, OK:46377, -> 90.25572162540868 % 
    7: Transactions TOTAL:51457, OK:46418, -> 90.20735759954914 % 
    1: Transactions TOTAL:51365, OK:46353, -> 90.24238294558552 % 
    4: Transactions TOTAL:51312, OK:46284, -> 90.20112254443406 % 
    6: Transactions TOTAL:51460, OK:46530, -> 90.41974349008939 % 
    5: Transactions TOTAL:51290, OK:46242, -> 90.15792552154416 % 
    2: Transactions TOTAL:51286, OK:46409, -> 90.49058222516867 % 

16 -> 1: Transactions TOTAL:23849, OK:18733, -> 78.54836680783261 % 
    13: Transactions TOTAL:23833, OK:18648, -> 78.24445097134226 % 
    8: Transactions TOTAL:23852, OK:18685, -> 78.33724635250712 % 
    3: Transactions TOTAL:23837, OK:18711, -> 78.49561605906784 % 
    10: Transactions TOTAL:23842, OK:18765, -> 78.70564549953863 % 
    4: Transactions TOTAL:23856, OK:18646, -> 78.16063044936284 % 
    7: Transactions TOTAL:23854, OK:18533, -> 77.69346860065397 % 
    12: Transactions TOTAL:23851, OK:18784, -> 78.75560773133202 % 
    5: Transactions TOTAL:23859, OK:18637, -> 78.11308101764533 % 
    14: Transactions TOTAL:23840, OK:18669, -> 78.30956375838926 % 
    2: Transactions TOTAL:23861, OK:18684, -> 78.30350781610159 % 
    9: Transactions TOTAL:23856, OK:18702, -> 78.39537223340041 % 
    15: Transactions TOTAL:23856, OK:18610, -> 78.00972501676728 % 
    16: Transactions TOTAL:23862, OK:18613, -> 78.00268208867655 % 
    11: Transactions TOTAL:23881, OK:18631, -> 78.01599598006784 % 
    6: Transactions TOTAL:23855, OK:18634, -> 78.11360301823517 % 

## 3. Experiment (ii): number of entries

```erlang
opty:start(4, 10, 5, 5, 5).
opty:start(4, 50, 5, 5, 5).
opty:start(4, 100, 5, 5, 5).
opty:start(4, 500, 5, 5, 5).
opty:start(4, 1000, 5, 5, 5).
```
### Results
10 -> 2: Transactions TOTAL:114513, OK:42420, -> 37.043829084907394 % 
    4: Transactions TOTAL:114420, OK:42286, -> 36.95682572976752 % 
    3: Transactions TOTAL:114526, OK:41940, -> 36.620505387422945 % 
    1: Transactions TOTAL:114428, OK:42105, -> 36.79606390044395 % 

50 -> 4: Transactions TOTAL:100404, OK:60409, -> 60.16592964423728 % 
    3: Transactions TOTAL:100525, OK:60502, -> 60.186023377269336 % 
    1: Transactions TOTAL:100531, OK:60627, -> 60.306771045747084 % 
    2: Transactions TOTAL:100244, OK:60579, -> 60.43154702525837 % 

100 -> 2: Transactions TOTAL:96957, OK:70678, -> 72.89623235042339 % 
    4: Transactions TOTAL:96902, OK:70452, -> 72.70438174650678 % 
    1: Transactions TOTAL:97007, OK:70642, -> 72.8215489603843 % 
    3: Transactions TOTAL:97010, OK:70249, -> 72.41418410473148 % 

500 -> 1: Transactions TOTAL:91984, OK:84871, -> 92.26713341450687 % 
    2: Transactions TOTAL:91914, OK:84779, -> 92.23730878865025 % 
    3: Transactions TOTAL:91877, OK:84762, -> 92.25595089086497 % 
    4: Transactions TOTAL:91848, OK:84865, -> 92.39722149638533 % 

1000 -> 1: Transactions TOTAL:90757, OK:87126, -> 95.99920667276353 % 
    2: Transactions TOTAL:90662, OK:86924, -> 95.87699366879177 % 
    4: Transactions TOTAL:90627, OK:86964, -> 95.95815816478533 % 
    3: Transactions TOTAL:90603, OK:86925, -> 95.94053177047118 % 

## 4. Experiment (iii): reads per transaction (writes fixed at 5)

```erlang
opty:start(4, 1000, 0, 5, 5).
opty:start(4, 1000, 1, 5, 5).
opty:start(4, 1000, 5, 5, 5).
opty:start(4, 1000, 10, 5, 5).
opty:start(4, 1000, 20, 5, 5).
```

### Results
0 -> 3: Transactions TOTAL:286431, OK:286431, -> 100.0 % 
    2: Transactions TOTAL:286025, OK:286025, -> 100.0 % 
    1: Transactions TOTAL:286208, OK:286208, -> 100.0 % 
    4: Transactions TOTAL:286471, OK:286471, -> 100.0 % 

1 -> 2: Transactions TOTAL:183620, OK:182078, -> 99.16022219801765 % 
    4: Transactions TOTAL:184385, OK:182777, -> 99.12791170648372 % 
    3: Transactions TOTAL:184028, OK:182451, -> 99.14306518573261 % 
    1: Transactions TOTAL:184083, OK:182542, -> 99.16287761498889 % 

5 -> 3: Transactions TOTAL:90548, OK:86897, -> 95.9678844369837 % 
    2: Transactions TOTAL:90626, OK:87064, -> 96.06956061174498 % 
    4: Transactions TOTAL:90633, OK:87048, -> 96.044487107345 % 
    1: Transactions TOTAL:90742, OK:87128, -> 96.01727976019924 % 

10 -> 1: Transactions TOTAL:57000, OK:52685, -> 92.4298245614035 % 
    3: Transactions TOTAL:56870, OK:52694, -> 92.6569368735713 % 
    4: Transactions TOTAL:56805, OK:52612, -> 92.61860751694392 % 
    2: Transactions TOTAL:56798, OK:52534, -> 92.49269340469735 %

20 -> 1: Transactions TOTAL:32314, OK:28069, -> 86.86327907408554 % 
    4: Transactions TOTAL:32181, OK:27920, -> 86.75926789099158 % 
    3: Transactions TOTAL:32201, OK:27837, -> 86.44762585012887 % 
    2: Transactions TOTAL:32195, OK:27942, -> 86.78987420406895 % 

## 5. Experiment (iv): writes per transaction (reads fixed at 5)

```erlang
opty:start(4, 1000, 5, 0, 5).
opty:start(4, 1000, 5, 1, 5).
opty:start(4, 1000, 5, 5, 5).
opty:start(4, 1000, 5, 10, 5).
opty:start(4, 1000, 5, 20, 5).
```

### Results
0 -> 2: Transactions TOTAL:99409, OK:99409, -> 100.0 % 
    3: Transactions TOTAL:99542, OK:99542, -> 100.0 % 
    4: Transactions TOTAL:99619, OK:99619, -> 100.0 % 
    1: Transactions TOTAL:99893, OK:99893, -> 100.0 % 

1 -> 2: Transactions TOTAL:99006, OK:98207, -> 99.19297820334121 % 
    1: Transactions TOTAL:99222, OK:98403, -> 99.17457821854025 % 
    4: Transactions TOTAL:98991, OK:98188, -> 99.18881514481114 % 
    3: Transactions TOTAL:98849, OK:97996, -> 99.13706764863579 % 

5 -> 2: Transactions TOTAL:91849, OK:88118, -> 95.93789807183529 % 
    1: Transactions TOTAL:91886, OK:88224, -> 96.01462682019023 % 
    3: Transactions TOTAL:91897, OK:88235, -> 96.01510386628507 % 
    4: Transactions TOTAL:92037, OK:88244, -> 95.87883133956996 % 

10 -> 1: Transactions TOTAL:80919, OK:74634, -> 92.2329737144552 % 
    4: Transactions TOTAL:80884, OK:74624, -> 92.26052124029475 % 
    2: Transactions TOTAL:80875, OK:74480, -> 92.09273570324575 % 
    3: Transactions TOTAL:80969, OK:74618, -> 92.15625733305339 % 

20 -> 1: Transactions TOTAL:68748, OK:58611, -> 85.25484377727352 % 
    4: Transactions TOTAL:68771, OK:58747, -> 85.42408864201481 % 
    3: Transactions TOTAL:68738, OK:58613, -> 85.27015624545375 % 
    2: Transactions TOTAL:69263, OK:59055, -> 85.26197248170018 % 

## 6. Experiment (v): read/write ratio (Reads + Writes = 10)

```erlang
opty:start(4, 1000, 10, 0, 5).   % only reads
opty:start(4, 1000, 7, 3, 5).
opty:start(4, 1000, 5, 5, 5).    % 1:1
opty:start(4, 1000, 3, 7, 5).
opty:start(4, 1000, 0, 10, 5).   % only writes
```

### Results
10, 0 -> 4: Transactions TOTAL:62509, OK:62509, -> 100.0 % 
    1: Transactions TOTAL:62652, OK:62652, -> 100.0 % 
    2: Transactions TOTAL:62514, OK:62514, -> 100.0 % 
    3: Transactions TOTAL:62452, OK:62452, -> 100.0 % 

7, 3 -> 2: Transactions TOTAL:76417, OK:73804, -> 96.58060379234988 % 
    4: Transactions TOTAL:76569, OK:73989, -> 96.63049014614269 % 
    1: Transactions TOTAL:76657, OK:74128, -> 96.70088837288179 % 
    3: Transactions TOTAL:76556, OK:73965, -> 96.61554940174513 % 

5, 5 -> 4: Transactions TOTAL:91407, OK:87702, -> 95.94669992451344 % 
    2: Transactions TOTAL:91335, OK:87638, -> 95.952263644824 % 
    1: Transactions TOTAL:91442, OK:87711, -> 95.91981802672733 % 
    3: Transactions TOTAL:91532, OK:87909, -> 96.04182143949657 % 

3, 7 -> 3: Transactions TOTAL:114240, OK:110171, -> 96.43820028011204 % 
    1: Transactions TOTAL:114503, OK:110467, -> 96.4752015231042 % 
    4: Transactions TOTAL:114224, OK:110154, -> 96.43682588597842 % 
    2: Transactions TOTAL:114296, OK:110277, -> 96.4836914677679 % 

0, 10 -> 2: Transactions TOTAL:204616, OK:204616, -> 100.0 % 
    4: Transactions TOTAL:204535, OK:204535, -> 100.0 % 
    3: Transactions TOTAL:204504, OK:204504, -> 100.0 % 
    1: Transactions TOTAL:204391, OK:204391, -> 100.0 % 


## 7. Experiment (vi): percentage of accessed entries

This experiment uses `opty:start/6`. The extra sixth argument, `Subset`, is the number of entries each client accesses. Each client gets its own random, not necessarily contiguous, subset of the store of that size, and `do_read`/`do_write` in `client.erl` pick only from that subset. `opty:start/5` is the same as `Subset = Entries`, i.e. the whole store.

Recompile `client` and `opty` after the change:

```erlang
c(client), c(opty).
```

Baseline with 1000 entries, testing 1%, 10%, 25%, 50%, 75% and 100% of the store:

```erlang
opty:start(4, 1000, 5, 5, 5, 10).
opty:start(4, 1000, 5, 5, 5, 100).
opty:start(4, 1000, 5, 5, 5, 250).
opty:start(4, 1000, 5, 5, 5, 500).
opty:start(4, 1000, 5, 5, 5, 750).
opty:start(4, 1000, 5, 5, 5, 1000).
```

### Results
10 -> Trail 1:
    3: Transactions TOTAL:94538, OK:94538, -> 100.0 % 
    4: Transactions TOTAL:94464, OK:94464, -> 100.0 % 
    1: Transactions TOTAL:94672, OK:94672, -> 100.0 % 
    2: Transactions TOTAL:94407, OK:94407, -> 100.0 % 

    Trail 2:
    1: Transactions TOTAL:105192, OK:105192, -> 100.0 % 
    4: Transactions TOTAL:105003, OK:105003, -> 100.0 % 
    3: Transactions TOTAL:105035, OK:105035, -> 100.0 % 
    2: Transactions TOTAL:104879, OK:104879, -> 100.0 % 

    Trail 3:
    3: Transactions TOTAL:101806, OK:87615, -> 86.0607429817496 % 
    2: Transactions TOTAL:101418, OK:101418, -> 100.0 % 
    1: Transactions TOTAL:101894, OK:87729, -> 86.09829823149548 % 
    4: Transactions TOTAL:101675, OK:101675, -> 100.0 % 

    Trail 4:
    1: Transactions TOTAL:104026, OK:104026, -> 100.0 % 
    4: Transactions TOTAL:103839, OK:103839, -> 100.0 % 
    2: Transactions TOTAL:104126, OK:104126, -> 100.0 % 
    3: Transactions TOTAL:103944, OK:103944, -> 100.0 % 

100 -> Trail 1:
    2: Transactions TOTAL:87828, OK:83224, -> 94.75793596575124 % 
    4: Transactions TOTAL:87935, OK:84541, -> 96.14033092625235 % 
    1: Transactions TOTAL:87968, OK:84867, -> 96.47485449254275 % 
    3: Transactions TOTAL:87927, OK:83948, -> 95.47465511162669 % 

    Trail 2:
    1: Transactions TOTAL:89502, OK:85593, -> 95.63249983240598 % 
    3: Transactions TOTAL:89533, OK:86898, -> 97.05695106832118 % 
    2: Transactions TOTAL:89933, OK:86289, -> 95.94809469271569 % 
    4: Transactions TOTAL:89999, OK:86949, -> 96.61107345637174 %

    Trail 3: 
    4: Transactions TOTAL:91801, OK:88236, -> 96.11660003703663 % 
    3: Transactions TOTAL:91755, OK:87761, -> 95.64710370007084 % 
    1: Transactions TOTAL:91687, OK:88153, -> 96.14558225266396 % 
    2: Transactions TOTAL:91665, OK:86521, -> 94.38826160475645 % 

    Trail 4:
    2: Transactions TOTAL:87663, OK:84166, -> 96.01085976980026 % 
    1: Transactions TOTAL:87926, OK:83717, -> 95.21302003957874 % 
    4: Transactions TOTAL:87892, OK:84596, -> 96.24994311200109 % 
    3: Transactions TOTAL:87787, OK:83910, -> 95.58362855548089 % 

250 -> 4: Transactions TOTAL:91780, OK:87871, -> 95.74090215733275 % 
    1: Transactions TOTAL:91881, OK:88631, -> 96.46281603378283 % 
    2: Transactions TOTAL:91738, OK:88041, -> 95.97004512851817 % 
    3: Transactions TOTAL:91702, OK:88308, -> 96.29888115853525 % 

500 -> 4: Transactions TOTAL:92441, OK:88671, -> 95.92172304496923 % 
    1: Transactions TOTAL:92351, OK:88545, -> 95.87876687853948 % 
    2: Transactions TOTAL:92380, OK:88721, -> 96.0391859709894 % 
    3: Transactions TOTAL:92271, OK:88739, -> 96.17214509434167 % 

750 -> 2: Transactions TOTAL:92775, OK:89008, -> 95.93963891134464 % 
    4: Transactions TOTAL:92686, OK:89001, -> 96.024210776169 % 
    3: Transactions TOTAL:92777, OK:89091, -> 96.02703256194962 % 
    1: Transactions TOTAL:92650, OK:88961, -> 96.01834862385321 % 

1000 -> Trail 1
    4: Transactions TOTAL:92813, OK:89130, -> 96.03180588926121 % 
    2: Transactions TOTAL:92883, OK:89019, -> 95.83992765091567 % 
    3: Transactions TOTAL:92730, OK:89049, -> 96.03041087026853 % 
    1: Transactions TOTAL:92670, OK:88924, -> 95.95769936333225 % 

    Trail 2:
    1: Transactions TOTAL:90303, OK:86681, -> 95.98905905673122 % 
    2: Transactions TOTAL:90345, OK:86615, -> 95.87138192484366 % 
    4: Transactions TOTAL:90317, OK:86623, -> 95.90996157976903 % 
    3: Transactions TOTAL:90316, OK:86613, -> 95.89995128216485 % 

> The subsets are random, so small subsets give very different results from run
> to run. Run each of those configurations several times.

## Notes

- Each configuration is run 2–3 times, because results vary between runs.
- The success rate is `OK / TOTAL` per client, as printed after each run.
