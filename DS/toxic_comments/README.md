## Classification of comments
***Machine Learning for Texts, NLP***.

### Brief description of the project
We have a data set with markup about the toxicity of edits.
We need to train the model to classify comments into positive and negative.

### libraries used
*pandas*, *string*, *re*, *nltk*, *sklearn.(feature_extraction, linear_model, madel_selection, metrics, tree), *lightgbm 
### Description of work performed
Performed data preprocessing, checking for gaps and duplicates.  
Performed tokenization - removed punctuation marks, the text is divided into separate words. Lemmatization now done.
Dataset divided into training and test samples. Three models were trained using cross validation.
Achieved the necessary metric `F1 score`.
