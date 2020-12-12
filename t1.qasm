/* Measuring the relaxation time of a qubit
 * This example demonstrates the repeated use of fixed delays.
*/
OPENQASM 3.0;
include "stdgates.inc"; 

length stride = 1us;            // time resolution of points taken
const points = 50;              // number of points taken
const shots = 1000;             // how many shots per point

int[32] counts0, counts1 = 0;   // surviving |1> populations of qubits

kernel tabulate(int[32]:counts, int[32]:shots, int[32]:num);

cbit c0, c1;

// define a gate calibration for an X gate on qubit 1
defcal "openpulse" x %0 {
   play drive(%0), gaussian(100, 30, 5);
}

for p in [0 : points-1] {
    for i in [1 : shots] {
        // start of a basic block
        reset %0;
        reset %1;
        // excite qubits
        x %0;
        x %1;
        // wait for a fixed time indicated by loop counter
        delay[p * stride] %0;
        // wait for a fixed time indicated by loop counters
        delay[p * lengthof({x %1;})];
        // read out qubit states
        c0 = measure %0;
        c1 = measure %1;
        // increment counts memories, if a 1 is seen
        counts0 += int(c0);
        counts1 += int(c1);
    }
    // log survival probability curve
    tabulate(counts0, shots, p);
    tabulate(counts1, shots, p);
}
