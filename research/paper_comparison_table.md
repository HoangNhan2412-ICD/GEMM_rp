# Paper comparison table

| Paper | Kiến trúc | Dữ liệu | FPGA/flow | Số liệu |
|---|---|---|---|---|
| Systolic Tensor Array (2020) | Tensor-PE/systolic GEMM, sparse extension | INT8 | Không map trực tiếp vào project | Dùng số liệu paper nếu trích dẫn trực tiếp; không áp vào project. |
| Systolic-CNN (2020) | 1-D systolic OpenCL | FP/suy luận CNN theo paper | Intel Arria/Stratix 10 theo abstract | Không dùng để claim project. |
| Low-Memory GEMMs (2020) | Low-memory GEMM/systolic | CNN/GEMM | FPGA theo paper | Không dùng để claim project. |
| High-Frequency Transformer SA (2023) | Systolic array + constraint flow | Transformer MHA/FFN | Xilinx ZCU102 theo paper | Không dùng để claim project. |

Project hiện tại chưa có synthesis/timing/resource thật: **Needs verification**.
