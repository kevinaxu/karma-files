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
# replace all special characters with an underscore
def urify(str):
  str = re.sub(r'[^!#$&amp;*+\--:=\?-\[\]_a-z~]+', '_', str.lower())
  # eliminate trailing underscores
  if str[len(str) - 1] == "_":
    str = str[:len(str) - 1]
  return str

import re

source = getValue("UCTS")
reftype = getValue("thesxreftype")
uri = ""

if re.search(reftype, "Geo location") and int(getValue("ID")) > 0:
    if re.search(source, "TGN", re.IGNORECASE):
		uri = "http://vocab.getty.edu/tgn/" + getValue("SourceTermID")
    else: 
        uri = "http://collection.britishart.yale.edu/id/thesauri/location/" + urify(getValue("Term"))

return uri


#### Loc inScheme
import re

source = getValue("UCTS")
reftype = getValue("thesxreftype")
uri = ""

if re.search(reftype, "Geo location") and int(getValue("ID")) > 0:
    if re.search(source, "TGN", re.IGNORECASE):
		uri = "http://vocab.getty.edu/tgn/"
    else: 
        uri = "http://collection.britishart.yale.edu/id/thesauri/location/"

return uri











