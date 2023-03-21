## Protection of clients' personal data
***Linear Algebra, Machine Learning***

### Brief description of the project
It is required to protect the customers' personal data.
Objective:
- To develop a method for converting data so that it is difficult to recover personal information from it.
- To protect the data so that the quality of the machine learning model is not degraded during the transformation.

### Libraries used
*pandas*, *numpy*, *sklearn.(model_selection, metrics, linear_model)*

### Description of the work done
Data is loaded and checked for gaps and duplicates, data types are made consistent.  
It has been proved that multiplication of the feature matrix by a reversible matrix will not change the quality of the linear regression.  
An algorithm of data transformation is suggested.  
Trained and tested the linear regression model. The algorithm is validated.