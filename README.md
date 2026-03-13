# FPGA-Based Vending Machine Controller (SystemVerilog)

## Project Description

This project presents the design and implementation of a **Vending Machine Controller using SystemVerilog** based on a **Finite State Machine (FSM)** architecture. The objective of the project is to simulate the behavior of an automated vending machine that accepts coins, verifies the total inserted amount, dispenses a product once the required balance is reached, and returns change if the inserted amount exceeds the product price.

The controller is designed following standard **RTL (Register Transfer Level) design methodology** used in digital hardware systems. The logic was implemented in **SystemVerilog**, verified through simulation using a dedicated testbench, and later synthesized and implemented using **AMD Vivado** to evaluate hardware feasibility and performance metrics.

The vending machine supports sequential coin insertion and continuously updates the internal balance until the required amount is reached. Once the payment condition is satisfied, the system transitions to the product dispensing state and generates appropriate output signals. If extra money is inserted, the system calculates and returns the change automatically. Additionally, a timeout mechanism is implemented to reset the machine if the transaction remains incomplete for a specific duration.

This project demonstrates practical concepts of **digital system design, FSM-based control logic, verification through simulation, and FPGA synthesis workflows**.

---

## Key Features

* Accepts multiple coin inputs from the user
* Real-time balance tracking and amount verification
* Product dispensing once required balance is reached
* Automatic change return for excess payment
* Timeout logic to reset incomplete transactions
* Finite State Machine based control logic
* Fully simulated and verified using testbench
* Synthesized and implemented using AMD Vivado

---

## System Architecture

The vending machine controller is organized into several logical blocks responsible for handling different tasks within the system:

* **Coin Input Logic** – Detects and processes the inserted coin value
* **Balance Counter** – Maintains the current total amount inserted
* **FSM Controller** – Controls the system states and transitions
* **Product Dispense Logic** – Activates when required amount is reached
* **Change Return Logic** – Calculates and returns remaining balance
* **Timeout Controller** – Resets the system when the transaction is inactive

Typical operational flow of the system:

```
Coin Insertion
      ↓
Balance Update
      ↓
Amount Verification
      ↓
Product Dispense
      ↓
Return Change (if any)
      ↓
Reset Machine
```

---

## Finite State Machine (FSM)

The core of the system is implemented using a **Finite State Machine**. Each state represents a stage of the vending process.

Typical states include:

* Idle State
* Coin Collection State
* Amount Verification State
* Product Dispense State

FSM design helps ensure predictable behavior, easy debugging, and efficient hardware implementation.

---

## Design Flow

The development of this project followed a standard digital hardware design flow:

1. System architecture planning
2. RTL implementation using SystemVerilog
3. Testbench development for functional verification
4. Simulation and waveform analysis
5. Synthesis using AMD Vivado
6. FPGA implementation
7. Timing and power analysis

This process ensures that the design behaves correctly before hardware deployment.

---

## Simulation and Verification

A **SystemVerilog testbench** was created to verify the functionality of the vending machine controller under different scenarios. Simulation was used to validate the correctness of FSM transitions and output signals.

Test cases verified include:

* Single coin insertion
* Multiple coin insertion
* Exact payment transactions
* Excess payment with change return
* Timeout reset conditions

Simulation waveforms were analyzed to ensure correct functional behavior.

---

## FPGA Synthesis and Implementation

After successful functional verification, the design was synthesized and implemented using **AMD Vivado**.

The following reports were generated during implementation:

* Timing Report
* Power Report
* Implementation Results
* Device Utilization Report

These reports provide insights into hardware resource usage, power consumption, and timing performance of the design.

---



## Tools and Technologies

* SystemVerilog
* AMD Vivado
* FPGA Design Flow
* Digital Logic Design
* Finite State Machines

---

## Learning Outcomes

Through this project, the following concepts were explored and implemented:

* RTL hardware design using SystemVerilog
* FSM-based controller design
* Digital system verification using testbenches
* FPGA synthesis and implementation
* Timing and power analysis of digital circuits

---

## Future Improvements

Possible future enhancements for this project include:

* Support for multiple products
* Seven-segment display interface for balance display
* Implementation on a physical FPGA development board
* Advanced verification using constrained random testing


