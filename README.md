```mermaid
graph TD
    A[Video Input] --> B(Frame Preprocessing <br/> Resize, Normalize)
    B --> C(Vehicle Detection <br/> YOLOv8 - yolov8s.pt)
    B --> D_BranchPoint(Slot Processing Input)

    subgraph Slot_Identification_Strategy["Slot Identification Strategy"]
        direction LR
        D_BranchPoint --> D1[Approach A: <br/> Static Slot Definition <br/> Predefined Polygonal ROIs]
        D_BranchPoint --> D2[Approach B: <br/> Dynamic Slot Detection <br/> Custom YOLOv8 - best.pt]
        D2 --> D3[Slot Tracking & <br/> Stabilization]
    end

    C --> E{Occupancy Logic <br/> IoU Calculation}
    D1 --> E
    D3 --> E

    E --> F(Data Logging <br/> Count Summary)
    E --> G(Output Visualization <br/> On-screen Display)
    F --> H[CSV File Output]

    classDef inputOutput fill:#f9f,stroke:#333,stroke-width:2px,color:#000
    classDef processing fill:#ccf,stroke:#333,stroke-width:2px,color:#000
    classDef model fill:#9f9,stroke:#333,stroke-width:2px,color:#000
    classDef decision fill:#ff9,stroke:#333,stroke-width:2px,color:#000
    classDef approachNodes fill:#e6e6fa,stroke:#333,stroke-width:1px,color:#000

    class A,H inputOutput
    class B,F,G,D_BranchPoint processing
    class C,D2 model
    class D1,D3 approachNodes
    class E decision
