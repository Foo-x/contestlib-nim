template stopwatch*(body) = (let t1 = cpuTime(); body; stderr.writeLine "TIME:",
    (cpuTime() - t1) * 1000, "ms")
