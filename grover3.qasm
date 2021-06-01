OPENQASM 3.0;
include "stdgates.inc";

// define computational registers

qubit q[6];
bit c[6];

// let the value we're searching for be the six-bit binary number 101010
// we want the oracle to add a negative phase to a state |x> if x = 101010 and do nothing otherwise

gate cccccx c0, c1, c2, c3, c4, t {
    ctrl @ ctrl @ ctrl @ ctrl @ ctrl x c0, c1, c2, c3, c4, t;
}

gate oracle q0, q1, q2, q3, q4, q5 {
    // should only trigger if q0 = 1, q1 = 0, q2 = 1, q3 = 0, q4 = 1, q5 = 0
    h q0;
    x q1;
    x q3;
    x q5;
    cccccx q1, q2, q3, q4, q5, q0;
    h q0;
    x q1;
    x q3;
    x q5;
}

gate diffusion q0, q1, q2, q3, q4, q5 {
    // unhadamard
    h q0;
    h q1;
    h q2;
    h q3;
    h q4;
    h q5;
    // should give negative phase to everyone but |000000>
    // alternatively, only give negative phase to |000000>
    // that works since overall phase is irrelevant
    x q0;
    x q1;
    x q2;
    x q3;
    x q4;
    x q5;
    h q0;
    cccccx q1, q2, q3, q4, q5, q0;
    h q0;
    x q0;
    x q1;
    x q2;
    x q3;
    x q4;
    x q5;
    // rehadamard
    h q0;
    h q1;
    h q2;
    h q3;
    h q4;
    h q5;
}

gate grover q0, q1, q2, q3, q4, q5 {
    // one grover iteration -- just oracle then diffusion
    oracle q0, q1, q2, q3, q4, q5;
    diffusion q0, q1, q2, q3, q4, q5;
}


// make everything zero
reset q;

// create equal superposition of all possible states
h q;

// we need ~6 grover iterations to have a good chance of getting the 6-bit correct answer
uint[3] i = 0;
while (i < 6) {
    grover q[0], q[1], q[2], q[3], q[4], q[5];
    i++;
}

// check our work
c = measure q;