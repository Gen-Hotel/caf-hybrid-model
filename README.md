# A large-scale hybrid model to adress reverse Warburg effect in breast cancer-associated fibroblasts

## Scope

This repository summarizes all the codes and data used to generate the results presented in [A large-scale hybrid model to adress reverse Warburg effect in breast cancer-associated fibroblasts](https://doi.org/10.1101/2022.07.20.500752). 
Please refer to the latter for all information concerning the methods used.


## Description

This repository includes thoroughly annotated Jupyter notebooks and R scripts covering:

- Differential expression analysis of CAFs-S1 vs. CAFs-S4 RNA-Seq data to extract breast CAF-specific initial conditions;
- Framework for generating a hybrid model coupling an asynchronous regulatory Boolean network with a constraint-based reconstruction of human central metabolism as follows:

![image](Framework_for_hybrid_modeling/workflow.png)

- Identification of regulatory molecular drivers through regulatory inputs knock-out/knock-in simulations. 

## Contributors

- Sahar Aghakhani, [sahar.aghakhani@univ-evry.fr](sahar.aghakhani@univ-evry.fr);
- Sylvain Soliman, [sylvain.soliman@inria.fr](sylvain.soliman@inria.fr);
- Anna Niarakis, [anna.niaraki@univ-evry.fr](anna.niaraki@univ-evry.fr).
