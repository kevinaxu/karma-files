#############################
# MATERIALS 
# File: aatMediumTerms.csv
# Kevin Xu
# 5/7/2014
#############################

## Bib Label
refID = getValue("ReferenceID")
label = ""
if int(refID) > 0: 
  label = "http://collection.britishart.yale.edu/id/bibliography/" + refID

return label


