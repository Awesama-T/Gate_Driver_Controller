# Gate_Driver_Controller
Its an FPGA-based gate driver controller. It produces up to three pairs of PWMs by using three reference signals. The dead-time is runtime adjustable through a potentiometer which is sampled by the sigma-delta ADC written into the FPGA logic with the help of LVDS IOs. It also produces a pair of center-aligned PWMs, to drive a full-bridge converter. This design is specific for Lattice iCE40LP FPGA. 
## Example Scenario (Dead-time Insertion)
<p align="center">
<img width="600" src= "https://github.com/Awesama-T/Gate_Driver_Controller/assets/121259619/05044c83-8e1c-46fc-85ad-9b1e768b49fa">
</p>

## Example Scenario (Full-bridge PWMs)
<p align="center">
<img width="600" src= "https://github.com/Awesama-T/Gate_Driver_Controller/assets/121259619/5fa39084-d53f-46e6-b1e6-6f1259ce061f">
</p>

