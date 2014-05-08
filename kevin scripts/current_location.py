#############################
# Current location 
# File: ConLocGeo.csv
# Kevin Xu
# 5/7/2014
#############################

########## ObjectUri ##########
objectID = getValue("ID")
if int(objectID) > 0:
	return "http://collection.britishart.yale.edu/id/" + objectID
return ""



### Loc ObjectUri
import re

source = getValue("UCTS")
uri = ""

if int(getValue("ID")) > 0:
    if re.search(source, "TGN", re.IGNORECASE):
		uri = "http://vocab.getty.edu/tgn/"
    else: 
        uri = "http://collection.britishart.yale.edu/id/thesauri/location"

return uri