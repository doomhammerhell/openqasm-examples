OPENQASM 2.0;
include "qelib1.inc";

// define computational registers
// maximum possible size is six qubits
qreg q[6];
creg c[6];

// let the value we're searching for be the six-bit binary number 101010
// we want the oracle to add a negative phase to a state |x> if x = 101010 and do nothing otherwise

// first, some auxiliary gates
// i freely use the gates defined in the ibm standard library [qelib1.inc]
// i'm implementing cccx without ccx since ccx is fairly inefficient

gate c4rx c, t {
    // controlled fourth root of x
    h t;
    u1(pi/8) t;
    cx c, t;
    u1(-pi/8) t;
    cx c, t;
    u1(pi/8) t;
    h t;
}

gate ci4rx c, t {
    // controlled inverse fourth root of x
    h t;
    u1(-pi/8) t;
    cx c, t;
    u1(pi/8) t;
    cx c, t;
    u1(-pi/8) t;
    h t;
}

gate c2rx c, t {
    // controlled square root of x
    h t;
    u1(pi/4) t;
    cx c, t;
    u1(-pi/4) t;
    cx c, t;
    u1(pi/4) t;
    h t;
    // this is a lot more efficient than c4rx twice!
}

gate ci2rx c, t {
    // controlled inverse square root of x
    h t;
    u1(-pi/4) t;
    cx c, t;
    u1(pi/4) t;
    cx c, t;
    u1(-pi/4) t;
    h t;
}

gate cccx c0, c1, c2, t {
    // c0-2 are the controls, t is the target
    c4rx c0, t;
    cx c0, c1;
    ci4rx c1, t;
    cx c0, c1;
    c4rx c1, t;
    cx c1, c2;
    ci4rx c2, t;
    cx c0, c2;
    c4rx c2, t;
    cx c1, c2;
    ci4rx c2, t;
    cx c0, c2;
    c4rx c2, t;
}

gate ccccx c0, c1, c2, c3, t {
    c2rx c3, t;
    cccx c0, c1, c2, c3;
    ci2rx c3, t;
    cccx c0, c1, c2t, c3;
    c2rx c3, t;
}

gate cccccx c0, c1, c2, c3, c4, t {
    // for encapsulation -- makes oracle neater
    c2rx c4, t;
    ccccx c0, c1, c2, c3, c4;
    ci2rx c4, t;
    ccccx c0, c1, c2, c3, c4;
    c2rx c4, t;
}

// and now the grover gates

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

// we need ~6 grover iterations to have a good chance of getting the six-bit correct answer
grover q[0], q[1], q[2], q[3], q[4], q[5]; // have to use this cumbersome notation because gates can't act on a register's component qubits
grover q[0], q[1], q[2], q[3], q[4], q[5];
grover q[0], q[1], q[2], q[3], q[4], q[5];
grover q[0], q[1], q[2], q[3], q[4], q[5];
grover q[0], q[1], q[2], q[3], q[4], q[5];
grover q[0], q[1], q[2], q[3], q[4], q[5];

// check our work
measure q -> c;